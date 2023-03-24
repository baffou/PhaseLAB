function writeStringCells2file( cellArray, fileName )
%
% Purpose : This functions writes a cell array of strings to an ascii file.
% E.g. text = matrix2latex( A ), could generate such a cell array. It a
% convenient documentation tool.
%
% Use (syntax):
%   writeStringCells2file( cellArray, fileName )
%
% Input Parameters :
%   cellArray: the cell array of strings. note some special cahacters e.g \
%   must be doubled up i.e. \\ if MATLAB is to write them correctly to disk. 
%
% Return Parameters :
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

%
fid = fopen( fileName, 'wt' );
if (fid == -1)    
    error('the file failed to open');
end;
%
%
[n, m] = size( cellArray );
%
if m > 1
    error('This function expects a cell array of dimension n x 1');
end;
%
for k=1:n
    line = cellArray{k};
    fprintf(fid,[line,' \n']);
end;
%
st = fclose( fid );