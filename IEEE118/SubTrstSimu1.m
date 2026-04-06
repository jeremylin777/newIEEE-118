function [xr, pe_vec, vt_vec] = SubTrstSimu1(x)
% 118节点系统深度优化版 - 稀疏矩阵求导引擎
% 返回值说明：
% xr: 状态量导数向量 (供暂态积分核心调用)
% pe_vec: 每台发电机的电磁功率 (供事后特征提取)
% vt_vec: 每台发电机机端电压幅值 (供事后特征提取)

GlobalVar;
global Ynet_Base_Sparse; % 引入预先计算好的静态稀疏网络矩阵

% 初始化返回值
xr = zeros(1, length(x)); 
pe_vec = zeros(1, GenNum);
vt_vec = zeros(1, GenNum);

%% 1. Network Solution (网络代数方程求解)
% 直接复用基础网络导纳矩阵 (不含发电机内导纳)
if isempty(Ynet_Base_Sparse)
    error('🚨 全局变量 Ynet_Base_Sparse 为空！请确保在暂态仿真开始前已经完成静态网络初始化。');
end

Ynet = Ynet_Base_Sparse;
I = zeros(2*BusNum, 1);
GStatsnum = 0;

% 遍历发电机，将发电机内部等效导纳和等效注入电流叠加到 Ynet 和 I 中
for loop_G = 1:GenNum 	
	BusNo = Mac(loop_G,1);
    Ra = Mac(loop_G,4);
    Xd = Mac(loop_G,5);
	Xq = Mac(loop_G,10);
    Xdd = Mac(loop_G,6);

    % 根据发电机模型阶数读取状态量
    if (Mac(loop_G,21) == 2)
         Sgnum = 2;
         Delta = x(GStatsnum+1);
         Eqq = GEqq0(loop_G); 
    elseif (Mac(loop_G,18) == 0)
         Sgnum = 3;
         Delta = x(GStatsnum+1);
         Eqq = x(GStatsnum+3);
    else
         Sgnum = 4;
         Delta = x(GStatsnum+1);
         Eqq = x(GStatsnum+3);                  
    end
    GStatsnum = GStatsnum + Sgnum;        
    
    % 计算诺顿等效导纳参数
    bx = (Ra*cos(Delta) + Xq*sin(Delta)) / (Ra*Ra + Xdd*Xq);
    gy = (Ra*sin(Delta) - Xq*cos(Delta)) / (Ra*Ra + Xdd*Xq);
    Gx = (Ra - (Xdd-Xq)*sin(Delta)*cos(Delta)) / (Ra*Ra + Xdd*Xq);
    Bx = (Xdd*cos(Delta)^2 + Xq*sin(Delta)^2) / (Ra*Ra + Xdd*Xq);
    By = (-Xdd*sin(Delta)^2 - Xq*cos(Delta)^2) / (Ra*Ra + Xdd*Xq);
    Gy = (Ra + (Xdd-Xq)*sin(Delta)*cos(Delta)) / (Ra*Ra + Xdd*Xq);
    
    % 🌟 极速寻址：仅修改发电机所在母线的对角线元素
    Ynet(2*BusNo-1, 2*BusNo-1) = Ynet(2*BusNo-1, 2*BusNo-1) + Gx;
    Ynet(2*BusNo-1, 2*BusNo)   = Ynet(2*BusNo-1, 2*BusNo) + Bx;
    Ynet(2*BusNo, 2*BusNo-1)   = Ynet(2*BusNo, 2*BusNo-1) + By;
    Ynet(2*BusNo, 2*BusNo)     = Ynet(2*BusNo, 2*BusNo) + Gy;

    % 节点注入电流
    I(2*BusNo-1) = bx * Eqq;
    I(2*BusNo)   = gy * Eqq;   
end

% 🌟 极速求逆：因为 Ynet 是稀疏矩阵，左除速度极快！
V = Ynet \ I;


%% 2. Generator dynamics (发电机微分方程求解)
GStatsnum = 0;

for loop_G = 1:GenNum 	
	BusNo = Mac(loop_G,1);
    Ra = Mac(loop_G,4);
    Xd = Mac(loop_G,5);
	Xq = Mac(loop_G,10);
    Xdd = Mac(loop_G,6);
    Tdd = Mac(loop_G,8);  
    
    % 🌟 直接读取最新生成的惯量和阻尼
    Tj_gen = Mac(loop_G, 16); 
    D_gen  = Mac(loop_G, 17);

    % 读取状态量
    if (Mac(loop_G,21) == 2)
         Sgnum = 2;
         Delta = x(GStatsnum+1);   
         Omiga = x(GStatsnum+2);
         Eqq = GEqq0(loop_G);
    elseif (Mac(loop_G,18) == 0)
         Sgnum = 3;
         Delta = x(GStatsnum+1);
         Omiga = x(GStatsnum+2);
         Eqq = x(GStatsnum+3);  
    else
         Sgnum = 4;
         Delta = x(GStatsnum+1);
         Omiga = x(GStatsnum+2);
         Eqq = x(GStatsnum+3); 
         Efd = x(GStatsnum+4);
    end
    
    % 计算发电机 d-q 轴机端电压
    Vtd = real((V(2*BusNo-1) + jay*V(2*BusNo)) * exp(jay*(pi/2 - Delta)));
    Vtq = imag((V(2*BusNo-1) + jay*V(2*BusNo)) * exp(jay*(pi/2 - Delta)));

    % 计算 d-q 轴电流
    Itdq = [Ra, -Xq; Xdd, Ra] \ ([0; Eqq] - [Vtd; Vtq]);
    Itd = Itdq(1);
    Itq = Itdq(2);

    % 计算电磁功率 Pe 和机端电压幅值 Vt_mag
    Pe = Vtd*Itd + Vtq*Itq + (Itd^2 + Itq^2)*Ra;
    Vt_mag = sqrt(Vtd^2 + Vtq^2);
    
    % 🌟 记录代数变量，供外部提取特征集使用
    pe_vec(loop_G) = Pe;
    vt_vec(loop_G) = Vt_mag;

    % ========== 组装微分方程 ==========
    % 1. 功角导数 d(delta)/dt
    xr(GStatsnum+1) = GOmigas * (Omiga - 1);
    
    % 2. 频率导数 d(omega)/dt
    xr(GStatsnum+2) = (GPm0(loop_G) - Pe - D_gen*(Omiga - 1)) / Tj_gen;

    % 3/4. 暂态电势及励磁导数
    if (Sgnum == 3)
         xr(GStatsnum+3) = (GEfd0(loop_G) - Eqq - (Xd - Xdd)*Itd) / Tdd;
    elseif (Sgnum == 4)
         loop_exc = Mac(loop_G,18);
         Ka = Exc(loop_exc,4); 
         Ta = Exc(loop_exc,5);
         xr(GStatsnum+3) = (Efd - Eqq - (Xd - Xdd)*Itd) / Tdd;
         xr(GStatsnum+4) = (-Efd + GEfd0(loop_G) + Ka*(GV_gen0(loop_G) - Vt_mag)) / Ta;
    end
    
    GStatsnum = GStatsnum + Sgnum;        
end

end