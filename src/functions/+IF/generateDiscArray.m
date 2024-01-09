function [x, y, r, phi] = generateDiscArray(radius,N,opt)
% functions that generates the coordinates of a regular 2D-array of points,
% distributed over a circulare area.
% phi is in degrees
arguments
    radius (1,1) {mustBeNumeric} % radius of the circular area
    N      (1,1) {mustBeInteger,mustBePositive} % number of points along a diameter
    opt.quadrant = 'full'
end

switch opt.quadrant
    case 'full'
        cond =@(ix,iy) true;
    case {'topright','TopRight',1}
        cond =@(ix,iy) ix>0 && iy>0;
    case {'bottomright','BottomRight',2}
        cond =@(ix,iy) ix>0 && iy<0;
    case {'bottomleft','BottomLeft',3}
        cond =@(ix,iy) ix<0 && iy<0;
    case {'topleft','TopLeft',4}
        cond =@(ix,iy) ix<0 && iy>0;
end

X = linspace(-radius, radius, N);
Y = linspace(-radius, radius, N);

count = 0;
for ix = X
    for iy = Y
        if (ix*ix+iy*iy <= radius^2) && cond(ix,iy)
            count = count+1;
            x(count) = ix;
            y(count) = iy;
        end
    end
end

r=sqrt(x.^2+y.^2);
phi = angle(x+1i*y)*180/pi;
