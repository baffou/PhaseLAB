function [R Q]=rq(A)
%
% Purpose : Compute the RQ decomposition of a matrix such that,
%       R Q = A
%
% Use (syntax): [R Q]=rq(A)
%
% Input Parameters :
%   A: a matrix
%
% Return Parameters :
%   R: is an upper trinagular matrix
%   Q: is a unitary matrix Q' * Q = I
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

[Qi Ri]=qr(flipud(A).');
%
% Map the results
%
R=fliplr(flipud(Ri.'));
Q=flipud(Qi.');