%% 
% \documentclass[12pt]{article}
%
% \title{Generate Admissible Functions using DOPbox}
% 
% \author{Matthew Harker and Paul O'Leary\\
% Institute for Automation\\
% University of Leoben\\
% A-8700 Leoben,
% Austria\\
% URL: automation.unileoben.ac.at\\
% \\
% Original: January 9, 2013\\
% $\copyright$ 2013\\
% \\
% Last Modified: \today}
%
%%
% This function demonstrates the use of the \lstinline{DOPbox} for the
% generation of admissible functions for a BVP and for the solution of the
% BVP, more details on this method can be found in~\cite{Oleary2012}.
%
% prepare tghe matlab environment
close all;
clear;
setUpGraphics;
%%
% \section{Synthesize Admissible Functions}
%
% Define the number of points and the number of basis functions to be
% generated.
%
noPts = 100;
noBfs = 15;
%
% Generate the vector of x values at which the problem is to be solved
%
x = linspace(0,1,noPts)';
%
% Synthesize the basis functions
%
[B, dB] = dop( x , noBfs );
%
% generate a local differentiating matrix
%
ls = 3;
noBfsD = ls;
D = dopDiffLocal( x, ls, noBfsD );
%
% Compute the second derivative
%
D2 = D * D;
D3 = D2 * D;
%----------------------------------------
% Define the constraints
%
% 1) Position constraint
c1 = zeros( noPts, 1);
c1(1) = 1;
%
% 2) derivative constraint
c2 = D(1,:)';
%
% 3) second derivatice constraint
c3 = D2(end,:)';
%
% 4) a positional constraint at 0.7
c4 = zeros( noPts, 1 );
frac = 0.7;
at = round( noPts * frac );
c4( at ) = 1;
%
c5 = D3(end,:)';
%
% form the constraint matrix
%
C = [c1, c2, c3, c4, c5];
%
% Synthesize the admissible functions
%
Bc = dopConstrain( C, B );
%
% plot the first three admissible functions
%
fig1 = figure;
for k=1:3
    plot( x, Bc(:,k), 'k');
    hold on;
end;
title('Admissible Functions for the BVP');
xlabel('$$x$$');
ylabel('$$y(x)$$');
grid on;
%\caption{The first three admissible functions.}
%
%%
%\section{Solve the Differential Equation}
%
% Define the linear differential opertor.
%
L = Bc' * D^4 * Bc;
%
% Compute the eigenvalues and eigenvectors
%
[vec, val] = eig( L );
%
% Sort the eigenvalues and vectors in assending order.
%
[val, inds] = sort( diag(val) );
vec = vec(:,inds);
%
% Compute the solution vectors from the spectrum.
%
solV = Bc * vec;
%
% Plot the solution vectors
%
fig2 = figure;
for k=1:3
    plot( x, solV(:,k), 'k');
    hold on;
end;
title('Solution to BVP');
xlabel('$$x$$');
ylabel('$$y(x)$$');
grid on;
%\caption{Eigenvectors for the Boundary Value Problem.}
%%
%\section{The spectrum of the Eigenvectors w.r.t. the Admissible Functions}
%
% The method implemented here is a discrete equivalent of a Rayleigh-Ritz
% method. The constrained polynomials are used for the series
% approximation. The \lstinline{vec} matrix contains the spectrum. Only the
% specrum of the first 4 eigenvectors w.r.t. the first 10 basis functions 
% are displayed here.
disp('The spectrum of the first 4 eigenvectors with respect to the first');
disp('10 basis functions');
vec(1:10,1:4)
%
%% Define the Bibliography
%
% \bibliographystyle{plain}
% \bibliography{harkerOleary}%
