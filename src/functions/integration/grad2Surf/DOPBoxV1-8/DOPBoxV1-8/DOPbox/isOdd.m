function odd = isOdd( numbers )
%
% Purpose : This function checks is a number is odd
%
% Use (syntax): odd = isOdd( numbers )
%
% Input Parameters :
%       numbers: scalar or vector of scalars
%
% Return Parameters :
%       odd: boolean or vector of boolean
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

odd = zeros( size( numbers ) );
%
rest = mod( numbers, 2 );
%
ind = find( rest == 1 );
%
if ~isempty( ind )
    odd( ind ) = 1;
end;