function InitGlobalVar()
%全局变量初始化;

GlobalVar;

PowerFlowIterNumMax = 20;

BusI = zeros(BusNum,T_Simulate_Num);
BusV = zeros(BusNum,T_Simulate_Num);
V = zeros(2*BusNum,1);
I = zeros(2*BusNum,1);

Ynet = zeros(2*BusNum, 2*BusNum);

%发电机参数初始化
GPe0 = zeros(GenNum,1);
GPm0 = zeros(GenNum,1);
GOmiga0 = zeros(GenNum,1);
GDelta0 = zeros(GenNum,1);
GEqq0 = zeros(GenNum,1);
GEq0 = zeros(GenNum,1);

GPe = zeros(GenNum,T_Simulate_Num);
GPm = zeros(GenNum,T_Simulate_Num);
GOmiga = zeros(GenNum,T_Simulate_Num);
GDelta = zeros(GenNum,T_Simulate_Num);
GEqq = zeros(GenNum,T_Simulate_Num);
GEq = zeros(GenNum,T_Simulate_Num);


DGDleta = zeros(GenNum,T_Simulate_Num);
DGOmiga = zeros(GenNum,T_Simulate_Num);
DGEqq = zeros(GenNum,T_Simulate_Num);

DGDleta0 = zeros(GenNum,1);
DGDleta1 = zeros(GenNum,1);
DGOmiga0 = zeros(GenNum,1);
DGOmiga1 = zeros(GenNum,1);
DGEqq0 = zeros(GenNum,1);
DGEqq1 = zeros(GenNum,1);

%励磁参数初始化
EVref = zeros(GenNum,1);

GEfd0 = zeros(GenNum,1);  
GEfd = zeros(GenNum,T_Simulate_Num);  
       
EIng = zeros(GenNum,T_Simulate_Num);  
EVtr = zeros(GenNum,T_Simulate_Num);  
EVa = zeros(GenNum,T_Simulate_Num);   
EVas = zeros(GenNum,T_Simulate_Num);  
EVr = zeros(GenNum,T_Simulate_Num);   
EEfd = zeros(GenNum,T_Simulate_Num);   
       
DEVtr0  = zeros(GenNum,1);
DEVtr1  = zeros(GenNum,1);
DEVas0  = zeros(GenNum,1);
DEVas1  = zeros(GenNum,1);
DEVr0   = zeros(GenNum,1);
DEVr1   = zeros(GenNum,1);
DEEfd0  = zeros(GenNum,1);
DEEfd1  = zeros(GenNum,1);

DEVtr  = zeros(GenNum,T_Simulate_Num);
DEVas  = zeros(GenNum,T_Simulate_Num);
DEVr   = zeros(GenNum,T_Simulate_Num);
DEEfd  = zeros(GenNum,T_Simulate_Num);

%PSS参数初始化
EPssA  = zeros(GenNum,T_Simulate_Num);
EPssB  = zeros(GenNum,T_Simulate_Num);
EPssC  = zeros(GenNum,T_Simulate_Num);
EPssD  = zeros(GenNum,T_Simulate_Num);
EPssE  = zeros(GenNum,T_Simulate_Num);
EPssF =  zeros(GenNum,T_Simulate_Num);

DEPssA0  = zeros(GenNum,1);
DEPssA1  = zeros(GenNum,1);
DEPssC0  = zeros(GenNum,1);
DEPssC1  = zeros(GenNum,1);
DEPssE0  = zeros(GenNum,1);
DEPssE1  = zeros(GenNum,1);

DEPssA  = zeros(GenNum,T_Simulate_Num);
DEPssC  = zeros(GenNum,T_Simulate_Num);
DEPssE  = zeros(GenNum,T_Simulate_Num);

%TG参数
% Tg_V10 = zeros(TgNum,1);
% Tg_V20 = zeros(TgNum,1);
% Tg_Pm0 = zeros(TgNum,1);
%               
% Tg_WRef = zeros(TgNum,1);
% Tg_PRef = zeros(TgNum,1);
%               
% Tg_V1 =  zeros(TgNum,T_Simulate_Num); 
% Tg_V2 =  zeros(TgNum,T_Simulate_Num);  
% Tg_Pm = zeros(TgNum,T_Simulate_Num);
%               
% DTg_V10 =  zeros(TgNum,1); 
% DTg_V20 =  zeros(TgNum,1); 
% DTg_V11 =  zeros(TgNum,1); 
% DTg_V21 =  zeros(TgNum,1); 
% DTg_V1 =  zeros(TgNum,T_Simulate_Num);  
% DTg_V2 =  zeros(TgNum,T_Simulate_Num); 


%STBE参数

P_stbe_Ref = zeros(StbeNum,1);
V_stbe_Ref = zeros(StbeNum,1);
Vdc_stbe_Ref = zeros(StbeNum,1);

Stbe_me0= zeros(StbeNum,1);  
Stbe_de0= zeros(StbeNum,1); 
Stbe_Vdc0= zeros(StbeNum,1);

