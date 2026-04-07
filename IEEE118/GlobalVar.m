%% Read File Name
% global InputFileName;

%% 系统参数
global Sbase %功率基准值；
global SHz  %BaseHz；
global GenNum %发电机总数；
global BusNum %节点总数； 
global LineNum %线路总数；
global SlackBus %平衡节点 节点号；
global SlackGen %平衡节点 发电机号；
global GenBus %发电机节点
global PqBus %PQ节点；
global PvBus %PV节点；
global PqPvBus %PQ节点和PV节点；
global PqBusNum %PQ节点总数；
global PvBusNum %PV节点总数；
global PqPvBusNum %PQ节点和PV节点节点总数；
global BusName %所有节点名称；
global BusType %所有节点类 1：平衡节点 2：PV节点 3：PQ节点
global Line %所有线路信息，存为矩阵；
global Bus %所有节点信息，存为矩阵；
global Bustemp %所有节点信息，存为矩阵；
global Mac %所有发电机信息，存为矩阵；
global Y0 %初始导纳矩阵
global Area;%初始数据区域信息


global DampAreaGenNo ;%阻尼分区发电机台数信息
global DampArea;%阻尼分区信息
global DTAAreaGen;%阻尼转矩分区信息

%% 潮流计算所需信息
global PowerFlowIterNum %潮流迭代次数；
global PowerFlowIterNumMax %潮流迭代次数最大次数
global Acc %加速因子；
global Y; %导纳矩阵；
global J; %夹克比矩阵；
global J_H;%夹克比矩阵H阵  有功/功角；
global J_N;%夹克比矩阵N阵  有功/电压；
global J_J;%夹克比矩阵J阵  无功/功角；
global J_L;%夹克比矩阵L阵  无功/电压；
global V_abs; %节点电压幅值
global V_ang; %节点电压相角
global P_Sel; %有功节点选择矩阵；
global Q_Sel; %无功节点选择矩阵；
global P_G; %节点输入有功功率
global Q_G ;%节点输入无功功率
global P_D ;%节点输出有功功率
global Q_D ;%节点输出无功功率
global P_e;%节点有功电磁功率
global Q_e;%节点无功电磁功率
global OutBusResult %节点输出结果信息
global OutRootResult %线路功率信息
global OutLineResult %线路功率信息
global OutBusNameResult %节点输出结果信息
global V_Comp I_Comp

%% 直流信息
global DBusNum %直流节点数
global DLineNum %直流线路数
global DBus %直流节点信息
global BusDCNoLoad%BUS中数据直流作为负荷加入；而BusDCNoLoad中数据直流没有作为负荷加入，为了后面暂态计算的需要。
global DLine %直流线路信息
global DCMD  %直流控制信息
global DCMDNum %直流控制个数
global DBusName %直流母线名称

%% 稳定计算所需信息
global GOmigas %发电机系数 即 dα/dt = Ws(Wi-1) 中 Ws=GOmigas 
global BusV_abs    %仿真计算中，各个时刻节点的电压幅值

global Y_Equal %稳定计算负荷等效导纳
global Ynet  %稳定计算网络矩阵 
global Ynet_temp %稳定计算网络矩阵 
global V     %网络等效输入电流信息
global I     %网络节点电压电流信息
global BusI %稳定计算中，各个时刻网络等效虚拟输入电流信息
global BusV %稳定计算中，各个时刻网络节点电压信息


%% 线性化计算所需信息

global Statsnum;%所有状态变量个数
global GStatsnum;%所有发电机状态变量个数
global DStatsnum;%所有直流状态变量个数
global LMnum;%所有机电振荡模态个数
global LX  %所有状态变量
global LE %所有控制变量 DeltaX=A*DeltaX+B*DeltaV+E*DeltaPss
global LF%所有输出变量 DeltaY=C*DeltaX
global LA % A矩阵; DeltaX=A*DeltaX+B*DeltaV
global LB % B矩阵; DeltaX=A*DeltaX+B*DeltaV
global LC % C矩阵; 0=C*DeltaX+D*DeltaV
global LD % D矩阵; 0=C*DeltaX+D*DeltaV
%global modeana;%模式分析的结果
global modeme;%分析得到的机电振荡模态
global Amatrix;%状态矩阵A
global P;%相关因子矩阵
global LVr;%右特征向量；
global LVl;%左特征向量；
global StategenBegin;

global LObs%可观性
global LCtrl%可控性

