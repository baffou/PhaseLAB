function sigma=sigmaTheo(Z,Lambda,d,w,Nim,Npx,NA,M)
d=abs(d);
if nargin==6
    sigma=Z.*Lambda./d .* sqrt(2./(Nim.*w)) .* sqrt(log10(Npx.*Npx))*0.57835e-6;
else
    NA0=sin(atan(1.22*Lambda*M/(4*d)));
    fracNA=3.5379e-9*NA./(NA0-NA);
    sigma=(Z.*Lambda./d*0.57835e-6 + fracNA) .* sqrt(2./(Nim.*w)) .* sqrt(log10(Npx.*Npx));

end


