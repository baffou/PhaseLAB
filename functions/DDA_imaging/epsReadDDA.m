%% NPimaging package
% function that returns the complex value of the dielectric constant of a
% material as a function of the wavelength lambda0nm.
%
% fileName is the name of the file that contains a set of permittivies
% values (real and imag values) as a function of the energies in eV.

% authors: Guillaume Baffou
% affiliation: CNRS, Institut Fresnel
% date: Feb 10, 2020

function EPS = epsReadDDA(lambda0,fileName)

nMetal = dlmread(['n' fileName '.txt']);
Nl = length(lambda0);
EPS = zeros(Nl,1);

eV = nMetal(:,1);
n = nMetal(:,2);
k = nMetal(:,3);
factor = 1239.8419e-9;
eV0 = factor./lambda0;
eps = complex(n.^2-k.^2,2.0*n.*k);

for il = 1:Nl

    EPS1 = interp1(eV,real(eps),eV0(il));
    EPS2 = interp1(eV,imag(eps),eV0(il));
    EPS(il) = complex(EPS1,EPS2);

end     
      
      
