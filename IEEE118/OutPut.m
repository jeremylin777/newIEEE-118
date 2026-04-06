function Output()
% 计算节点潮流信息 电压幅值 电压相位 节点输出有功 节点输出无功
% 计算线路潮流信息 线路1侧有功 线路1侧无功  线路2侧有功 线路2侧无功

GlobalVar;
%***********************************************

%***********************************************************************************************
%平衡节点信息
OutBusNameResult = cell(BusNum,7);
OutLineResult = cell(length(Line(:,1)),6);
%***********************************************

V_Comp = V_abs.*exp(jay*V_ang);
% bus current injection
I_Comp = Y * V_Comp;
% power output based on voltages 
S = V_Comp.*conj(I_Comp);
P_e = real(S); 
Q_e = imag(S);
P_D = Bus(:,6);
Q_D = Bus(:,7);
P_G = P_e + P_D;
Q_G = Q_e + Q_D;

for loop = 1:BusNum
    OutBusResult(loop,1) = Bus(loop,1);
    OutBusResult(loop,2) = V_abs(loop);
    OutBusResult(loop,3) = V_ang(loop)*180/pi;
    OutBusResult(loop,4) = P_e(loop);
    OutBusResult(loop,5) = Q_e(loop);
    OutBusResult(loop,6) = P_G(loop);
    OutBusResult(loop,7) = Q_G(loop);    
    OutBusResult(loop,8) = P_D(loop);
    OutBusResult(loop,9) = Q_D(loop);
    OutBusResult(loop,10) =V_Comp(loop);
    OutBusResult(loop,11) =I_Comp(loop);
    OutBusNameResult(loop,1) = {BusName(Bus(loop,1))};
    OutBusNameResult(loop,2) = {OutBusResult(loop,2)};
    OutBusNameResult(loop,3) = {OutBusResult(loop,3)};
    OutBusNameResult(loop,4) = {OutBusResult(loop,4)};
    OutBusNameResult(loop,5) = {OutBusResult(loop,5)};
    OutBusNameResult(loop,6) = {OutBusResult(loop,6)};
    OutBusNameResult(loop,7) = {OutBusResult(loop,7)};
    Bus(loop,2) = V_abs(loop);
    Bus(loop,3) = V_ang(loop);
    Bus(loop,4) = OutBusResult(loop,6);
    Bus(loop,5) = OutBusResult(loop,7);    
    Bus(loop,6) = OutBusResult(loop,8);
    Bus(loop,7) = OutBusResult(loop,9); 
    
end

BusFrom = Line(:,1);
BusTo = Line(:,2);
Line_R = Line(:,3);
Line_X = Line(:,4);
Line_B = Line(:,5);
Line_RATIO =  Line(:,6);

for loop = 1:length(Line(:,1))
    
    V_s = V_abs(BusFrom(loop))*exp(jay*V_ang(BusFrom(loop)));
    V_r = V_abs(BusTo(loop))*exp(jay*V_ang(BusTo(loop)));
    
    R = Line_R(loop);
    X = Line_X(loop);
    B = Line_B(loop);
    RATIO = Line_RATIO(loop);
    
    Yt   = 1 / (R + X*jay);
	Yt12 = Yt / RATIO;
	Yt10 = (1-RATIO)/RATIO/RATIO * Yt;
	Yt20 = (RATIO-1)/RATIO * Yt;
    I_s = (V_s - V_r)*( Yt12 )  + V_s * (jay*B/2 + Yt10);
    I_r = (V_r - V_s)*( Yt12 )  + V_r * (jay*B/2 + Yt20);
    S_s = V_s*conj(I_s);
    S_r = V_r*conj(I_r);
    P_s = real(S_s); 
    Q_s = imag(S_s); 
    P_r = real(S_r); 
    Q_r = imag(S_r); 
    
    OutRootResult(loop,1)= BusFrom(loop);
    OutRootResult(loop,2)= BusTo(loop);
    OutRootResult(loop,3)=P_s;
    OutRootResult(loop,4)=Q_s;
    OutRootResult(loop,5)=P_r;
    OutRootResult(loop,6)=Q_r;
    
    OutLineResult(loop,1) = {BusName(BusFrom(loop))};
    OutLineResult(loop,2) = {BusName(BusTo(loop))};
    OutLineResult(loop,3)={P_s};
    OutLineResult(loop,4)={Q_s};
    OutLineResult(loop,5)={P_r};
    OutLineResult(loop,6)={Q_r};    
 end  
