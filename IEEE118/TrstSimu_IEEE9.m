% TrstSimu_IEEE9.m
GlobalVar;
global Ynet_Base_Sparse; % 引入全局稀疏矩阵

%% 仿真初始化
% 定义仿真的时间以及故障时间
% 步长为0.01s
% 在0.20秒时发生故障，故障持续到0.30秒 (对应第21步到第30步)
Step_Length = 0.01;
Step_Faultstart = 21;
Step_Faultend = 30;

YFault = 1e+10 + jay*1e+10;
% 注意：FaultBusNo, LoadStep 和 FaultFlag 已在主程序 Main_Sys230703 中统一定义并传入

% --- 强制清空旧矩阵并预分配内存，极大提升仿真速度 ---
t = zeros(StepNum_Simu+1, 1);
StatVar = zeros(StepNum_Simu+1, length(StatVar0)); 

t(1) = 0;
StatVar(1,:) = StatVar0;

tic;
%% 1. 故障前稳态仿真 (Pre-fault)
% 利用四阶龙格-库塔法解微分方程
for Step_Simu = 1:(Step_Faultstart-1)
    % 注: SubTrstSimu1 现在有多个返回值，我们只接收第一个即导数 xr
    StatVar1 = SubTrstSimu1(StatVar(Step_Simu,:));
    StatVar2 = SubTrstSimu1(StatVar(Step_Simu,:) + Step_Length/2*StatVar1);
    StatVar3 = SubTrstSimu1(StatVar(Step_Simu,:) + Step_Length/2*StatVar2);
    StatVar4 = SubTrstSimu1(StatVar(Step_Simu,:) + Step_Length*StatVar3);
    
    t(Step_Simu+1) = t(Step_Simu) + Step_Length;
    StatVar(Step_Simu+1,:) = StatVar(Step_Simu,:) + Step_Length/6*(StatVar1+2*StatVar2+2*StatVar3+StatVar4);
end
toc;
disp('  ------系统发生扰动/故障------  ');

%% 施加故障 / 扰动 (并同步微调稀疏网络矩阵)
if (FaultFlag==1)
    % 机械功率阶跃 (不改变网络拓扑)
    GPm0_temp = GPm0(1);
    GPm0(1) = GPm0(1)*1.05;
    Tpm_temp = Tpm;
    
elseif (FaultFlag==2)
    % 短路故障
    Y(FaultBusNo,FaultBusNo) = Y(FaultBusNo,FaultBusNo) + YFault;
    
    % 🌟 O(1) 极速微调底层稀疏矩阵对角线
    dG = real(YFault); dB = imag(YFault);
    Ynet_Base_Sparse(2*FaultBusNo-1, 2*FaultBusNo-1) = Ynet_Base_Sparse(2*FaultBusNo-1, 2*FaultBusNo-1) + dG;
    Ynet_Base_Sparse(2*FaultBusNo-1, 2*FaultBusNo)   = Ynet_Base_Sparse(2*FaultBusNo-1, 2*FaultBusNo) - dB;
    Ynet_Base_Sparse(2*FaultBusNo, 2*FaultBusNo-1)   = Ynet_Base_Sparse(2*FaultBusNo, 2*FaultBusNo-1) + dB;
    Ynet_Base_Sparse(2*FaultBusNo, 2*FaultBusNo)     = Ynet_Base_Sparse(2*FaultBusNo, 2*FaultBusNo) + dG;
    
elseif (FaultFlag==3)
    % 负荷阶跃扰动
    Y_Equal_temp = Y_Equal(FaultBusNo);
    Y_Equal(FaultBusNo) = Y_Equal(FaultBusNo) * LoadStep;
    
    % 🌟 O(1) 极速微调底层稀疏矩阵对角线
    dY = Y_Equal(FaultBusNo) - Y_Equal_temp; % 计算导纳变化量
    dG = real(dY); dB = imag(dY);
    Ynet_Base_Sparse(2*FaultBusNo-1, 2*FaultBusNo-1) = Ynet_Base_Sparse(2*FaultBusNo-1, 2*FaultBusNo-1) + dG;
    Ynet_Base_Sparse(2*FaultBusNo-1, 2*FaultBusNo)   = Ynet_Base_Sparse(2*FaultBusNo-1, 2*FaultBusNo) - dB;
    Ynet_Base_Sparse(2*FaultBusNo, 2*FaultBusNo-1)   = Ynet_Base_Sparse(2*FaultBusNo, 2*FaultBusNo-1) + dB;
    Ynet_Base_Sparse(2*FaultBusNo, 2*FaultBusNo)     = Ynet_Base_Sparse(2*FaultBusNo, 2*FaultBusNo) + dG;
end

