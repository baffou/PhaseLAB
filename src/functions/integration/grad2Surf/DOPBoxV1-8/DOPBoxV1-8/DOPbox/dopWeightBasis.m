function [Bw, Ui] = dopWeightBasis(B, W)
%
% Purpose : This function generates a discrete orthogonal weighted  
%           basis from a unitary basis function set. The weightings must
%           either be a vector w or a matrix W. In the case of a vector of
%           weighty they are used as the diagonal of the weighting matrix
%           i.e. W = diag(w);
%
% Use (syntax):
%       Pw = generateWeightedPoly(noPoints, degree, weights);
%
% Input Parameters :
%       B: A unitary basis set from which the weighted basis functions ar
%       eto be generated
%       W: the weights which must be the same length as the number of
%       points.
%
% Return Parameters :
%       Bw: the weighted polynomial basis.
%       Ui: The post multiplying matrix which einsures Bw = B * Ui
%
% Description and algorithms:
%       This algorith is based on a method developed by Paul O'Leary and
%       Matthew Harker.
%
% References : "Savitzky-Golay Smoothing for Multivariate Cyclic
% Measurement Data", Paul O'Leary, Matthew Harker and Richard Neumayr,
% Submitted to the National Indian Conference on Graphics and Computer
% Vision 2010, Jaipur India.
%
% Author :  Paul O'Leary
% Date :    15. Sept 2009
% Version : 1.0
%
% (c) 2009 Paul O'Leary, Chair of Automation, University of Leoben, Leoben, Austria
% email: automation@unileoben.ac.at, url: automation.unileoben.ac.at
%
% History:
%   Date:           Comment:
%   15. Sept        Original version
%
%--------------------------------------------------------
%

% if a vector of weights is delivered then generate the seighting matrix
if isvector(W)
    factor = 10;
    if ( min( W ) / max(W) )<= factor*eps
        error('The weighting vector must be positive definite.');
    end;
    W = diag( W );
end;
%
% test the inputs for correctness
%
[nW, mW] = size( W );
%
if ~(nW == mW)
    error('The weigthing matrix must be square');
end;
%
try
    % test if W is positive definite
    chol(W);
catch me
    error('The weighting matrix W must be positive semi definite');
end;
%
[nB, mB] = size( B );
if ~(nB == nW)
    error('The dimensions of the basis function matrix B and W are not consistent');
end;
%---------------------------------------------------------------
% Do the necessary computations to generate the weighted basis.
%
U = chol(B' * W * B);
Ui = inv( U );
%
Bw = B * Ui;