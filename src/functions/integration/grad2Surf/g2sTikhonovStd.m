function [ Z, lamOpt, RC, Theta ] = g2sTikhonovStd( Zx, Zy, x, y, N, noLambdas, Z0 )
%
% Purpose : Computes the Global Least Squares reconstruction of a surface
%   from its gradient field with Tikhonov regularization in Standard form,
%   while estimating the optimal regularization parameter by means of the
%   L-Curve method.
%
% Use (syntax):
%   Z = g2sTikhonovStd( Zx, Zy, x, y, N, noLambdas )
%   Z = g2sTikhonovStd( Zx, Zy, x, y, N, noLambdas, Z0 )
%   [Z,lamOpt, RC, Theta] = g2sTikhonovStd( Zx, Zy, x, y, N, lambda, deg )
%   [Z,lamOpt, RC, Theta] = g2sTikhonovStd( Zx, Zy, x, y, N, lambda, deg, Z0 )
%
% Input Parameters :
%   Zx, Zy := Components of the discrete gradient field
%   x, y := support vectors of nodes of the domain of the gradient
%   N := number of points for derivative formulas (default=3)
%   noLambdas := the number of points on the L-Curve to compute
%   Z0 := (optional) a-priori estimate of the solution surface
%
% Return Parameters :
%   Z := The reconstructed surface
%   lamOpt := the "optimal" value of the regularization parameter
%   Res := Residuals of the LS term and the Regularization term, typically
%       needed for calculating the Regularization parameter (e.g., L-Curve)
%
% Description and algorithms:
%   The algorithm solves the normal equations of the Least Squares cost
%   function with Tikhonov Regularization terms, formulated by matrix algebra:
%   e(Z) = || D_y * Z - Zy ||_F^2 + || Z * Dx' - Zx ||_F^2
%         + lambda^2 * || eye(m) * ( Z - Z0 ) ||_F^2 + lambda^2 * || ( Z - Z0 ) * eye(n) ||_F^2
%   Following a complete orthogonal decomposition of the coefficient
%   matrices, points on the L-Curve can be computed efficiently.  The
%   optimal lambda on the curve is determined and the GFS coefficients of
%   the reconstructed surface are computed.  The integral surface is
%   recovered by orthogonal transformations.
%
% References :
%    @inproceedings{
%    Harker2008c,
%       Author = {Harker, M. and O'Leary, P.},
%       Title = {Least Squares Surface Reconstruction from Measured Gradient Fields},
%       BookTitle = {CVPR 2008},
%       Address= {Anchorage, AK},
%       Publisher = {IEEE},
%       Pages = {1-7},
%          Year = {2008} }
%
%    @inproceedings{
%    harker2011,
%       Author = {Harker, M. and O'Leary, P.},
%       Title = {Least Squares Surface Reconstruction from Gradients:
%           \uppercase{D}irect Algebraic Methods with Spectral, \uppercase{T}ikhonov, and Constrained Regularization},
%       BookTitle = {IEEE CVPR},
%       Address= {Colorado Springs, CO},
%       Publisher = {IEEE},
%       Pages = {2529--2536},
%          Year = {2011} }
%
% Author :  Matthew Harker and Paul O'Leary
% Date :    25. June 2013
% Version : 1.0
%
% (c) 2013 Matthew Harker and Paul O'Leary, 
% Chair of Automation, University of Leoben, Leoben, Austria
% email: office@harkeroleary.org, 
% url: www.harkeroleary.org
%
% History:
%   Date:           Comment:
%   Mar. 4, 2011    Original Version
%
if ~all( size(Zx)==size(Zy) )
    %
    error('Gradient components must be the same size') ;
    %
end
%
if ~( size(Zx,2)==length(x) ) || ~( size(Zx,1)==length(y) )
    %
    error('Support vectors must have the same size and the gradient') ;
    %
end
%
%
[m,n] = size( Zx ) ;
%
if nargin < 7
    %
    Z0 = zeros(m,n) ;
    %
end
%
if nargin==4
    %
    N = 3 ;
    %
end
Dx = dopDiffLocal( x, N, N, 'sparse' ) ;
Dy = dopDiffLocal( y, N, N, 'sparse' ) ;
%
%=================================
% Reduce the Sylvester Equation :
%=================================
%
[Ux,Sx,Vx] = svd( full(Dx) ) ;
[Uy,Sy,Vy] = svd( full(Dy) ) ;
%
W0 = Vy'*Z0*Vx ;
Wx = Vy'*Zx*Ux ;
Wy = Uy'*Zy*Vx ;
%
%
alpha = diag( Sx ) ;
beta = diag( Sy ) ;
alpha(n) = 0 ;
beta(m) = 0 ;
%
Num = diag(beta)*Wy + Wx*diag(alpha) ;
%
Den = beta.^2 * ones(1,n) + ones(m,1) * ( alpha.^2 )' ; 
%
%=================================
% Compute the L-Curve
%=================================
%
lamMax = min( [ beta(end-1), alpha(end-1) ] ) ;
lamMin = 10 ^( log10( lamMax ) - 5 ) ;
%
tau = linspace(lamMin,lamMax,noLambdas) ;
%
xL = zeros(noLambdas,1) ;
yL = zeros(noLambdas,1) ;
%
for k = 1:noLambdas
    %
    if tau(k) ~= 0
        W = ( Num + tau(k)^2 * W0 ) ./ ( Den + tau(k)^2 ) ;
    else
        W = ( Num ) ./ ( Den ) ;
        W(m,n) = 0 ;
    end
    %
    Nx = norm( diag(beta)*W - Wy, 'fro' ) ;
    Ny = norm( W*diag(alpha) - Wx, 'fro' ) ;
    %
    xL(k) = sqrt( Nx^2 + Ny^2 ) ; % LS Residual Norm
    yL(k) = norm( W, 'fro' ) ; % Solution Norm (Reg. Term)
    %
end
%
%===================================================
% Curvature via Angle Change (forward differences):
%===================================================
%
% The point with maximum signed direction change in the L-Curve is chosen:
%
xP = log10( xL ) ;
yP = log10( yL ) ;
theta = atan2( diff( yP ), diff( xP ) ) ;
%
dtheta = diff( theta ) ;
[~,ind] = max( dtheta ) ;
%
%========================================
% Reconstruct Using the Optimal Lambda :
%========================================
%
lamOpt = tau(ind) ;
%
% Eigenfunction Series Coefficients :
%
W = ( Num + lamOpt^2 * W0 ) ./ ( Den + lamOpt^2 ) ;
W(m,n) = 0 ; % Constant of integration is zero.
%
% Obtain the Surface:
%
Z = Vy * W * Vx' ;
%
if nargout > 2
    %
    RC = [ tau' , xL , yL ] ;
    %
    Theta = [ theta , [ dtheta; NaN ] ] ; % Dummy... no difference at end
    %
end
%
%========
% END
%========