Stbe_me=zeros(StbeNum,T_Simulate_Num);  
Stbe_de=zeros(StbeNum,T_Simulate_Num);  
Stbe_Vdc=zeros(StbeNum,T_Simulate_Num); 

Stb_me=zeros(StbeNum,T_Simulate_Num); 
Stb_de=zeros(StbeNum,T_Simulate_Num); 
Stb_Vdc=zeros(StbeNum,T_Simulate_Num); 

Dme_stb0=zeros(StbeNum,1);
Dme_stb1=zeros(StbeNum,1);
Dme_stb=zeros(StbeNum,T_Simulate_Num); 
Dde_stb0=zeros(StbeNum,1);
Dde_stb1=zeros(StbeNum,1);
Dde_stb=zeros(StbeNum,T_Simulate_Num);
Dvdc_stb0=zeros(StbeNum,1);
Dvdc_stb1=zeros(StbeNum,1);
Dvdc_stb=zeros(StbeNum,T_Simulate_Num);


%STBE附加控制器参数
EStbe_PssA  = zeros(Stbe_PssNum,T_Simulate_Num);
EStbe_PssB  = zeros(Stbe_PssNum,T_Simulate_Num);
EStbe_PssC  = zeros(Stbe_PssNum,T_Simulate_Num);
EStbe_PssD  = zeros(Stbe_PssNum,T_Simulate_Num);
EStbe_PssE  = zeros(Stbe_PssNum,T_Simulate_Num);
EStbe_PssF =  zeros(Stbe_PssNum,T_Simulate_Num);

DEStbe_EPssA0  = zeros(Stbe_PssNum,1);
DEStbe_EPssA1  = zeros(Stbe_PssNum,1);
DEStbe_EPssC0  = zeros(Stbe_PssNum,1);
DEStbe_EPssC1  = zeros(Stbe_PssNum,1);
DEStbe_EPssE0  = zeros(Stbe_PssNum,1);
DEStbe_EPssE1  = zeros(Stbe_PssNum,1);

DEStbe_EPssA  = zeros(Stbe_PssNum,T_Simulate_Num);
DEStbe_EPssC  = zeros(Stbe_PssNum,T_Simulate_Num);
DEStbe_EPssE  = zeros(Stbe_PssNum,T_Simulate_Num);

StbePIng =zeros(StbeNum,T_Simulate_Num);
StbeVIng =zeros(StbeNum,T_Simulate_Num);
Stbe_err=zeros(Stbe_PssNum,T_Simulate_Num);



%%Load参数
LoadPot=zeros(LoadNum,4);          

%SVC参数
SvcPot = zeros(SvcNum,4);
BSvc_Vref = zeros(SvcNum,1);
B_cv0 = zeros(SvcNum,1);

B_cv = zeros(SvcNum,T_Simulate_Num);
BSvc = zeros(SvcNum,T_Simulate_Num);

DB_cv0 = zeros(SvcNum,1);
DB_cv1 = zeros(SvcNum,1);
DB_cv = zeros(SvcNum,T_Simulate_Num);

%STATCOM参数
StatPot = zeros(StatNum,10);
Stat_Vref = zeros(StatNum,1);
Stat_Ing = zeros(StatNum,T_Simulate_Num);

St_Vdc0 = zeros(StatNum,1);
St_Vdc = zeros(StatNum,T_Simulate_Num);
DSt_Vdc0 = zeros(StatNum,1);
DSt_Vdc1 = zeros(StatNum,1);
DSt_Vdc  = zeros(StatNum,T_Simulate_Num);

St_M0 = zeros(StatNum,1);
St_M = zeros(StatNum,T_Simulate_Num);
DSt_M0 = zeros(StatNum,1);
DSt_M1 = zeros(StatNum,1);
DSt_M  = zeros(StatNum,T_Simulate_Num);

St_Angle0 = zeros(StatNum,1);
St_Angle = zeros(StatNum,T_Simulate_Num);

%TCSC参数
TcscPot = zeros(TcscNum,5);
X_tcsc_Ref = zeros(TcscNum,1);
X_tcsc0 = zeros(TcscNum,1);

X_tcsc = zeros(TcscNum,T_Simulate_Num);

DX_tcsc0 = zeros(TcscNum,1);
DX_tcsc1 = zeros(TcscNum,1);
DX_tcsc  = zeros(TcscNum,T_Simulate_Num);

%动态电动机负荷参数
MotorPot = zeros(MotoNum,5);

M_Ee0 = zeros(MotoNum,1);
M_S0 = zeros(MotoNum,1);
M_Ee = zeros(MotoNum,T_Simulate_Num);
M_S = zeros(MotoNum,T_Simulate_Num);
M_P = zeros(MotoNum,T_Simulate_Num);
M_Q = zeros(MotoNum,T_Simulate_Num);
M_Te = zeros(MotoNum,T_Simulate_Num);
M_Tm = zeros(MotoNum,T_Simulate_Num);