global CtrlEigenNum %所有需要观察的模态的个数
global CtrlEigen %所有需要观察的模态

global LAmatrix %状态矩阵;
global LAeigen %特征值；
global LMAeigen %机电振荡特征值；
global LRMAeigen %和机电振荡特征值相关的模态的右特征向量；
global GFactor %参与因子矩阵
global Rij %留数

global CtrlBgenName%发电机PSS控制变量所在母线名称；
global OutBGen%发电机PSS输出变量所在母线名称；
global CtrlDName%直流控制变量所在母线名称；
global CtrlBGenBusNo ;%发电机PSS控制量所在母线编号,初始为零
global CtrlDBusNo;%直流控制量所在母线编号,初始为零
global CtrlBBusNo %控制量编号
global TTj %发电机惯性常数

global LACtrlmatrix %矩阵重新排序后的状态矩阵
global LXCtrl %矩阵重新排序后的所有状态变量
global LECtrl %矩阵重新排序后的所有控制变量
global LACtrl11 %A矩阵分解
global LACtrl12 %A矩阵分解
global LACtrl13 %A矩阵分解
global LACtrl21 %A矩阵分解
global LACtrl22 %A矩阵分解
global LACtrl23 %A矩阵分解
global LACtrl31 %A矩阵分解
global LACtrl32 %A矩阵分解
global LACtrl33 %A矩阵分解
global LECtrl1 %控制矩阵分解
global LECtrl2 %控制矩阵分解
global LECtrl3 %控制矩阵分解
global LFCtrl  %控制变量到机电振荡的前向通路
global LGCtrl  %反馈量到控制变量的传递函数
global LRCtrl  %输出量到反馈量的传递函数
global LHCtrl  %阻尼转矩到各机的通路
global LHCtrlVal %阻尼转矩到各机的通路的具体值（左半部）
global LHCtrlValAbs %阻尼转矩到各机的通路的具体值的幅值
global LHCtrlValAngle %阻尼转矩到各机的通路的具体值的角度
global LHGenCtrlVal %PSS阻尼转矩到各机的通路的具体值（左半部）
global LHGenCtrlValAbs %PSS阻尼转矩到各机的通路的具体值的幅值
global LHGenCtrlValAngle %PSS阻尼转矩到各机的通路的具体值的角度
global LHDCtrlVal %HVDC阻尼转矩到各机的通路的具体值（左半部）
global LHDCtrlValAbs %HVDC阻尼转矩到各机的通路的具体值的幅值
global LHDCtrlValAngle %HVDC阻尼转矩到各机的通路的具体值的角度
global LArea %存储判断区域震荡的相关信息，包括参与因子，右特征向量角度
global Lgama %反馈矩阵
global SijD %灵敏度系数（右半部）
global Sij %灵敏度系数，根据解析法求得
global DTAGen  %PSS阻尼转矩贡献（左半部*右半部）
global DTAGenE
global DTAGenabs %PSS阻尼转矩贡献的幅值
global DTAGenangle %PSS阻尼转矩贡献的角度
global DTAD  %HVDC阻尼转矩贡献（左半部*右半部）
global DTADabs %HVDC阻尼转矩贡献的幅值
global DTADangle %HVDC阻尼转矩贡献的角度
global DTAGenResult %PSS阻尼转矩贡献结果
global DTAGenEResult;
global DTADResult %HVDC阻尼转矩贡献结果

%% 灵敏度计算所需数据
global SBus; %考察对象
global CalBusNo; %考察对象母线编号
global SLA;
global SLB;
global SLC;
global SLD;
global SEigenK; %特征值对参数的灵敏度
global SEigenKTest; %特征值对参数的灵敏度
global Svk;
global SvkTest;
global Sik;
global SikTest;
global Ssk;
global SGDeltaK;
global SGVdK;
global SGVqK;
global SGIdK;
global SGIqK;
global YequalK;

global SEigenK_LoadP;
global SEigenK_SLoadP;
global SEigenK_SLoadPName;
global SEigenK_LoadQ;
global SEigenK_SLoadQ;
global SEigenK_SLoadQName;
global SEigenK_GenP;
global SEigenK_SGenP;
global SEigenK_SGenPName;
global SEigenK_GenV;
global SEigenK_SGenV;
global SEigenK_SGenVName;
global SEigenK_Sum;
global SEigenK_SumName;

