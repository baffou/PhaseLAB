function Z = g2sDirichlet( Zx, Zy, x, y, N, ZB )
%
% Purpose : Computes the Global Least Squares reconstruction of a surface
%   from its gradient field with Dirichlet Boundary conditions.  The
%   solution surface is thereby constrained to have fixed values at the
%   boundary, specified by ZB.
%
% Use (syntax):
%   Z = g2sDirichlet( Zx, Zy, x, y )
%   Z = g2sDirichlet( Zx, Zy, x, y, N )
%   Z = g2sDirichlet( Zx, Zy, x, y, N, ZB )
%
% Input Parameters :
%   Zx, Zy := Components of the discrete gradient field
%   x, y := support vectors of nodes of the domain of the gradient
%   N := number of points for derivative formulas (default=3)
%   ZB := a matrix specifying the value of the solution surface at the
%      boundary ( omitting this assumes ZB=zeros(m,n) )
%
% Return Parameters :
%   Z := The reconstructed surface
%
% Description and algorithms:
%   The algorithm solves the normal equations of the Least Squares cost
%   function, formulated by matrix algebra:
%   e(Z) = || D_y * Z - Zy ||_F^2 + || Z * Dx' - Zx ||_F^2
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
%   Feb. 11, 2011   Original Version
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
if nargin==4
    %
    N = 3 ;
    %
end
%
[m,n] = size( Zx ) ;
%
Dx = dopDiffLocal( x, N, N, 'sparse' ) ;
Dy = dopDiffLocal( y, N, N, 'sparse' ) ;
%
% Set Z equal to ZB for memory useage (avoids using ZI):
%
if nargin < 6
    %
    Z = zeros(m,n) ;
    %
else
    %
    Z = ZB ;
    %
end
%
P = spdiags( ones(m-1,1), -1, sparse(m,m-2) ) ;
Q = spdiags( ones(n-1,1), -1, sparse(n,n-2) ) ;
%
A = Dy * P ;
B = Dx * Q ;
%
F = ( Zy - Dy * Z ) * Q ; % Note: Z = ZB here
G = P' * ( Zx - Z * Dx' ) ; % Note: Z = ZB here
%
Z(2:m-1,2:n-1) = Z(2:m-1,2:n-1) + lyap( full(A'*A), full(B'*B), -A'*F - G*B ) ;
%
%========
% END
%========
