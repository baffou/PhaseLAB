function [y, Ly] = dopVal( g, x, S )
%
% Function : Computes the y values for a Gram polynomial given the coefficients.
% If x is provided then Gram polynomial interpolation is performed. This
% may only be accurate up to degree d = 40. If the structure S is provided
% without x then the polynomials are accurate up to degrees over 1000.
%
% It is recommedned to use the form without specification of x. In this
% case the polynomial is computed at exactly the same points as where the
% fit was performed. The function dopfit provied all the necessary data in
% the structure S. 
%
% Syntax :
%   (recommended form)
%   y = dopval( g, S )
%   [y, Ly] = dopval( g, S )
%
%   (should only be used if the evaluation is required at other pöints than
%   the fit.
%
%   y = dopval( g, x, S )
%   [y, Ly] = dopval( g, x, S )
%
% Input :
%   g := the Gram coefficients
%   x := the nodes at which the result is to be computed (optional)
%   S := the structure delivered by dopfit.
%   
% Output :
%   y := the evaluated values of the gram polynomials
%   Ly := The covariance matrix associated with y
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
[ng,mg] = size( g );
%
if ~( (ng>1) &&(mg == 1) )
    error('g must be a column vector of the Gram coefficients.');
end;
%
if nargin == 2
    % No Interpolation required
    %---------------------------
    % case when no xs are delivered. All the required information is to be
    % found in the structure
    %
    if ~isstruct(x)
        error('S must be a structure as defivered from dopfit');
    end;
    %
    S = x;
    %
    y = S.G * g;
    %
    if nargout == 2
        Ly = S.G * S.Lg * S.G';
    end;
end;
%
if nargin == 3
    %
    [nx,mx] = size( x );
    %
    if ~( (nx>1) &&(mx == 1) )
        error('x must be a column vector.');
    end;
    %
    % Perform interpolation on the Gram basis
    %
    if nargout == 1
        y = dopInterpolate( g, S.rG , x );
    end;
    %
    if nargout == 2
        [y, Gi] = dopInterpolate( g, S.rG , x );
        Ly = Gi * S.Lg * Gi';
    end;    
end;