%% 发电机数据；
global GPe0 %稳定计算中，各台发电机初始输出电磁功率
global GPm0 %稳定计算中，各台发电机初始输入机械功率
global GOmiga0 %稳定计算中，各台发电机初始角速度
global GDelta0 %稳定计算中，各台发电机初始功角
global GEq0    %稳定计算中，各台发电机初始Eq
global GEqq0  %稳定计算中，各台发电机初始Eq'

global GPe %稳定计算中，各个时刻各台发电机输出电磁功率信息
global GPm %稳定计算中，各个时刻各台发电机输入机械功率信息
global GQe %稳定计算中，各个时刻各台发电机机端输出无功功率信息
global GOmiga %稳定计算中，各个时刻各台发电机角速度信息
global GDelta %稳定计算中，各个时刻各台发电机功角信息
global GEq    %稳定计算中，各个时刻各台发电机Eq信息
global GEqq   %稳定计算中，各个时刻各台发电机Eq'信息

global DGDleta0 %稳定计算中，EULA仿真计算中，预测环节中，各个时刻各台发电机功角变化率
global DGDleta1 %稳定计算中，EULA仿真计算中，校正环节中，各个时刻各台发电机功角变化率
global DGDleta  %稳定计算中，EULA仿真计算中，各个时刻各台发电机功角变化率
global DGOmiga0 %稳定计算中，EULA仿真计算中，预测环节中，各个时刻各台发电机角速度变化率
global DGOmiga1 %稳定计算中，EULA仿真计算中，校正环节中，各个时刻各台发电机角速度变化率
global DGOmiga  %稳定计算中，EULA仿真计算中，各个时刻各台发电机角速度变化率
global DGEqq0   %稳定计算中，EULA仿真计算中，预测环节中，各个时刻各台发电机Eq'变化率
global DGEqq1   %稳定计算中，EULA仿真计算中，校正环节中，各个时刻各台发电机Eq'变化率 
global DGEqq    %稳定计算中，EULA仿真计算中，各个时刻各台发电机Eq'变化率

%励磁参数
global ExcNum %励磁总数； 
global ExcBus %励磁节点；
global Exc %所有励磁信息，存为矩阵；
%励磁数据；
global EVref;  %稳定计算中，各台发电机励磁Vref初始信息
global EIng;   %稳定计算中，各个时刻各台发电机励磁附加励磁Ing信息   

global GEfd0    %稳定计算中，各台发电机励磁Efd初始信息
global GEfd     %稳定计算中，各个时刻各台发电机励磁Efd信息

global EVtr;   %稳定计算中，各个时刻各台发电机励磁Vtr信息   
global EVa;    %稳定计算中，各个时刻各台发电机励磁Va信息
global EVr;    %稳定计算中，各个时刻各台发电机励磁Vr信息   
global EVf     %稳定计算中，各个时刻各台发电机励磁Vf信息   
global EEfd    %稳定计算中，各个时刻各台发电机Efd变化率信息，即为▲Efd,一定要注意这一个变量，很容易和Efd混淆。

global DEVtr0 %稳定计算中，EULA仿真计算中，预测环节中，各个时刻各台发电机励磁Vtr变化率
global DEVtr1 %稳定计算中，EULA仿真计算中，校正环节中，各个时刻各台发电机励磁Vtr变化率
global DEVa0 %稳定计算中，EULA仿真计算中，预测环节中，各个时刻各台发电机励磁Vas变化率
global DEVa1 %稳定计算中，EULA仿真计算中，校正环节中，各个时刻各台发电机励磁Vas变化率
global DEVr0  %稳定计算中，EULA仿真计算中，预测环节中，各个时刻各台发电机励磁Vr变化率
global DEVr1  %稳定计算中，EULA仿真计算中，校正环节中，各个时刻各台发电机励磁Vr变化率
global DEVf0  %稳定计算中，EULA仿真计算中，预测环节中，各个时刻各台发电机励磁Vf变化率
global DEVf1  %稳定计算中，EULA仿真计算中，校正环节中，各个时刻各台发电机励磁Vf变化率
global DEEfd0 %稳定计算中，EULA仿真计算中，预测环节中，各个时刻各台发电机励磁Efd变化率
global DEEfd1 %稳定计算中，EULA仿真计算中，校正环节中，各个时刻各台发电机励磁Efd变化率
global DEVtr %稳定计算中，EULA仿真计算中，各个时刻各台发电机励磁Vtr变化率
global DEVr  %稳定计算中，EULA仿真计算中，各个时刻各台发电机励磁Vr变化率
global DEVf  %稳定计算中，EULA仿真计算中，各个时刻各台发电机励磁Vf变化率
global DEEfd %稳定计算中，EULA仿真计算中，各个时刻各台发电机励磁Efd变化率