%% 2. 故障中仿真 (During-fault)
tic;
for Step_Simu = Step_Faultstart:Step_Faultend
    StatVar1 = SubTrstSimu1(StatVar(Step_Simu,:));
    StatVar2 = SubTrstSimu1(StatVar(Step_Simu,:) + Step_Length/2*StatVar1);
    StatVar3 = SubTrstSimu1(StatVar(Step_Simu,:) + Step_Length/2*StatVar2);
    StatVar4 = SubTrstSimu1(StatVar(Step_Simu,:) + Step_Length*StatVar3);
    
    t(Step_Simu+1) = t(Step_Simu) + Step_Length;
    StatVar(Step_Simu+1,:) = StatVar(Step_Simu,:) + Step_Length/6*(StatVar1+2*StatVar2+2*StatVar3+StatVar4);
end
toc;
disp('  ------系统扰动/故障切除------  ');

%% 切除故障 / 恢复网络状态 (并同步还原稀疏网络矩阵)
if (FaultFlag==1)
    GPm0(1) = GPm0_temp;
    Tpm = Tpm_temp;
    
elseif (FaultFlag==2)
    Y = Y0; % 全局矩阵复原
    
    % 🌟 O(1) 极速还原底层稀疏矩阵对角线
    dG = -real(YFault); dB = -imag(YFault); % 加上负的变化量进行扣除
    Ynet_Base_Sparse(2*FaultBusNo-1, 2*FaultBusNo-1) = Ynet_Base_Sparse(2*FaultBusNo-1, 2*FaultBusNo-1) + dG;
    Ynet_Base_Sparse(2*FaultBusNo-1, 2*FaultBusNo)   = Ynet_Base_Sparse(2*FaultBusNo-1, 2*FaultBusNo) - dB;
    Ynet_Base_Sparse(2*FaultBusNo, 2*FaultBusNo-1)   = Ynet_Base_Sparse(2*FaultBusNo, 2*FaultBusNo-1) + dB;
    Ynet_Base_Sparse(2*FaultBusNo, 2*FaultBusNo)     = Ynet_Base_Sparse(2*FaultBusNo, 2*FaultBusNo) + dG;
    
elseif (FaultFlag==3)
    dY = Y_Equal_temp - Y_Equal(FaultBusNo); % 计算还原带来的差值
    Y_Equal(FaultBusNo) = Y_Equal_temp;
    
    % 🌟 O(1) 极速还原底层稀疏矩阵对角线
    dG = real(dY); dB = imag(dY);
    Ynet_Base_Sparse(2*FaultBusNo-1, 2*FaultBusNo-1) = Ynet_Base_Sparse(2*FaultBusNo-1, 2*FaultBusNo-1) + dG;
    Ynet_Base_Sparse(2*FaultBusNo-1, 2*FaultBusNo)   = Ynet_Base_Sparse(2*FaultBusNo-1, 2*FaultBusNo) - dB;
    Ynet_Base_Sparse(2*FaultBusNo, 2*FaultBusNo-1)   = Ynet_Base_Sparse(2*FaultBusNo, 2*FaultBusNo-1) + dB;
    Ynet_Base_Sparse(2*FaultBusNo, 2*FaultBusNo)     = Ynet_Base_Sparse(2*FaultBusNo, 2*FaultBusNo) + dG;
end

%% 3. 故障后仿真 (Post-fault)
tic;
for Step_Simu = (Step_Faultend+1):StepNum_Simu
    StatVar1 = SubTrstSimu1(StatVar(Step_Simu,:));
    StatVar2 = SubTrstSimu1(StatVar(Step_Simu,:) + Step_Length/2*StatVar1);
    StatVar3 = SubTrstSimu1(StatVar(Step_Simu,:) + Step_Length/2*StatVar2);
    StatVar4 = SubTrstSimu1(StatVar(Step_Simu,:) + Step_Length*StatVar3);
    
    t(Step_Simu+1) = t(Step_Simu) + Step_Length;
    StatVar(Step_Simu+1,:) = StatVar(Step_Simu,:) + Step_Length/6*(StatVar1+2*StatVar2+2*StatVar3+StatVar4);
    
    % 进度播报
    if Step_Simu == round(0.2*StepNum_Simu)
        disp('  ------时域仿真进度达 20%------  ');
    elseif Step_Simu == round(0.4*StepNum_Simu)
        disp('  ------时域仿真进度达 40%------  ');
    elseif Step_Simu == round(0.6*StepNum_Simu)
        disp('  ------时域仿真进度达 60%------  ');
    elseif Step_Simu == round(0.8*StepNum_Simu)
        disp('  ------时域仿真进度达 80%------  ');
    end
end
disp('  ------时域仿真进度达 100%------  ');
toc;