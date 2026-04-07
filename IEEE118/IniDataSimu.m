function IniDataSimu()
%% 暂态仿真数据初始化
% 计算负荷等效导纳信息；发电机初始功率、功角、角速度信息，节点初始电压信息；
GlobalVar;

if (WndG_Flag==1)
    GlobalVarP;
end
if (PVG_Flag==1)
    GlobalVarPV;
end

%*************************************************************************
%% 1. 节点电压与等值导纳矩阵建立
BusV(:,1) = V_abs.*exp(jay*V_ang);
Y_Equal = zeros(BusNum,1);
V = Bus(:,2).*exp(jay*Bus(:,3));

% 非线性静态负荷处理
if LoadNum ~= 0
    j = Load(:,1);
    P_X = (ones(LoadNum,1)-Load(:,2)-Load(:,4)) .*Bus(j,6);
    Q_X = (ones(LoadNum,1)-Load(:,3)-Load(:,5)) .*Bus(j,7);
    V_nc = Bus(j,2).*exp(jay*Bus(j,3));
    LoadPot(:,1) = Bus(j,6).*Load(:,2) + jay*Bus(j,7).*Load(:,3); 
    S_cc = Bus(j,6).*Load(:,4)  + jay*Bus(j,7).*Load(:,5);      
    LoadPot(:,2) = S_cc./abs(V_nc); 
    LoadPot(:,3) = LoadPot(:,1)./V_nc./conj(V_nc);
    LoadPot(:,4) = S_cc./V_nc./conj(V_nc);
    Bus(j,6) = P_X;
    Bus(j,7) = Q_X;    
end

% 非线性动态电动机负荷初始信息计算
for loop_moto = 1:MotoNum
    MBusNo = Moto(loop_moto,1);
    Moto_S = Moto(loop_moto,2);
    Rs = Moto(loop_moto,3);
    Xs = Moto(loop_moto,4);
    Rm = Moto(loop_moto,5);
    Xm = Moto(loop_moto,6);
    Rr = Moto(loop_moto,7);
    Xr = Moto(loop_moto,8);
    a = Moto(loop_moto,12);
    p = Moto(loop_moto,13);
    S0 = Moto(loop_moto,16);
    Tt = (Xr+Xm)/Rr;
    Moto_X = Xs + Xm;
    Moto_XX = Xs + Xm*Xr/(Xm+Xr);
    Kh = Moto_S/Sbase;
    options = optimset('Display', 'iter', 'LargeScale', 'off');
    S = fsolve(@MotoSCal, S0, options,loop_moto);
    Sys_P = Moto(loop_moto,15) .*Bus(MBusNo,6);
    Moto_Z = (Rs+jay*Xs) + (Rm+jay*Xm).*(Rr./S+jay*Xr) ./ ((Rm+jay*Xm) + (Rr/S+jay*Xr) ); 
    Moto_V = Bus(MBusNo,2).*exp(jay*Bus(MBusNo,3));
    Moto_I = Moto_V/Moto_Z;
    Smoto = Moto_V * conj(Moto_I);
    Moto_P = real(Smoto);
    Moto_Q = imag(Smoto);
    Sys_Q = Moto_Q*Kh;   
    Bus(MBusNo,6) = Bus(MBusNo,6) - Sys_P;
    Bus(MBusNo,7) = Bus(MBusNo,7) - Sys_Q;
    M_S0(loop_moto,1) = S;
    M_S(loop_moto,1) = S;
    
    Te_I = Moto_I /((Rr/S+jay*Xr) + (Rm+jay*Xm) ) * (Rm+jay*Xm); 
    Moto_Pe = Te_I*conj(Te_I)*Rr/S;
    Moto_Te = Te_I*conj(Te_I)*(Rr/S-Rr)/(1-S);
    
    K = Moto_Te/(a+(1-a)*((1-S)^p));
    Scr = Rr/( Xr + Xs*Xm/(Xs+Xm) );
    M_Scr(loop_moto,1) = Scr;
    
    M_P(loop_moto,1) = Moto_P;
    M_Q(loop_moto,1) = Moto_Q;
    M_Te(loop_moto,1) = Moto_Te;
    M_Tm(loop_moto,1) = Moto_Te;
    
    MotoPot(loop_moto,1) = MBusNo;
    MotoPot(loop_moto,2) = Kh;
    MotoPot(loop_moto,3) = Moto_X;
    MotoPot(loop_moto,4) = Moto_XX;
    MotoPot(loop_moto,5) = K;
    MotoPot(loop_moto,6) = Tt;
end

% 根据修正Bus矩阵得到输入有功和输入无功并计算等效导纳
S = Bus(:,6) + jay*Bus(:,7);
Y_Equal = conj(S)./(V.*conj(V));

%% 2. 发电机及控制器初值计算
GStatsnum = 0;
Statsnum = 0;

