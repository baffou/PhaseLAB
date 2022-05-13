%% NPimaging package
% function that computes a nano-object polarizability from its image. To be
% used more specifically with experimental images, where a cropping area
% has to be selected.

% authors: Guillaume Baffou
% affiliation: CNRS, Institut Fresnel
% date: Aug 18, 2019

% For the moment, works for a uniform medium n=nS. Uncertain for a
% non-uniform medium

function alpha = alpha_Image_crop(Image,ME)
[Ny,Nx] = size(Image.T);

close all

Image.figure()

n = 0;
alpha = 0;
while(1)

    fprintf('Clich on 3 points: the particle position, and the integration radii r1, r2.\n')

    [x0,y0,button] = ginput(1);
    if button == 1 
        [x,y] = ginput(2);

        k0 = 2*pi/Image.lambda;

        [I,J] = ndgrid(1:Ny,1:Nx);
        ic = y0;
        jc = x0;
        r1 = sqrt((x(1)-x0)^2+(y(1)-y0)^2);
        r2 = sqrt((x(2)-x0)^2+(y(2)-y0)^2);
        M1 = double((I-ic).^2+(J-jc).^2<=r1^2);
        M2 = double(((I-ic).^2+(J-jc).^2<=r2^2));
        Mbk = M2-M1;

        Nbk = sum(Mbk(:));
        bkgT   = sum(sum(Image.T  .*Mbk))/Nbk;
        bkgOPD = sum(sum(Image.OPD.*Mbk))/Nbk;
        cmpImage = 1-sqrt(Image.T/bkgT).*exp(1i*k0*(Image.OPD-bkgOPD));

        elt = sum(sum(cmpImage.*M1));

        %alpha = 1i*2*ME.n/(k0*(1+r12*exp(-2*1i*ME.n*k0*z0)))*elt*Image.pxSize*Image.pxSize;
        n = n+1;
        alpha(n) = 1i*2*ME.n/k0*elt*Image.pxSize*Image.pxSize;
        fprintf('%4.2e + i*%4.2e\n',real(alpha(n)),imag(alpha(n)))
    else
        break
    end

end

alpha = alpha.'

