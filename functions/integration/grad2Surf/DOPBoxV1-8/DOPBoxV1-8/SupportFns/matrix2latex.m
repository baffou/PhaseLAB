function txt = matrix2latex( D, tol, format )
%
% Purpose : This functioon converts a matlab matrix to a
% \begin{bmatrix}
% \end{bamtrix}
% Environment in latex. The numbers are given the provided fromat. This is
% a convenient tool for generating documentation.
%
% Use (syntax):
%   txt = matrix2latex( D, tol, format )
%
% Input Parameters :
%   D:      the matrix to be converted
%   tol:    the value below which the number is considered to be zero
%   format: see sprintf for details of formats
%
% Return Parameters :
%   txt:    is a cell array of strings. This is the Latex code for the
%   matrix; however, specific characters are doubled up so that when
%   writing to dist the correct string is obtained.
%
% The function writeStringCells2file.m will enable writing the text strings
% to a -tex file.
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
if nargin == 1
    tol = 1e-15;
    format = '%1.5f';
end;
%
[n,m] = size( D );
%
txt = cell( n + 2 , 1 );
%
txt{1} = '\\begin{bmatrix}';
%
for k=1:n
    line = '   ';
    d = D(k,1);
    if abs(d) < tol
        d = 0;
    end;
    line = [line, num2str(d,format)];
    for j=2:m
        d = D(k,j);
        if abs(d) < tol
            d = 0;
        end;
        line = [line,'& ', num2str(d,format)];
    end;
    if k<n
        line = [line, '\\\\ '];
    end;
    txt{k+1} = line;
end;
%
txt{end} = '\\end{bmatrix}';
