%% Demo2: Demonstrate Constrained Solution Spaces
%
% This script demonstrates the generation of a particular solution and 
% the determination of a set of homogeneously constrained basis 
% functions which fulfil constraints. The particular solution together
% with the constrained basis functions define the space of all possible
% solutions to the constrained problem. This space can then be used to
% solve differential equations, perform least square fitting etc.
%
% They can be used as admissible functions for discrete implementation
% of a discrete Rayleigh Ritz method for the solution of boundary
% value problems. See:
%
%       http://www.mathworks.com/matlabcentral/fileexchange/41250
%
% for their use in such problems.
%
% The constrained basis functions are orthonormal, i.e., Bh^T Bh = I.
% This property simplifies the solution of many problems, such as least
% squares approximation.
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
%% Define the Number of Basis Functions and x 
%
nrBfs = 10;
%
% Generate the vector of x values
%
nrPts = 200;
x = dopNodes( nrPts, 'Gramends');
%% Definig the Triplets for the Constraints
%
% Each triplet ti = [n, a, b] defined a constraint of the form
%
%   D^(n) y(a) = b
%
% Value constraints y(a) = b
%
t2 = [0, x(end), 2];
t3 = [0, x(1), 1];
%
% Derivative constraints D y(a) = b
%
t1 = [1, x(1), 0];
t4 = [1, x(end), 0];
%
% Concatinate the triplets to form an array of triplest which define all
% the constraints.
%
T = [t1; t2; t3; t4];
%% Call |dopGenConstrained|
%
% The function |dopGenConstrained| computes a particular solution y_p and
% determine a set of basis functions Bh suche that the homogeneous solution
% y_h = Bh * \beta. In this manner the possible solutions to y are of the
% form: y = y_p + y_h = y_p + Bh * \beta.
%
[ypMD, Bh, S] = dopGenConstrained( x, nrBfs, T );
%%
% Extract some additional information from the structure:
%
% 1) The derivatives of the homogeneously constrained basis functions.
dBh = S.dBh;
%%
% 2) The minimum norm particular solution
ypMN = S.ypMN;
%%
% 3) The structuring matrix R such that Bh = B * R 
R = S.R;
%% Display the Homogeneously Constrained Basis Functions
%
fig1 = figure;
plot( x, Bh, 'k');
xlabel( 'Support' );
ylabel( '$$B_h(x)$$' );
grid on;
%
%% Display the Derivitives of Bh
%
fig2 = figure;
plot( x, dBh, 'k');
xlabel( 'Support' );
ylabel( '$$\frac{d B_h(x)}{d x}$$' );
grid on;
%
%% Display Two Different particular Solutions
%
% Here the minimum degree and minimum norm psrticular solutions are
% displayed.
%
fig3 = figure;
plot(x, ypMD, 'b');
hold on;
plot(x, ypMN, 'r');
xlabel( 'Support' );
ylabel( '$$y_p(x)$$' );
grid on;
legend( 'Min degree', 'Min norm', 'Location', 'NorthWest');
%%
% Plot the positions of the constraints. The value constraints are drawn at
% their position and value with white filled circles. All other constraints
% i.e. differential constrainst, are marked as a position on the x axis.
%
[nt, mt] = size( T );
for k = 1:nt
    if T(k,1) == 0
        plot( T(k,2), T(k,3), 'ko', 'MarkerFaceColor', 'w');
    else
        plot( T(k,2), 0, 'ko', 'MarkerFaceColor', 'k');
    end;
end;