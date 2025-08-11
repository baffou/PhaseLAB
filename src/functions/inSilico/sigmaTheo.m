function sigma=sigmaTheo(Z,Gamma,d,w,Nim,Npx,NA,M)
d=abs(d);
if nargin==6
    sigma=Z.*Gamma./d .* sqrt(2./(Nim.*w)) .* sqrt(log10(Npx.*Npx))*0.57835e-6;
else
    NA0=sin(atan(1.22*Gamma*M/(4*d)));
    fracNA=3.5379e-9*NA./(NA0-NA);
    sigma=(Z.*Gamma./d*0.57835e-6 + fracNA) .* sqrt(2./(Nim.*w)) .* sqrt(log10(Npx.*Npx));

end


