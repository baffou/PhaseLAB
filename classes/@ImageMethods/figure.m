function [hfig0out,UIk0,cb0] = figure(IM,varargin)
% Display an image in intensity and phase
% all the inputs are optional
% IM: can be either from the ImageEM or from the ImageQLSI classes.
% varargin: can be a number, in this case it is a figure handle hfig
%           can be strings: if 'px' 'µm', then it is assigned to the variable unit. default: 'px'
%                           if 'dx1' 'dx2', then it is assigned to the variable dx. default: 'st' (standard)

% UserData{1}:colorbars
% UserData{2}:unit
% UserData{3}:st/3D rendering
% UserData{4}:duo/mix image
% UserData{5}:current Image object.
% UserData{6}:colors.
% UserData{7}:subplots.
% UserData{8}:handles.
% UserData{9}.xLim,UserData{9}.yLim
% UserData{10}:measurements (alpha or OVD or crosscut).
% UserData{11}:XY coordinates when measuring a series of values on the images.
% UserData{12}:roiIN and OUT of Magic wand.

alpha = char(hex2dec('03B1'));

%% Default values
unit = 'px'; % default value
st3D = 'st';
duomix = 'duo';

%% attribution of the inputs
isfig = 0;
if nargin~=1 % not only IM specified
    for iar = 1:numel(varargin)
        if ischar(varargin{iar})
            if strcmp(varargin{iar},'px')
                unit = 'px';
            elseif  strcmp(varargin{iar},'µm') || strcmp(varargin{iar},'um')
                unit = 'µm';
            elseif strcmp(varargin{iar},'st') || strcmp(varargin{iar},'3D')
                st3D = varargin{iar};
            elseif strcmp(varargin{iar},'mix') || strcmp(varargin{iar},'duo')
                duomix = varargin{iar};
            elseif strcmp(varargin{iar},'single')
                duomix = 'mix';
            else
                error('wrong input')
            end
        else
            hfig0 = varargin{iar};
            isfig = 1;
        end
    end
end

if isfig==0
    hfig0 = figure;
    screenSz = get(groot,'ScreenSize');
    %[left bottom width height]
    set(hfig0,'position',[0 200 ceil(screenSz(3)) ceil(screenSz(4))-200]);
    %set(hfig0,'position',screenSz);
end

hfig0.UserData{2} = unit;
hfig0.UserData{3} = st3D;
hfig0.UserData{4} = duomix;
hfig0.UserData{5} = IM(1);

hfig0.UserData{12}.roiIN{1} = [];
hfig0.UserData{12}.roiOUT{1} = [];

%hfig0.ToolBar = 'none';
%hfig0.MenuBar = 'none';
%% Title of the figure

if isa(IM(1),'ImageQLSI')
    titleName = 'Experimental image';
else
    titleName = 'Numerical image';
end

if numel(IM)==1
    set(hfig0,'NumberTitle', 'off', 'Name',['NANOPHASE INTERFACE -- ' titleName])
else
    set(hfig0,'NumberTitle', 'off', 'Name',['NANOPHASE INTERFACE -- '  num2str(numel(IM)) ' ' titleName 's'])
end

%% Colors
AxesColor = [0 0 0];
BackgroundColor = [1 1 1];
PanelBackgroundColor = [0.8 0.8 0.8];
TitlePanelColor = 'k';
FunctionBackgroundColor = [1 0.9 0.8];
ButtonOnColor = [0.8 1 0.8];
ButtonOffColor = [0.94 0.94 0.94];

hfig0.UserData{6}.AxesColor = AxesColor;
hfig0.UserData{6}.ButtonOnColor = ButtonOnColor;
hfig0.UserData{6}.ButtonOffColor = ButtonOffColor;
set(hfig0,'color',BackgroundColor)

%%%%%%%%%%%%%%%%%%%%
%% GUI interface %%%
%%%%%%%%%%%%%%%%%%%%

%% definitions of the GUI components

