function [] = ReadFile(InputFileName)
% 读取xlsx文件以获得电网初始信息
% 传入参数例如：ReadFile('GridData.xlsx');

GlobalVar;
jay = 1i; % 复数单位，确保上下文中存在

% 获取文件中所有的Sheet名称，以便于后续按需读取
sheets = sheetnames(InputFileName);

%% 1. 读取系统基准信息 (SYS Sheet)
if ismember("SYS", sheets)
    sysData = readmatrix(InputFileName, 'Sheet', 'SYS');
    sysData(any(isnan(sysData), 2), :) = []; % 【修复】剔除因表头产生的 NaN 行
    Sbase = sysData(1, 1);
    SHz   = sysData(1, 2);
else
    error('DPLMSG: 找不到 SYS 表单，无法读取系统基准容量和频率！');
end

%% 2. 读取节点信息 (BUS Sheet)
if ismember("BUS", sheets)
    busData = readmatrix(InputFileName, 'Sheet', 'BUS');
    busData(any(isnan(busData(:,1)), 2), :) = []; % 【修复】剔除因表头产生的 NaN 行
    
    BusNum = size(busData, 1);
    MaxBusNo = max(busData(:,1)); % 获取最大节点号
    Bus = zeros(MaxBusNo, 18); % 初始化至18列以容纳发电机、励磁、PSS的索引标识
    Y = zeros(MaxBusNo, MaxBusNo); % Admittance matrix
    
    % 【关键修复】初始化全局变量 BusName，将其赋值为对应的字符串编号，防止 OutPut 报错
    BusName = string(1:MaxBusNo)'; 
    
    for loop = 1:BusNum
        BusNo  = busData(loop, 1);
        Vabs   = busData(loop, 2);
        Vangle = busData(loop, 3) * pi / 180; % 角度转弧度
        Pg     = busData(loop, 4);
        Qg     = busData(loop, 5);
        Pd     = busData(loop, 6);
        Qd     = busData(loop, 7);
        G      = busData(loop, 8);
        B      = busData(loop, 9);
        Type   = busData(loop, 10);
        Qmax   = busData(loop, 11);
        Qmin   = busData(loop, 12);
        Vmax   = busData(loop, 13);
        Vmin   = busData(loop, 14);
        
        % 【重大修复】转换节点类型: CSV中 1=PQ, 2=PV, 3=Slack -> 程序中 1=Slack, 2=PV, 3=PQ
        if Type == 1
            Type = 3; % 转为系统内部的 PQ 节点
        elseif Type == 3
            Type = 1; % 转为系统内部的 平衡节点
        end
        
        Bus(BusNo, 1:14) = [BusNo, Vabs, Vangle, Pg, Qg, Pd, Qd, G, B, Type, Qmax, Qmin, Vmax, Vmin];
        
        % 计入并联导纳到节点导纳矩阵对角线
        Y(BusNo, BusNo) = Y(BusNo, BusNo) + G + B * jay;
    end
else
    error('DPLMSG: 找不到 BUS 表单！');
end

%% 3. 读取线路信息 (LINE Sheet)
if ismember("LINE", sheets)
    lineData = readmatrix(InputFileName, 'Sheet', 'LINE');
    lineData(any(isnan(lineData(:,1)), 2), :) = []; % 【修复】剔除 NaN 行
    LineNum = size(lineData, 1);
    Line = zeros(LineNum, 6);
    
    for loop = 1:LineNum
        BusNo1 = lineData(loop, 1);
        BusNo2 = lineData(loop, 2);
        R      = lineData(loop, 3);
        X      = lineData(loop, 4);
        B      = lineData(loop, 5); % 读入的数据已经是 B/2
        RATIO  = lineData(loop, 6); % V1:V2 = 1:RATIO 且导纳归算在V1侧
        
        Line(loop, 1:6) = [BusNo1, BusNo2, R, X, B, RATIO];
        
        % 节点导纳矩阵计算逻辑(保持与原版绝对一致)
        Yt   = 1 / (R + X * jay);
        Yt12 = Yt / RATIO;
        Yt20 = (1 - RATIO) / RATIO / RATIO * Yt;
        Yt10 = (RATIO - 1) / RATIO * Yt;
        
        Y(BusNo1, BusNo2) = Y(BusNo1, BusNo2) - Yt12;
        Y(BusNo2, BusNo1) = Y(BusNo2, BusNo1) - Yt12;
        Y(BusNo1, BusNo1) = Y(BusNo1, BusNo1) + Yt12 + Yt10 + B * jay;
        Y(BusNo2, BusNo2) = Y(BusNo2, BusNo2) + Yt12 + Yt20 + B * jay;
    end
else
    error('DPLMSG: 找不到 LINE 表单！');
end

