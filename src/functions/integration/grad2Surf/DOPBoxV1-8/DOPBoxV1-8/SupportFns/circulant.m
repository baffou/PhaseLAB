function S = circulant( noPoints, coeffs, option);
%
% Purpose : This function generates a circulant metrix from a coefficient vector.
%
% Use (syntax):
%       S = circulant( noPoints, coeffs);
% Input Parameters :
%       noPoints: the number of points required, defines the size of S
%       coeffs: the coefficients to be used for convolution.
%       option: 'sparse' generated sparse matrix notations, default is full.
%
% Return Parameters :
%       S = the projection corresponding to the cyclic operator
%
% Description and algorithms:
%
% References :
%
% Author :  Paul O'Leary
% Date :    10. May 2012
% Version : 1.1
%
% (c) 2009 Paul O'Leary, Chair of Automation, University of Leoben, Leoben, Austria
% email: automation@unileoben.ac.at, url: automation.unileoben.ac.at
%
% History:
%   Date:           Comment:
%   15. Sept 2009      Original version
%   10. May 2012       Extended to also deal with sparse matrix formats
%
%--------------------------------------------------------
%
if nargin == 3
    intOption = option;
else
    intOption = 'full';
end;
%
S = zeros( noPoints );
% odd support length
%------------------------------
[n,m] = size( coeffs );
%
if n == 1
    ls = m;
elseif m == 1
    ls = n;
    coeffs = coeffs';
else
    error('The coefficients must be a vector');
end;
%
ls = length( coeffs );
if isodd( ls )
    m = round( (ls - 1) / 2 );
    %
    for k=1:noPoints - ls + 1;
        S(k+m,k:k+ls-1) = coeffs;
    end;
    %
    % generate the top region
    %
    coreStart = m + 1;
    coreEnd = noPoints - m;
    %
    for k=1:m
        L = m + k;
        front = coeffs( end-L+1:end );
        S( k, 1:L ) = front;
        %
        back = coeffs( 1:m-k+1 );
        b = length(back);
        S(k, end-b+1:end) = back;
    end;
    %
    % generate the bottom region
    %
    for k=1:m
        L = m + k;
        back = coeffs( 1:end-k  );
        b = length( back);
        S( coreEnd + k, end-b+1:end ) = back;
        %
        front = coeffs( end-k+1:end  );
        b = length( front );
        S(coreEnd + k, 1:b) = front;
    end;
else
    error('Only odd support lengths are supported presently');
end;
%
if strcmp( intOption, 'sparse' )
    % convert the circulant matrix to a sparse matrix
    [i,j,s] = find(S);
    [m,n] = size(S);
    S = sparse(i,j,s,m,n);
end;