bH = 20;    % box height
pWth = 120; % panel width
bWth = 30;  % box width
bWthL = 50;    % box width large
spacing = 3;
xshift = 28;

% Panels
hpProperties    = uipanel('Title','properties','FontSize',12,'FontWeight','bold','TitlePosition','centertop','ForegroundColor',TitlePanelColor,'BackgroundColor',PanelBackgroundColor,'Units','pixels');
hpMeasurements = uipanel('Title','measurements','FontSize',12,'FontWeight','bold','TitlePosition','centertop','ForegroundColor',TitlePanelColor,'BackgroundColor',PanelBackgroundColor,'Units','pixels');
hpDisplay = uipanel('Title','display','FontSize',12,'FontWeight','bold','TitlePosition','centertop','ForegroundColor',TitlePanelColor,'BackgroundColor',PanelBackgroundColor,'Units','pixels');
hpCorrections = uipanel('Title','corrections','FontSize',12,'FontWeight','bold','TitlePosition','centertop','ForegroundColor',TitlePanelColor,'BackgroundColor',PanelBackgroundColor,'Units','pixels');
hpControls    = uipanel('Title','controls','FontSize',12,'FontWeight','bold','TitlePosition','centertop','ForegroundColor',TitlePanelColor,'BackgroundColor',PanelBackgroundColor,'Units','pixels');

% image properties
hand.lambda = annotation(hpProperties,'textbox', 'FontSize',12,'Fontweight','bold','units','pix','Interpreter','Tex','LineStyle','none');
hand.obj = annotation(hpProperties,'textbox', 'FontSize',12,'Fontweight','bold','units','pix','Interpreter','Tex','LineStyle','none');
hand.pxSize = annotation(hpProperties,'textbox', 'FontSize',12,'Fontweight','bold','units','pix','Interpreter','Tex','LineStyle','none');
hand.Npx = annotation(hpProperties,'textbox', 'FontSize',12,'Fontweight','bold','units','pix','Interpreter','Tex','LineStyle','none');
hand.n1 = annotation(hpProperties,'textbox', 'FontSize',12,'Fontweight','bold','units','pix','Interpreter','Tex','LineStyle','none');
hand.n2 = annotation(hpProperties,'textbox', 'FontSize',12,'Fontweight','bold','units','pix','Interpreter','Tex','LineStyle','none');
hand.comment = annotation(hpProperties,'textbox', 'FontSize',12,'Fontweight','bold','units','pix','Interpreter','Tex','LineStyle','none');

% display panel
hand.standard = uicontrol('Parent',hpDisplay,'Style','pushbutton','String','standard');
hand.threeD = uicontrol('Parent',hpDisplay,'Style','pushbutton','String','3D');
hand.duo = uicontrol('Parent',hpDisplay,'Style','pushbutton','String','duo');
hand.single = uicontrol('Parent',hpDisplay,'Style','pushbutton','String','single');
hand.px = uicontrol('Parent',hpDisplay,'Style','pushbutton','String','px');
hand.um = uicontrol('Parent',hpDisplay,'Style','pushbutton','String','µm');