%% 4. 读取发电机信息 (MAC Sheet)
if ismember("MAC", sheets)
    macTable = readtable(InputFileName, 'Sheet', 'MAC', 'VariableNamingRule', 'preserve');
    GenNum = size(macTable, 1);
    Mac = zeros(GenNum, 21);
    
    for loop = 1:GenNum
        GenName = macTable{loop, 1};
        BusNo   = macTable{loop, 2};
        GBase   = macTable{loop, 3};
        Xl      = macTable{loop, 4};
        Rl      = macTable{loop, 5};
        Xd      = macTable{loop, 6};
        Xd1     = macTable{loop, 7};
        Xd2     = macTable{loop, 8};
        Td01    = macTable{loop, 9};
        Td02    = macTable{loop, 10};
        Xq      = macTable{loop, 11};
        Xq1     = macTable{loop, 12};
        Xq2     = macTable{loop, 13};
        Tq01    = macTable{loop, 14};
        Tq02    = macTable{loop, 15};
        GTj     = macTable{loop, 16};
        D1      = macTable{loop, 17};
        D2      = macTable{loop, 18};
        
        K = Sbase / GBase; % 系统基准功率/发电机基准功率
        
        Mac(loop, 1)  = BusNo;
        Mac(loop, 2)  = GBase;
        Mac(loop, 3)  = Xl * K;
        Mac(loop, 4)  = Rl * K;
        Mac(loop, 5)  = Xd * K;
        Mac(loop, 6)  = Xd1 * K;
        Mac(loop, 7)  = Xd2 * K;
        Mac(loop, 8)  = Td01;
        Mac(loop, 9)  = Td02;
        Mac(loop, 10) = Xq * K;
        Mac(loop, 11) = Xq1 * K;
        Mac(loop, 12) = Xq2 * K;
        Mac(loop, 13) = Tq01;
        Mac(loop, 14) = Tq02;
        Mac(loop, 15) = 0; % 空置位对齐
        
        % 【重大修复】将惯量放在第16列，阻尼放在第17列，精准对齐 Main 文件的需求
        Mac(loop, 16) = GTj / K; 
        Mac(loop, 17) = D1 / K;  
        
        Mac(loop, 18) = 0; % Exc
        Mac(loop, 19) = 0; % PSS
        Mac(loop, 20) = 0; % Tg
        Mac(loop, 21) = 0; % whether classical model (2=YES) 
        
        Bus(BusNo, 16) = loop; % 在母线矩阵记录对应的发电机编号
    end
end

%% 5. 读取励磁信息 (EXC Sheet)
if ismember("EXC", sheets)
    excTable = readtable(InputFileName, 'Sheet', 'EXC', 'VariableNamingRule', 'preserve');
    ExcNum = size(excTable, 1);
    Exc = zeros(ExcNum, 9);
    
    for loop = 1:ExcNum
        BusNo   = excTable{loop, 2};
        ExcType = excTable{loop, 3};
        Tr      = excTable{loop, 4};
        Ka      = excTable{loop, 5};
        Ta      = excTable{loop, 6};
        Tb      = excTable{loop, 7};
        Tc      = excTable{loop, 8};
        Vmax    = excTable{loop, 9};
        Vmin    = excTable{loop, 10};
        
        ib = find(Mac(:,1) == BusNo, 1);
        if ~isempty(ib)
            if Mac(ib, 21) == 2 % Classical model不含Exc
                continue;
            end
            Exc(loop, 1:9) = [BusNo, ExcType, Tr, Ka, Ta, Tb, Tc, Vmax, Vmin];
            Mac(ib, 18) = loop;
            Bus(BusNo, 17) = loop;
        end
    end
end

%% 6. 读取PSS信息 (PSS Sheet)
if ismember("PSS", sheets)
    pssTable = readtable(InputFileName, 'Sheet', 'PSS', 'VariableNamingRule', 'preserve');
    PssNum = size(pssTable, 1);
    Pss = zeros(PssNum, 7);
    
    for loop = 1:PssNum
        GenName = pssTable{loop, 1};
        if iscell(GenName)
            GenName = strtrim(GenName{1}); % 去除可能的空格
        else
            GenName = strtrim(char(GenName));
        end
        
        % 【修复】增加名称防错配逻辑
        macNames = macTable{:, 1};
        if iscell(macNames)
            macNames = cellfun(@strtrim, macNames, 'UniformOutput', false);
        else
            macNames = strtrim(string(macNames));
        end
        
        macIdx = find(strcmp(macNames, GenName), 1);
        if isempty(macIdx)
            continue; 
        end
        BusNo = macTable{macIdx, 2};
        
        Ts = pssTable{loop, 2};
        T1 = pssTable{loop, 3};
        T2 = pssTable{loop, 4};
        T3 = pssTable{loop, 5};
        T4 = pssTable{loop, 6};
        Kw = pssTable{loop, 7};
        
        ib = find(Mac(:,1) == BusNo, 1);
        ic = find(Exc(:,1) == BusNo, 1);
        
        if ~isempty(ib) && ~isempty(ic) && Mac(ib, 21) ~= 2
            Pss(loop, 1:7) = [BusNo, Ts, T1, T2, T3, T4, Kw];
            Mac(ib, 19) = loop;
            Bus(BusNo, 18) = loop;
        end
    end
end

%% 7. 收尾操作
Y0 = Y;

end