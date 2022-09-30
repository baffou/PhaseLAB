function [Z,flag] = g2sSparse( Zx, Zy, x, y, N, tol, maxit )
%
% Purpose : Computes the Global Least Squares reconstruction of a surface
%   from its gradient field based on Sparse Matrix Solvers.  This function
%   is only intended for demonstration purposes.  For for faster, more
%   accurate, and more stable results, use "g2s"
%
% Use (syntax):
%   Z = g2sSparse( Zx, Zy, x, y, N )
%   Z = g2sSparse( Zx, Zy, x, y, N, tol, maxit )
%   [Z,flag] = g2sSparse( Zx, Zy, x, y, N )
%   [Z,flag] = g2sSparse( Zx, Zy, x, y, N, tol, maxit )
%
% Input Parameters :
%   Zx, Zy := Components of the discrete gradient field
%   x, y := support vectors of nodes of the domain of the gradient
%   N := number of points for derivative formulas (default=3)
%   tol := the tolerance to which LSQR should iterate
%   maxit := the maximum number of iterations for the LSQR algorithm
%
% Return Parameters :
%   Z := The reconstructed surface
%   flag := convergence flag for LSQR (see help lsqr).
%
% Description and algorithms:
%   The algorithm yields an approximate solution to the Least Squares
%   minimization problem:
%   e(Z) = || D_y * Z - Zy ||_F^2 + || Z * Dx' - Zx ||_F^2
%   by vectorizing the residual matrices.  This yields a large (m*n x m*n)
%   sparse system of equations, which is solved in the LS sense by LSQR.
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
%   Feb. 11, 2011    Original Version
%
warning('WarnTests:convertTest',['This function is only for purposes of comparison; \n',...
            'for faster, more accurate, and more stable results, use "g2s"']) ;
%
if nargin < 6
    %
    tol = 1e-6 ;
    maxit = 1000 ;
    %
end
%
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
% Solve:
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
% Use LSQR to solve the Least Squares System:
%
[Z,flag] = lsqr( [ kron( Dx, speye(m) ) ; kron( speye(n), Dy ) ], [ Zx(:) ; Zy(:) ], tol, maxit ) ;
%
Z = reshape( Z, m, n ) ;
%
%========
% END
%========