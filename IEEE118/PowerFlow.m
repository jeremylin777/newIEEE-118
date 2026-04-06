function PowerFlow()
%潮流计算

GlobalVar;

if(DBusNum ~= 0) %含有直流的的潮流计算，需要迭代加迭代
    
    for(loop = 1: DLineNum)
        BusNo1 = DLine(loop,1);
        BusNo2 = DLine(loop,2) ;
        RDline = DLine(loop,3);
        for(temp=1:DBusNum)
            if(DBus(temp) == BusNo1);
                DLine(loop,4) = temp;%记录线路首端所在直流母线位置
            end
            if(DBus(temp) == BusNo2);
                DLine(loop,7) = temp;%记录线路末所在直流母线位置
            end
        end
        if(DBus(DLine(loop,4),7) ~= 0)
           DLine(loop,5) = 1; %记录线路首端所在直流母线的控制方式：定电流
           DLine(loop,6) = DBus(DLine(loop,4),7);%定电流值
        end
        if(DBus(DLine(loop,4),8) ~= 0)
           DLine(loop,5) = 2; %记录线路首端所在直流母线的控制方式：定功率
           DLine(loop,6) = DBus(DLine(loop,4),8);%定功率值
        end
        if(DBus(DLine(loop,7),9) ~= 0)
           DLine(loop,8) = 1; %记录线路末端所在直流母线的控制方式：定电压
           DLine(loop,9) = DBus(DLine(loop,7),9);%定电压值
        end
        if(DBus(DLine(loop,7),10) ~= 0)
           DLine(loop,8) = 2; %记录线路首端所在直流母线的控制方式：定逆变角
           DLine(loop,9) = DBus(DLine(loop,7),10);%定逆变角值
        end
        
        DLine(loop,10) = Bus(BusNo1,2);
        DLine(loop,11) = Bus(BusNo2,2);        
        DBusV0(1,2*loop-1) = DLine(loop,10);%迭代假设的首端初始电压；
        DBusV0(1,2*loop) = DLine(loop,11);%迭代假设的末端初始电压；
    end
    
    Bustemp = Bus;
    options = optimset('Display', 'iter', 'LargeScale', 'off');
    DBusV = fsolve(@CalDPowerFlow,DBusV0,options);
    OutPut;
    
    BusDCNoLoad = Bus;%BUS中直流作为负荷加入；而BusDCNoLoad中直流没有作为负荷加入，为了后面暂态计算的需要。
    
    for(loop = 1: DLineNum)
        DBusNo1Pos = DLine(loop,4);
        DBusNo1 = DBus(DBusNo1Pos,1);
        DBus(DBusNo1Pos,16) = Bus(DBusNo1,2);
        DBus(DBusNo1Pos,17) = Bus(DBusNo1,3);
        DBus(DBusNo1Pos,18) = Bus(DBusNo1,6);
        DBus(DBusNo1Pos,19) = Bus(DBusNo1,7);
      
        DBusNo2Pos = DLine(loop,7);
        DBusNo2 = DBus(DBusNo2Pos,1);
        DBus(DBusNo2Pos,16) = Bus(DBusNo2,2);
        DBus(DBusNo2Pos,17) = Bus(DBusNo2,3);
        DBus(DBusNo2Pos,18) = Bus(DBusNo2,6);
        DBus(DBusNo2Pos,19) = Bus(DBusNo2,7);
        
      
        BusDCNoLoad(DBusNo1,6) = Bustemp(DBusNo1,6);
        BusDCNoLoad(DBusNo1,7) = Bustemp(DBusNo1,7);
      
        BusDCNoLoad(DBusNo2,6) = Bustemp(DBusNo2,6);
        BusDCNoLoad(DBusNo2,7) = Bustemp(DBusNo2,7);
    end
    
else%正常潮流计算
       PowerFlowSub;
       OutPut;
         
end%if

% disp('潮流迭代次数 = ');      disp(PowerFlowIterNum);


