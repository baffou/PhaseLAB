function [ypMD, Bh, S] = dopGenConstrained( x, nrBfs, T, ls, noDBfs )
%
% Purpose : Compute the particular to a set of constraints and determine a
% set of basis functions which fulfil the constrainst in a homogeneous
% manner.
%
% The method is based on a postmultiplication of B, i.e. Bh = B * R i.e.,
% linear combinations  of the basis functions fulfil the constraints. The
% most notable difference to |dopConstrain| is that the derivatives are
% determined from the analytical derivatives and not from the numerical
% approximations of the derivatives.
%
% Use (syntax):
%  The matrix M to compute the derivatives of the coefficients is computed
%  on a global basis: M = BT * dB
%
%   [ypMD, Bh] = dopGenConstrained( x, nrBfs, T)
%   [ypMD, Bh, S] = dopGenConstrained( x, nrBfs, T)
%
%  In this case a local approximation for the derivative is computed and
%  the corresponding coefficient matrix M is determined from the local Ds
%       M = B' * D * B
%  This case may be used full when high degree polynomials are required and
%  where M would be come rank deficient.
%
%   [ypMD, Bh] = dopGenConstrained( x, nrBfs, T, ls, noDBfs )
%   [ypMD, Bh, S] = dopGenConstrained( x, nrBfs, T, ls, noDBfs )
%
% Input Parameters :
%   x:      The vector of x values at which the basis functions are to be
%           evaluated.
%   nrBfs:  The number of basis functions required
%   T:      An array of triplets which define the constraints
%           Each constraint is defined as a three vector
%   for example the constraint D(n) y(b) = b, i.e. the n-th derivative of y
%   at the points x = a, has the value. Some examples
%
%   t1 = [0, 1, 0]  => y(1) = 0
%   t2 = [1, 0, 1]  => D y(0) = 1
%   t3 = [3, 1, 0]  => D^3 y(1) = 0.
% 
%   the correponding T would be T = [t1; t2; t3];
%
%   Optional paramaters should local approximations for derivatives be
%   required.
%
%   ls:     Support length
%   noDBfs: Number of basis functions used in the local derivative
%           approximation.
%
% Return Parameters :
%
%   ypMD:   The minimum degree particular solution 
%   Bh:     The set of homogeneously constrained basis functions
%   S:      (optional) a structure containing many intermediate variables,
%           see the end of this code for a full list.
%
% Description and algorithms:
%
% References : 
%
% Author :  Matthew Harker and Paul O'Leary
% Date :    17. July 2013
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

%
% generate the unconstrained basis functions
%
[B, dB, rC] = dop( x, nrBfs );
%-----------------------------------------------------------------------
% Compute the matrix required to compute the defivatives of the
% coefficients
%
% Two cases:
% 1) if ls and noDBfs are provided then use a local estimate for D 
%    and compute M from D.
%       M = B' D B;
% 2) otherwise compute M directly from B and dB
%       M = B^T dB
%
if nargin == 5
    disp('Using a local approx for M');
    DL = dopDiffLocal( x, ls, noDBfs );
    M = B' * DL * B;
else
    M = B' * dB;
end;
%-----------------------------------------------------------------------
% Convert the constraints defined as triplets to a constraint matrix
%
[nrCs, mCs] = size( T );
Ct = zeros( nrCs, nrBfs);
for k=1:nrCs
    [~, gi] = dopInterpolate( ones(nrBfs,1), rC, T(k,2) );
    Ct(k,:) = gi * M^(T(k,1));
end;
%
% The vector of constraint values
%
c = T(:,3);
%
% Test the constraints for uniqueness and consitency
%
[nCt, ~] = size( Ct );
rankCt = rank( Ct );
%
if rankCt < nCt
    warning('The constraints provided are not unique');
    if nargin == 3
        disp('This may also indicate that a local approach is required.');
    end;
end;
%
% Compute the minimum norm solution, this is a unique solution
%
ppMinNorm = pinv( Ct ) * c ;
%
% Determine the distance between the constraint values and the range of the
% constraints
%
err = norm( Ct * ppMinNorm - c );
errorTol = 1e-10;
if err > errorTol
    error(['The constraints provided are inconsistent, the values are not',... 
    ' in the range of the constraints.']);
end;
%---------------------------------------------------------------------
% Determine the null space of Ct and structure the coefficients so that
% they are in order of increasing power.
%
Cn = null(Ct);
%
% Compute an RQ decomposition of Ct to determine the ordered coefficients
%
[R,~] = rq( Cn );
%
% Compute the homogeneously constrained bases and their derivitives
%
Bh = B * R;
%----------------------------------------------------------------------
% Strating from the minimum morm solution determine the solution with the
% lowest possible dergee polynomial solution. This step is based on
% removing multiples of the null space from the minimum norm solution
%
[nr, mr] = size(R);
ppMinDegree = ppMinNorm;
tol = 1e-6;
for k=0:(mr-1)
    %
    % Extract the values require for scaling
    %
    r = R(nr-k,mr-k);
    p = ppMinDegree( nr - k );
    %
    if abs(r) > tol
        ppMinDegree = ppMinDegree - p * R(:,mr-k) / r;
    end;
end;
%------------------------------------------------------------------------
% Compute the particular solutions
%
ypMD = B * ppMinDegree;
ypMN = B * ppMinNorm;
%------------------------------------------------------------------------
% Save the intermediate variables is a structure for returning if required.
%
if nargout == 3
    S.B = B;    % Return the unconstrained basis functions
    S.dB = dB;  % Return the derivatives of B
    S.dBh = dB * R; % return the derivatives of Bh
    S.R = R;    % return the matrid R, whereby Bh = B * R.
    S.ypMN = ypMN; % the minimum norm particular solution
    S.ppMN = ppMinNorm; % The coefficients of the minimum norm solution, i.e.
                        % ypMN = B * ppMN
    S.ypMD = ypMD; % The minimum degree particular solution
    S.ppMD = ppMinDegree; % The coefficients of the minimum degree solution, i.e.
                        % ypMD = B * ppMD
    S.rC = rC;      % return the recurrence coefficients for interpolation.
    S.M = M;    % return the M matrix
    S.Ct = Ct;  % return the ct matrix
end;
