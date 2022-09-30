function hOut = g2sPlotSurf( x, y, Z, hIn, figTitle )
%
% Purpose : Plots a surface Z with x and y abscissae using the "surfl"
%   function, according to the convention of the "g2s" functions.
%
% Use (syntax):
%   g2sPlotSurf( x, y, Z )
%   g2sPlotSurf( x, y, Z, hIn )
%   g2sPlotSurf( x, y, Z, hIn, figTitle )
%   hOut = g2sPlotSurf( x, y, Z )
%   hOut = g2sPlotSurf( x, y, Z, hIn )
%   hOut = g2sPlotSurf( x, y, Z, hIn, figTitle )
%
% Input Parameters :
%   x, y := support vectors of nodes of the domain of the gradient
%   Z := The surface to be plotted
%   hIn := handle to an open figure (optional)
%   figTitle := the title of the figure (optional)
%
% Return Parameters :
%   hOut := handle to the figure which is opened
%
% Description and algorithms:
%   Plots the surface using MATLAB's "surfl" according to the domain
%   conventions of the "g2s" functions.
%
% References :
%    @inproceedings{
%    Harker2008c,
%       Author = {Harker, M. and O'Leary, P.},
%       Title = {Least Squares Surface Reconstruction from Measured Gradient Fields},
%       BookTitle = {CVPR 2008},
%       Address= {Anchorage, AK},
%       Publisher = {IEEE},
%       Pages = {1-7},
%          Year = {2008} }
%
%    @inproceedings{
%    harker2011,
%       Author = {Harker, M. and O'Leary, P.},
%       Title = {Least Squares Surface Reconstruction from Gradients:
%           \uppercase{D}irect Algebraic Methods with Spectral, \uppercase{T}ikhonov, and Constrained Regularization},
%       BookTitle = {IEEE CVPR},
%       Address= {Colorado Springs, CO},
%       Publisher = {IEEE},
%       Pages = {2529--2536},
%          Year = {2011} }
%
% Author :  Matthew Harker and Paul O'Leary
% Date :    25. June 2013
% Version : 1.0
%
% (c) 2013 Matthew Harker and Paul O'Leary, 
% Chair of Automation, University of Leoben, Leoben, Austria
% email: office@harkeroleary.org, 
% url: www.harkeroleary.org
%
% History:
%   Date:           Comment:
%   Jun. 18, 2013   Original Version
%
if nargin > 3
    %
    figure(hIn) ;
    hOut = hIn ;
    %
end
%
if nargout == 1
    %
    hOut = figure ;
    %
end
%
surfl(x,y,Z);
shading interp
colormap(gray);
xlabel('{\it x}') ;
ylabel('{\it y}') ;
%
axis equal
%
if nargin == 5
    title( figTitle ) ;
end
%
%========
% END
%========