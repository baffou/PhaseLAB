function [image2, Ph, T]=imProp(image,pxSize,lambda,z,opt)
% function that propagates a scalar E field over a distance z
arguments
    image
    pxSize    % pixel size [m]
    lambda    % wavelength
    z         % defocus

    opt.n = 1 % refractive index of the propagation medium

    opt.dx = 0 % dx and dy shift the phase of the image by dx and dy pixels
    opt.dy = 0 %  (not necessarily integers)
end

Nz = length(z);
[Ny,Nx] = size(image);
image2 = zeros(Ny,Nx,Nz);
if nargout >= 2
    Ph = zeros(Ny,Nx,Nz);
end
Fimage = fftshift(fft2(image));

%L=2*pi/(2*G.N*G.pxSize);

[xx,yy] = meshgrid(-Nx/2:Nx/2-1,-Ny/2:Ny/2-1);

kx = xx*2*pi/(Nx*pxSize);
ky = yy*2*pi/(Ny*pxSize);

k0 = 2*opt.n*pi/lambda;
kz = real(sqrt(k0^2-kx.^2-ky.^2));
        % real part, otherwise, if one spans over kx values that exceed k0,
        % it yields complex values of kz. When defocusing in one direction,
        % it is not a problem because it gives evanescent waves, but when
        % defocusing in the other direction, it yields divergences,
        % even if the image Fimage has no information in this frequency range.

for iz = 1:Nz
    Prop = exp(1i*kz*z(iz)) .* exp(1i*kx*opt.dx*pxSize) .* exp(1i*ky*opt.dy*pxSize);
    Fimagez = Fimage.*Prop;
    image2(:,:,iz) = ifft2(ifftshift(Fimagez));
    T = abs(image2(:,:,iz)).^2;
    if nargout >= 2
        Ph(:,:,iz) = Unwrap_TIE_DCT_Iter(angle(image2(:,:,iz)));
    end
end




