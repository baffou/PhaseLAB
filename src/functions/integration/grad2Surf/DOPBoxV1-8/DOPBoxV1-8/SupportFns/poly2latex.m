function latexStr = poly2latex( p, variable )
%
% Purpose : This function converts a polynomial is a format compatible with
% MATLAB "poly" to a latex string.
%
% Use (syntax): str = poly2latex( poly, variable );
%
% Input Parameters :
%   p: the polynomial coefficients in decending degree.
%   variable: a string for the variable in which the polynomial is defined,
%   e.g. 'x'.
%
% Return Parameters :
%   latexStr: the required Latex string
%
% Description and algorithms:
%
% References :
%
% Author :  Paul O'Leary
% Date :    14 Dec 2011
% Version : 1.0
%
% (c) 2011 Paul O'Leary, Chair of Automation, University of Leoben, Austria
% email: automation@unileoben.ac.at, url: automation.unileoben.ac.at
%
% History:
%   Date:           Comment:
%
%

limit = 1e-10;
%
% remove leading zeros
%
n = length(p);
at = 1;
while (abs(p(at)) < limit) && (at < n)
    at = at + 1;
end;
%
p = p(at:end);
n = length(p);
%
% determine the degree of the polynomial
%
d = length(p) - 1;
%
%determine which coefficients are to be used
%
inds = find( abs(p) > limit );
%
% Prepare the sign symbols
%
signs = sign( p );
signSym = cell(d+1,1);
%
if signs(1) ~= 1
    signSym{1} = ' - ';
end;
%
for k=(1:d)+1
    if (signs(k) == 1)
        signSym{k} = ' + ';
    else
        signSym{k} = ' - ';
    end;
end;
%
% prepare the power symbols
%
powers = d:(-1):2;
powerSym = cell( d+1,1 );
at = 0;
for k=d:(-1):0
    at = at + 1;
    powerSym{at} = ['^{',int2str(k),'}'];
end;
%
% Prepare coefficient strings
%
coeffSym = cell( d+1,1 );
for k=1:(d+1)
    if (abs(p(k)) == 1) && (k < (d+1))
        coeffSym{k} = '';
    else
        coeffSym{k} = num2str(abs(p(k)));
    end;
end;
%
% Concatinate the polynomial
%
latexStr = [];
%
nu = length( inds )
for k=1:nu
    j = inds(k);
    if j == n
        latexStr = [latexStr, signSym{j}, coeffSym{j}];
    else
        latexStr = [latexStr, signSym{j}, coeffSym{j}, ' ', variable, powerSym{j}];
    end;
end;
%
    