%PSS参数
global PssNum %PSS总数； 
global PssBus %PSS节点；
global Pss %所有PSS信息，存为矩阵；
%PSS数据；
global EPssA;    
global EPssB;    
global EPssC;   
global EPssD;    
global EPssE;
global EPssF;%PSS中的六个中间的状态变量

global DEPssA0 %稳定计算中，EULA仿真计算中，预测环节中，EPssA变化率
global DEPssA1 %稳定计算中，EULA仿真计算中，校正环节中，EPssA变化率
global DEPssA %稳定计算中，EULA仿真计算中，预测环节中，EPssA变化率
global DEPssC0 %稳定计算中，EULA仿真计算中，预测环节中，EPssC变化率
global DEPssC1 %稳定计算中，EULA仿真计算中，校正环节中，EPssC变化率
global DEPssC %稳定计算中，EULA仿真计算中，预测环节中，EPssC变化率
global DEPssE0 %稳定计算中，EULA仿真计算中，预测环节中，EPssE变化率
global DEPssE1 %稳定计算中，EULA仿真计算中，校正环节中，EPssE变化率
global DEPssE %稳定计算中，EULA仿真计算中，预测环节中，EPssE变化率


%% 直流稳定数据；
global DId %稳定计算中，各个时刻整流侧的直流电流信息
global DA1 %稳定计算中，各个时刻整流侧的触发角信息
global DA2 %稳定计算中，各个时刻逆变侧的触发角信息
global DVd1 %%稳定计算中，各个时刻整流侧的直流电压信息
global DVd2 %%稳定计算中，各个时刻逆变侧的直流电压信息

global DDA10 %稳定计算中，EULA仿真计算中，预测环节中，各个时刻各直流整流侧触发角变化率
global DDA11 %稳定计算中，EULA仿真计算中，校正环节中，各个时刻各直流整流侧触发角变化率
global DDA1  %稳定计算中，EULA仿真计算中，各个时刻各各直流整流侧触发角变化率
global DDA20   %稳定计算中，EULA仿真计算中，预测环节中，各个时刻各直流逆变侧触发角变化率
global DDA21   %稳定计算中，EULA仿真计算中，校正环节中，各个时刻各直流逆变侧触发角变化率 
global DDA2    %稳定计算中，EULA仿真计算中，各个时刻各各直流逆变侧触发角变化率

global D1Ing %考虑直流调制时，附加到整流侧的控制信号；
global D2Ing %考虑直流调制时，附加到逆变侧的控制信号；



%SVC数据；
global B_cv0; %稳定计算中，各SVC初始导纳信息  

global BSvc_VRef %稳定计算中，各SVC参考电压信息  

global B_cv;  %稳定计算中，各个时刻各SVC导纳变化值信息（变化量，与初值相加得到）
global BSvc;  %稳定计算中，各个时刻各SVC导纳信息

global DB_cv0;%稳定计算中，EULA仿真计算中，预测环节中，各个时刻各SVC导纳变化值变化率
global DB_cv1;%稳定计算中，EULA仿真计算中，校正环节中，各个时刻各SVC导纳变化值变化率
global DB_cv; %稳定计算中，EULA仿真计算中，各个时刻各SVC导纳变化值变化率
%SVC参数
global SvcNum; %svc总数
global SvcBus; %svc节点
global Svc;    %所有svc信息，存为矩阵
global SvcPot; %所有svc内部信息，存为矩阵   

%STATCOM数据
global Stat_Vref;%稳定计算中，各STATCOM参考电压信息  
global Stat_Ing;%稳定计算中，各STATCOM额外输入信息  
global St_Vdc0;  %稳定计算中，各STATCOM初始直流电压信息
global St_M0;    %稳定计算中，各STATCOM初始M信息
global St_Angle0;%稳定计算中，各STATCOM初始角度信息

global Statcom_Vdc;  %稳定计算中，各STATCOM直流电压信息；
global Statcom_M;    %稳定计算中，各STATCOM的M信息；
global Statcom_Angle;%稳定计算中，各STATCOM的角度信息；


global St_Vdc;     %稳定计算中，各STATCOM直流电压变化信息
global St_M;       %稳定计算中，各STATCOM的M变化信息         
global St_Angle;   %稳定计算中，各STATCOM角度变化信息      
                     