% corrections panel
hand.OPDhighPass = uicontrol('Parent',hpCorrections,'Style','pushbutton','String','OPD highPass','BackgroundColor',FunctionBackgroundColor);
hand.UIhighPass  =  uicontrol('Parent',hpCorrections,'Style','Edit','string',num2str(3),'HorizontalAlignment','Center');
hand.smooth = uicontrol('Parent',hpCorrections,'Style','pushbutton','String','smooth','BackgroundColor',FunctionBackgroundColor);
hand.UIsmooth  =  uicontrol('Parent',hpCorrections,'Style','Edit','string',num2str(2),'HorizontalAlignment','Center');
hand.Zernike = uicontrol('Parent',hpCorrections,'Style','pushbutton','String','Zernike','BackgroundColor',FunctionBackgroundColor);
hand.UIzernike_n = uicontrol('Parent',hpCorrections,'Style','Edit','string',num2str(1),'HorizontalAlignment','Center');
hand.UIzernike_m = uicontrol('Parent',hpCorrections,'Style','Edit','string',num2str(1),'HorizontalAlignment','Center');
hand.UIzernike_R = uicontrol('Parent',hpCorrections,'Style','Edit','string',num2str(floor(min([IM.Nx,IM.Ny])/2)-4),'HorizontalAlignment','Center');
hand.Z00 = uicontrol('Parent',hpCorrections,'Style','pushbutton','String','00','BackgroundColor',FunctionBackgroundColor);
hand.Z11 = uicontrol('Parent',hpCorrections,'Style','pushbutton','String','11','BackgroundColor',FunctionBackgroundColor);
hand.Z20 = uicontrol('Parent',hpCorrections,'Style','pushbutton','String','20','BackgroundColor',FunctionBackgroundColor);
hand.Z22 = uicontrol('Parent',hpCorrections,'Style','pushbutton','String','22','BackgroundColor',FunctionBackgroundColor);
hand.Z31 = uicontrol('Parent',hpCorrections,'Style','pushbutton','String','31','BackgroundColor',FunctionBackgroundColor);
hand.Z33 = uicontrol('Parent',hpCorrections,'Style','pushbutton','String','33','BackgroundColor',FunctionBackgroundColor);

% measurements panel
hand.pixels = uicontrol('Parent',hpMeasurements,'Style','pushbutton','String','pixel','BackgroundColor',FunctionBackgroundColor);
hand.area = uicontrol('Parent',hpMeasurements,'Style','pushbutton','String','area','BackgroundColor',FunctionBackgroundColor);
hand.distance = uicontrol('Parent',hpMeasurements,'Style','pushbutton','String','dist.','BackgroundColor',FunctionBackgroundColor);
hand.HVcrosscuts = uicontrol('Parent',hpMeasurements,'Style','pushbutton','String','HV cross','BackgroundColor',FunctionBackgroundColor);
hand.OV = uicontrol('Parent',hpMeasurements,'Style','pushbutton','String','OV','BackgroundColor',FunctionBackgroundColor);
hand.alpha = uicontrol('Parent',hpMeasurements,'Style','pushbutton','String',alpha,'BackgroundColor',FunctionBackgroundColor);
hand.roiAlphaOV = uicontrol('Parent',hpMeasurements,'Style','pushbutton','String',['roi ' alpha '/OV'],'BackgroundColor',FunctionBackgroundColor);
hand.magicAlphaOV = uicontrol('Parent',hpMeasurements,'Style','pushbutton','String',['MW ' alpha '/OV'],'BackgroundColor',FunctionBackgroundColor);
hand.crosscut = uicontrol('Parent',hpMeasurements,'Style','pushbutton','String','crosscut','BackgroundColor',FunctionBackgroundColor);
hand.PDCM = uicontrol('Parent',hpMeasurements,'Style','pushbutton','String','PDCM','BackgroundColor',FunctionBackgroundColor);
hand.radialCrosscut = uicontrol('Parent',hpMeasurements,'Style','pushbutton','String','radial cross','BackgroundColor',FunctionBackgroundColor);
hand.text_step = annotation(hpMeasurements,'textbox','String','step', 'FontSize',8,'Fontweight','bold','units','pix','Interpreter','Tex','LineStyle','none','HorizontalAlignment','center');
hand.text_NNP = annotation(hpMeasurements,'textbox','String','#NP', 'FontSize',8,'Fontweight','bold','units','pix','Interpreter','Tex','LineStyle','none','HorizontalAlignment','center');
hand.text_nmax = annotation(hpMeasurements,'textbox','String','nmax', 'FontSize',8,'Fontweight','bold','units','pix','Interpreter','Tex','LineStyle','none','HorizontalAlignment','center');
hand.text_bkgThick = annotation(hpMeasurements,'textbox','String','bkg thick.', 'FontSize',8,'Fontweight','bold','units','pix','Interpreter','Tex','LineStyle','none','HorizontalAlignment','center');
hand.UIalpha_NNP = uicontrol('Parent',hpMeasurements,'Style','Edit','string','1','HorizontalAlignment','Center');
hand.UIalpha_nmax = uicontrol('Parent',hpMeasurements,'Style','Edit','string','40','HorizontalAlignment','Center');
hand.UIalpha_step = uicontrol('Parent',hpMeasurements,'Style','Edit','string','1','HorizontalAlignment','Center');
hand.UIalpha_bkgThick = uicontrol('Parent',hpMeasurements,'Style','Edit','string','3','HorizontalAlignment','Center');
hand.UIalpha_Dz = uicontrol('Parent',hpMeasurements,'Style','Edit','string','0','HorizontalAlignment','Center');
hand.text_Dz = annotation(hpMeasurements,'textbox','String','zNP', 'FontSize',8,'Fontweight','bold','units','pix','Interpreter','Tex','LineStyle','none','HorizontalAlignment','center');
hand.text_Dze9 = annotation(hpMeasurements,'textbox','String','\times10^{-9}', 'FontSize',8,'Fontweight','bold','units','pix','Interpreter','Tex','LineStyle','none');
hand.UIresult = uicontrol('Parent',hpMeasurements,'Style','Edit','Max',2,'HorizontalAlignment','Center');

