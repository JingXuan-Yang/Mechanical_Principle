
% Dynamic statics analysis
% date: 2018/6/26
% designer: XuanYuan_huan

clc
clear

d = 0.001;               %unit coefficient

L_AB = 100.62*d;
L_AC = 360.0*d;
L_CD = 590.35*d;
L_DE = 159.40*d;
L = 578.59*d;            %vertical distance between C and E

Ls3 = L_CD/2;
Ls4 = L_DE/2;

m3 = 20;
m4 = 5;
m5 = 80;

F = -4000;

Js3 = 1.2;
Js4 = 0;
Js5 = 0;

theta = 32.46; %limit position angle
k = 180 + floor(theta);
nr = 52;                 %r/min
omega_AB = 2*pi*nr/60;   %rad/s
alpha_AB = 0;
dr = pi/180;            %ratio of deg. to rad.

Ax = 0; Ay = L_AC; Adx = 0; Ady = 0; Addx = 0; Addy = 0;
Cx = 0; Cy = 0; Cdx = 0; Cdy = 0; Cddx = 0; Cddy = 0;
Kx = 0; Ky = L; Kdx = 0; Kdy = 0; Kddx = 0; Kddy = 0;

%angle of DE
phi = 0; dphi =0; ddphi =0;

%rad. to deg.
rd = 180/pi;
deg = 0:1:360;
m = length(deg);

%initialize matrices
theta_AB = ones(m,1);
theta_BC = ones(m,1);s_BC = ones(m,1);
Bx = ones(m,1);By = ones(m,1);Bdx = ones(m,1);Bdy = ones(m,1);Bddx = ones(m,1); Bddy = ones(m,1);
Dx = ones(m,1);Dy = ones(m,1);Ddx = ones(m,1);Ddy = ones(m,1);Dddx = ones(m,1); Dddy = ones(m,1);
Ex = ones(m,1);Ey = ones(m,1);Edx = ones(m,1);Edy = ones(m,1);Eddx = ones(m,1); Eddy = ones(m,1);

Frxd = ones(m,1);Fryd = ones(m,1);Frxe = ones(m,1);Frye = ones(m,1);
Fre = ones(m,1);Mre = ones(m,1);Mc = ones(m,1);
Frxc = ones(m,1);Fryc = ones(m,1);

for n = 1:m
    
   theta_AB(n) = deg(n)*dr;
   
   if n > k
       F = 0; %return stroke, F = 0
   end
   
   %--------------------------------------------------------
   %----------------kinematics analysis---------------------
   %--------------------------------------------------------
   
   % A->B
   [Bx(n),By(n),Bdx(n),Bdy(n),Bddx(n),Bddy(n)] =...
       RR(Ax,Ay,Adx,Ady,Addx,Addy,theta_AB(n),omega_AB,alpha_AB,L_AB);
   
   %B,C->D
   [~,~,~,~,~,~,Dx(n),Dy(n),Ddx(n),Ddy(n),Dddx(n),Dddy(n),theta_CD,omega_CD,alpha_CD,s_B,v_B,a_B] =...
       RPR(Bx(n),By(n),Bdx(n),Bdy(n),Bddx(n),Bddy(n),Cx,Cy,Cdx,Cdy,Cddx,Cddy,0,0,L_CD);
   
   %D->E
   [~,~,~,~,~,~,Ex(n),Ey(n),Edx(n),Edy(n),Eddx(n),Eddy(n),theta_DE,omega_DE,alpha_DE,s_E,v_E,a_E] =...
        RRP(Dx(n),Dy(n),Ddx(n),Ddy(n),Dddx(n),Dddy(n),Kx,Ky,Kdx,Kdy,Kddx,Kddy,phi,dphi,ddphi,L_DE,0);

   %angle of BC and length of L_BC
   theta_BC(n) = theta_CD;
   s_BC(n) = s_B;
   
   %--------------------------------------------------------
   %-----------dyanmic statics analysis---------------------
   %--------------------------------------------------------
   
   %link 3 centroid
   [xs3,ys3,dxs3,dys3,ddxs3,ddys3] = RR(Cx,Cy,Cdx,Cdy,Cddx,Cddy,theta_CD,omega_CD,alpha_CD,Ls3);
   
   %link 4
   %mass is zero
   [xs4,ys4,dxs4,dys4,ddxs4,ddys4] = ...
       RR(Dx(n),Dy(n),Ddx(n),Ddy(n),Dddx(n),Dddy(n),theta_DE,omega_DE,alpha_DE,Ls4);
   
   %D,E reaction force
   [Frxd(n),Fryd(n),Frxe(n),Frye(n),Fre(n),Mre(n)] = fRRP2(Dx(n),Dy(n),Ex(n),Ey(n),xs4,ys4,Ex(n),...
    Ey(n),ddxs4,ddys4,Eddx(n),Eddy(n),alpha_DE,0,m4,m5,Js4,0,0,0,F,0,-F*50*d);
   
   %D->C
   [Mc(n),Frxc(n),Fryc(n)] = ...
       fcrank(Cx,Cy,Dx(n),Dy(n),xs3,ys3,ddxs3,ddys3,alpha_CD,m3,Js3,Frxd(n),Fryd(n),0,0,0);
   
end

fprintf('Results \n'); 
fprintf('Frxa\t\tFrya\tFrxb\t\tFryb\t\tFrxc\tFryc\t\tMb\n');

for n = 1:m
    
    fprintf( '%8.2f %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f\n',Frxc(n),Fryc(n),Frxd(n),Fryd(n),Frxe(n),Frye(n),Mc(n));
    
end

% length and angle of BC
figure(1)
plot(deg, s_BC,'r');
legend('s');
title('Length of BC');
xlabel('\theta_{AB}/\circ');
ylabel('BC/m');

figure(2)
subplot(2,2,1);
plot(deg,Frxe, 'b',deg,Frye, 'r');
legend('Frxe','Frye');
title('Reaction of E');
xlabel('\theta_{AB}/\circ')
ylabel('F/N')
grid on; hold on;

subplot(2,2,2);
plot(deg,Frxd, 'b',deg,Fryd, 'r');
legend('Frxd','Fryd');
title('Reaction of D');
xlabel('\theta_{AB}/\circ')
ylabel('F/N')
grid on; hold on;

subplot(2,2,3);
plot(deg,Frxc, 'b',deg,Fryc, 'r');
legend('Frxc','Fryc');
title('Reaction of C');
xlabel('\theta_{AB}/\circ')
ylabel('F/N')
grid on; hold on;

subplot(2,2,4);
plot(deg,Mc, 'b');
legend('Driving moment');
title('Driving Moment');
xlabel('\theta_{AB}/\circ')
ylabel('M/(N\cdotm)')
grid on; hold on;

figure(3)
plot(deg,Mre,'g');
title('Reaction moment of E');
