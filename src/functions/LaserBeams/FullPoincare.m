function Ep = FullPoincare(z,rho_max,w0,N,lambda,gamma)

U00 = LaguerreGauss(z,rho_max,w0,N,lambda);

%[gradX,gradY] = gradient(U00);
%U01 = w0/sqrt(2)*(gradX + 1i*gradY).*U00 *N/(rho_max*2);

x=linspace(-rho_max, rho_max, N);
[XX, YY]=meshgrid(x,x);

k = 2*pi/lambda;
ksi = 1 + 2*1i*z/(k*w0^2);

U01 = sqrt(2)*(XX+1i*YY)/(w0*ksi).*U00;

Ep.x = cos(gamma)*U00;
Ep.y = sin(gamma)*U01;
Ep.XX=sqrt(2)*(XX+1i*YY)/(w0*ksi);
Ep.YY=U00;


