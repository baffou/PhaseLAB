function S = expand2bandMatrix( n, D, option );
%
% Purpose : This function takes a matrix D and expands it to a banded
% matrix S of size(n x n) so that D operated as a local operator. It
% supports both sparse and full matrix notation.
%
% Use (syntax):
%   S = expand2bandMatrix( n, D );
%   S = expand2bandMatrix( n, D, 'spares' );
%
% Input Parameters :
%   n: The size of S is an (n x n) matrix
%   D: The matrix operator which is to be expanded
%   option: 'sparse' generated sparse matrix notations, default is full.
%
% Return Parameters :
%   S: is the banded matrix.
%
% Description and algorithms:
%
% References : 
%
% Author :  Paul O'Leary and Matthew Harker
% Date :    27 Jan 2012
% Version : 1.0
%
% (c) 20012 Paul O'Leary, Chair of Automation, University of Leoben, Leoben, Austria
% email: automation@unileoben.ac.at, url: automation.unileoben.ac.at
%
% History:
%   Date:           Comment:
%

%-----------------------------------------------------------------------
if nargin == 3
    genFull = ~strcmpi( option , 'sparse' );
else
    genFull = true;
end;
%
[p,q] = size( D );
%
% Is the requested output matrix size sufficiently large
%
if (n <= max( [p,q]))
    error( 'Given [p,q] = size( D ) then n > max( [p,q] ).');
end;
%
% Deal with the two cases is interstitial points.
%
if iseven( q )
    % if q is even then the computation is valid at the interstitial
    % points. Consequently p should be odd.
    if ( p ~= ( q - 1 ))
        error('Given [p,q] = size( D ), if q is even then p = q - 1.');
    end;
    %
    k = round( (p - 1)/2 );
    m = n - 1;
else
    % if q is odd then the computation is valid at the nodes, it is assumed
    % that the linear operator must deliver a solution for each node to be
    % complete. Consequently, p == q is required.
    if ( p ~= q )
        error('Given [p,q] = size( D ), if q is odd then p = q.');
    end;
    k = round( (p - 1) /2 );
    m = n;
end;
%-----------------------------------------------------------------------
% Extract the partitioning of D
%
D1 = D(1:k,:);
d = D(k+1,:)';
D2 = D(k+2:end,:);
%
rd = 1:length(d);
%
% Setup an empty S
%
S = zeros( m, n );
%
% Add the start and end blocks using sparce matrices
%
rs = 1:k;
cs = 1:q;
[Cs, Rs] = meshgrid( cs, rs );
R = Rs(:);
C = Cs(:);
D = D1(:);
%
%
rs = (m-k+1):m;
cs = (n-q+1):n;
[Cs, Rs] = meshgrid( cs, rs );
R = [R; Rs(:)];
C = [C; Cs(:)];
D = [D; D2(:)];
%
% Add the diagonal vector
%
noVs = m - 2 *k;
for j=1:noVs
    rs = j+k;
    cs = j+rd-1;
    [Rs, Cs] = meshgrid( rs, cs );
    R = [R; Rs(:)];
    C = [C; Cs(:)];
    D = [D; d];
end;
%
% Generate S
%
S = sparse( R, C, D, m, n );
%
% Convert to 'full' matrix notation if required.
%
if genFull
    S = full( S );
end;
