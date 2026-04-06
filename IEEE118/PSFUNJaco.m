function PSFunJaco;
% 得到夹克比矩阵

GlobalVar;

%***********************************************

%***********************************************************************************************

% Step 1: Network Jacobian and f(x)
J = zeros(2*BusNum, 2*BusNum); %Initialize Jacobi Matrix
J_H = zeros(BusNum,BusNum);
J_N = zeros(BusNum,BusNum);
J_J = zeros(BusNum,BusNum);
J_L = zeros(BusNum,BusNum);

for loop1 = 1:BusNum
for loop2 = 1:BusNum
	Vi = V_abs(loop1);
	Vj = V_abs(loop2);
	Aij = V_ang(loop1) - V_ang(loop2);
	Gij = real(Y(loop1, loop2));
	Bij = imag(Y(loop1, loop2));
	J_H(loop1, loop2) = -Vi * Vj * (Gij*sin(Aij) - Bij*cos(Aij));
    J_N(loop1, loop2) =	-Vi * Vj * (Gij*cos(Aij) + Bij*sin(Aij));
    J_J(loop1, loop2) = Vi * Vj * (Gij*cos(Aij) + Bij*sin(Aij));
	J_L(loop1, loop2) = -Vi * Vj * (Gij*sin(Aij) - Bij*cos(Aij));
end%loop1
end%loop2  Y矩阵是按照节点名中的节点顺序给定的  因此，母线节点输入必须与节点名输入的顺序保持一致

for loop = 1:BusNum
    Vi = V_abs(loop);
	Gii = real(Y(loop, loop));
	Bii = imag(Y(loop, loop));
	J_H(loop, loop) = Vi*Vi*Bii + Q_e(loop);
	J_N(loop, loop) = -Vi*Vi*Gii - P_e(loop);
	J_J(loop, loop) = Vi*Vi*Gii - P_e(loop);
	J_L(loop, loop) = Vi*Vi*Bii - Q_e(loop);
end%loop

J_H = P_Sel * J_H * P_Sel';

J_N = P_Sel * J_N ;
J_N = J_N * Q_Sel';

J_J = J_J * P_Sel';
J_J = Q_Sel * J_J ;

J_L = J_L* Q_Sel';
J_L = Q_Sel * J_L ;


J = [J_H J_N;
	 J_J J_L];
 