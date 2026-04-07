%% 批量生成节点惯量与阻尼估计数据集 (118节点 神经网络专用固定拓扑版)
clc;
clear; 

GlobalVar; 
global Ynet_Base_Sparse; 

% ==================== 0. 数据读取与基态备份 ====================
InFileNam = '2GridData_118.xlsx'; 
ReadFile(InFileNam); 

Mac_Backup = Mac;
Bus_Backup = Bus;
Y_Backup   = Y;
Y0_Backup  = Y0;

% ==================== 1. 深度学习数据集生成配置区 ====================
NumSimulations = 1;      % 样本数量（正式训练建议 500+）
StepNum_Simu = 1500;      % 仿真步数
FaultFlag = 3;           % 故障类型: 3--负荷突变扰动

% ==================== 2. 主力机节点永久锚定 ====================
% 2.1 锁定平衡节点 (69号)
SlackBusNo = 69; 
SlackGenIdx = find(Mac(:, 1) == SlackBusNo); 

% 2.2 手动指定前10大主力机中，一半为 VSG，一半为 SG
% (基于 IEEE 118 标准出力排行，不包含 69 号)
Fixed_VSG_BusNos = [89, 10, 65, 26, 59];    % 5台 VSG
Fixed_MainSG_BusNos = [80, 66, 100, 49, 61]; % 5台 SG

% 2.3 转换为 Mac 矩阵索引
VSG_Indices = [];
for b = Fixed_VSG_BusNos
    VSG_Indices = [VSG_Indices, find(Mac(:,1) == b)];
end

MainSG_Indices = [];
for b = Fixed_MainSG_BusNos
    MainSG_Indices = [MainSG_Indices, find(Mac(:,1) == b)];
end

% 2.4 汇总评估目标 (顺序固定，用于神经网络输入/输出对齐)
% 顺序：Slack(1) -> VSG(5) -> MainSG(5) 共 11 个节点
Major_Gen_Idx = [SlackGenIdx, VSG_Indices, MainSG_Indices];
Num_Major = length(Major_Gen_Idx);

fprintf('==== 神经网络训练环境配置报告 ====\n');
fprintf('VSG 节点 (Label 2-6): Bus %s\n', num2str(Fixed_VSG_BusNos));
fprintf('SG 节点 (Label 7-11): Bus %s\n', num2str(Fixed_MainSG_BusNos));
fprintf('================================\n');

t_start = clock;
Dataset_Labels = zeros(NumSimulations, Num_Major * 2); % 存放 Tj 和 D
Dataset_Features = cell(NumSimulations, 1);           % 存放特征矩阵

