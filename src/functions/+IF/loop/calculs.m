figure
imagegb(log(abs(imgaussfilt(IM(1).FT,4))))
[x,y]=ginput(1);
dx=x-(IM(1).Nx/2+1);
dy=y-(IM(1).Ny/2+1);
Rpx=sqrt(dx*dx+dy*dy);

dk = 2*pi/(IM(1).dxSize*IM(1).Nx);

kmin=0
kmax= 2*pi/(IM(1).dxSize*2*IM(1).Nx)*IM(1).Nx;
kmin= 2*pi/(IM(1).dxSize*2*IM(1).Nx);

% pour une image à 2x2 pixels
f0 = 2*pi/dx*0 /2;
f1 = 2*pi/dx*1 /2;
% pour une image à 4x4 pixels
f0 =-1 * 2*pi/dx /4;
f1 = 0 * 2*pi/dx /4;
f0 = 1 * 2*pi/dx /4;
f1 = 2 * 2*pi/dx /4;
% ce qui confirme cette expression :
dk = 2*pi/(IM(1).dxSize*IM(1).Nx);


kx=Rpx*dk
lambda=632.8e-9
k0=2*pi/lambda

% (1)
sintheta=kx/k0

n_glass=1.5
M=abs(IM(1).Microscope.M)
% the spot brillant doit être à NA = 0.5 et le disque à 0.9

% l'ouverture numérique est concervée à la traversée d'interfaces planes,
% mais quand il y a des lentilles et des surfaces incurvées, ce n'est plus
% le cas; Quand il y a un système de grandissement donné, les grandissement
% s'applique au tan(theta)

tan(theta_image) = tan(theta_glass)/M = tan(asin(sin(theta_inc)/n_glass))/M
tan(theta_image) = tan(asin(sin(theta_inc)/n_glass))/M

NAmax = sin(theta_image)

theta_inc=30;
% (2)
NAmax = tan(asin(sind(theta_inc)/n_glass))/M

% (1) et (2) donnent la même chose !
0.003580212333246


%%
figure
ax1=subplot(1,2,1)
imagegb(log(abs(IM(1).FT)))
ax2=subplot(1,2,2)
imagegb(angle(mask))
linkaxes([ax1,ax2])
