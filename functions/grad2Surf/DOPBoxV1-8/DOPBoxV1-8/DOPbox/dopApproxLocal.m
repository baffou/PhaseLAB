function S = dopApproxLocal( x, ls, noBfs, option )
%
% Purpose : This function generates a global matrix operator which
% implements the computation of local discrete orthogonal polynomial
% approximation. The x vector may be iregullarly spaced.
%
% Use (syntax):
%   S = dopApproxLocal( x, ls, noBfs, option )
%
% Input Parameters :
%   x : The vestor of x value fo rthe computation.
%   ls : The support length used for the local differential
%   noBfs : the number of basis functions to be used.
%   option: 'sparse' generated sparse matrix notations, default is full.
%
% Return Parameters :
%   S: The local discrete polynomial approximation operator
%
% Description and algorithms:
%   Local discrete orthogonal polynomials are used to generate the local approximations
%
% Author :  Matthew Harker and Paul O'Leary
% Date :    24 Oct 2012
% Version : 1.0
%
% (c) 2012 Paul O'Leary, Chair of Automation, University of Leoben, Leoben, Austria
% email: office@harkeroleary.org, 
% url: www.harkeroleary.org
%
% History:
%   Date:           Comment:
% 22 April          Imporved efficency by computing vector matrix product 
%                   rather than matrix matrix product.

%-----------------------------------------------------------------------
[noPts, mt] = size(x);
% Test the input paramaters
%----------------------------------------------------------------
% Use sparse matrices if necessary
%
if nargin == 4
    intOption = option;
    genSparse = true;
else
    intOption = 'full';
    genSparse = false;
end;
%
% Test if the support length is compatible with the number of points
% requested.
%
if noPts <= ls
    error('The number of nodes n must be greater that the support length ls');
end;
%
% Test the degree and support length for campatability
%
if noBfs > ls
    error('The number of basis functions must fulfill n <= ls');
end;
%
if mt > 1
    error('A column vector is expected for x');
end;
%
if isEven( ls )
    error('This function is only implemented for even values of ls.');
end;
%
%------------------------------------------------------------------------
% Prepare empty Internal S
%
rows = [];
cols = [];
vals = [];
%
% Determine the half length of ls this determine the upper ane lower
% postions of Si.
%
ls2 = round( (ls + 1 )/2 );
%
% generatethe top of Si
%
range = (1:ls)';
halfRange = (1:ls2)';
%
startX = x(range);
%
Gt = dop( startX, noBfs );
Dt = Gt * Gt';
%
for k=1:length(halfRange)
    row = halfRange(k) * ones(length(range),1);
    rows = [rows; row];
    %
    cols = [cols; range];
    %
    vals = [vals; Dt(halfRange(k),:)'];
end;
%
% Compute for the strip diagonal entries
%
noOnDiag = noPts - 2 * ls2;
for k=1:noOnDiag
    localX = x(range+k);
    Gt = dop( localX, noBfs );
    gt = Gt( ls2,: );
    dt = gt * Gt';
    %
    row = (k + ls2) * ones( length(range),1 );
    %
    rows = [rows; row];
    cols = [cols; range + k];
    vals = [vals; dt'];
end;
%
% generate the bottom part of Si
%
endX = x(end-ls+1:end);
Gt = dop( endX, noBfs );
Dt = Gt * Gt';
halfRange = (noPts-ls2+1:noPts)';
range = (noPts-ls+1:noPts)';
%
for k=1:length(halfRange)
    row = halfRange(k) * ones(length(range),1);
    %
    rows = [rows; row];
    cols = [cols; range];
    vals = [vals; Dt(k+ls2-1,:)'];
end;
%
S = sparse(rows, cols, vals, noPts, noPts );
%
if ~genSparse
    S = full(S);
end;
