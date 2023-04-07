%% 
% \documentclass[12pt]{article}
%
% \title{\textbf{DOPbox}\\ Demonstration of the Chebyshev Polynomials}
% 
% \author{Matthew Harker and Paul O'Leary\\
% Institute for Automation\\
% University of Leoben\\
% A-8700 Leoben,
% Austria\\
% URL: automation.unileoben.ac.at\\
% \\
% Original: January 20, 2013\\
% $\copyright$ 2013\\
% \\
% Last Modified: \today}
%
%% 
%\section{Setting things up}
%
% Clear up the workspace
%
clear;
close all;
setUpGraphics;
%
% Define the number of points and the number of basis functions
%
noPts = 100;
noBfs = 5;
%%
%\section{Generate the nodes and basis functions}
%
% Generate the Chebyshev nodes
%
x = dopNodes( noPts, 'cheby');
%
% Setup the first two basis functions
%
t0 = ones( noPts, 1 );
t1 = x;
%
% Use the Chenbshev recurrence relationship
%
T = zeros( noPts, noBfs );
T(:,1) = t0;
T(:,2) = t1;
for k=3:noBfs
    T(:,k) = 2 * x .* T(:,k-1) - T(:,k-2);
end;
%%
% \section{Determine the quality of the basis functions}
%
% The discrete basis functions should form an orthogonal 
% (but not orthonormal) set of basis
% functions. The Gram matrix is defined as $\M{G} \defas \MT{T} \, \M{T}$.
%
G = T' * T;
%
% Removing the diagonal elements should yield a matrix of
% zeros.
%
Gperp = diag(diag(G)) - G;
%
% The Frobenius norm of Gperp is now used as a measure of quality for the
% basis functions.
%
e = (norm( Gperp, 'fro'));
%
%%
%
% and the $n_d = - log_{10}$ as an estimate for the number of available
% digits.
%
nd = - log10( e );
%
%%
% \section{Plot the basis functions}
%
% Plot the Chebyshev basis functions
%
figure
plot( x, t1, 'k' );
hold on;
for k=2:noBfs
    plot( x, T(:,k), 'k' );
end;
grid on;
xlabel('Support');
ylabel('Value');
title(['The first $$n = ',int2str( noBfs ),'$$ Chebyshev basis functions ( no digits $$n_d = ',num2str(nd),'$$)']);
% \caption{Some Chebyshev polynomials.}
%%
% \section{Plot the matrix of errors}
%
% Plot the error matrix.
%
fig2 = figure;
imagesc( Gperp );
colorbar;
axis image;
xlabel('Basis function no.');
ylabel('Basis function no.');
%
%\caption{Projection of the basis functions onto their orthogonal complement.}