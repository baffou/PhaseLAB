function Z = g2sWeighted( Zx, Zy, x, y, N, Lxx, Lxy, Lyx, Lyy )
%
% Purpose : Computes the Global Weighted Least Squares reconstruction of a
%   surface from its gradient field, whereby the weighting is defined by a
%   weighted Frobenius norm
%
% Use (syntax):
%   Z = g2sWeighted( Zx, Zy, x, y, N, Lxx, Lxy, Lyx, Lyy )
%
% Input Parameters :
%   Zx, Zy := Components of the discrete gradient field
%   x, y := support vectors of nodes of the domain of the gradient
%   N := number of points for derivative formulas (default=3)
%   Lxx, Lxy, Lyx, Lyy := Each matrix Lij is the covariance matrix of the
%       gradient's i-component the in j-direction.
%
% Return Parameters :
%   Z := The reconstructed surface
%
% Description and algorithms:
%   The algorithm solves the normal equations of the Weighted Least Squares
%   cost function, formulated by matrix algebra:
%   e(Z) = || Lyy^(-1/2) * (D_y * Z - Zy) * Lyx^(-1/2) ||_F^2 +
%               || Lxy^(-1/2) * ( Z * Dx' - Zx ) * Lxx^(-1/2) ||_F^2
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
%   Apr. 20, 2011   Original Version
%
[m,n] = size( Zx ) ;
%
if nargin==4
    %
    N = 3 ;
    %
end
Dx = dopDiffLocal( x, N, N, 'sparse' ) ;
Dy = dopDiffLocal( y, N, N, 'sparse' ) ;
%
Wxx = sqrtm( Lxx ) ;
Wxy = sqrtm( Lxy ) ;
Wyx = sqrtm( Lyx ) ;
Wyy = sqrtm( Lyy ) ;
%
%==================================
% Solution for Zw (written here Z)
%==================================
%
u = Wxy \ ones(m,1) ;
v = Wyx \ ones(n,1) ;
%
A = Wyy \ Dy * Wxy ;
B = Wxx \ Dx * Wyx ;
F = Wyy \ Zy / Wyx ;
G = Wxy \ Zx / Wxx ;
%
Z = g2sSylvester( A, B, F, G, u, v ) ;
%
Z = Wxy * Z * Wyx ; % "Unweight" the solution
%
%========
% END
%========