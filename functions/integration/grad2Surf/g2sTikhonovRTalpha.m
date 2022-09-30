function S = g2sTikhonovRTalpha( x, y, N )
%
% Purpose : Computes the Global Least Squares reconstruction of a surface
%   from its gradient field with Tikhonov Regularization.  This function
%   computes the matrix decompositions necessary, and is to be used in
%   conjunction with "g2sTikhonovRT" to compute the real-time (RT)
%   reconstruction.
%
% Use (syntax):
%   S = g2sTikhonovRTalpha( x, y, N )
%
% Input Parameters :
%   x, y := support vectors of nodes of the domain of the gradient
%   N := number of points for derivative formulas (default=3)
%
% Return Parameters :
%   S := Structured array containg the derivative matrices and their
%   numerical decompositions
%
% Description and algorithms:
%   The algorithm solves the normal equations of the Least Squares cost
%   function with Tikhonov Regularization terms, formulated by matrix algebra:
%   e(Z) = || D_y * Z - Zy ||_F^2 + || Z * Dx' - Zx ||_F^2
%         + lambda^2 * || eye(m) * ( Z - Z0 ) ||_F^2 + lambda^2 * || ( Z - Z0 ) * eye(n) ||_F^2
%   This function computes the orthogonal decomposition of the coefficient
%   matrices, which then must be input to "g2sTikhonovRT" to complete the
%   reconstruction.
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
Dx = dopDiffLocal( x, N, N, 'sparse' ) ;
Dy = dopDiffLocal( y, N, N, 'sparse' ) ;
%
[Ux,Tx] = schur( full(Dx'*Dx) ) ;
[Uy,Ty] = schur( full(Dy'*Dy) ) ;
%
lamX = diag( Tx ) ;
lamY = diag( Ty ) ;
%
S = struct( 'Dx', Dx, 'Dy', Dy, 'Ux', Ux, 'Uy', Uy, 'lamX', lamX, 'lamY', lamY ) ;
