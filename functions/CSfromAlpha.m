function OptProp = CSfromAlpha(alpha,lambda,n_ext)

k0=2*pi./lambda;

Cext=k0/n_ext.*imag(alpha);
Csca=k0.^4/(6*pi).*abs(alpha).^2;
Cabs=Cext-Csca;
OptProp=NPprop(alpha,Cext,Csca,Cabs);






