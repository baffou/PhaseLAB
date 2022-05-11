function even = isEven( numbers );
%
% Purpose : Checks is a number is even
%
% Use (syntax): even = isEven( numbers );
%
% Input Parameters :
%       numbers: a scalar or vector of scalars
%
% Return Parameters :
%       even: boolean or vector of boolean
%
% Description and algorithms:
%
% References : 
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

even = zeros( size( numbers ) );
%
rest = mod( numbers, 2 );
%
ind = find( rest == 0 );
%
if ~isempty( ind )
    even( ind ) = 1;
end;