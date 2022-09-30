function nodes = dopNodes( n, type )
% Purpose : This function generates a set of n nodes of the requested type.
% In general such nodes are then used to synthesize basis functions.
%
% Use (syntax): nodes = dopNodes( n, type )
%
% Input Parameters :
%       n: the number of nodes
%       type: this paramater determines which set of nodes are generated.
%       The type should be one of the following:
%
%       'Gram': generate the nodes required for the gram polynomials.
%       'GramEnds': a set of equally spaced nodes in the interval [-1,1].
%       'Cheby': the Chebyshev nodes.
%       'ChebyEnds': the Chebyshev nodes in the full interval [-1,1].
%
% Return Parameters :
%       nodes: an n column vector containing the values of the nodes.
%
% Description and algorithms:
%
% References : 
%
% Author :  Matthew Harker and Paul O'Leary
% Date :    17. January 2013
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

type = lower( type ); % ensure that the selection is not case sensitive.
switch type
    case 'gram'
        % Gram points
        k = [1:n]';
        nodes = -1 + (2*k - 1) / n;
    case 'gramends'
        % gram extended to the end of the interval [-1,1]
        nodes = linspace(-1,1,n)';
    case 'cheby'
        % the Chebyshev nodes
        k = [1:n]';
        nodes = - cos( pi * (k -1/2) / n );
    case 'chebyends'
        k = linspace(0,1,n)';
        nodes = - cos( pi * k );
    otherwise
        error('Invalid node type selected, see help dopNodes for further information');
end;