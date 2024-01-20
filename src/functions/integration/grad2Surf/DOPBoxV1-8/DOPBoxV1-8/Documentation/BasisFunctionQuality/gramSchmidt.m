%%
% \documentclass[12pt]{article}
% 
% \title{Discrete Orthogonal Polynomial Toolbox\\
%  \textbf{DOPBox}:\\
%  \\
% Investigation of Basis Function Quality}
% 
% \author{Matthew Harker and Paul O'Leary\\
% Institute for Automation\\
% University of Leoben\\
% A-8700 Leoben,
% Austria\\
% URL: automation.unileoben.ac.at\\
% \\
% Original: January 9, 2013\\
% $\copyright$ 2012\\
% \\
% Last Modified: \today}
% 
%
%%
% \begin{abstract}
%      This file uses the DOP Toolbox to investigates objective measures
%      for the quality of  discrete orthonormal basis functions $\M{B}$. 
%      different measures are compared: the Gramian i.e, the determinant of the
%      Gram matrix, $|\M{G}| = |\MT{B} \M{B}|$; the maximum error in the projection onto the
%      orthogonal complement, $\max( \M{I} - \M{G})$; and the Frobenius
%      norm of the projection onto the orthogonal complement $\|\M{I}
%      - \M{G})\|_F$.
%
%      The quality of the new synthesis algorithm is verified.
% \end{abstract}
%%
% \section{Functions used from the \lstinline{DOPBox} toolbox.}
%
% This file uses the functions:
% \begin{enumerate}
%    \item \lstinline{dop}: to synthesize the orthogonal basis functions.
% \end{enumerate}
%
%
%%
% \section{Introduction}
%
% Much has been written on the application of discrete orthogonal basis
% functions, particularly in image 
% processing~\cite{Mukundan2001,Yap2003,Yap2005,Yang2006,Hosny2007,Zhu2007,Zhu2007B,baik2007}. 
% Unfortunatly, very little
% work has been do to establish objective measured for the quality of basis
% functions. In general the quality of the basis functions was measured
% using the reconstruction quality of an image. This is unsatisfactory since
% the result is a mixture of the information content of the image and the
% quality of the basis functions.
% 
% Gram polynomials~\cite{Gram1883,Barnard1998,oleary2008b} are an
% interesting set of basis functions since they for an orthonormal basis
% function set. They are used in this investigation.
%
% This file investigate three possible measures for the quality of basis
% functions.
% The three measures are then used to compar the quality of Gram
% polynomials using the method originally proposed by Gram which has become
% known as Gram-Schmidt orthogonalization, with the polynomial synthesis
% method proposed in~\cite{oleary2008b} and applied in~\cite{Oleary2012}.
%%
% \section{Proposed Measures of Quality}
%
% Objective measures of quality of a set of basis functions are required,
% if we wish to evaluate new synthesis methody.
%
% Given a set of basis functions $\M{B}$ formed by concatinating the
% individual basis functions as the columns of $\M{B}$, the Gram matrix is
% defined as,
%
% \begin{equation}
%    \M{G} = \MT{B} \, \M{B}.
% \end{equation}
% %
% Ideally, the Gram matrix should be the identity matrix independent of the
% degree of the set of basis functions. Consequently, the projection onto
% the orthogonal complement,
%
% \begin{equation}
%    \M{G}^\perp = \M{I} - \M{G} = \M{0}
% \end{equation}
%
% should be exactly the zero matrix.
%
% \subsection{The Gramian as a measure of quality}
% The Gramian is defined as the
% determinant of the Gram matrix. Here we define the symbol 
% $g_{\M{B}} \defas |\M{G}| = | \MT{B} \, \M{B} |$ as the Gramian 
% of the set of basis functions contained in $\M{B}$.
% The determinant of the Gram matrix should be exactly, i.e. $|\M{G}| =
% 1$. Consequently the error measure can be defined as $\epsilon_{g} = 1 -
% g_{\M{B}}$.
% 
% \subsection{The maximum in $\M{G}^\perp$}
% The first new measure proposed here is the maximum value in the matrix
% $\epsilon_m = \max(\M{G}^\perp)$.
%
% \subsection{The Frobenius norm of $\M{G}^\perp$}
%
% The Frobenius norm of $\epsilon_F = \|\M{G}^\perp\|_F$ is a measure for
% the total error.
%
% \subsection{Error Measures and number of Significant Digits}
%
% Ideally the error measures $\epsilon$ should be exactly zero. However,
% all computer systems have finite precision, e.g. MATLAB has
% \lstinline{eps = 2.2204e-16}. This is the smallest relative
% distance between two numbers, if we consider the number $1$ there there
% are approximatly $d_s = 16$ significant digits. The significant digits
% for the basis functions can be estimates from the error measures as follows,
% $d_s \approx \log_{10}(\epsilon)$
%
% \section{A new Synthesis Algorithm}
%
% The synthesis method proposed by Gram~\cite{Gram1883} is now known as
% Gram Schnidt orthogonalization. This method is, however, known to be
% numerically unstable. A method based on complete re-orthogonalization
% was proposed in~\cite{oleary2008b} and applied to inverse problems in~\cite{Oleary2012}.
% The proposed error measures are used here to compare the two synthesis
% methods.
%%
% \section{Matlab Code}
%
% A few preparatory lines of code.
%
close all;
clear all;
setUpGraphics;
%%
% define the minimum and maximum degrees to be tested
minD = 5;
maxD = 70;
%
% Define a vector of degrees
%
d = minD : maxD ;
%
% Prepare storage for the results
%
noSims = length( d );
Eg = zeros( noSims, 1 );
Em = zeros( noSims, 1 );
Ef = zeros( noSims, 1);
%%
% Compute the measures of error for each degree
%
for k=1:noSims
    %
    % Synthesize the basis functions using Gram Schmidt orthogonalization
    %
    B2 = dopGram( d(k) );
    %
    % Compute the Gram matrix and its orthogonal complement
    %
    G = B2' * B2;
    Gort =  G - eye(d(k));
    %
    % compute the error measures
    %
    Eg(k) = 1 - det( G );
    Em(k) = max(abs(Gort(:)));
    Ef(k) =  norm(Gort,'fro');
    %