global DSt_Vdc0; %稳定计算中，各STATCOM直流电压变化变化率信息
global DSt_Vdc1;  
global DSt_Vdc;   
global DSt_M0;   %稳定计算中，各STATCOM的M变化变化率信息        
global DSt_M1;
global DSt_M;

%STATCOM参数
global StatNum; %svc总数
global StatBus; %svc节点
global Stat;    %所有svc信息，存为矩阵
global StatPot; %所有svc内部信息，存为矩阵  
global Statcom_Smax % 用来体现容量限制，   Mmax = M + Statcom_Smax;


%TG数据；
global Tg_V10; %稳定计算中，TG调速器初始信息  
global Tg_V20; %稳定计算中，TG初始信息  
global Tg_Pm0; %稳定计算中，TG初始输出功率  

global Tg_WRef %稳定计算中，各Tg 角速度参考电压信息
global Tg_PRef %稳定计算中，各Tg 功率参考电压信息

global Tg_V1; %稳定计算中，各个时刻TG调速器信息  
global Tg_V2; %稳定计算中，各个时刻TG信息  
global Tg_Pm; %稳定计算中，各个时刻TG输出功率  


global DTg_V10; %稳定计算中，EULA仿真计算中，预测环节中，各个时刻TG调速器变化率  
global DTg_V20; %稳定计算中，EULA仿真计算中，预测环节中，各个时刻TG变化率  
global DTg_V11; %稳定计算中，EULA仿真计算中，校正环节中，各个时刻TG调速器变化率  
global DTg_V21; %稳定计算中，EULA仿真计算中，校正环节中，各个时刻TG变化率  
global DTg_V1;  %稳定计算中，EULA仿真计算中，校正环节中，各个时刻TG调速器变化率  
global DTg_V2;  %稳定计算中，EULA仿真计算中，校正环节中，各个时刻TG变化率  

%TG参数
global TgNum; %svc总数
global TgBus; %svc节点
global Tg;    %所有svc信息，存为矩阵
global TgPot; %所有svc内部信息，存为矩阵   


%TCSC数据；
global X_tcsc0; %稳定计算中，各tcsc初始电抗信息  

global P_tcsc_Ref %稳定计算中，各tcsc参考有功功率信息  

global X_tcsc;  %稳定计算中，各个时刻各tcsc电抗信息    

global DX_tcsc0;%稳定计算中，EULA仿真计算中，预测环节中，各个时刻各tcsc电抗变化率
global DX_tcsc1;%稳定计算中，EULA仿真计算中，校正环节中，各个时刻各tcsc电抗变化率
global DX_tcsc; %稳定计算中，EULA仿真计算中，各个时刻各tcsc电抗变化率
%TCSC参数
global TcscNum; %tcsc总数
global TcscFromBus; %tcsc起始节点
global TcscToBus; %tcsc终结节点
global Tcsc;      %所有tcsc信息，存为矩阵
global TcscPot;   %所有tcsc内部信息，存为矩阵   

%STBE数据
global P_stbe_Ref;%稳定计算中，各STBE参考功率信息 
global V_stbe_Ref;%稳定计算中，各STBE参考电压信息
global Vdc_stbe_Ref;%稳定计算中，各STBE电容参考电压信息

global Stbe_Vdc0;  %稳定计算中，各STBE初始直流电压信息
global Stbe_me0;    %稳定计算中，各STBE初始幅值信息
global Stbe_de0;%稳定计算中，各STBE初始角度信息

global Stbe_Vdc;  %稳定计算中，各个时刻各stbe直流电压信息
global Stbe_me;   %稳定计算中，各个时刻各stbe幅值信息
global Stbe_de;  %稳定计算中，各个时刻各stbe幅角信息

global Stb_me;  %稳定计算中，各个时刻各stbe并联电压幅值变化信息中的积分部分  
global Stb_de;  %稳定计算中，各个时刻各upfc并联电压幅角变化信息中的积分部分
global Stb_Vdc; %稳定计算中，各个时刻各stbe直流电压变化信息

global StbeIed  %稳定计算中，各个时刻各stbe的q电流信息
global StbeIeq  %稳定计算中，各个时刻各stbe的q电流信息
global Steb_P   %稳定计算中，各个时刻各stbe的注入有功信息

