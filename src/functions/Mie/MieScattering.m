function Output  =  MieScattering(lambda,radius,n_m,mat)
%% SCATTERING BY A SPHERICAL NANOPARTICLE USING MIE THEORY
% inputs

% lambda    wavelength in [m], possibly an array
% r         radius of the particle in [m], possibly an array
% n_m       optical index of the surrounding medium
% mat       material, in the form 'Au', 'BK7', 'Mg'. Around 40 materials available.
%             The whole list is in src/spec/materials

% Output is a structure

%Output.Qext  Nlambda x Nradius
%Output.Qsca  Nlambda x Nradius
%Output.Qabs  Nlambda x Nradius

%% parameters

Nl = length(lambda);
Nr = length(radius);

Output.Qext = zeros(Nl,Nr);
Output.Qsca = zeros(Nl,Nr);
Output.Qabs = zeros(Nl,Nr);

for il = 1:Nl
    lambda0 = lambda(il) ;
    for ir = 1:Nr
        r0 = radius(ir);
        if lambda0<0.1
            lambda0 = lambda0*1e9;
        end
        
        if r0<0.1
            r0 = r0*1e9;
        end
        
        if nargin == 3
            n_Au = indexRead('Au',lambda0);
        elseif nargin == 4
            n_Au = indexRead(mat,lambda0);
        end

        m = n_Au/n_m;
        k = 2*pi*n_m/lambda0;
        x = k*r0;
        z = m*x;
        N = round(2+x+4*x^(1/3));
        
        %% computation
        
        j = 1:N;
        
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
        
        Qsca = sum( (2*j+1).*(abs(aj).*abs(aj)+abs(bj).*abs(bj)) );
        Qext = sum( (2*j+1).*real(aj+bj) );
        
        Output.Qext(il,ir) = Qext*2*pi/(k*k)*1e-18;
        Output.Qsca(il,ir) = Qsca*2*pi/(k*k)*1e-18;
        Output.Qabs(il,ir) = Output.Qext(il,ir)-Output.Qsca(il,ir);
    end %radius
end %lamdda
