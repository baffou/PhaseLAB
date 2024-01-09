%% NPimaging package
% function that returns the complex value of the complex refractive index
% of a material as a function of the wavelength lambda0nm.
%
% fileName is the name of the file that contains a set of permittivies
% values (real and imag values) as a function of the energies in eV.

% authors: Guillaume Baffou
% affiliation: CNRS, Institut Fresnel
% date: Feb 10, 2020

function index = indexRead(lambda0,fileName)

nMetal = dlmread(['n' fileName '.txt']);
Nl = length(lambda0);
index = zeros(Nl,1);

eV = nMetal(:,1);
n = nMetal(:,2);
k = nMetal(:,3);
factor = 1239.8419e-9;
eV0 = factor./lambda0;


for il = 1:Nl

    n1 = interp1(eV,n,eV0(il));
    n2 = interp1(eV,k,eV0(il));
    index(il) = complex(n1,n2);
    
end  