global Dme_stb0;%稳定计算中，EULA仿真计算中，预测环节中，各个时刻各stbe并联电压幅值积分部分变化率(交流电压偏差)
global Dme_stb1;%稳定计算中，EULA仿真计算中，校正环节中，各个时刻各stbe并联电压幅值积分部分变化率(交流电压偏差)
global Dme_stb; %稳定计算中，EULA仿真计算中，各个时刻各stbe并联电压幅值积分部分变化率(交流电压偏差)
global Dde_stb0;%稳定计算中，EULA仿真计算中，预测环节中，各个时刻各stbe并联电压幅角积分部分变化率(直流电压偏差)
global Dde_stb1;%稳定计算中，EULA仿真计算中，校正环节中，各个时刻各stbe并联电压幅角积分部分变化率(直流电压偏差)
global Dde_stb; %稳定计算中，EULA仿真计算中，各个时刻各stbe并联电压幅角积分部分变化率(直流电压偏差)
global Dvdc_stb0;%稳定计算中，EULA仿真计算中，预测环节中，各个时刻各stbe直流电压变化率
global Dvdc_stb1;%稳定计算中，EULA仿真计算中，校正环节中，各个时刻各stbe直流电压变化率
global Dvdc_stb;%稳定计算中，EULA仿真计算中，各个时刻各stbe直流电压变化率

%STBE参数
global StbeNum; %stbe总数
global Stbe1Bus; %stbe接入线路
global Stbe2Bus; %stbe功率相关的另一个节点
global Stbe;    %所有stbe信息，存为矩阵
global StbePot; %所有stbe内部信息，存为矩阵  
global Stbe_Smax % 用来体现容量限制，
global Stbe_Pmax % 用来体现有功功率限制，
global StbePIng   ;    
global StbeVIng   ;    %STBE附加控制信息

%STBE附加控制器数据
global EStbe_PssA;    
global EStbe_PssB;    
global EStbe_PssC;   
global EStbe_PssD;    
global EStbe_PssE;
global EStbe_PssF;%控制回路1中的六个中间的状态变量
global DEStbe_PssA0 %稳定计算中，EULA仿真计算中，预测环节中，EStbe_PssA变化率
global DEStbe_PssA1 %稳定计算中，EULA仿真计算中，校正环节中，EStbe_PssA变化率
global DEStbe_PssA %稳定计算中，EULA仿真计算中，预测环节中，EStbe_PssA变化率
global DEStbe_PssC0 %稳定计算中，EULA仿真计算中，预测环节中，EStbe_PssC变化率
global DEStbe_PssC1 %稳定计算中，EULA仿真计算中，校正环节中，EStbe_PssC变化率
global DEStbe_PssC %稳定计算中，EULA仿真计算中，预测环节中，EStbe_PssC变化率
global DEStbe_PssE0 %稳定计算中，EULA仿真计算中，预测环节中，EStbe_PssE变化率
global DEStbe_PssE1 %稳定计算中，EULA仿真计算中，校正环节中，EStbe_PssE变化率
global DEStbe_PssE %稳定计算中，EULA仿真计算中，预测环节中，EStbe_PssE变化率
global Dpss0;
global Dpss1;
global Stbe_err;%偏差向量
global Ctrl_STBE_No; %DTA计算时用于定位
%STBE附加控制器参数
global Stbe_PssNum;%stbe附加控制器总数
global Stbe_Pss;   %所有stbe附加控制器信息，存为矩阵
global Stbeline;%STBE附加阻尼控制器所取功率信号所在的线路；
global S_L;%STBE附加阻尼控制器所取功率信号所在的线路的有功功率；
global Angle_L;%STBE附加阻尼控制器所取功率信号所在的线路的两端电压角度差值；
%静态非线性负荷参数
global LoadNum; %非线性负荷总数
global LoadBus; %非线性负荷节点
global Load; %所有非线性负荷信息，存为矩阵；
global LoadPot;  %所有load内部信息，存为矩阵   

%动态电动机负荷参数
global MotoNum;%动态电动机负荷总数
global MotoBus;%动态电动机负荷节点
global Moto;   %所有动态电动机负荷信息，存为矩阵
global MotoPot;%所有动态电动机负荷内部信息，存为矩阵

global M_S0;   %稳定计算中，各电动机初始滑差（S）信息
global M_Scr;  %稳定计算中，各电动机临界滑差（S）信息

