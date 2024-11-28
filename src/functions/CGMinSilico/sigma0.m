function [sigma,NA0]=sigma0(Z,Lambda,p,d,w,Nim,Npx,NA,M)

d=abs(d);
if nargin==7
    sigma=p.*Lambda./(d.*Z) .* sqrt(2./(Nim.*w)) .* sqrt(log10(Npx.*Npx))/(8*sqrt(2));
%    sigma=Z.*Lambda./d .* sqrt(2./(Nim.*w)) .* sqrt(log10(Npx.*Npx))*0.58e-6;
else
    M=abs(M);
    NA0=sin(atan(1.22*Lambda*M/(4*d)));
    fracNA=3.5379e-9*NA./(NA0-NA);
    sigma=(Lambda./(d.*Z)*p/(8*sqrt(2)) + fracNA) .* sqrt(2./(Nim.*w)) .* sqrt(log10(Npx.*Npx));
%    sigma=(Z.*Lambda./d*0.58e-6 + fracNA) .* sqrt(2./(Nim.*w)) .* sqrt(log10(Npx.*Npx));

end