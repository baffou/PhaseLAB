function [S, dS, x] = dopSine( noPts, noBfs )
%
% Purpose : This function generates a set of sinus basis functions.
%
%     b_n = sqrt(2) * sin( 0..pi n )
%
% These may provide usefull basis functions for some boundary value
% problems.
%
% Use (syntax):
%   [S, dS, x] = dopSine( noPts, noBfs )
%
% Input Parameters :
%   noPts: the number of points in the basis functions
%   noBfs: the number of basis functions to be generated
%
% Return Parameters :
%   T: a matrix whos 
%
% Description and algorithms:
%
% References : 
%
% Author :  Matther Harker and Paul O'Leary
% Date :    16. Feb 2013
% Version : 1.0
%
% (c) 2013 Matther Harker and Paul O'Leary
% url: www.harkeroleary.org
% email: office@harkeroleary.org
%
% History:
%   Date:           Comment:
%
x = linspace(0,1,noPts)';
%
% Setup the matrix and compute the basis functions 
%
S = zeros( noPts, noBfs );
dS = zeros( noPts, noBfs );
scale = sqrt(2/(noPts-1));
for k=1:noBfs
    S(:,k) = scale * sin( k * pi * x) ;
    dS(:,k) = k * pi * scale * cos( k * pi * x);
end;
%
