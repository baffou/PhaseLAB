function W = intgrad_CPM(DWx,DWy)

%superDWx0 = [ DWx, DWx(:,size(DWx,2):-1:1) ];
%superDWx = [ superDWx0; superDWx0(size(DWy,1):-1:1,:) ];
%superDWy0 = [ DWy, DWy(:,size(DWx,2):-1:1) ];
%superDWy = [ superDWy0; superDWy0(size(DWy,1):-1:1,:) ];

superDWx = DWx;
superDWy = DWy;

[Ny, Nx] = size(superDWx);
[kx, ky] = meshgrid(1:Nx,1:Ny);
kx = kx-Nx/2-1;
ky = ky-Ny/2-1;
kx(logical((kx==0).*(ky==0)))=Inf;
ky(logical((kx==0).*(ky==0)))=Inf;

%kx(Ny/2,Nx/2)=Inf;
%ky(Ny/2,Nx/2)=Inf;

superW = ifft2(ifftshift((fftshift(fft2(superDWx)) + 1i*fftshift(fft2(superDWy)))./(1i*(kx/Nx + 1i*ky/Ny))));

%W = abs(superW(1:Ny/2, 1:Nx/2))/2; % Don't know why there is this factor of 2.

W=real(superW/2);

% figure
% subplot(2,3,1)
% imagegb(abs(kx + 1i*ky))
% title('abs k')
% subplot(2,3,4)
% imagegb(angle(kx + 1i*ky))
% title('angle k')
% subplot(2,3,2)
% imagegb(abs(fftshift(fft2(superDWx))))
% title('abs denom')
% subplot(2,3,5)
% imagegb(abs(fftshift(fft2(superDWx))))
% title('angle denom')
% 

end