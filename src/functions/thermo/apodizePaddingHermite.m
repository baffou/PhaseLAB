function B = apodizePaddingHermite(A, opt)
% Double the image size with smooth Hermite apodized padding.
% The original image is kept unchanged in the center.
% The padding reaches zero with zero slope at the outer border.
% Border slopes are estimated by local linear fits.

arguments
    A double
    opt.nFit (1,1) double {mustBePositive, mustBeInteger} = ...
        max(5, round(min(size(A))/20))
end

[ny, nx] = size(A);

Ny = 2*ny;
Nx = 2*nx;

px1 = floor(nx/2);
px2 = Nx - nx - px1;
py1 = floor(ny/2);
py2 = Ny - ny - py1;

nFitX = min(opt.nFit, nx);
nFitY = min(opt.nFit, ny);

%% Horizontal extension

C = zeros(ny, Nx);
C(:, px1+1:px1+nx) = A;

dxL = estimateBorderSlope(A, 'left',  nFitX);
dxR = estimateBorderSlope(A, 'right', nFitX);

% Left padding
for k = 1:px1
    s = k/px1; % s = 0 at image border, s = 1 at outer border

    h00 =  2*s^3 - 3*s^2 + 1;
    h10 =      s^3 - 2*s^2 + s;

    % minus sign because we extrapolate towards decreasing x
    C(:, px1+1-k) = h00*A(:,1) + h10*(-px1*dxL);
end

% Right padding
for k = 1:px2
    s = k/px2;

    h00 =  2*s^3 - 3*s^2 + 1;
    h10 =      s^3 - 2*s^2 + s;

    C(:, px1+nx+k) = h00*A(:,end) + h10*(px2*dxR);
end

%% Vertical extension

B = zeros(Ny, Nx);
B(py1+1:py1+ny, :) = C;

dyT = estimateBorderSlope(C, 'top',    nFitY);
dyB = estimateBorderSlope(C, 'bottom', nFitY);

% Top padding
for k = 1:py1
    s = k/py1;

    h00 =  2*s^3 - 3*s^2 + 1;
    h10 =      s^3 - 2*s^2 + s;

    % minus sign because we extrapolate towards decreasing y
    B(py1+1-k, :) = h00*C(1,:) + h10*(-py1*dyT);
end

% Bottom padding
for k = 1:py2
    s = k/py2;

    h00 =  2*s^3 - 3*s^2 + 1;
    h10 =      s^3 - 2*s^2 + s;

    B(py1+ny+k, :) = h00*C(end,:) + h10*(py2*dyB);
end

B = fixCornerPatches(B, px1, px2, py1, py2);

B = smoothPaddingOnly(B, px1, px2, py1, py2, 10);

end


function g = estimateBorderSlope(A, side, nFit)
% Estimate normal slope at one image border using local linear fit.

[ny, nx] = size(A);

switch side
    case 'left'
        x = (1:nFit).';
        Y = A(:,1:nFit).';
        p = polyfitMatrix(x, Y);
        g = p(1,:).';

    case 'right'
        x = (nx-nFit+1:nx).';
        Y = A(:,nx-nFit+1:nx).';
        p = polyfitMatrix(x, Y);
        g = p(1,:).';

    case 'top'
        y = (1:nFit).';
        Y = A(1:nFit,:);
        p = polyfitMatrix(y, Y);
        g = p(1,:);

    case 'bottom'
        y = (ny-nFit+1:ny).';
        Y = A(ny-nFit+1:ny,:);
        p = polyfitMatrix(y, Y);
        g = p(1,:);

    otherwise
        error('Unknown side.');
end

end


function p = polyfitMatrix(x, Y)
% Linear fit Y = p1*x + p2 for several signals at once.

X = [x, ones(size(x))];
p = X \ Y;

end

function B = fixCornerPatches(B, px1, px2, py1, py2)
% Rebuild the four corner patches with smooth Coons patches.
% This enforces value continuity with the four neighboring padding bands.

[Ny, Nx] = size(B);

% Top-left
B(1:py1, 1:px1) = smoothCoonsPatch( ...
    zeros(py1,1), ...
    B(1:py1, px1+1), ...
    zeros(1,px1), ...
    B(py1+1, 1:px1));

% Top-right
B(1:py1, Nx-px2+1:Nx) = smoothCoonsPatch( ...
    B(1:py1, Nx-px2), ...
    zeros(py1,1), ...
    zeros(1,px2), ...
    B(py1+1, Nx-px2+1:Nx));

% Bottom-left
B(Ny-py2+1:Ny, 1:px1) = smoothCoonsPatch( ...
    zeros(py2,1), ...
    B(Ny-py2+1:Ny, px1+1), ...
    B(Ny-py2, 1:px1), ...
    zeros(1,px1));

% Bottom-right
B(Ny-py2+1:Ny, Nx-px2+1:Nx) = smoothCoonsPatch( ...
    B(Ny-py2+1:Ny, Nx-px2), ...
    zeros(py2,1), ...
    B(Ny-py2, Nx-px2+1:Nx), ...
    zeros(1,px2));

end


function P = smoothCoonsPatch(leftEdge, rightEdge, topEdge, bottomEdge)
% Smooth 2D patch interpolating four boundary curves.
%
% leftEdge   : nY-by-1
% rightEdge  : nY-by-1
% topEdge    : 1-by-nX
% bottomEdge : 1-by-nX

nY = numel(leftEdge);
nX = numel(topEdge);

u = linspace(0,1,nX);
v = linspace(0,1,nY).';

% Smooth coordinates with zero slope at both ends
su = smootherstep(u);
sv = smootherstep(v);

[SU, SV] = meshgrid(su, sv);

L = leftEdge(:)  * ones(1,nX);
R = rightEdge(:) * ones(1,nX);
T = ones(nY,1) * topEdge(:).';
D = ones(nY,1) * bottomEdge(:).';

% Corner values
P00 = topEdge(1);
P10 = topEdge(end);
P01 = bottomEdge(1);
P11 = bottomEdge(end);

% Smooth Coons patch
P = (1-SU).*L + SU.*R + (1-SV).*T + SV.*D ...
    - ((1-SU).*(1-SV)*P00 ...
    +   SU .*(1-SV)*P10 ...
    + (1-SU).* SV *P01 ...
    +   SU .* SV *P11);

end


function s = smootherstep(t)
% C2 smooth transition from 0 to 1.

s = 6*t.^5 - 15*t.^4 + 10*t.^3;

end

function B = smoothPaddingOnly(B, px1, px2, py1, py2, sigma)
% Smooth only the padded region, with a progressive blending.
% The original central image is not modified.

if nargin < 6
    sigma = 3;
end

[Ny, Nx] = size(B);

% Smoothed version of the full image
Bs = imgaussfilt(B, sigma, 'Padding', 'replicate');

% Mask equal to 0 in the original image, 1 far inside the padding
M = ones(Ny, Nx);

M(py1+1:Ny-py2, px1+1:Nx-px2) = 0;

% Smooth transition of the mask to avoid discontinuity
M = imgaussfilt(M, sigma, 'Padding', 'replicate');

% Normalize mask to stay between 0 and 1
M = M ./ max(M(:));

% Keep exactly zero mask in the original image
M(py1+1:Ny-py2, px1+1:Nx-px2) = 0;

% Blend
B = (1 - M).*B + M.*Bs;

end