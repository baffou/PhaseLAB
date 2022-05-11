function publishFigureFormat;
%
FontSize=12;
%
set(0,'DefaultFigureColor',[1,1,1]);
set(0,'DefaultaxesFontName','Times New Roman');
set(0,'DefaultaxesFontSize',FontSize);
set(0,'DefaulttextFontName','Times New Roman');
set(0,'DefaulttextFontSize',FontSize);
set(0,'DefaultfigurePaperType','A4');
set(0,'DefaultuicontrolFontName','Times New Roman');
set(0,'DefaultuicontrolFontSize',FontSize-1);
set(0,'DefaultTextInterpreter', 'latex');
%
%warning('off','MATLAB:dispatcher:InexactCaseMatch');
%
% Special Settings for normal figures
%
width=13.5;
height=8;
%
FigureSize=[1 1 width height];
MyAxesPosition=[0.1300 0.1500 0.8500 0.7500];
%
set(0,'DefaultFigureUnits','centimeters');
set(0,'DefaultFigurePosition',FigureSize);
set(0,'DefaultFigurePaperUnits','centimeters');
set(0,'DefaultFigurePaperPosition',FigureSize);
set(0,'DefaultaxesPosition',MyAxesPosition);


