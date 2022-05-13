%% NPimaging package
% function that computes a nano-object polarizability from its image
% see Optica, Khadir et al. 2020

% authors: Guillaume Baffou
% affiliation: CNRS, Institut Fresnel
% date: Jul 31, 2019

% For the moment, works for a uniform medium n=nS. Uncertain for a
% non-uniform medium

function [alpha,NPprops] = alpha_Image(Image,z0)
ME = Image(1).Illumination.Medium;
Nim = length(Image);
alpha = zeros(Nim,1);
lambda0 = zeros(Nim,1);
k0 = zeros(Nim,1);

for iim = 1:Nim
    lambda0(iim) = Image(iim).lambda;
    k0(iim) = 2*pi/Image(iim).lambda;
    sqtT = sqrt(Image(iim).T);
    Ph = k0(iim)*Image(iim).OPD;
    expPh = exp(1i*Ph);
    alphaS = 1i*2*ME.n/k0(iim)*(1-sqtT.*expPh);

    alpha(iim) = sum(alphaS(:))*Image(iim).pxSize*Image(iim).pxSize;
end

if ME.n~=ME.nS && nargin==1
    warning('You should specify the Dipole''s z position for a 2-layer medium when calculating alpha using obj.alpha')
end

if ME.n==ME.nS && nargin==2
    warning('It is unnecessary to specify a dipole height if the medium is uniform')
end

if nargin==2
    if ME.n~=ME.nS
        r12 = (ME.n-ME.nS)/(ME.n+ME.nS);
        k0 = 2*pi/Image.Illumination.lambda;
        Gamma = r12*exp(-2*1i*ME.n*k0*z0);
        alpha0 = 32*pi*z0^3*(ME.nS^2+ME.n^2)/(ME.nS^2-ME.n^2);
        alpha = alpha./(1+Gamma+alpha/alpha0);
        fprintf('Gamma\talpha/alpha0\n')
        fprintf('%.3g\t%.3g\n',abs(Gamma),abs(alpha/alpha0))
    end
end

Cext = k0(:)/ME.nS.*imag(alpha(:));
Csca = k0(:).^4/(6*pi).*abs(alpha(:)).^2;
Cabs = Cext-Csca;
NPprops = NPprop(alpha,Cext,Csca,Cabs);


