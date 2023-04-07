function [P,dP, recurrenceCoeffs] = dopGram( m, n )
%
% Function : Generates a set of discrete orthonormal polynomials, P, and
%   their derivatives, dP, either of size (m x n), or on the arbitrary
%   support vector x. It also returns the coefficients for the recurrence
%   relationships, these can be used to perform interpolation.
%
%   NOTE: Gram-Schmidt orthogonalization is used here. This is not suitable
%   for the generation of high quality basis functions. This function is
%   only provided for documentation purposes.
%
% Syntax :
%   [P,dP] = dopGram( m ) ;
%   [P,dP] = dopGram( m, n ) ;
%   [P,dP] = dopGram( x ) ;
%   [P,dP, recurrenceCoeffs] = dop( x, n ) ;
%
% Input :
%   m := number of evenly (unit) spaced points in support
%   x := arbitrary support vector
%   n := number of functions
%   
% Output :
%   P = [ p0, p1, ..., p(n-1) ] := Discete polynomials, pk are vectors.
%   dP = [ dp0, dp1, ..., dp(n-1) ] := Derivatives of the polynomials.
%   recurrenceCoeffs = a matrix, the first and second columns are the
%      alphas and betas respectivly used during the recurrence relationship
%
% Cite this as :

% @article{DBLP:journals/tim/OLearyH12,
%  author    = {Paul O'Leary and
%               Matthew Harker},
%  title     = {A Framework for the Evaluation of Inclinometer Data in the
%               Measurement of Structures},
%  journal   = {IEEE T. Instrumentation and Measurement},
%  volume    = {61},
%  number    = {5},
%  year      = {2012},
%  pages     = {1237-1251},
% }
%
% @inproceedings{
% olearyHarker2008B,
%   Author = {O'Leary, Paul and Harker, Matthew},
%   Title = {An Algebraic Framework for Discrete Basis Functions in Computer Vision},
%   BookTitle = {IEEE Indian Conference on Computer Vision, Graphics and Image Processing},
%   Address= {Bhubaneswar, Dec},
%   Year = {2008} }
%
% Author : Matthew Harker
% Date : Nov. 29, 2011
% Version : 1.0
%--------------------------------------------------------------------------
% (c) 2011, Harker, O'Leary, University of Leoben, Leoben, Austria
% email: automation@unileoben.ac.at, url: automation.unileoben.ac.at
%--------------------------------------------------------------------------
% History:
%   Date:           Comment:
%   Nov. 29, 2011   Original Version 1.0
%--------------------------------------------------------------------------
%
[u,v] = size( m ) ;
%
if u == 1 && v == 1
    %
    x = (-1:2/(m-1):1)' ;
    %
elseif u ~= 1 && v == 1
    %
    x = m ;
    m = length(x) ;
    %
else
    %
    error('Support x should be an m x 1 vector') ;
    %
end
%
if nargin == 1
    n = m ;
end
%
%==============================
% Generate the Basis
%==============================
%
% Generate the first two polynomials :
p0 = ones(m,1)/sqrt(m) ;
meanX = mean( x );
p1 = x - meanX ;
np1 = norm( p1 ) ;
p1 = p1 / np1;
%
% Compute the derivatives of the degree-1 polynomial :
hm = sum( diff( x ) ) ; % Alternatively mean(...)
h = sum( diff( p1 ) ) ; % Alternatively mean(...), but 1/n cancels.
dp1 = (h/hm) * ones(m,1) ;
%
% Initialize the basis function matrices :
P = zeros(m,n) ;
P(:,1:2) = [ p0, p1 ] ;
%
dP = zeros(m,n) ;
dP(:,2) = dp1 ;
%
% Setup storage for the coefficients of the three term relationship
%
alphas = zeros(n,1);
alphas(1) = 1/sqrt(m);
alphas(2) = 1/np1;
%
betas = zeros(n,1);
betas(2) = meanX;
%
for k = 3:n
    %
    % Augment previous polynomial :
    pt = P(:,k-1) .* p1 ;
    %
    % 3-term recurrence :
    beta0 = (P(:,k-2)'*pt) ;
    pt = pt - beta0 * P(:,k-2) ;
    betas(k) = beta0;
    %
    % Complete reorthogonalization :
    beta = P(:,1:k-1)' * pt ;
    %pt = pt - P(:,1:k-1) * beta ;
    %
    % Apply coefficients to recurrence formulas : 
    alpha = 1/sqrt(pt'*pt) ;
    alphas(k) = alpha;
    P(:,k) = alpha * pt ;
    dP(:,k) = alpha * ( dP(:,k-1) .* p1 + P(:,k-1) .* dp1 - dP(:,k-2) * beta0 - dP(:,1:k-1)*beta  ) ;
    %
end;
%
recurrenceCoeffs = [alphas, betas];
%========
% END
%========