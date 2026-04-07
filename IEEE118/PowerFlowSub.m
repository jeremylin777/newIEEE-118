function PowerFlowSub()
%潮流计算子函数,实现潮流计算主功能;;

GlobalVar;
PowerFlowIterNumMax = 20;
PowerFlowIterNum = 0;
Acc = 1.0;
V_abs = Bus(:,2);
V_ang = Bus(:,3);
P_G = Bus(:,4);
Q_G = Bus(:,5);
P_D = Bus(:,6);
Q_D = Bus(:,7);


P_Sel = zeros( (PqBusNum+PvBusNum) ,BusNum);
Q_Sel = zeros( PqBusNum ,BusNum);

il = length(PqPvBus);
ii = [1:1:il]';
for(loop =1:length(PqPvBus))
    P_Sel(ii(loop),PqPvBus(loop)) = 1;
end

il = length(PqBus);
ii = [1:1:il]';
for(loop =1:length(PqBus))
    Q_Sel(ii(loop),PqBus(loop)) = 1;
end


jay = sqrt(-1);
V_Comp = V_abs.*exp(jay*V_ang);
% bus current injection
I_Comp = Y * V_Comp;
% power output based on voltages 
S = V_Comp.*conj(I_Comp);
P_e = real(S); 
Q_e = imag(S);
        
DelP = P_G - P_D - P_e;
DelQ = Q_G - Q_D - Q_e;
DelP_Sel = P_Sel * DelP;
DelQ_Sel = Q_Sel * DelQ;
        
        
ff = 1;%功率误差最大值；
while((ff >= 10^-10) &&(PowerFlowIterNum<PowerFlowIterNumMax))
                
        PSFUNJaco;
        
        DelS_Sel = [DelP_Sel ; DelQ_Sel];
        % solve for voltage magnitude and phase angle increments
        temp = J \ DelS_Sel;
        % expand solution vectors to all buses
        temp1 = temp(1:(PqPvBusNum));
        Del_Vang = P_Sel' * temp1;
        temp2 = temp((PqPvBusNum)+1:length(temp));
        Del_Vabs = Q_Sel' * temp2;
        % update voltage magnitude and phase angle
        V_abs = V_abs - Acc*(Del_Vabs.*V_abs);
        V_ang = V_ang - Acc*Del_Vang;
        %  total mismatch
        
        V_Comp = V_abs.*exp(jay*V_ang);
        % bus current injection
        I_Comp = Y * V_Comp;
        % power output based on voltages 
        S = V_Comp.*conj(I_Comp);
        P_e = real(S); 
        Q_e = imag(S);
        
        DelP = P_G - P_D - P_e;
        DelQ = Q_G - Q_D - Q_e;
        DelP_Sel = P_Sel * DelP;
        DelQ_Sel = Q_Sel * DelQ;
        
%         % check if Qg is outside limits
%         Q_g(GenBus,1) = Q_e(GenBus) + Q_D(GenBus);
%         Lim_Flag = CheckQ_Lim(Q_g);
%         if Lim_Flag == 1; 
%          disp('Qg at var limit');
%         end

        
        [pmis,ip]=max(abs(DelP_Sel));
        [qmis,iq]=max(abs(DelQ_Sel));
        if(isempty(DelP_Sel) == 1)
            pmis = 0;
        end
        if(isempty(DelQ_Sel) == 1)
            qmis = 0;
        end
        ff = max(abs(pmis),abs(qmis)); 
        PowerFlowIterNum = PowerFlowIterNum + 1;
end

if(PowerFlowIterNum == PowerFlowIterNumMax)
   error('潮流迭代不收敛！！！！');
end