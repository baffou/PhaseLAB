function T = dopCheby( noPts, noBfs )
%
% Purpose : This function generates a set of Chebyshev polynomials using
% the classical recurrence relationship.
%
% We do not recommend using these basis functions for the solution of
% problems. We suggest using the dop.m function with a set of Chebyshev
% Nodes
%
% Use (syntax):
%   T = dopCheby( noPts, noBfs )
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
% Date :    29. Jan 2013
% Version : 1.0
%
% (c) 2013 Matther Harker and Paul O'Leary
% url: www.harkeroleary.org
% email: office@harkeroleary.org
%
% History:
%   Date:           Comment:
%

warning('This functions should not be used to solve problems, please use the function dop.m');
disp('This function is only provided for documentation reasons.');
%
x = dopNodes( noPts, 'cheby');
%
% Setup the first two basis functions
%
t0 = ones( noPts, 1 );
t1 = x;
%
% Use the Chenbshev recurrence relationship
%
T = zeros( noPts, noBfs );
T(:,1) = t0;
T(:,2) = t1;
for k=3:noBfs
    T(:,k) = 2 * x .* T(:,k-1) - T(:,k-2);
end;