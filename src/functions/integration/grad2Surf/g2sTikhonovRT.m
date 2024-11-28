function Z = g2sTikhonovRT( Zx, Zy, S, lambda, Z0 )
%
% Purpose : Computes the Global Least Squares reconstruction of a surface
%   from its gradient field with Tikhonov Regularization.  This function
%   uses the matrix decompositions computed by "g2sTikhonovRTalpha" to
%   reconstruct the surface from its gradient field.  This function is the
%   real-time (RT) portion of the algorithm.
%
% Use (syntax):
%   Z = g2sTikhonovRT( Zx, Zy, S, lambda )
%   Z = g2sTikhonovRT( Zx, Zy, S, lambda, Z0 )
%
% Input Parameters :
%   Zx, Zy := Components of the discrete gradient field
%   S := Structured array containg the derivative matrices and their
%   numerical decompositions (computed by "g2sTikhonovRTalpha")
%   lambda := the regularization parameter for Tikhonov Regularization
%   Z0 := an initial estimate for the integral surface
%
% Return Parameters :
%   Z := the reconstructed surface
%
% Description and algorithms:
%   The algorithm solves the normal equations of the Least Squares cost
%   function with Tikhonov Regularization terms, formulated by matrix algebra:
%   e(Z) = || D_y * Z - Zy ||_F^2 + || Z * Dx' - Zx ||_F^2
%         + lambda^2 * || eye(m) * ( Z - Z0 ) ||_F^2 + lambda^2 * || ( Z - Z0 ) * eye(n) ||_F^2
%   This function uses the orthogonal decomposition of the coefficient
%   matrices, and then solves the reduced normal equations.
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
%   @article{
%   Harker2013,
%       title = "Direct regularized surface reconstruction from gradients for Industrial Photometric Stereo ",
%       journal = "Computers in Industry ",
%       volume = "",
%       number = "0",
%       pages = " - ",
%       year = "2013",
%       note = "",
%       issn = "0166-3615",
%       doi = "http://dx.doi.org/10.1016/j.compind.2013.03.013",
%       url = "http://www.sciencedirect.com/science/article/pii/S0166361513000663",
%       author = "Matthew Harker and Paul O’Leary"}
%
% Author :  Matthew Harker and Paul O'Leary
% Date :    27. July 2013
% Version : 1.0
%
% (c) 2013 Matthew Harker and Paul O'Leary, 
% Chair of Automation, University of Leoben, Leoben, Austria
% email: office@harkeroleary.org, 
% url: www.harkeroleary.org
%
% History:
%   Date:           Comment:
%   Jul. 27, 2013   Original Version
%
[m,n] = size( Zx ) ;
%
if nargin < 5
    Z0 = zeros(m,n) ;
end
%
%==========================
% Reconstruct the Surface:
%==========================
%
% size(S.Uy')
% size(S.Dy')
% size(Zy)
% size(Zx)
% size(S.Dx)
% size(Z0)


F = ( S.Uy' * ( S.Dy'*Zy + Zx*S.Dx + 2*lambda^2*Z0 ) * S.Ux ) ./ ( S.lamY*ones(1,n) + ones(m,1)*S.lamX' + 2*lambda^2 ) ;
%
if lambda <= eps
    F(1,1) = 0 ;
end
%
Z = S.Uy * F * S.Ux' ;