for loop_G = 1:GenNum
	BusNo = Mac(loop_G,1);
    Xd = Mac(loop_G,5);
	Xq = Mac(loop_G,10);
    Ra = Mac(loop_G,4);
    Xdd = Mac(loop_G,6);

	V_gen = Bus(BusNo,2).*exp(jay*Bus(BusNo,3));
    S = P_G(BusNo) + jay* Q_G(BusNo);
    I_gen = conj(S)/conj(V_gen);

    EQ = V_gen + Xq*I_gen*jay + Ra*I_gen;
    Delta = angle(EQ);  
    [Vd,Vq,Id,Iq] = XY_DQ(V_gen,I_gen,Delta); 
    Eq = Vq + Xd*Id + Ra*Iq;   
    Eqq = Vq + Xdd*Id + Ra*Iq; 
    Efd = Eq;

    Pe = real(V_gen* conj(I_gen)) + norm((I_gen)*(I_gen))*Ra;
    Pm = Pe;
    
    % 记录发电机状态初值
    GEq0(loop_G) = Eq;
    GEqq0(loop_G) = Eqq;
    GPm0(loop_G) = Pm;
    GPe0(loop_G) = Pe;
    GDelta0(loop_G) = Delta;
    GOmiga0(loop_G) = 1;
    GEfd0(loop_G) = Efd;
    
    GEq(loop_G,1) = Eq;
    GEqq(loop_G,1) = Eqq;
    GPm(loop_G,1) = Pm;
    GPe(loop_G,1) = Pe;
    GDelta(loop_G,1) = Delta;
    GOmiga(loop_G,1) = 1;
    GEfd(loop_G,1) = Efd;
    GV_gen0(loop_G) = norm(V_gen);
    
    %%%%%%%%%%%%% 动态状态变量分配 (已解除硬编码) %%%%%%%%%%%%%
    if (Mac(loop_G,21) == 2)
        % 1. 经典二阶模型 (无励磁)
        Sgnum = 2;
        StatVar0(GStatsnum+1:GStatsnum+Sgnum) = [Delta, 1];
        
    elseif (Mac(loop_G,18) == 0)
        % 2. 考虑励磁绕组的三阶模型 (无励磁控制器)
        Sgnum = 3;
        StatVar0(GStatsnum+1:GStatsnum+Sgnum) = [Delta, 1, Eqq];
        
    elseif (Mac(loop_G,18) ~= 0 && Mac(loop_G,19) == 0)
        % 3. 四阶模型 (有励磁控制器, 无PSS)
        Sgnum = 4;
        StatVar0(GStatsnum+1:GStatsnum+Sgnum) = [Delta, 1, Eqq, Efd];
        
    % 若未来加入 PSS，可在此处扩展高阶模型分支
    % elseif (Mac(loop_G,18) ~= 0 && Mac(loop_G,19) ~= 0)
    %     Sgnum = x;
    %     StatVar0(...) = [...];
    end
    
    GStatsnum = GStatsnum + Sgnum;        
    Statsnum = GStatsnum;   
    %%%%%%%%%%%%% 动态状态变量分配完毕 %%%%%%%%%%%%%
    
    % 励磁初始信息
    if(ExcNum > 0 && Mac(loop_G,18) ~= 0)
        EVref(loop_G,1) = abs(V_gen);
        EEfd(loop_G,1) = 0;
        EVr(loop_G,1) = 0;
        EVa(loop_G,1) = 0;
        EVf(loop_G,1) = 0;
        EVtr(loop_G,1) = EVref(loop_G,1);
    end
    
    % PSS初始信息
    if(PssNum > 0 && Mac(loop_G,19) ~= 0)
        EPssA(loop_G,1) = 0;
        EPssB(loop_G,1) = 0;
        EPssC(loop_G,1) = 0;
        EPssD(loop_G,1) = 0;
        EPssE(loop_G,1) = 0;
        EPssF(loop_G,1) = 0;
    end
end%for loop_G


%% 3. 新能源构网/跟网模型初始化
if (VSG_Flag==1)
    for loop_W = GenNum+1:VSGNum
        SWGT = 2;  
        BusNo = Mac(loop_W,1);
	    V_gen = Bus(BusNo,2).*exp(jay*Bus(BusNo,3));
        S = P_G(BusNo) + jay* Q_G(BusNo);
        I_gen = conj(S)/conj(V_gen);
        EQ = V_gen + Xf*I_gen*jay;
        Delta = angle(EQ); 
        [Vd,Vq,Id,Iq] = XY_VSG(V_gen,I_gen,Delta); 
        Pe = Vd*Id+Vq*Iq;
        Qe = Vq*Id-Vd*Iq;
        Pm = Pe;
        Qm = Qe;
        Ed = Vd-Xf*Iq;
        GEQ0(loop_W) = Ed;
        GPm0(loop_W) = Pm;
        GPe0(loop_W) = Pe;
        GDelta0(loop_W) = Delta;
        GOmiga0(loop_W) = 1;
        GQm0(loop_W,1) = Qm;
        GQe0(loop_W,1) = Qe;
        GDelta(loop_W,1) = Delta;
        GOmiga(loop_W,1) = 1;

        StatVar0(Statsnum+1:Statsnum+SWGT) =[Delta,1];
        Statsnum = Statsnum + SWGT;
    end
end

if (WndG_Flag==1)
    for loop_W = 1:WndGNum
        SWGT = 15;          
        StatVar0(Statsnum+1:Statsnum+SWGT) = xWnG0;
        Statsnum = Statsnum + SWGT;
    end
end

if (PVG_Flag==1)
    for loop_W = 1:PVGNum
        SPVT = 12;          
        StatVar0(Statsnum+1:Statsnum+SPVT) = xPVG0;
        Statsnum = Statsnum + SPVT;
    end
end

end % End of function IniDataSimu

    



