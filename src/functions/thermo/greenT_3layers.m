%% FUNCTION THAT COMPUTES THE GREEN'S FUNCTION FOR A 3-LAYER MEDIUM.
%
% greenT_3layers(x, y, z, universe)
%
%   x, y, z:   vectors of coordinates, all the same length.
%   universe: array of 2 or 3 Medium objects.

% Theory from the article Appl. Phys. Lett. 102, 244103 (2013)
%                         https://doi.org/10.1063/1.4811557

% author: Guillaume Baffou
% affiliation: CNRS, Institut Fresnel
% date: Feb 1, 2018

function Green = greenT_3layers(x,y,z,universe)

k1 = universe(1).kappa;
k2 = universe(2).kappa;
k3 = universe(3).kappa;

% conversion of distances from nanometers to meters:
x = x*1e-9;
y = y*1e-9;
z = z*1e-9;

z1 = universe(2).mesh.z1;
z2 = universe(2).mesh.z2;

if z2 < z1
    error('attention, interfaces z2 et z1 inversées !!!\n')% normalement, ne doit jamais arriver car z2 et z1 construits à partir d'une méthode de classe.
end

nVal = length(z);

%% calculation of the Green's function in the (rho,z) plane

%source point
xs = 0;
ys = 0;
zs = 0;

%
Delta = z2-z1;

Green = zeros(nVal,1);

for ii = 1:nVal
    z0 = z(ii);
    
    if (z0 < z1)
        rexp = min([2*Delta;2*z2 - zs - z0;zs-z0]);
        if rexp==0, rexp=10;end;
 
        r1 = sqrt((x(ii)-xs)*(x(ii)-xs)+(y(ii)-ys)*(y(ii)-ys));
        dh = 0.05*min([1/(2*r1);1/(20*rexp)]);
        N = 10*round(3/(rexp*dh));
        G = zeros(N,1);
        for j = 1:N
            h = dh*(j-0.5);
            detA = (k2+k3)*(k2+k1)+(k2-k1)*(k3-k2)*exp(-2*h*Delta);
            cA = (k2+k3)*exp(-h*(        zs - z0 ));
            cB = (k2-k3)*exp(-h*( 2*z2 - zs - z0 ));
            G(j) = (cA+cB)*besselj(0,h*r1)/(2*pi*detA)*dh;
        end
        Green(ii) = (sum(G)+sum(G(2:N-1)))/2;        %methode des trapèzes
    end%if z0<z1
    
    if z0>=z1 && z0<=z2
        rexp = min([2*Delta ; 2*Delta + zs - z0;2*z2  - zs - z0;- 2*z1  + zs + z0;2*Delta - zs + z0]);
        
        r2 = sqrt((x(ii)-xs)*(x(ii)-xs)+(y(ii)-ys)*(y(ii)-ys));
        if z0==0 && rexp==0, rexp = r2/2;%should be : r2/20;
        elseif rexp==0, rexp=r2/2;end;
        dh = 0.05*min([1/(2*r2);1/(20*rexp)]);
        N = 10*round(3/(rexp*dh));
        G = zeros(N,1);
        for j = 1:N
            h = dh*(j-0.5);
            detA = (k2+k3)*(k2+k1)+(k2-k1)*(k3-k2)*exp(-2*h*Delta);
            cA = (k2-k3)*(k2-k1)*exp(-h*( 2*Delta + zs - z0 ));
            cB = (k2-k3)*(k2+k1)*exp(-h*(   2*z2  - zs - z0 ));
            cC = (k2-k1)*(k2+k3)*exp(-h*( - 2*z1  + zs + z0 ));
            cD = (k2-k3)*(k2-k1)*exp(-h*( 2*Delta - zs + z0 ));
            G(j) = (cA+cB+cC+cD)*besselj(0,h*r2)/(4*pi*k2*detA)*dh;
        end
        R = sqrt(r2*r2+(z0-zs)*(z0-zs)) + (z0==zs && r2==0)*abs(x(1)-x(2))/(4*log(1+sqrt(2)));
        Green(ii) = (sum(G)+sum(G(2:N-1)))/2;
        Green(ii) = 1/(4*pi*R*k2)+Green(ii);
    end%if z0>=z1 && z0<=z2

    if z0>z2
        
        r3 = sqrt((x(ii)-xs)*(x(ii)-xs)+(y(ii)-ys)*(y(ii)-ys));
        rexp = min([2*Delta;zs+z0-2*z1;z0-zs]);
        if rexp == 0, rexp = 10;end;
        dh = 0.05*min([1/(2*r3);1/(20*rexp)]);
        N = 10*round(3/(rexp*dh));
        G = zeros(N,1);
        for j = 1:N
            h = dh*(j-0.5);
            detA = (k2+k3)*(k2+k1)+(k2-k1)*(k3-k2)*exp(-2*h*Delta);
            cA = (k2-k1)*exp( -h*(  zs + z0 - 2*z1 ));
            cB = (k2+k1)*exp( -h*( -zs + z0        ));
            G(j) = (cA+cB)*besselj(0,h*r)/(2*pi*detA)*dh;
        end
        Green(ii) = (sum(G)+sum(G(2:N-1)))/2;
    end%if z0>z2

end % ii

Green = Green*1e-9; %go back to nanometers


