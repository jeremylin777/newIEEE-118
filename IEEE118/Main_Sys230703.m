%% 批量生成节点惯量与阻尼估计数据集 (118节点 科学定容+特征降维+底层协议适配版)
clc;
clear; 

GlobalVar; 
global Ynet_Base_Sparse; 

InFileNam = '2GridData_118.xlsx'; % 🌟 读取带有 EXC 的新表
ReadFile(InFileNam); 

% ==================== 0. 创建干净的物理基态快照 (Backup) ====================
Mac_Backup = Mac;
Bus_Backup = Bus;
Y_Backup   = Y;
Y0_Backup  = Y0;

% ==================== 1. 深度学习数据集生成配置区 ====================
NumSimulations = 1;      % 样本数量 
StepNum_Simu = 1500;     % 每次仿真的步数
FaultFlag = 3;           % 故障类型: 3--负荷突变扰动
VSG_Ratio = 0.4;         % VSG 渗透率

% ==================== 1.5 提前锚定 VSG 的位置 ====================
SlackBusNo = find(Bus(:, 10) == 1); 
SlackGenIdx = find(Mac(:, 1) == SlackBusNo(1)); 

NonSlackGens = setdiff(1:GenNum, SlackGenIdx); 
NumVSG = round(length(NonSlackGens) * VSG_Ratio); 

rand_order = randperm(length(NonSlackGens));
VSG_Indices = NonSlackGens(rand_order(1:NumVSG)); 

% ==================== 1.8 🌟 核心升级：智能雷达锁定主力发电机 ====================
Major_Gen_Idx = [];
for i = 1:GenNum
    if Bus(Mac(i, 1), 4) > 0.5 
        Major_Gen_Idx = [Major_Gen_Idx, i];
    end
end
Major_Gen_Idx = unique([Major_Gen_Idx, SlackGenIdx]); 
Num_Major = length(Major_Gen_Idx);

fprintf('==== 拓扑与降维配置报告 ====\n');
fprintf('系统共 %d 台发电机，已将 %d 台机组永久设为 VSG。\n', GenNum, NumVSG);
fprintf('🎯 精准锁定 %d 台主力发电机作为 KANs 网络评估目标！\n', Num_Major);
fprintf('===========================\n');

t_start = clock;
Dataset_Labels = zeros(NumSimulations, Num_Major * 2); 
Dataset_Features = cell(NumSimulations, 1);         

%% ==================== 开始批量仿真 ====================
for sim_iter = 1:NumSimulations
    fprintf('\n正在生成样本 %d / %d ...\n', sim_iter, NumSimulations);

    % ================= 2. 恢复干净的物理基态 =================
    Mac = Mac_Backup;
    Bus = Bus_Backup;
    Y   = Y_Backup;
    Y0  = Y0_Backup;
    
    % ================= 3. 🌟 动态随机生成发电机参数 (完美对齐 39 节点逻辑) =================
    
    % 🌟【终极绝杀】：无差别全局关闭 PSS，防止状态向量全面错位爆炸！
    Mac(:, 19) = 0; 
    
    for i = 1:GenNum
        if i == SlackGenIdx
            % ---- 平衡节点 (大电源等效) ----
            Mac(i, 16) = 100; % 极大惯量
            Mac(i, 17) = 36;   % 强阻尼
            % 🌟 注意：这里不碰 Mac(i, 18) 和 Mac(i, 21)，保留 Excel 原汁原味的四阶励磁模型！
            
        elseif ismember(i, VSG_Indices)
            % ---- 虚拟同步机 (VSG - 经典二阶) ----
            Mac(i, 16) = 7 + rand() * 7;  
            Mac(i, 17) = 36 + rand() * 4;  
            
            Mac(i, 18) = 0; % 关励磁
            Mac(i, 21) = 2; % 强行二阶
            Mac(i, 10) = Mac(i, 6); % 消除凸极效应，保证二阶绝对稳定
            
        else
            % ---- 传统机组 (SG) ----
            Mac(i, 16) = 7 + rand() * 7;  
            Mac(i, 17) = 36 + rand() * 2;  
            % 🌟 注意：不碰 Mac(i, 18) 和 Mac(i, 21)，保留原始四阶+励磁！
        end
    end

    % 极简标签提取
    Tj_major = Mac(Major_Gen_Idx, 16); 
    D_major  = Mac(Major_Gen_Idx, 17);  
    Dataset_Labels(sim_iter, :) = [Tj_major', D_major']; 

    % ================= 3.5 初始化网络和全局变量 =================
    InitNet;
    InitGlobalVar;

    % ================= 4. 动态设置负荷扰动大小 =================
    [~, max_load_idx] = max(Bus(:, 6));
    FaultBusNo = Bus(max_load_idx, 1);

    if FaultFlag == 3 
        LoadStep = 1 + (rand()*1); % 2%~3% 的扰动
    else
        LoadStep = 1; 
    end

    % ================= 5. 稳态潮流与数据初始化 =================
    PowerFlow;
    if any(isnan(V_abs))
        warning('💥 样本 %d 潮流发散，放弃该样本！', sim_iter);
        continue; 
    end
    IniDataSimu; 
    
    % ================= 5.5 极速版核心：预组装稀疏矩阵 =================
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
    
    % ================= 核心诊断 =================
    clear Step_Simu; 
    dX0 = SubTrstSimu1(StatVar0); 
    max_der = max(abs(dX0));
    fprintf('👉 样本 %d 初始导数最大值 = %.6e\n', sim_iter, max_der);
    
    if max_der > 1e-3
        warning('🚨 稳态初始化失败！最大偏差: %f。跳过该样本！', max_der);
        continue; 
    end
    
    % ================= 6. 时域暂态仿真 =================
    TrstSimu_IEEE9; 
    
    % ================= 7. 🌟 提取特征 (修复混合阶数错位Bug) =================
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
        % 🌟 完美对齐原版 39 节点的状态变量计数器！
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

    Feature_Matrix = [Delta_all(:, Major_Gen_Idx), ...
                      Omiga_all(:, Major_Gen_Idx), ...
                      PE(1:StepNum_Simu+1, Major_Gen_Idx + 1), ...
                      VsG(1:StepNum_Simu+1, Major_Gen_Idx + 1)];
                      
    Dataset_Features{sim_iter} = Feature_Matrix;
