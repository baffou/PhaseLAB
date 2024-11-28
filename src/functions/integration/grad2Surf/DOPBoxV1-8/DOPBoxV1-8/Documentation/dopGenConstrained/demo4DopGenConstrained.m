%% Demo4: Constraining Outside the Range of the Support
%
% This demonstration shows the possability of placing constraints
% outside the range of the support of the basis functions. Such
% problems occure when solving Sturm-Liouville problems.
%
%
% (c) 2013 Paul O'Leary and Matthew Harker
% Institute for Automation
% University of Leoben
% A-8700 Leoben
% Austria
%
% URL: automation.unileoben.ac.at
% Email: office@harkeroleary.org
%
%%
close all;
clear all;
%
% Set some defaults
%
FontSize = 12;
set(0,'DefaultaxesFontName','Times');
set(0,'DefaultaxesFontSize',FontSize);
set(0,'DefaulttextFontName','Times');
set(0,'DefaulttextFontSize',FontSize);
set(0,'DefaultfigurePaperType','A4');
set(0,'DefaultTextInterpreter', 'latex');
%% Example 1: A Simple Example
%
% This is a simple example: The basis functions are computed in the
% range (-1 <= x <= 1) a zero value constraint is placed at X = -0.35
% (not at a node), a zero derivative constraints is placed at x = 1.
% and an zero additional zero constraint is placed at 1.1, .e. outside
% the raneg of the support.
%
% Define the Number of Basis Functions and x
%
nrBfs = 8;
%
% Note the basis functions are computed on the Tchebyshev points, i.e.
% there are for the range (-1 < x < 1)
%
nrPts = 15;
x = dopNodes( nrPts, 'Gramends');
%%
% Definig the Triplets for the Constraints
%
t1 = [0,1.1,1]; % note this constraint is outside the range
t2 = [1,1,0];
t3 = [0,-0.35,0]; % this constraint is not at a node.
%
% Concatinate the triplets to form an array of triplest which define all
% the constraints.
%
T = [t1; t2; t3];
%%
% Call |dopGenConstrained|
%
[yp, Bh, S] = dopGenConstrained( x, nrBfs, T );
%%
% Display the Prticular Solution
%
% Here the minimum degree  psrticular solution is
% displayed.
%
fig1 = figure;
plot(x, yp, 'b');
hold on;
xlabel( 'Support' );
ylabel( '$$y_p(x)$$' );
grid on;
plot( x, zeros( size(x)), 'ko', 'MarkerFaceColor', 'w');
plot( T(:,2), 0, 'ko', 'MarkerFaceColor', 'k');
legend( 'Min degree', 'Nodes','Constraint locations','Location', 'NorthWest');
%
title( 'Note the constraint outside the range');
%
%% 
% Display the Homogeneously Constrained Basis Functions
%
% The basis functions are interpolated to show them more smoothly
%
% Extract the recurrence coefficients from the structure S
rC = S.rC;
%%
% Now the basis functions at the nodes are plotted toegther with the
% basis functions extrapolated outside the range.
%
%%
% Define the range for the wxtrapolation and interpolation 
%
noInt = 200;
xMin = -1;  % This corresponds to the lower end of the range
xMax = 1.1; % This value is outside the range.
%
xi = linspace( xMin, xMax, noInt )';
%%
% generate the interpolated and extrapolated basis functions
%
[~, Bi] = dopInterpolate( ones( nrBfs, 1), rC, xi );
Bih = Bi * S.R;
%%
%
fig1 = figure;
plot( xi, Bih, 'k');
xlabel( 'Support' );
ylabel( '$$B_h(x)$$' );
grid on;
hold on;
plot( x, Bh, 'k.');
%
[nt, mt] = size( T );
for k = 1:nt
    plot( T(k,2), 0, 'ko', 'MarkerFaceColor', 'k');
end;
%
%% Example 2: Admissible Functions for a Sturm-Liouville Problem
%
% Define the Number of Basis Functions and x
%
nrBfs = 6;
%
% Note the basis functions are computed on the Tchebyshev points, i.e.
% there are for the range (-1 < x < 1)
%
nrPts = 9;
x = dopNodes( nrPts, 'Cheby');
%&
% Note the constraints are defined at x = -1 nd x = 1, i.e., outside
% the raneg of the support. This means the basis functions are not
% actually evaluated at these points, but would fulfil the constraints
% if extraporlated to these points.
%
t1 = [0,-1,0];
t2 = [0,1,0];
%
T = [t1; t2];
%% 
%
% Note the particular solution is the zero vector foe these
% constraints, for this reasone it is not computer here.
%
[~, Bh, S] = dopGenConstrained( x, nrBfs, T );
%% 
% Display the Homogeneously Constrained Basis Functions
%
% The basis functions are interpolated to show them more smoothly
%
% Extract the recurrence coefficients from the structure S
rC = S.rC;
%% 
% Interpolate and extrapolate the basis functions
%
% This figure shows the homogeneously constrained basis functions and
% the nodes at which the basis functions were computed prior to
% interpolation. Note the constraints are located at points which do
% not correspond to nodes.
%
noInt = 200;
xi = linspace( -1, 1, noInt )';
[~, Bi] = dopInterpolate( ones( nrBfs, 1), rC, xi );
Bih = Bi * S.R;
%
fig1 = figure;
plot( xi, Bih, 'k');
xlabel( 'Support' );
ylabel( '$$B_h(x)$$' );
grid on;
hold on;
plot( x, Bh, 'k.');
%
%%
% Now we zoom in to the end of the figure to show the points where the
% basis functions are evaluated 'k.', the interpolation and the
% extrapolation.
%
range = axis;
figure( fig1 );
axis( [0.8, 1, -0.6, 0.6] );
%%
% This may seem a very minor issue; however, it is key to solving a
% number of improtant problems. It enables us to places constraints on
% the value of solutions at specific points, without having the
% requirement of evaluating the functions at these points. 
% Many Schrodinger equations have energy functions which are singular
% at the end points, whereby the solution itsels is stable at these
% points. This numerical approach presents a possible solution to such
% problems.
%
% A further advantage of this method is that it enables the solution
% of a problem with high resolution for a subrange of the support
% while maintaining the constraints at the endpoints of the complete
% range.
