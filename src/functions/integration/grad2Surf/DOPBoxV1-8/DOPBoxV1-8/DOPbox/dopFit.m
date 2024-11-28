function [g, Lg, S] = dopFit( x, y, d )
%
% Function : Computed the Gram polynomial coefficients corresponding the
% the data vector y.
%
% Syntax :
%   [g, S] = dopfit( y, degree )
%
% Input :
%   x := the vector of x coordinates correcponding to y
%   y := the vector of data for which the Gram coefficients ar eto be
%   computed
%   d := the degre eof the polynomial.
%   
% Output :
%   g := the Gram  polynomial coefficients
%   Lg := The covariance matrix associated with g
%   S := a structure containing information required for later evaluation
%   of the polynomials and for the computation of covariance
%
% The theory can be found in,
%
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
% (c) 2013, Harker, O'Leary, University of Leoben, Leoben, Austria
% email: automation@unileoben.ac.at, url: automation.unileoben.ac.at
%--------------------------------------------------------------------------
% History:
%   Date:           Comment:
%   May. 29, 2013   Original Version 1.0
%--------------------------------------------------------------------------
%

%---------------------------------------------------------------
% Test the input data dimensions
%
[nx,mx] = size( x ) ;
[ny,my] = size( y ) ;
%
if ~( (ny>1) &&(my == 1) )
    error('y must be a column vector.');
end;
%
if ~( (nx>1) &&(mx == 1) )
    error('x must be a column vector.');
end;
%
if ~(nx == ny)
    error('The x and y vectors must be of the same size.');
end;
%
if ~(d < nx - 1)
    error('d must be smaller than n -1, n is the number of data points.');
end;
%
% generate the basis functions
%
[G, dG, rG] = dop( x, d + 1 );
%
% compute the coefficients
%
g = G' * y;
%
% If required compute the residual and degrees of freedom
%
if nargout > 1
    yg = G * g;
    r = y - yg;
    normR = norm( r );
    df = nx - (d+1);
    % Compute an estimate for the covariance of g
    Lg = G' * G * normR^2 / df ;
end;    
%
if nargout > 2
    %
    % Basis functions and their deivatives
    %
    S.G = G;
    S.dG = dG;
    S.rG = rG;
    %
    % Reconstruction and residual
    %
    S.yg = yg;
    S.r = r;
    S.normr = normR;
    S.df = df;
    S.Lg = Lg;
end;

