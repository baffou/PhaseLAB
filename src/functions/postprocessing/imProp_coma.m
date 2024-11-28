function [imagetot, Ph, T]=imProp_coma(image,pxSize,lambda,z,opt)
% function that propagates a scalar E field; non uniformly over the field
% of view, according to a parabolic pattern

% this function does not work properly, the theory should be wrong

arguments
    image
    pxSize    % pixel size [m]
    lambda    % wavelength
    z         % defocus

    opt.n = 1 % refractive index of the propagation medium

    opt.coma = 0
end

[Ny,Nx] = size(image);
if nargout >= 2
    Ph = zeros(Ny,Nx);
end
Fimage = fftshift(fft2(image));

%L=2*pi/(2*G.N*G.pxSize);

[xx,yy] = meshgrid(-Nx/2:Nx/2-1,-Ny/2:Ny/2-1);

kx = xx*2*pi/(Nx*pxSize);
ky = yy*2*pi/(Ny*pxSize);

r2 = opt.coma * (xx.^2 + yy.^2) * pxSize^2;

k0 = 2*opt.n*pi/lambda;
kz = real(sqrt(k0^2-kx.^2-ky.^2));
% real part, otherwise, if one spans over kx values that exceed k0,
% it yields complex values of kz. When defocusing in one direction,
% it is not a problem because it gives evanescent waves, but when
% defocusing in the other direction, it yields divergences,
% even if the image Fimage has no information in this frequency range.


%%


order = 10;
imagetot = image;
for ii = 1:order
    Prop = (1i*kz*z).^ii /factorial(ii);
    Fimagez = Fimage.*Prop;
    image = ifft2(ifftshift(Fimagez));
    imagetot = imagetot + r2.^ii.*image;
end


T = abs(imagetot).^2;
if nargout >= 2
    Ph = Unwrap_TIE_DCT_Iter(angle(imagetot));
end




