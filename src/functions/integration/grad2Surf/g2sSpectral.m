function Z = g2sSpectral( Zx, Zy, x, y, N, Mask, basisFns )
%
% Purpose : Computes the Global Least Squares reconstruction of a surface
%   from its gradient field with Spectral filtering, using either
%   polynomial, cosine, or Fourier bases.
%
% Use (syntax):
%   Z = g2sSpectral( Zx, Zy, x, y, N, Mask, basisFns )
%   Z = g2sSpectral( Zx, Zy, x, y, N, Mask )
%
% Input Parameters :
%   Zx, Zy := Components of the discrete gradient field
%   x, y := support vectors of nodes of the domain of the gradient
%   N := number of points for derivative formulas (default=3)
%   Mask := either a 1x2 matrix, [p,q], specifying the size of a low pass
%      filter, or a general mxn spectral mask.
%   basisFns := 'poly', 'cosine', 'fourier', specifying the type of basis
%      functions used for regularization.  Defaults is polynomial.  For
%      arbitrary node spacing, only polnomial filtering is implemented.
%
% Return Parameters :
%   Z := The reconstructed surface
%
% Description and algorithms:
%   The algorithm solves the normal equations of the Least Squares cost
%   function, formulated by matrix algebra:
%   e(C) = || D_y * By * C * Bx' - Zy ||_F^2 + || By * C * Bx' * Dx' - Zx ||_F^2
%   The surface is parameterized by its spectrum, C, w.r.t. sets of orthogonal
%   basis functions, as,
%   Z = By * C * Bx'
%   The normal equations are a rank deficient Sylvester equation which is
%   solved by means of Householder reflections and the Bartels-Stewart
%   algorithm.
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
% Date :    29. July 2013
% Version : 1.0
%
% (c) 2013 Matthew Harker and Paul O'Leary, 
% Chair of Automation, University of Leoben, Leoben, Austria
% email: office@harkeroleary.org, 
% url: www.harkeroleary.org
%
% History:
%   Date:           Comment:
%   Feb. 11, 2011   Original Version
%
%------------------
% Argument checks:
%------------------
%
% Check gradient/support sizes:
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
% Set a default set of basis functions (polynomials):
%
if nargin ~= 7
    basisFns = 'poly' ;
end
%
basisFns = lower( basisFns ) ;
%
% Check for evenly spaced points in the case of Cosine and Fourier bases:
%
if ~strcmp(basisFns,'poly')
    %
    if sqrt( std( diff( x ) )^2+std( diff( y ) )^2 ) >= 10*eps
        error('Basis Functions other than polynomial are only implemented for evenly spaced nodes') ;
    end
    %
end
%
% Check type of mask (either low-pass of size p x q, or general):
%
[m,n] = size( Zx ) ;
%
if all( size(Mask)==[1,2] )
    %
    % Low Pass Filter
    p = Mask(1) ;
    q = Mask(2) ;
    %
elseif all( size(Mask)==size(Zx) )
    %
    % Arbitrary Mask
    p = m ;
    q = n ;
    %
else
    %
    error('Mask must be the same size as the gradient, or define the size of the low-pass filter') ;
    %
end
%
% Assumptions for the low-pass mask are the following shapes:
%
% Low Pass for 'poly', 'cosine':
% [ 1 1 1 0 0 0 ;...
%   1 1 1 0 0 0 ;...
%   0 0 0 0 0 0 ;...
%   0 0 0 0 0 0 ] ;
%
% Low Pass for 'fourier':
% [ 1 1 0 0 1 1 ;...
%   1 1 0 0 1 1 ;...
%   0 0 0 0 0 0 ;...
%   1 1 0 0 1 1 ;...
%   1 1 0 0 1 1 ] ;
%
%=============================
% Set up Derivative Matrices:
%=============================
%
if nargin==4
    %
    N = 3 ;
    %
end

Dx = dopDiffLocal( x, N, N, 'sparse' ) ;
Dy = dopDiffLocal( y, N, N, 'sparse' ) ;
%
%===============================
% Generate the Basis Functions:
%===============================
%
switch basisFns
    %
    case 'poly'
        %
        Bx = dop( x ) ;
        By = dop( y ) ;
        %
        Bx = Bx(:,1:q) ;
        By = By(:,1:p) ;
        %
    case 'cosine'
        %
        Bx = dctmtx(n)' ;
        By = dctmtx(m)' ;
        %
        Bx = Bx(:,1:q) ;
        By = By(:,1:p) ;
        %
    case 'fourier'
        %
        Bx = gallery('orthog',n,3) ; % Symmetric
        By = gallery('orthog',m,3) ; % Symmetric
        %
        Bx = Bx(:,[1:ceil(q/2),(n-floor(q/2)+1):n]) ;
        By = By(:,[1:ceil(p/2),(m-floor(p/2)+1):m]) ;
        %
    otherwise
        %
        error('Not a valid choice of Basis Functions') ;
        %
end
%
%===============================
% Solve the Sylvester Equation:
%===============================
%
A = Dy * By ;
B = Dx * Bx ;
%
F = Zy * Bx ;
G = By' * Zx ;
%
C = zeros(p,q) ;
%
C(1,2:q) = G(1,:) / B(:,2:q)' ;
C(2:p,1) = A(:,2:p) \ F(:,1) ;
C(2:p,2:q) = lyap( A(:,2:p)'*A(:,2:p), B(:,2:q)'*B(:,2:q), -A(:,2:p)'*F(:,2:end) - G(2:end,:)*B(:,2:q) ) ;
%
%===========================================
% Apply the Spectral Filter (if necessary):
%===========================================
%
if ~all( size(Mask)==[1,2] )
    %
    C = Mask .* C ;
    %
end
%
% Taking the real part is only neccessary for the Fourier basis:
%
Z = real( By * C * Bx' ) ; % Z = By * C * Bx' for all others
%
%========
% END
%========