global M_S;    %稳定计算中，各个时刻各电动机滑差（S）信息
global M_P;    %稳定计算中，各个时刻各电动机吸收有功信息
global M_Q;    %稳定计算中，各个时刻各电动机吸收无功信息
global M_Pe;   %稳定计算中，各个时刻各电动机转子侧电磁有功信息
global M_Te;   %稳定计算中，各个时刻各电动机转子侧电磁转矩信息
global M_Tm;   %稳定计算中，各个时刻各电动机转子侧负荷转矩信息

global DM_S0; %稳定计算中，EULA仿真计算中，预测环节中，各个时刻各电动机滑差（S）变化率
global DM_S1; %稳定计算中，EULA仿真计算中，校正环节中，各个时刻各电动机滑差（S）变化率
global DM_S;  %稳定计算中，各个时刻各电动机滑差（S）变化率


%DFIM参数
global DfimNum; %DFIM总数
global Dfim;    %所有DFIM信息，存为矩阵
global Dfim_Pe Dfim_Qe Dfim_Ps Dfim_Qs Dfim_Pr Dfim_Qr %DFIM总功率，定子功率，转子功率
global Dfim_Te  %DFIM 转子机械转矩
global Dfim_S Dfim_Edd Dfim_Eqq  %DFIM 转差 Edd Eqq 3个状态变量
global Dfim_Udr Dfim_Uqr Dfim_Uds Dfim_Uqs Dfim_Idr Dfim_Iqr Dfim_Iqs Dfim_Ids DfimV %DFIM定子和转子的电压、电流DQ轴分量 接入点电压
global EIds  EIqs EUqr EUdr EUqs EPs EGPs EIdr EIqr;
global DfimPline;
global DD_Edd0 DD_Eqq0 DD_S0 DD_Uqs0 DD_Idr0 DD_Ps0 DD_Iqr0

%DFIM PSS参数
global Dfim_PssNum; %DFIM总数
global Dfim_Pss;    %所有DFIM信息，存为矩阵
global DfimPIng   ;    
global DfimVIng   ;    %DFIM附加控制信息
global P_Dfim_Ref;%稳定计算中，各DFIM参考功率信息 
global V_Dfim_Ref;%稳定计算中，各DFIM参考电压信息
global EDfim_PssA;    
global EDfim_PssB;    
global EDfim_PssC;   
global EDfim_PssD;    
global EDfim_PssE;
global EDfim_PssF;%控制回路1中的六个中间的状态变量
global DEDfim_PssA0 %稳定计算中，EULA仿真计算中，预测环节中，EDfim_PssA变化率
global DEDfim_PssA1 %稳定计算中，EULA仿真计算中，校正环节中，EDfim_PssA变化率
global DEDfim_PssA %稳定计算中，EULA仿真计算中，预测环节中，EDfim_PssA变化率
global DEDfim_PssC0 %稳定计算中，EULA仿真计算中，预测环节中，EDfim_PssC变化率
global DEDfim_PssC1 %稳定计算中，EULA仿真计算中，校正环节中，EDfim_PssC变化率
global DEDfim_PssC %稳定计算中，EULA仿真计算中，预测环节中，EDfim_PssC变化率
global DEDfim_PssE0 %稳定计算中，EULA仿真计算中，预测环节中，EDfim_PssE变化率
global DEDfim_PssE1 %稳定计算中，EULA仿真计算中，校正环节中，EDfim_PssE变化率
global DEDfim_PssE %稳定计算中，EULA仿真计算中，预测环节中，EDfim_PssE变化率

%仿真数据；
global Fault;%整个故障信息
global FaultNum;%故障阶段数
global FaultSimuNum;%仿真期间各个故障阶段的步数区间
global T_Simulate_Num;  %仿真总步长；
global FP_dt%仿真步长
global T_Simulate %仿真总时间

global PronyMat;%保存Prony分析所需数组

global t; %仿真各个时刻；
global h; %仿真各个时刻步长；

global plot_now;
global plot_end;



