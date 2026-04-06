% =================================================================
% 一键生成适应于代码框架的 118 节点静态 Excel 数据 (含暂态控制器参数)
% 完美适配专属 ReadFile.m 格式
% =================================================================
clc; clear;

% 1. 加载 MATPOWER 118节点标准算例
mpc = loadcase('case118'); 

%% 2. 处理 BUS（节点）数据
busNum = size(mpc.bus, 1);
BusData = zeros(busNum, 14);

BusData(:, 1)  = mpc.bus(:, 1); 
BusData(:, 2)  = mpc.bus(:, 8); 
BusData(:, 3)  = mpc.bus(:, 9); 
BusData(:, 6)  = mpc.bus(:, 3) / mpc.baseMVA; 
BusData(:, 7)  = mpc.bus(:, 4) / mpc.baseMVA; 
BusData(:, 8)  = mpc.bus(:, 5) / mpc.baseMVA; 
BusData(:, 9)  = mpc.bus(:, 6) / mpc.baseMVA; 
BusData(:, 10) = mpc.bus(:, 2); 
BusData(:, 13) = mpc.bus(:, 12); 
BusData(:, 14) = mpc.bus(:, 13); 

for i = 1:size(mpc.gen, 1)
    busIdx = mpc.gen(i, 1);
    BusData(busIdx, 4)  = BusData(busIdx, 4) + mpc.gen(i, 2) / mpc.baseMVA; 
    BusData(busIdx, 5)  = BusData(busIdx, 5) + mpc.gen(i, 3) / mpc.baseMVA; 
    BusData(busIdx, 11) = BusData(busIdx, 11) + mpc.gen(i, 4) / mpc.baseMVA; 
    BusData(busIdx, 12) = BusData(busIdx, 12) + mpc.gen(i, 5) / mpc.baseMVA; 
end

%% 3. 处理 LINE（线路）数据
lineNum = size(mpc.branch, 1);
LineData = zeros(lineNum, 6);

LineData(:, 1) = mpc.branch(:, 1); 
LineData(:, 2) = mpc.branch(:, 2); 
LineData(:, 3) = mpc.branch(:, 3); 
LineData(:, 4) = mpc.branch(:, 4); 
LineData(:, 5) = mpc.branch(:, 5) / 2; 
LineData(:, 6) = mpc.branch(:, 9); 
LineData(LineData(:, 6) == 0, 6) = 1; 

%% 4. 处理 MAC（发电机动态）数据 & 🌟 新增完美适配的 EXC 和 PSS 数据
genBuses = mpc.gen(:, 1);
genNum = length(genBuses);

% 全部改用 cell 数组，为了兼容 PSS 要求的第一列字符串名称 ('G1', 'G2'...)
MacData = cell(genNum, 18);
ExcData = cell(genNum, 10);
PssData = cell(genNum, 7);

% 定义真实的“发电机自身基准 (Machine Base)”下的典型物理参数 (标幺值)
typical_Xd  = 1.8;   % 同步电抗
typical_Xd1 = 0.3;   % 暂态电抗
typical_Xq  = 1.7;   % 交轴同步电抗
typical_Ra  = 0.005; % 定子电阻
typical_H   = 4.0;   % 典型惯性常数 H (秒)
typical_D   = 2.0;   % 典型阻尼系数