%% ==================== 开始批量仿真循环 ====================
for sim_iter = 1:NumSimulations
    fprintf('\n正在生成样本 %d / %d ...\n', sim_iter, NumSimulations);

    % 恢复原始快照
    Mac = Mac_Backup;
    Bus = Bus_Backup;
    Y   = Y_Backup;
    Y0  = Y0_Backup;
    
    % ================= 3. 参数分配 (完全遵循你要求的固定逻辑) =================
    Mac(:, 19) = 0; % 强制关闭 PSS
    
    for i = 1:GenNum
        if i == SlackGenIdx
            % ---- 69号平衡节点 (大电源等效) ----
            Mac(i, 16) = 1000; % 极大惯量
            Mac(i, 17) = 2;   % 强阻尼
        elseif ismember(i, VSG_Indices)
            % ---- 虚拟同步机 (VSG) ----
            Mac(i, 16) = 7 + rand() * 7;   % 随机 Tj: 7~14
            Mac(i, 17) = 36 + rand() * 4;  % 随机 D: 36~40
            Mac(i, 18) = 0; % 关励磁
            Mac(i, 21) = 2; % 强行二阶
            Mac(i, 10) = Mac(i, 6); % 消除凸极
        elseif ismember(i, MainSG_Indices)
            % ---- 主力传统机组 (SG) ----
            Mac(i, 16) = 7 + rand() * 7;   
            Mac(i, 17) = 36 + rand() * 2;  
            % 保持原始四阶模型 (不碰 18 和 21 列)
        else
            % ---- 其余非主力机组 (设为背景固定值) ----
            Mac(i, 16) = 7; 
            Mac(i, 17) = 10;
        end
    end

    % 提取标签
    Tj_major = Mac(Major_Gen_Idx, 16); 
    D_major  = Mac(Major_Gen_Idx, 17);  
    Dataset_Labels(sim_iter, :) = [Tj_major', D_major']; 

    % ================= 4. 初始化与潮流计算 =================
    InitNet;
    InitGlobalVar;

    % 动态负荷扰动
    [~, max_load_idx] = max(Bus(:, 6));
    FaultBusNo = Bus(max_load_idx, 1);
    LoadStep = 1 + rand()*0.05; % 1%~3% 扰动

    PowerFlow;
    if any(isnan(V_abs))
        warning('潮流发散，跳过样本 %d', sim_iter);
        continue; 
    end
    IniDataSimu; 
    
    % ================= 5. 稀疏矩阵组装逻辑 =================
    Ynet_Base_Sparse = spalloc(2*BusNum, 2*BusNum, 10*BusNum);
    for loop1 = 1:BusNum
        for loop2 = 1:BusNum
            if Y(loop1,loop2) ~= 0
                G = real(Y(loop1,loop2));  B = imag(Y(loop1,loop2));
                Ynet_Base_Sparse(2*loop1-1,2*loop2-1) = G;
                Ynet_Base_Sparse(2*loop1-1,2*loop2) = -B;
                Ynet_Base_Sparse(2*loop1,2*loop2-1) = B;
                Ynet_Base_Sparse(2*loop1,2*loop2) = G;
            end
        end
    end
    for loop = 1:BusNum 
        BusNo = Bus(loop,1); 
        Y_Eq = Y_Equal(BusNo);
        G = real(Y_Eq);  B = imag(Y_Eq);
        Ynet_Base_Sparse(2*BusNo-1,2*BusNo-1) = Ynet_Base_Sparse(2*BusNo-1,2*BusNo-1) + G;
        Ynet_Base_Sparse(2*BusNo-1,2*BusNo)   = Ynet_Base_Sparse(2*BusNo-1,2*BusNo) - B;
        Ynet_Base_Sparse(2*BusNo,2*BusNo-1)   = Ynet_Base_Sparse(2*BusNo,2*BusNo-1) + B;
        Ynet_Base_Sparse(2*BusNo,2*BusNo)     = Ynet_Base_Sparse(2*BusNo,2*BusNo) + G;
    end
    
    % 初始导数诊断
    dX0 = SubTrstSimu1(StatVar0); 
    max_der = max(abs(dX0));
    if max_der > 1e-3
        warning('初始化失败，跳过样本 %d', sim_iter);
        continue; 
    end
    
    % ================= 6. 时域暂态仿真 =================
    TrstSimu_IEEE9; 
    
    % ================= 7. 提取特征 =================
    PE = zeros(StepNum_Simu+1, GenNum+1);
    VsG = zeros(StepNum_Simu+1, GenNum+1);
    
    for k = 1:(StepNum_Simu+1)
        [~, pe_vec, vt_vec] = SubTrstSimu1(StatVar(k, :)); 
        PE(k, 2:end) = pe_vec;
        VsG(k, 2:end) = vt_vec;
    end

    Delta_all = zeros(StepNum_Simu+1, GenNum);
    Omiga_all = zeros(StepNum_Simu+1, GenNum);
    
    Idx = 1;
    for i = 1:GenNum
        
        if Mac(i, 21) == 2
            Sgnum = 2;
        elseif Mac(i, 18) == 0
            Sgnum = 3;
        else
            Sgnum = 4; 
        end
        
        Delta_all(:, i) = StatVar(:, Idx);     
        Omiga_all(:, i) = StatVar(:, Idx+1);   
        Idx = Idx + Sgnum; 
    end

    % 按照 Major_Gen_Idx 的顺序提取 11 台机组的特征
    Feature_Matrix = [Delta_all(:, Major_Gen_Idx), ...
                      Omiga_all(:, Major_Gen_Idx), ...
                      PE(1:StepNum_Simu+1, Major_Gen_Idx + 1), ...
                      VsG(1:StepNum_Simu+1, Major_Gen_Idx + 1)];
                      
    Dataset_Features{sim_iter} = Feature_Matrix;
end

% 保存数据
save('Inertia_Dataset_Labels.mat', 'Dataset_Labels');
save('Inertia_Dataset_Features.mat', 'Dataset_Features');
t_end = clock;
fprintf('批量数据生成完毕！总耗时: %8.2f 秒 \n', etime(t_end,t_start));

%% ==================== 8. 交互式画图 (保留原有可视化逻辑) ====================
if ~exist('Delta_all', 'var'), error('仿真未成功执行'); end

time_axis = t(1:StepNum_Simu+1);
%Selected_Gens = [SlackGenIdx, VSG_Indices(1), MainSG_Indices(1)]; % 画三台代表机型
Selected_Gens = Major_Gen_Idx;
for idx = 1:length(Selected_Gens)
    gen_id = Selected_Gens(idx);
    
    if gen_id == SlackGenIdx
        type_str = '平衡节点 (Slack)';
    elseif ismember(gen_id, VSG_Indices)
        type_str = '虚拟同步机 (VSG)';
    else
        type_str = '传统机组 (SG)';
    end
    
    % 创建大尺寸画布，防止子图挤压
    figure('Name', sprintf('Gen %d 动态特性 [%s]', gen_id, type_str), ...
           'Position', [100 + idx*50, 100 + idx*50, 1000, 700]);
    
    % 1. 功角 (Delta)
    subplot(2,2,1); 
    plot(time_axis, Delta_all(:, gen_id), 'b', 'LineWidth', 1.5); 
    title(sprintf('Gen %d [%s] - 功角 (\\delta)', gen_id, type_str)); 
    grid on;
    
    % 2. 频率 (Omega)
    subplot(2,2,2); 
    plot(time_axis, Omiga_all(:, gen_id), 'r', 'LineWidth', 1.5); 
    title(sprintf('Gen %d [%s] - 频率 (\\omega)', gen_id, type_str)); 
    grid on;
    
    % 3. 有功功率 (Pe)
    subplot(2,2,3); 
    plot(time_axis, PE(1:StepNum_Simu+1, gen_id+1), 'k', 'LineWidth', 1.5); 
    title(sprintf('Gen %d [%s] - 有功功率 (P_e)', gen_id, type_str)); 
    grid on;
    
    % 4. 机端电压 (Vt)
    subplot(2,2,4); 
    plot(time_axis, VsG(1:StepNum_Simu+1, gen_id+1), 'm', 'LineWidth', 1.5); 
    title(sprintf('Gen %d [%s] - 机端电压 (V_t)', gen_id, type_str)); 
    grid on;
end
