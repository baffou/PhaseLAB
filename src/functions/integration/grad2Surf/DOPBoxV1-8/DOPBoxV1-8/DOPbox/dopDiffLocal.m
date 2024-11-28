function S = dopDiffLocal( x, ls, noBfs, option )
%
% Purpose : This function generates a global matrix operator which
% implements the computation of local differentials where the vector of x
% values may be irregullarly spaced.
%
% In general the support length ls should be an odd number. There is an
% exceltion made upto to ls = 20 and ls = noPoints, in this case a full
% differentiating matrix is computed.
%
% Use (syntax):
%   S = dopDiffLocal( x, ls, noBfs, option )
%
% Input Parameters :
%   x : The vestor of x value for the computation.
%   ls : The support length used for the local differential
%   noBfs : the number of basis functions to be used.
%   option: 'sparse' generated sparse matrix notations, default is full.
%
% Return Parameters :
%   S: The local differential operator
%
% Description and algorithms:
%   Local discrete orthogonal polynomials are used to generate the local approximations
%   for the dreivatives
%
%
% Author :  Matthew Harker and Paul O'Leary
% Date :    17. January 2012
% Version : 1.0
%
% (c) 2013 Matthew Harker and Paul O'Leary,
% Chair of Automation, University of Leoben, Leoben, Austria
% email: office@harkeroleary.org,
% url: www.harkeroleary.org
%
% History:
%   Date:           Comment:
%

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
end
%
%
if mt > 1
    error('A column vector is expected for x');
end
%
%
% Test the degree and support length for campatability
%
if noBfs > ls
    error('The number of basis functions must fulfill n <= ls');
end
%
if ls > 13
    warning('With a support length greater than 13 there may be problems with the Runge phenomena.');
end
%
% Compute a full matrix
%
if (ls == noPts)
    [Gt, dGt] = dop( x, noBfs );
    S = dGt * Gt';
    rS = rank( S );
    if rS < noPts - 1
        warning(['The rank of S is ',int2str(rS),' while x has n = ',int2str(noPts),' points.']);
    end
    return;
end
%
% Test if the support length is compatible with the number of points
% requested.
%
if noPts < ls
    error('The number of nodes n must be greater that the support length ls');
end
%
if isEven( ls )
    disp(ls)
    error('this function is only implemented for odd values of ls.');
else
    %
    %------------------------------------------------------------------------
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
    
    startX = x(range);
    [Gt, dGt] = dop( startX, noBfs );
    Dt = dGt * Gt';
    %
    for k=1:length(halfRange)
        row = halfRange(k) * ones(length(range),1);
        %
        rows = [rows; row];
        cols = [cols; range];
        vals = [vals; Dt(halfRange(k),:)'];
    end
    %
    % Compute the strip diagonal entries
    %
    noOnDiag = noPts - 2 * ls2;
    for k=1:noOnDiag
        localX = x(range+k);
        [Gt, dGt] = dop( localX, noBfs );
        tdGt = dGt(ls2,:);
        dt = tdGt * Gt';
        row = (k + ls2) * ones( length(range),1 );
        %
        rows = [rows; row];
        cols = [cols; range + k];
        vals = [vals; dt'];
    end
    %
    % generate the bottom part of Si
    %
    endX = x(end-ls+1:end);
    [Gt, dGt] = dop( endX, noBfs );
    Dt = dGt * Gt';
    halfRange = (noPts-ls2+1:noPts)';
    range = (noPts-ls+1:noPts)';
    for k=1:length(halfRange)
        row = halfRange(k) * ones(length(range),1);
        %
        rows = [rows; row];
        cols = [cols; range];
        vals = [vals; Dt(k+ls2-1,:)'];
    end
    %
    S = sparse(rows, cols, vals, noPts, noPts );
    %
    rS = sprank( S );
    if rS < noPts - 1
        warning(['The rank of S is ',int2str(rS),' while x has n = ',int2str(noPts),' points.']);
    end
    %
    if ~genSparse
        S = full(S);
    end
    %
end