for i = 1:genNum
    % ====== 发电机参数计算 ======
    Pg = mpc.gen(i, 2);
    Qg = mpc.gen(i, 3);
    
    S_apparent = sqrt(Pg^2 + Qg^2);
    S_mac_base = max(S_apparent * 1.2, 50); 
    K = 100 / S_mac_base;
    
    genNameStr = sprintf('G%d', i); % 发电机标号
    busNo = genBuses(i);
    
    MacData{i, 1}  = genNameStr; 
    MacData{i, 2}  = busNo;        
    MacData{i, 3}  = 100; % 系统基准
    
    MacData{i, 4}  = 0.15 * K;              % Xl (漏抗)
    MacData{i, 5}  = typical_Ra * K;        % Rl
    MacData{i, 6}  = typical_Xd * K;        % Xd 
    MacData{i, 7}  = typical_Xd1 * K;       % Xd1
    MacData{i, 8}  = 0.2 * K;               % Xd2
    MacData{i, 9}  = 6.0;                   % Td01
    MacData{i, 10} = 0.05;                  % Td02
    MacData{i, 11} = typical_Xq * K;        % Xq
    MacData{i, 12} = typical_Xd1 * K;       % Xq1
    MacData{i, 13} = 0.2 * K;               % Xq2
    MacData{i, 14} = 1.0;                   % Tq01
    MacData{i, 15} = 0.05;                  % Tq02
    
    MacData{i, 16} = (2 * typical_H) / K;   % GTj (惯量)
    MacData{i, 17} = typical_D / K;         % D1 (阻尼)
    MacData{i, 18} = 0;                     % D2 

    % ====== 🌟 核心新增：完美适配 ReadFile.m 结构的 EXC 和 PSS ======
    % EXC 对应 ReadFile 解析: [GenName, BusNo, ExcType, Tr, Ka, Ta, Tb, Tc, Vmax, Vmin]
    ExcData{i, 1} = genNameStr; % 第一列虽然 ReadFile 不读，但加上以备不时之需
    ExcData{i, 2} = busNo;      % ReadFile 依靠此列匹配发电机
    ExcData{i, 3} = 1;          % ExcType = 1
    ExcData{i, 4} = 0.01;       % Tr (测量时间常数)
    ExcData{i, 5} = 50;         % Ka (放大器增益，设为50防越限)
    ExcData{i, 6} = 0.02;       % Ta (放大器时间常数)
    ExcData{i, 7} = 0.0;        % Tb (超前滞后)
    ExcData{i, 8} = 0.0;        % Tc (超前滞后)
    ExcData{i, 9} = 5.0;        % Vmax
    ExcData{i, 10} = -5.0;      % Vmin
    
    % PSS 对应 ReadFile 解析: [GenName, Ts, T1, T2, T3, T4, Kw]
    PssData{i, 1} = genNameStr; % 🌟 ReadFile 第 6 部分严格依靠名称匹配！
    PssData{i, 2} = 0.02;       % Ts (测量环节时间常数)
    PssData{i, 3} = 0.05;       % T1 (超前时间常数)
    PssData{i, 4} = 0.02;       % T2 (滞后时间常数)
    PssData{i, 5} = 0.05;       % T3 (超前时间常数)
    PssData{i, 6} = 0.02;       % T4 (滞后时间常数)
    PssData{i, 7} = 20;         % Kw (即 PSS 增益)
end

% 转为 Table
MacTable = cell2table(MacData, 'VariableNames', ...
    {'GenName','BusNo','GBase','Xl','Rl','Xd','Xd1','Xd2','Td01','Td02','Xq','Xq1','Xq2','Tq01','Tq02','GTj','D1','D2'});

ExcTable = cell2table(ExcData, 'VariableNames', ...
    {'GenName', 'BusNo', 'ExcType', 'Tr', 'Ka', 'Ta', 'Tb', 'Tc', 'Vmax', 'Vmin'});

PssTable = cell2table(PssData, 'VariableNames', ...
    {'GenName', 'Ts', 'T1', 'T2', 'T3', 'T4', 'Kw'});

%% 5. 输出为 Excel 文件
filename = '2GridData_118.xlsx';

if exist(filename, 'file')==2
    delete(filename);
end

writematrix([100, 60], filename, 'Sheet', 'SYS'); 
writematrix(BusData, filename, 'Sheet', 'BUS');   
writematrix(LineData, filename, 'Sheet', 'LINE'); 
writetable(MacTable, filename, 'Sheet', 'MAC');
writetable(ExcTable, filename, 'Sheet', 'EXC');
writetable(PssTable, filename, 'Sheet', 'PSS');

disp('✅ 完美适配 ReadFile.m 格式的 118 节点数据已生成 2GridData_118.xlsx！');