end;
%%
% \subsection{Measures for Gram Schmidt synthesis}
%
% The error measures for the Gram Schmidt synthesis of the Gram polynomials
% are shown in Figure~\ref{Figure1}. The error measures $\epsilon_m$ and 
% $\epsilon_f$ deliver similar results indicating that there is a low in
% significant digits even for very modest degrees and that the quality of
% the basis functions degenerats progressively. The Gramian $\epsilon_m$
% shown no initial degredation up to a degree of $d \approx 30$ and then
% degenerates more rapidly. At degree $d \approx 60$ the basis functions
% have degenerated to an extend that there are no significant digits.
%
fig1 = figure;
plot( d, log10(abs(Eg)+eps), 'k');
hold on;
plot( d, log10(Em), 'r' );
plot( d, log10(Ef), 'b' );
%
range = axis;
plot( [34,34], range(3:4), 'k');
plot( [59,59], range(3:4), 'k');
grid on;
%
xlabel('Degree $$d$$');
ylabel('$$ \log_{10}( \epsilon )$$');
legend( '$$\epsilon_g$$', '$$\epsilon_m$$','$$\epsilon_f$$','Location','NorthWest');
% \caption{Error measures for the Gram Schmidt synthesis of the Gram polynomials.}
%%
% \subsection{Measures for synthesis using \lstinline{dop.m}}
%
% In this the synthesis algorithn with complete orthogonalization is
% investigated. It produces high quality basis functions for very high
% degrees. To avoid inordinate computation time the degrees at which the
% reqults are logarithmicly spaced, here between $d = 10 \ldots 1000$.
%

% setup the vector of degrees
%
Log10minD = 1;
Log10maxD = 3;
%
% Use a logarithmic spacing of the degree to save time
%
d = round(logspace( Log10minD, Log10maxD ));
%
% Prepare stoorage for the results
%
noSims = length( d );
Eg = zeros( noSims, 1 );
Em = zeros( noSims, 1 );
Ef = zeros( noSims, 1);
%%
% Compute the measures of error for each degree
%
for k=1:noSims
    %
    % Synthesize the basis functions using the new procedure
    %
    B2 = dop( d(k) );
    %
    % Compute the Gram matrix and its orthogonal complement
    %
    G = B2' * B2;
    Gort =  G - eye(d(k));
    %
    % compute the error measures
    %
    Eg(k) = 1 - det( G );
    Em(k) = max(abs(Gort(:)));
    Ef(k) =  norm(Gort,'fro');
    %
end;
%%
% Plot the results for the new algorithm
%
fig2 = figure;
plot( d, log10(abs(Eg)+eps), 'k');
hold on;
plot( d, log10(Em), 'r' );
plot( d, log10(Ef), 'b' );
grid on;
%
xlabel('Degree $$d$$');
ylabel('$$ \log_{10}( \epsilon )$$');
legend( '$$\epsilon_g$$', '$$\epsilon_m$$','$$\epsilon_f$$','Location','NorthWest');
% \caption{Error measures for the complete orthogonalization synthesis of the Gram polynomials.}
%%
% Note that there are still more than $d_s > 13$ significant digits at
% degree $d = 1000$. These basis functions are for all intents and
% purposes free from error.
%
%%
% \section{Conclusions}
% The Frobenius norm of the orthogonal complement of the Gram matrix
% yields a stable estimate for the error in a set of orthogonal basis
% functions. It corresponds to the upperbound of the deviation of teh
% Granian from $1$, it is however, more stable (see Figure~\ref{Figure2}).
%
% The synthesis method for basis functions implemented in \lstinline{dop.m}
% yield basis functions which have excelent quality even at degrees of $d
% = 1000$.
%
%%
% \bibliographystyle{plain}
% \bibliography{cps}