%Wind data
global  Pr;
global  Vwind_c;
global  Vwind_r;
global  Vwind_f;
global  k1_Pwv; 
global  k2_Pwv;
global  Vwind_mean;
global  sigma_wind;
global  Pw_mean;
global  k0_WBL; 
global  c0_WBL; 
global  c_WBL;  
global  b_WBL;  
global  a_WBL;  
global  Fwbl_vf;
global  Fwbl_vc;
global  Fwbl_vr;
global  Fwbl1;  
global  Fwbl2;  
%Wind generator load flow calculation
global cosphi WndG_Flag WndG_BusNo WndGNum;
%Frequency domain analysis
global lambda_info
%Validate the sensitivity calculation
global SEigenK1 SEigenK2 SLA1 SLB1 SLC1 SLD1;
%the sensitivity calculation
global LA LB LC LD;
global V_lambda1 W_lambda1 V_lambda2 W_lambda2 SEigenKP SEigenKQ SEigenKV;
%Probabilistic Analysis
global lambda_in lambda_out lambda1 lambda2 relambdaleft relambdaright imlambdaleft imlambdaright;
global a_WBL b_WBL c_WBL;
%Monte Carlo Simulation
global random_Pw0 MntCrl_Cnt MntCrl_Flag MntCrl_BusNo MntCrl_Num MntCrl_lambda_re MntCrl_lambda_im random_U01 random_Pw0;
%from previous program
global wb w_dfigb s_dfigb D D_dfig M Mb M_dfig Pm Peref Pmb Pm_dfig0 Pm_dfig Tm_dfig0 KP KQ KPP KPI KQP KQI;
global Xt1 X1l Xl2 X2b Xsl Xt Xd Xq Xdp Xdb Xqb Xdbp rs rr Xs Xr Xm Xss Xrr Y;
global Vb0 Vs0 Vt0 Eqp0 Eqbp0 delta0 deltab0;
global rota rotab rota_dfig;
global Psl0 Qsl0 IDsl0 IQsl0 Ps0 Qs0 IDs0 IQs0 Pr30 Qr30 IDr30 IQr30 Pr20 Qr20 Pdc0 Pr0 Qr0 IDr0 IQr0 VDrr0 VQrr0 IDrr0 IQrr0;
global VDs0 VQs0 VDr0 VQr0 EDDp0 EQQp0 phiDs0 phiQs0 phiDr0 phiQr0 EDp0 EQp0;
global delta w s_dfig Pe Ps Pr3 Psl Vtx Vty V1x V1y Itd Itq Ibd Ibq I1lx I1ly Vlx Vly Islx Isly Il2x Il2y V2x V2y I2bx I2by Qr3 Vds Vqs Ids Iqs Idr3 Iqr3 dphidr dphiqr Vdr Vqr Vdrr Vqrr Vrr Eddp Eqqp Vs Iqrr Idrr;
global jay;
global DTAresult lambda_move lambda_nocontroller; 
global s_vector;
global xc S eAbFd rate SNR;

global   s_s;                  
global   s_Ep;                 
global   s_Is;                 
global   Ep_s;                
global   Ep_Ep;                
global   Ep_Is;                
global   Ep_Vdr;               
global   Ep_Vqr;               
global   Is_Ep;                
global   Is_Vs;                
global   Vdr_Vdrr;             
global   Vdr_Vqrr;             
global   Vdr_Vs;               
global   Vqr_Vdrr;             
global   Vqr_Vqrr;             
global   Vqr_Vs;               
global   Vdrr_s;               
global   Vdrr_Vs;              
global   Vdrr_Idrr;           
global   Vdrr_Iqrr;            
global   Vqrr_s;               
global   Vqrr_Vs;           
global   Vqrr_Idrr;           
global   Vqrr_Iqrr;          
global   Idrr_Vs;              
global   Idrr_Idsr;            
global   Iqrr_Iqsr;            
global   Idsr_Is;              
global   Idsr_Vs;              
global   Iqsr_Is;              
global   Iqsr_Vs;              
global    Ps_Vs;               
global    Ps_Is;               
global    Ir3_s;               
global    Ir3_Ps;  
global GV_gen0;




global StepNum_Simu Step_Length Step_Simu Step_Faultstart Step_Faultend FaultFlag FaultBusNo YFault
global B
global Ynet Inet
global Step_EPACend EPACFlag Step_PACend PACFlag
global StatVar StatVar0 Vsx Vsy Irx Iry Isx Isy VsG IsG PE QE VS IS PS QS

global V_PMU I_PMU

global Sgnum    

global jay;  jay=sqrt(-1);
global InFileNam; %文件名

global Delta Eqq Efd %2019-06-12 22:32

global PVG_Flag WndG_Flag VSG_Flag VSGNum GQm0 GQe0 GEQ0 Xf Lf;
VSG_Flag = 0;  % 关闭旧版独立的VSG模块
WndG_Flag = 0; % 关闭旧版风机模块
PVG_Flag = 0;  % 关闭旧版光伏模块

global Pt Tj D results AllStatVars;










