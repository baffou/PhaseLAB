function U = LaguerreGauss(z,rho_max,w0,N,lambda)
% z:        coordinate along the direction of propagation
% rho_max:  maximum radial coordinate along the x, or y, axis
% w0:       beam waist
% NxN:      number of pixels in the image
% lambda:   wavelength

x=linspace(-rho_max, rho_max, N);
[XX, YY]=meshgrid(x,x);
R2=XX.*XX+YY.*YY;

k = 2*pi/lambda;
ksi = 1 + 2*1i*z/(k*w0^2);

U = 1/ksi*exp(1i*k*z - R2/(w0^2*ksi));