% measurements panel
hand.file = uicontrol('Parent',hpMeasurements,'Style','Edit','string','prefix','HorizontalAlignment','Center');
hand.folder = uicontrol('Parent',hpMeasurements,'Style','Edit','string',todayFolder(),'HorizontalAlignment','Center');
hand.save = uicontrol('Parent',hpMeasurements,'Style','pushbutton','String','save','BackgroundColor',[0.3 0.3 0.3],'ForegroundColor',[0.9 0.9 0.9]);
hand.autosave = uicontrol('Parent',hpMeasurements,'Style','checkbox','String','auto','Value',0,'BackgroundColor',PanelBackgroundColor);
hand.saveImage = uicontrol('Parent',hpMeasurements,'Style','pushbutton','String','save images','BackgroundColor',[0.3 0.3 0.3],'ForegroundColor',[0.9 0.9 0.9]);

% controls panel
hand.UIk      = uicontrol('Parent',hpControls,'Style','Edit','string',num2str(1),'HorizontalAlignment','Center');
hand.next     = uicontrol('Parent',hpControls,'Style','pushbutton','String','>');
hand.previous = uicontrol('Parent',hpControls,'Style','pushbutton','String','<');
hand.go       = uicontrol('Parent',hpControls,'Style','pushbutton','String','go');

hand.close    = uicontrol('Style','pushbutton','String','close','BackgroundColor',[0.3 0.3 0.3],'ForegroundColor',[0.9 0.9 0.9]);
hand.reload   = uicontrol('Style','pushbutton','String','reload','BackgroundColor',[0.3 0.3 0.3],'ForegroundColor',[0.9 0.9 0.9]);




%% Positions

%panels
set(hpProperties,     'Position',[ pWth+20 100+24*bH 3*pWth 4*bH]);
set(hpDisplay,        'Position',[ 10 100+23.5*bH pWth 4.5*bH]);
set(hpCorrections,    'Position',[ 10 100+17.8*bH pWth 5.7*bH]);
set(hpMeasurements,   'Position',[ 10 100 pWth 17.8*bH]);
set(hpControls,       'Position',[ 10 2*bH pWth 3*bH]);

%properties
offy = 5;
set(hand.lambda,      'Position', [ 10 offy+2*bH pWth bH]);
set(hand.obj,         'Position', [ 10+pWth offy+2*bH pWth bH]);
set(hand.pxSize,      'Position', [ 10+2*pWth offy+2*bH pWth bH]);
set(hand.Npx,         'Position', [ 10 offy+bH   pWth bH]);
set(hand.n1,          'Position', [ 10+pWth offy+bH   pWth bH]);
set(hand.n2,          'Position', [ 10+2*pWth offy+bH   pWth bH]);
set(hand.comment,     'Position', [ 10 offy      3*pWth bH]);

