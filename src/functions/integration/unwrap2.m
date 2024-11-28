
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2D phase Unwrapping algorithm based on a manuscript entitled "Robust 2D phase unwrapping algorithm based on the transport of intensity equation",which was submitted to Measurement Science and Technology(MST).
% Inputs:
%   * phase_wrap: wrapped phase from -pi to pi
% Output:
%   * phase_unwrap: unwrapped phase
%   * N: number of iterations
% Author:Zixin Zhao (Xi'an Jiaotong University, 08-15-2018)
% Email:zixinzhao@xjtu.edu.cn
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [phase_unwrap,N]=Unwrap_TIE_DCT_Iter(phase_wrap)
phi1 = unwrap_TIE(phase_wrap);
phi1=phi1+mean2(phase_wrap)-mean2(phi1); %adjust piston
K1=round((phi1-phase_wrap)/2/pi);  %calculate integer K
phase_unwrap=phase_wrap+2*K1*pi;
residue=wrapToPi(phase_unwrap-phi1);
phi1=phi1+unwrap_TIE(residue);
phi1=phi1+mean2(phase_wrap)-mean2(phi1); %adjust piston
K2=round((phi1-phase_wrap)/2/pi);  %calculate integer K
phase_unwrap=phase_wrap+2*K2*pi;
residue=wrapToPi(phase_unwrap-phi1);
N=0;
while sum(sum(abs(K2-K1)))>0
    K1=K2;
    phic=unwrap_TIE(residue);
    phi1=phi1+phic;
    phi1=phi1+mean2(phase_wrap)-mean2(phi1); %adjust piston
    K2=round((phi1-phase_wrap)/2/pi);  %calculate integer K
    phase_unwrap=phase_wrap+2*K2*pi;
    residue=wrapToPi(phase_unwrap-phi1);
    N=N+1;
end
end
function [phase_unwrap]=unwrap_TIE(phase_wrap)
psi=exp(1i*phase_wrap);
edx = [zeros([size(psi,1),1]), wrapToPi(diff(psi, 1, 2)), zeros([size(psi,1),1])];
edy = [zeros([1,size(psi,2)]); wrapToPi(diff(psi, 1, 1)); zeros([1,size(psi,2)])];
lap = diff(edx, 1, 2) + diff(edy, 1, 1); %calculate Laplacian using the finite difference
rho=imag(conj(psi).*lap);   % calculate right hand side of Eq.(4) in the manuscript
phase_unwrap = solvePoisson(rho);
end
function phi = solvePoisson(rho)
% solve the poisson equation using DCT
dctRho = dct2(rho);
[N, M] = size(rho);
[I, J] = meshgrid([0:M-1], [0:N-1]);
dctPhi = dctRho ./ 2 ./ (cos(pi*I/M) + cos(pi*J/N) - 2);
dctPhi(1,1) = 0; % handling the inf/nan value
% now invert to get the result
phi = idct2(dctPhi);
end
