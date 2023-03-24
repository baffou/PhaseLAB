function setUpGraphics(FontSize)
%
% Purpose : This function changes some of the default graphic settings in
% MATLAB. This is used to generate figures with a specifi style.
%
% Use (syntax):
%   setUpGraphics(FontSize)
%
% Input Parameters :
%   FontSize: to be used as the default font size 
%
% Return Parameters :
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
%
if nargin==0
    % The default font size
    FontSize=12;
end;
%
set(0,'DefaultFigureColor',[1,1,1]);
set(0,'DefaultaxesFontName','Times');
set(0,'DefaultaxesFontSize',FontSize);
set(0,'DefaulttextFontName','Times');
set(0,'DefaulttextFontSize',FontSize);
set(0,'DefaultfigurePaperType','A4');
set(0,'DefaultTextInterpreter', 'latex');
