%% NPimaging package
% SCATTERING BY A SPHERICAL GOLD NANOPARTICLE USING MIE THEORY

% author: Guillaume Baffou
% affiliation: CNRS, Institut Fresnel
% date: Aug 3, 2019


function prop = MieTheory(DIlist)
% DI: Dipole object
% returns a structure with the properties alpha, Cext, Csca, Cabs.    
if ~isa(DIlist,'Dipole')
    error('The MieTheory applies for Dipole objects')
end

N = numel(DIlist); % number of dipoles

prop = repmat(NPprop(),N,1);

for io = 1:N
    DI = DIlist(io);
    lambda = DI.lambda;
    r0 = DI.r;
    n_ext = DI.n_ext;
    n_DI = DI.n;
    m = n_DI/n_ext;
    k = 2*pi*n_ext/lambda;
    x = k*r0;
    z = m*x;
    N = round(2+x+4*x.^(1/3));

    % computation

    j = (1:N);

    sqr = sqrt(pi*x/2);
    sqrm = sqrt(pi*z/2);

    phi = sqr.*besselj(j+0.5,x);
    xi = sqr.*(besselj(j+0.5,x)+1i*bessely(j+0.5,x));
    phim = sqrm.*besselj(j+0.5,z);

    phi1 = [sin(x), phi(1:N-1)];

    phi1m = [sin(z), phim(1:N-1)];
    y = sqr*bessely(j+0.5,x);

    y1 = [-cos(x), y(1:N-1)];

    phip = (phi1-j/x.*phi);
    phimp = (phi1m-j/z.*phim);
    xip = (phi1+1i*y1)-j/x.*(phi+1i*y);

    aj = (m*phim.*phip-phi.*phimp)./(m*phim.*xip-xi.*phimp);
    bj = (phim.*phip-m*phi.*phimp)./(phim.*xip-m*xi.*phimp);

    Csca = sum( (2*j+1).*(abs(aj).*abs(aj)+abs(bj).*abs(bj)) );
    Cext = sum( (2*j+1).*real(aj+bj) );    

    Cext = Cext*2*pi/(k*k);
    Csca = Csca*2*pi/(k*k);
    Cabs = Cext-Csca;

    alpha = 1i*6*pi*n_ext*n_ext*aj(1)/(k*k*k);

    prop(io) = NPprop(alpha,Cext,Csca,Cabs);

end

    
    
    
    
