function Ep = FullPoincarre(z,rho_max,w0,N,lambda,gamma)

U00 = LaguerreGauss(z,rho_max,w0,N,lambda);

%[gradX,gradY] = gradient(U00);
%U01 = w0/sqrt(2)*(gradX + 1i*gradY).*U00 *N/(rho_max*2);

U01 = sqrt(2)*(x+1i*y)/(w0*ksi).*U00;


Ep.x = cos(gamma)*U00;
Ep.y = sin(gamma)*U01;