% display panel
offy = 5;
set(hand.standard,    'Position',[ pWth/2-bWthL/2-xshift 2*(bH+spacing)+offy bWthL bH]);
set(hand.threeD,      'Position',[ pWth/2-bWthL/2+xshift 2*(bH+spacing)+offy bWthL bH]);
set(hand.duo,         'Position',[ pWth/2-bWthL/2-xshift 1*(bH+spacing)+offy bWthL bH]);
set(hand.single,      'Position',[ pWth/2-bWthL/2+xshift 1*(bH+spacing)+offy bWthL bH]);
set(hand.px,          'Position',[ pWth/2-bWthL/2-xshift 0*(bH+spacing)+offy bWthL bH]);
set(hand.um,          'Position',[ pWth/2-bWthL/2+xshift 0*(bH+spacing)+offy bWthL bH]);

% corrections panel
offy = 5;
set(hand.smooth,      'Position',[ pWth/2-bWthL/2-xshift 3*(bH+spacing)+offy bWthL bH]);
set(hand.UIsmooth,    'Position',[ pWth/2                3*(bH+spacing)+offy bWth bH]);
set(hand.OPDhighPass, 'Position',[ pWth/2-bWthL/2-xshift 2*(bH+spacing)+offy bWthL*3/2 bH]);
set(hand.UIhighPass,  'Position',[ pWth/2+ xshift        2*(bH+spacing)+offy bWth bH]);
set(hand.Zernike,     'Position',[ pWth/2-bWthL/2-xshift 1*(bH+spacing)+offy bWthL bH]);
set(hand.UIzernike_n, 'Position',[ pWth/2                1*(bH+spacing)+offy bWth/2 bH]);
set(hand.UIzernike_m, 'Position',[ pWth/2+ xshift/2      1*(bH+spacing)+offy bWth/2 bH]);
set(hand.UIzernike_R, 'Position',[ pWth/2+ xshift        1*(bH+spacing)+offy bWth bH]);
set(hand.Z00,         'Position',[ pWth/2-bWthL/2-xshift+00 0*(bH+spacing)+offy bWthL/3 bH]);
set(hand.Z11,         'Position',[ pWth/2-bWthL/2-xshift+19 0*(bH+spacing)+offy bWthL/3 bH]);
set(hand.Z20,         'Position',[ pWth/2-bWthL/2-xshift+38 0*(bH+spacing)+offy bWthL/3 bH]);
set(hand.Z22,         'Position',[ pWth/2-bWthL/2-xshift+57 0*(bH+spacing)+offy bWthL/3 bH]);
set(hand.Z31,         'Position',[ pWth/2-bWthL/2-xshift+76 0*(bH+spacing)+offy bWthL/3 bH]);
set(hand.Z33,         'Position',[ pWth/2-bWthL/2-xshift+95 0*(bH+spacing)+offy bWthL/3 bH]);

% measurements panel
offy = 17;
set(hand.pixels,      'Position',[ pWth/2-bWthL/2-xshift 13*(bH+spacing)+offy bWthL*2/3 bH]);
set(hand.area,        'Position',[ pWth/2-bWthL/3        13*(bH+spacing)+offy bWthL*2/3 bH]);
set(hand.distance,    'Position',[ pWth/2-bWthL/3+xshift*4/3 13*(bH+spacing)+offy bWthL*2/3 bH]);

set(hand.HVcrosscuts, 'Position',[ pWth/2-bWthL/2-xshift 12*(bH+spacing)+offy bWthL bH]);
set(hand.radialCrosscut,'Position',[pWth/2-bWthL/2+xshift 12*(bH+spacing)+offy bWthL bH]);
set(hand.crosscut,    'Position',[ pWth/2-bWthL/2-xshift 11*(bH+spacing)+offy bWthL bH]);
set(hand.PDCM,    'Position',[ pWth/2-bWthL/2+xshift 11*(bH+spacing)+offy bWthL bH]);

