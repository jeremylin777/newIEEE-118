
function [Vd,Vq,Id,Iq] = XY_DQ(V,Ig,Delta)
V_angle = angle(V);
V_abs = abs(V);
Vx = V_abs*cos(V_angle);
Vy = V_abs*sin(V_angle);
Ig_angle = angle(Ig);
Ig_abs = abs(Ig);
Igx = Ig_abs*cos(Ig_angle);
Igy = Ig_abs*sin(Ig_angle);

T = [sin(Delta)   -cos(Delta)
     cos(Delta)  sin(Delta)
    ];
    
Vdq = T * [Vx;Vy];
Idq = T * [Igx;Igy];
Vd = Vdq(1);
Vq = Vdq(2);
Id = Idq(1);
Iq = Idq(2);