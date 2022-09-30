function Phi = g2sSylvester( A, B, F, G, u, v )
%
% Purpose : Solves the semi-definite Sylvester Equation of the form
%   A'*A * Phi + Phi * B'*B - A'*F - G*B = 0,
%   Where the null vectors of A and B are known to be
%   A * u = 0
%   B * v = 0
%
% Use (syntax):
%   Phi = g2sSylvester( A, B, F, G, u, v )
%
% Input Parameters :
%   A, B, F, G := Coefficient matrices of the Sylvester Equation
%   u, v := Respective null vectors of A and B
%
% Return Parameters :
%   Phi := The minimal norm solution to the Sylvester Equation
%
% Description and algorithms:
%   The rank deficient Sylvester equation is solved by means of Householder
%   reflections and the Bartels-Stewart algorithm.  It uses the MATLAB
%   function "lyap", in reference to Lyapunov Equations, a special case of
%   the Sylvester Equation.
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
%   Feb. 9, 2011    Original Version
%
%----------------------
% Householder Vectors:
%----------------------
%
m = length(u) ;
n = length(v) ;
%
u(1) = u(1) + norm( u, 2 ) ;
u = ( sqrt(2) / norm( u, 2 ) ) * u ;
%
v(1) = v(1) + norm( v, 2 ) ;
v = ( sqrt(2) / norm( v, 2 ) ) * v ;
%
%--------------------------------
% Apply the Householder Updates:
%--------------------------------
%
% With:
% Pa = eye(m) - u * u' ;
% Pb = eye(n) - v * v' ;
% 
% Compute:
% A = A * Pa ;
% B = B * Pb ;
% F = F * Pb ;
% G = Pa' * G ;
%
A = A - ( A * u ) * u' ;
B = B - ( B * v ) * v' ;
F = F - ( F * v ) * v' ;
G = G - u * ( u' * G ) ;
%
%--------------------------------
% Solve the System of Equations:
%--------------------------------
%
Phi = zeros(m,n) ;
%
Phi(1,2:n) = G(1,:) / B(:,2:n)' ;
Phi(2:m,1) = A(:,2:m) \ F(:,1) ;
Phi(2:m,2:n) = lyap( A(:,2:m)'*A(:,2:m), B(:,2:n)'*B(:,2:n), -A(:,2:m)'*F(:,2:end) - G(2:end,:)*B(:,2:n) ) ;
%
%---------------------------------
% Invert the Householder Updates:
%---------------------------------
%
Phi = Phi - u * ( u' * Phi ) ;
Phi = Phi - ( Phi * v ) * v' ;
%
%Phi = Phi - u * ( u' * Phi ) - ( Phi * v ) * v' + u * ( u' * Phi * v ) * v' ;
%
%=====
% END
%=====