end

save('Inertia_Dataset_Labels.mat', 'Dataset_Labels');
save('Inertia_Dataset_Features.mat', 'Dataset_Features');
t_end = clock;
fprintf('\n✅ 批量数据生成完毕！总耗时: %8.2f 秒 \n', etime(t_end,t_start));

%% ==================== 9. 交互式画图 (自适应主力机组) ====================
if ~exist('Delta_all', 'var')
    error('💥 哎呀，仿真全部被跳过了。');
end

time_axis = t(1:StepNum_Simu+1);

% 找出一台主力 SG 和 一台主力 VSG 进行展示
sample_SG = setdiff(Major_Gen_Idx, VSG_Indices);
sample_SG = setdiff(sample_SG, SlackGenIdx); 
sample_VSG = intersect(Major_Gen_Idx, VSG_Indices);

Selected_Gens = SlackGenIdx; 
if ~isempty(sample_SG), Selected_Gens = [Selected_Gens, sample_SG(1)]; end
if ~isempty(sample_VSG), Selected_Gens = [Selected_Gens, sample_VSG(1)]; end

for idx = 1:length(Selected_Gens)
    gen_id = Selected_Gens(idx);
    
    if gen_id == SlackGenIdx
        type_str = '平衡节点 (Slack)';
    elseif ismember(gen_id, VSG_Indices)
        type_str = '虚拟同步机 (VSG)';
    else
        type_str = '传统机组 (SG)';
    end
    
    figure('Name', sprintf('Gen %d 动态特性 (%s)', gen_id, type_str), ...
           'Position', [100 + idx*30, 100 + idx*30, 900, 700]);
    
    subplot(2,2,1); plot(time_axis, Delta_all(:, gen_id), 'b', 'LineWidth', 1.5); 
    title(sprintf('Gen %d [%s] - 功角 (\\delta)', gen_id, type_str)); grid on;
    
    subplot(2,2,2); plot(time_axis, Omiga_all(:, gen_id), 'r', 'LineWidth', 1.5); 
    title(sprintf('Gen %d [%s] - 频率 (\\omega)', gen_id, type_str)); grid on;
    
    subplot(2,2,3); plot(time_axis, PE(1:StepNum_Simu+1, gen_id+1), 'k', 'LineWidth', 1.5); 
    title(sprintf('Gen %d [%s] - 有功功率 (P_e)', gen_id, type_str)); grid on;
    
    subplot(2,2,4); plot(time_axis, VsG(1:StepNum_Simu+1, gen_id+1), 'm', 'LineWidth', 1.5); 
    title(sprintf('Gen %d [%s] - 机端电压 (V_t)', gen_id, type_str)); grid on;
end