set(hand.alpha,       'Position',[ pWth/2-bWthL/2-xshift 10*(bH+spacing)+offy bWthL bH]);
set(hand.OV,          'Position',[ pWth/2-bWthL/2+xshift 10*(bH+spacing)+offy bWthL bH]);
set(hand.roiAlphaOV,    'Position',[ pWth/2-bWthL/2-xshift 9*(bH+spacing)+offy bWthL bH]);
set(hand.magicAlphaOV,  'Position',[ pWth/2-bWthL/2-xshift 8*(bH+spacing)+offy bWthL bH]);
set(hand.text_NNP,    'Position',[ pWth/2-bWthL/2-xshift 7.5*(bH+spacing)+offy bWthL*2/3 bH/2]);
set(hand.text_nmax,   'Position',[ pWth/2-bWthL/3        7.5*(bH+spacing)+offy bWthL*2/3 bH/2]);
set(hand.text_bkgThick,'Position',[pWth/2-bWthL/3+xshift*4/3 7.5*(bH+spacing)+offy bWthL*2/3 bH/2]);
set(hand.UIalpha_NNP, 'Position',[ pWth/2-bWthL/2-xshift 6.5*(bH+spacing)+offy bWthL*2/3 bH]);
set(hand.UIalpha_nmax,'Position',[ pWth/2-bWthL/3        6.5*(bH+spacing)+offy bWthL*2/3 bH]);
set(hand.UIalpha_bkgThick,'Position',[pWth/2-bWthL/3+xshift*4/3 6.5*(bH+spacing)+offy bWthL*2/3 bH]);
set(hand.text_step,   'Position',[pWth/2-bWthL/2-xshift  6*(bH+spacing)+offy bWthL*2/3 bH/2]);
set(hand.UIalpha_step,'Position',[pWth/2-bWthL/2-xshift  5*(bH+spacing)+offy bWthL*2/3 bH]);
set(hand.text_Dz,     'Position',[pWth/2-bWthL/3         6*(bH+spacing)+offy bWthL*2/3 bH/2]);
set(hand.UIalpha_Dz,  'Position',[pWth/2-bWthL/3         5*(bH+spacing)+offy bWthL*2/3 bH]);
set(hand.text_Dze9,   'Position',[pWth/2-bWthL/3+xshift  5.5*(bH+spacing)+offy bWthL*2/3 bH/2]);

set(hand.UIresult,    'Position',[ 0                     2.5*(bH+spacing)+offy pWth 2.5*bH]);
set(hand.folder,      'Position',[ 0                     1.5*(bH+spacing)+offy bWthL+10 bH]);
set(hand.file,        'Position',[ pWth/2-bWthL/2+xshift 1.5*(bH+spacing)+offy bWthL+5 bH]);
set(hand.save,        'Position',[ pWth/2-bWthL/2-xshift 0.5*(bH+spacing)+offy bWthL bH]);
set(hand.autosave,    'Position',[ pWth/2-bWthL/2+xshift 0.5*(bH+spacing)+offy bWthL bH]);
set(hand.saveImage,   'Position',[ pWth/2-bWthL/2-xshift -0.5*(bH+spacing)+offy bWthL*2 bH]);

% controls
set(hand.UIk,         'Position',[ pWth/2-bWth/2 bH+3 bWth bH]);
set(hand.next,        'Position',[ pWth/2-bWth/2+bWth bH+3 bWth bH]);
set(hand.previous,    'Position',[ pWth/2-bWth/2-bWth bH+3 bWth bH]);
set(hand.go,          'Position',[ pWth/2-bWth/2 3 bWth bH]);

