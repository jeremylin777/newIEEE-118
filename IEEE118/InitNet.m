function InitNet()
%对网络进行初始化；
%初始所得信息
GlobalVar;


V_abs  = Bus(:,2);
V_angle = Bus(:,3);
Pg = Bus(:,4);
Qg = Bus(:,5);
Pd = Bus(:,6);
Qd = Bus(:,7);

SlackBus = find(Bus(:,10) == 1);
for(loop=1:length(SlackBus))
    SlackGen(loop,1) = find(Mac(:,1) == SlackBus(loop) );
end
PqBus = find(Bus(:,10) == 3);
PvBus = find(Bus(:,10) == 2);
PqPvBus = find(Bus(:,10) > 1);
PqBusNum = length(PqBus);
PvBusNum = length(PvBus);
PqPvBusNum = length(PqPvBus);

BusType = Bus(:,10);

if(isempty(DBus))
    DBusNum = 0;
else
    DBusNum = length(DBus(:,1));
end

if(isempty(DLine))
    DLineNum = 0;
else
    DLineNum = length(DLine(:,1));
end

if(isempty(DCMD))
    DCMDNum = 0;
else
    DCMDNum = length(DCMD(:,1));
end

if(isempty(Mac))
   GenNum = 0;
else
  GenNum = length(Mac(:,1));  
  GenBus = Mac(:,1);
end
    
if(isempty(Exc))
    ExcNum = 0;
else
    ExcNum = length(Exc(:,1));
    ExcBus = Exc(:,1);
end
if(isempty(Pss))
    PssNum = 0;
else
    PssNum = length(Pss(:,1));
    PssBus = Pss(:,1);
end


if(isempty(Load))
    LoadNum = 0;
else
    LoadNum = length(Load(:,1));
    LoadBus = Load(:,1);
end


if(isempty(Svc))
    SvcNum = 0;
else
   SvcNum = length(Svc(:,1));
   SvcBus = Svc(:,1);
end

if(isempty(Stat))
    StatNum = 0;
else
   StatNum = length(Stat(:,1));
   StatBus = Stat(:,1);
end

% if(isempty(Tg))
%     TgNum = 0;
% else
%    TgNum = length(Tg(:,1));
%    TgBus = Tg(:,1);
% end

if(isempty(Tcsc))
    TcscNum = 0;
else
   TcscNum = length(Tcsc(:,1));
   TcscFromBus = Tcsc(:,1);
   TcscToBus = Tcsc(:,2);
end

if(isempty(Moto))
    MotoNum = 0;
else
   MotoNum = length(Moto(:,1));
   MotoBus = Moto(:,1);
end

if(isempty(Stbe))
    StbeNum = 0;
else
   StbeNum = length(Stbe(:,1));
   Stbe1Bus = Stbe(:,1);
   Stbe2Bus = Stbe(:,2);
end

if(isempty(Stbe_Pss))
    Stbe_PssNum = 0;
else
   Stbe_PssNum = length(Stbe_Pss(:,1));
end

if(isempty(Dfim))
    DfimNum = 0;
else
   DfimNum = length(Dfim(:,1));
end

if(isempty(Dfim_Pss))
    Dfim_PssNum = 0;
else
   Dfim_PssNum = length(Dfim_Pss(:,1));
end



if(isempty(Fault))
    FaultNum = 0;   %故障阶段数目
else
   FaultNum = length(Fault(:,3));
end
