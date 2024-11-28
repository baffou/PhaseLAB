function [Bc, X] = dopConstrain( C, B );
%
% Purpose : This functions applys a set of constraints C to a set of 
%           basis functions B such that
% 
%           Bc = B * X;
%           X' * X = I;
%           C' * Bc = 0;
% It is most commonly used to generate addmissible basis functions.
%
% Use (syntax):
%   Bc = dopConstrain( C, B );
%   [Bc, X] = dopConstrain( C, B );
%
% Input Parameters :
%   C: the matrix whos columns define the homogeneous constraints
%   B: a set of basis functions to which the constraints are applied
%
% Return Parameters :
%   Bc: the constrained basis functions C' * Bc = 0;
%   X: the uppertrinagular matrix defined such that Bc = B * X and X' + X =
%   I.
%
% Description and algorithms:
%
% References : 
%
% Author :  Matthew Harker and Paul O'Leary
% Date :    15 Jan 2012
% Version : 1.0
%
% (c) 2012 Paul O'Leary, Chair of Automation, University of Leoben, Leoben, Austria
% email: office@harkeroleary.org, 
% url: automation.unileoben.ac.at
%
% History:
%   Date:           Comment:
%

[n,m] = size( C );
[p,q] = size( B );
%
if ~(n==p)
    error('The matrix C must have the same number of rows as B');
end;
%
if rank( C ) >= q
    error( 'There are too many constraints');
end;
%
[Q, R] = qr( B' * C );
%
% partition according to the rank of C
%
p = rank( C );
%
Q2 = Q(:,p+1:end);
[X, ~] = rq( Q2 );
%
Bc = B * X;