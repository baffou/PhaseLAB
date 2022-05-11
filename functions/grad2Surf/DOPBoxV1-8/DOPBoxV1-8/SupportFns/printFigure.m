function printFigure(H,FileName,Format,PrintOn)
%
% Description: Function to print a figure to disk
%
% Input Parameters:
%  H:        Handel to the figure which is to be plotted
%  FileName: File name to be used without extension
%  Format:   The type of file format to be used.
%                  jpg, bmp, wmf, eps, eps2, png
%  PrintOn:  Boolean to switch on or off printing.
%
% Return Paramerets:
%
%
% By: 		Paul O`Leary
% Date:		2. July 1999
% Version:	1.0
%
% (c) 1999, Instutite for Automation, University of Leoben, Leoben, Austria
% email: automation@unileoben.ac.at, url: automation.unileoben.ac.at
%
%
% History:
%	Date: 	Comment:
%	1.7.1999	Original Vereion 1.0
%
narg=nargin;
figure(H);
drawnow;
%
if ((nargin==4)&(PrintOn==1))|(nargin==3)
    Format=lower(Format);
    switch Format,
        case {'jpg'}
            print('-djpeg','-opengl','-zbuffer',FileName);
        case {'wmf'}
            print('-dmeta',FileName);
        case {'eps'}
        %
            figure2eps( H, FileName );
        %
        case {'tiff'}
            print('-dtiffn','-opengl','-r300','-zbuffer',FileName);
        case {'bmp'}
            print('-dbitmap','-opengl','-r300','-zbuffer',FileName);
        case {'png'}
            print('-opengl','-dpng','-loose','-zbuffer',FileName);
        case {'pdf'}
            print('-opengl','-dpdf','-loose','-zbuffer',FileName);
        otherwise
            error('Incorrect file format requested');
    end;
end;
%
% End M file