DM_Ee0 = zeros(MotoNum,1);
DM_S0 = zeros(MotoNum,1);
DM_Ee1 = zeros(MotoNum,1);
DM_S1 = zeros(MotoNum,1);
DM_Ee = zeros(MotoNum,1);
DM_S = zeros(MotoNum,1);

%% 双馈电机参数初始化
if(DfimNum>0)
%    MotorPot = zeros(DfimNum,5);
    D_S0 = zeros(DfimNum,1);
    DfimV=zeros(DfimNum,1);
    Dfim_Pe=zeros(DfimNum,T_Simulate_Num);
    Dfim_Qe=zeros(DfimNum,T_Simulate_Num);
    Dfim_Ps =zeros(DfimNum,T_Simulate_Num);
    Dfim_Qs=zeros(DfimNum,T_Simulate_Num);
    Dfim_Pr=zeros(DfimNum,T_Simulate_Num);
    Dfim_Qr=zeros(DfimNum,T_Simulate_Num);
    EIds =zeros(DfimNum,T_Simulate_Num);
    EIqs =zeros(DfimNum,T_Simulate_Num);
    EUqr =zeros(DfimNum,T_Simulate_Num);
    EUdr=zeros(DfimNum,T_Simulate_Num);
    EUqs=zeros(DfimNum,T_Simulate_Num);
    EPs=zeros(DfimNum,T_Simulate_Num);
    EGPs=zeros(DfimNum,T_Simulate_Num);
    EIdr=zeros(DfimNum,T_Simulate_Num);
    EIqr=zeros(DfimNum,T_Simulate_Num);
    Kh_Pr=zeros(DfimNum,T_Simulate_Num);
    EPss = zeros(DfimNum,T_Simulate_Num);
    EPe = zeros(DfimNum,T_Simulate_Num);
    Dfim_Uqs= zeros(DfimNum,T_Simulate_Num);
    Dfim_Idr=zeros(DfimNum,T_Simulate_Num);
    Dfim_Iqr=zeros(DfimNum,T_Simulate_Num);
    Dfim_Udr=zeros(DfimNum,T_Simulate_Num);
    Dfim_Uqr=zeros(DfimNum,T_Simulate_Num);    
    Dfim_S=zeros(DfimNum,T_Simulate_Num);
    Dfim_Edd =zeros(DfimNum,T_Simulate_Num);
    Dfim_Eqq =zeros(DfimNum,T_Simulate_Num);
    Dfim_Te =zeros(DfimNum,T_Simulate_Num);
    Pline12 =zeros(DfimNum,T_Simulate_Num);
    Us_ref= zeros(DfimNum,1);
    Pe_ref= zeros(DfimNum,1);
    Kh_Pr0= zeros(DfimNum,1);
    D_temp = zeros(DfimNum,1);
    
%    K_Pr= zeros(DfimNum,1);
  %  Dfim_S0
    DD_Edd0 = zeros(DfimNum,1);
    DD_Eqq0 = zeros(DfimNum,1);
    DD_S0= zeros(DfimNum,1);
    DD_Uqs0=zeros(DfimNum,1);
    DD_Idr0=zeros(DfimNum,1);
    DD_Ps0=zeros(DfimNum,1);
    DD_Iqr0=zeros(DfimNum,1);
    %    zeros(DfimNum,1);
    %PSS参数初始化
    P_Dfim_Ref = zeros(DfimNum,1);
    V_Dfim_Ref = zeros(DfimNum,1);
    %DFIM附加控制器参数
    EDfim_PssA  = zeros(Dfim_PssNum,T_Simulate_Num);
    EDfim_PssB  = zeros(Dfim_PssNum,T_Simulate_Num);
    EDfim_PssC  = zeros(Dfim_PssNum,T_Simulate_Num);
    EDfim_PssD  = zeros(Dfim_PssNum,T_Simulate_Num);
    EDfim_PssE  = zeros(Dfim_PssNum,T_Simulate_Num);
    EDfim_PssF =  zeros(Dfim_PssNum,T_Simulate_Num);

    DEDfim_EPssA0  = zeros(Dfim_PssNum,1);
    DEDfim_EPssA1  = zeros(Dfim_PssNum,1);
    DEDfim_EPssC0  = zeros(Dfim_PssNum,1);
    DEDfim_EPssC1  = zeros(Dfim_PssNum,1);
    DEDfim_EPssE0  = zeros(Dfim_PssNum,1);
    DEDfim_EPssE1  = zeros(Dfim_PssNum,1);

    DEDfim_EPssA  = zeros(Dfim_PssNum,T_Simulate_Num);
    DEDfim_EPssC  = zeros(Dfim_PssNum,T_Simulate_Num);
    DEDfim_EPssE  = zeros(Dfim_PssNum,T_Simulate_Num);

    DfimPIng =zeros(DfimNum,T_Simulate_Num);
    DfimVIng =zeros(DfimNum,T_Simulate_Num);
    Dfim_err=zeros(Dfim_PssNum,T_Simulate_Num);
    err_P=zeros(DfimNum,T_Simulate_Num);
end



GOmigas = SHz*2*pi;%系统频率