set(hand.close,       'Position',[ 10+pWth/2-bWthL/2+xshift 10 bWthL bH]);
set(hand.reload,      'Position',[ 10+pWth/2-bWthL/2-xshift 10 bWthL bH]);

%% callbacks
set(hand.standard, 'callback',{@(src,event)figure_callback(hfig0,hfig0.UserData{5},hfig0.UserData{2},'st',hfig0.UserData{4},str2double(get(hand.UIk,'String')))});
set(hand.threeD,   'callback',{@(src,event)figure_callback(hfig0,hfig0.UserData{5},hfig0.UserData{2},'3D',hfig0.UserData{4},str2double(get(hand.UIk,'String')))});
set(hand.duo,      'callback',{@(src,event)figure_callback(hfig0,hfig0.UserData{5},hfig0.UserData{2},hfig0.UserData{3},'duo',str2double(get(hand.UIk,'String')))});
set(hand.single,   'callback',{@(src,event)figure_callback(hfig0,hfig0.UserData{5},hfig0.UserData{2},hfig0.UserData{3},'mix',str2double(get(hand.UIk,'String')))});
set(hand.px,       'callback',{@(src,event)figure_callback(hfig0,hfig0.UserData{5},'px',hfig0.UserData{3},hfig0.UserData{4},str2double(get(hand.UIk,'String')))});
set(hand.um,       'callback',{@(src,event)figure_callback(hfig0,hfig0.UserData{5},'µm',hfig0.UserData{3},hfig0.UserData{4},str2double(get(hand.UIk,'String')))});
set(hand.HVcrosscuts,'callback', @(src,event)HVcrosscuts(hfig0.UserData{5},gcf));
set(hand.radialCrosscut,   'callback', @(src,event)radialAverage(hfig0.UserData{5},hfig0));
set(hand.crosscut,'callback', @(src,event)crosscut(hfig0.UserData{5},gcf));
set(hand.PDCM,'callback', @(src,event)PDCMdisplay(hfig0.UserData{5},gcf));
set(hand.roiAlphaOV,  'callback', @(src,event)roiAlphaOV(hfig0.UserData{5},hand));
set(hand.magicAlphaOV,  'callback', @(src,event)magicWandAlphaOV2(hfig0));
set(hand.OPDhighPass,'callback',{@(src,event)figure_callback(hfig0,OPDhighPass(hfig0.UserData{5},str2double(get(hand.UIhighPass,'String'))),hfig0.UserData{2},hfig0.UserData{3},hfig0.UserData{4},str2double(get(hand.UIk,'String')))});
set(hand.Zernike,  'callback',{@(src,event)figure_callback(hfig0,ZernikeRemove(hfig0.UserData{5},str2double(get(hand.UIzernike_n,'String')),str2double(get(hand.UIzernike_m,'String')),str2double(get(hand.UIzernike_R,'String'))   ),hfig0.UserData{2},hfig0.UserData{3},hfig0.UserData{4},str2double(get(hand.UIk,'String')))});
set(hand.Z00,  'callback',{@(src,event)figure_callback(hfig0,ZernikeRemove(hfig0.UserData{5},0,0,str2double(get(hand.UIzernike_R,'String'))   ),hfig0.UserData{2},hfig0.UserData{3},hfig0.UserData{4},str2double(get(hand.UIk,'String')))});
set(hand.Z11,  'callback',{@(src,event)figure_callback(hfig0,ZernikeRemove(hfig0.UserData{5},1,1,str2double(get(hand.UIzernike_R,'String'))   ),hfig0.UserData{2},hfig0.UserData{3},hfig0.UserData{4},str2double(get(hand.UIk,'String')))});
set(hand.Z20,  'callback',{@(src,event)figure_callback(hfig0,ZernikeRemove(hfig0.UserData{5},2,0,str2double(get(hand.UIzernike_R,'String'))   ),hfig0.UserData{2},hfig0.UserData{3},hfig0.UserData{4},str2double(get(hand.UIk,'String')))});
set(hand.Z22,  'callback',{@(src,event)figure_callback(hfig0,ZernikeRemove(hfig0.UserData{5},2,2,str2double(get(hand.UIzernike_R,'String'))   ),hfig0.UserData{2},hfig0.UserData{3},hfig0.UserData{4},str2double(get(hand.UIk,'String')))});
set(hand.Z31,  'callback',{@(src,event)figure_callback(hfig0,ZernikeRemove(hfig0.UserData{5},3,1,str2double(get(hand.UIzernike_R,'String'))   ),hfig0.UserData{2},hfig0.UserData{3},hfig0.UserData{4},str2double(get(hand.UIk,'String')))});
set(hand.Z33,  'callback',{@(src,event)figure_callback(hfig0,ZernikeRemove(hfig0.UserData{5},3,3,str2double(get(hand.UIzernike_R,'String'))   ),hfig0.UserData{2},hfig0.UserData{3},hfig0.UserData{4},str2double(get(hand.UIk,'String')))});
set(hand.alpha,    'callback', @(src,event)alpha_ImageProfile(hfig0.UserData{5},hfig0));
set(hand.smooth,   'callback',{@(src,event)figure_callback(hfig0,smooth(hfig0.UserData{5},str2double(get(hand.UIsmooth,'String'))),hfig0.UserData{2},hfig0.UserData{3},hfig0.UserData{4},str2double(get(hand.UIk,'String')))});
set(hand.OV,  'callback', @(src,event)OV(hfig0.UserData{5},str2double(get(hand.UIalpha_NNP,'String')),str2double(get(hand.UIalpha_nmax,'String')),hfig0));
set(hand.pixels,   'callback', @(src,event)getPixel(hfig0.UserData{5},hfig0));
set(hand.area,     'callback', @(src,event)getAreaMean(hfig0.UserData{5},str2double(get(hand.UIalpha_NNP,'String')),hfig0) );
set(hand.distance, 'callback', @(src,event)distance(hfig0.UserData{5},gcf));
set(hand.close,    'callback', @(src,event)close(hfig0));
set(hand.reload,   'callback',{@(src,event)reloadFigure(hfig0,hfig0.UserData{5},hfig0.UserData{2},hfig0.UserData{3},hfig0.UserData{4},str2double(get(hand.UIk,'String')))});
set(hand.next,     'callback',{@(src,event)figure_callback(hfig0,IM(1+str2double(get(hand.UIk,'String'))),hfig0.UserData{2},hfig0.UserData{3},hfig0.UserData{4},str2double(get(hand.UIk,'String'))+1)});
set(hand.previous, 'callback',{@(src,event)figure_callback(hfig0,IM(-1+str2double(get(hand.UIk,'String'))),hfig0.UserData{2},hfig0.UserData{3},hfig0.UserData{4},str2double(get(hand.UIk,'String'))-1)});
set(hand.go,       'callback',{@(src,event)figure_callback(hfig0,IM(str2double(get(hand.UIk,'String'))),hfig0.UserData{2},hfig0.UserData{3},hfig0.UserData{4},str2double(get(hand.UIk,'String')))});
set(hand.save,     'callback',{@(src,event)saveData(hfig0)});
set(hand.saveImage,'callback',{@(src,event)saveImages(hfig0)});

if isa(IM(1),'ImageEM')
    set(hand.OPDhighPass,'visible','off');
    set(hand.UIhighPass,'visible','off');
end

if numel(IM)==1
    set(hpControls,'visible','off')
end


hfig0.UserData{8} = hand;

figure_callback(hfig0,IM(str2double(get(hand.UIk,'String'))),hfig0.UserData{2},hfig0.UserData{3},hfig0.UserData{4},str2double(get(hand.UIk,'String')))

set(hfig0,'Visible','on') % in case this method is called in a liveeditor program

if nargout % do not display ans if no output is asked by the user.
    hfig0out = hfig0;
    UIk0 = hand.UIk;
    cb0 = hfig0.UserData{1};
end

end

