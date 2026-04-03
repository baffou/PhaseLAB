function [hfig, hax, him] = buildCustomFigure(tag,opt)
arguments
    tag char = 'W'
    opt.Nx (1,1) double = 1024
    opt.Ny (1,1) double = 1024
    opt.Position = 0 % 0, 1, or 2
    opt.enableClose logical = true
end

%% Set the position of the figure
screenSize = get(0, 'ScreenSize');
screenWidth = screenSize(3);
screenHeight = screenSize(4);

% Define the window width as one-third of the screen width
figWidth = screenWidth / 3;

% Define the window height (you can adjust this value as needed)
figHeight = figWidth;  % Example: 500 pixels tall

% Calculate y position to center the window vertically
yPos = (screenHeight - figHeight) / 2;

yPos = yPos/2; % otherwise may overlap with the app window

% Set x position to 0 (aligned to the left edge of the screen)
xPos = mod(opt.Position,3)*figWidth;
        
%% Create a classic figure with a black background and no menu bar
hfig = figure('Name', 'Custom GUI', ...
    'Color', [0.1 0.1 0.1], ...%    'MenuBar', 'none', ...
    'Units', 'pixels', ...
    'Position', [xPos yPos figWidth figWidth]);

% future handles of the fft and histogram axes
hfig.UserData.twinImageType = [];
hfig.UserData.twinAx = matlab.graphics.axis.Axes.empty();
hfig.Name = tag;
hfig.NumberTitle = 'off';

% Set the height for the top control panel
panelHeight = 70;

% Create a top horizontal panel for UI controls
topPanel = uipanel('Parent', hfig, ...
    'Units', 'pixels', ...
    'Position', [0, hfig.Position(4)-panelHeight, hfig.Position(3), panelHeight], ...
    'BackgroundColor', [0.2 0.2 0.2]);
hfig.UserData.topPanel  = topPanel;
% Define layout parameters for controls
spacing = 10;      % spacing between controls
x = spacing;       % initial x position
y1 = 10;            % y position for the first line of controls in the panel
y2 = panelHeight/2;  % y position for the 2nd line of controls in the panel
controlHeight = 25;


% Create axes that fill the remaining area of the figure
axesHeight = hfig.Position(4) - panelHeight;
imSize = min([hfig.Position(3)-120 axesHeight-80]);
hax = axes('Parent', hfig, ...
    'Units', 'pixels', ...
    'Position', [60 40 imSize imSize], ...
    'Color', 'k', ...                        % black axes background
    'Box', 'on');

hfig.UserData.hax  = hax;

% Display a test image using imagesc
him = imagesc(zeros(opt.Ny,opt.Nx), 'Parent', hax);
cb = colorbar(hax);
hax.XColor = 'w';
hax.YColor = 'w';
set(hax,'YDir','normal')
% Set the aspect ratio of the axes to 1:1 to maintain proper scaling
axis(hax, 'image');
cb.Color = 'w';

hax.Title.String = tag;
hax.Title.FontSize = 16;
hax.Title.Color = 'w';

%xlim([1, opt.Nx])
%ylim([1, opt.Ny])



% Add a dropdown menu (popup) for the colormap
controlWidth = 100;
uic_colormap = uicontrol('Style', 'popup', 'Parent', topPanel, ...
    'FontSize',14, ...
    'String', {'gray', 'Sepia', 'parula', 'Pradeep'}, ...
    'Position', [x, y2, controlWidth, controlHeight]);



% Add the invert checkbox
uic_invert = uicontrol('Style', 'checkbox', 'Parent', topPanel, ...
    'String', 'invert', ...
    'FontSize',14, ...
    'Position', [x, y1, controlWidth, controlHeight], ...
    'ForegroundColor', 'w', ...                % white text
    'BackgroundColor', topPanel.BackgroundColor);
x = x + controlWidth + spacing;




% Add the min numeric edit field
uic_min = uicontrol('Style', 'edit', 'Parent', topPanel, ...
    'HorizontalAlignment','right', ...
    'FontSize',14, ...
    'String', '', ...
    'Position', [x, y2, controlWidth*0.7, controlHeight]);


% Add the hold checkbox
uic_hold = uicontrol('Style', 'checkbox', 'Parent', topPanel, ...
    'String', 'hold', ...
    'FontSize',14, ...
    'Position', [x, y1, controlWidth*0.7, controlHeight], ...
    'ForegroundColor', 'w', ...                % white text
    'BackgroundColor', topPanel.BackgroundColor);
x = x + controlWidth*0.7 + spacing;


% Add the max numeric edit field
uic_max = uicontrol('Style', 'edit', 'Parent', topPanel, ...
    'HorizontalAlignment','right', ...
    'FontSize',14, ...
    'String', '', ...
    'Position', [x, y2, controlWidth*0.7, controlHeight]);


x = x + controlWidth*0.7 + 4*spacing;


%% toggle buttons


% Créer un uibuttongroup (permet mutual exclusivity)
bg = uibuttongroup('Parent', topPanel, ...
                   'Units','pixels', ...
                   'Position', [x, 0, panelHeight*3/2, panelHeight], ...
                   'BackgroundColor', [0.2 0.2 0.2], ...
                   'BorderType','none',...
                   'SelectionChangedFcn', @TwinImageChanged);

topPanel.Position(3) = x + bg.Position(3) + spacing;

% Créer les toggle buttons dans le groupe
imgButton = imread('icons/erase.png');
uicontrol('Style', 'togglebutton', ...
          'Parent', bg, ...
          'CData', imgButton, ...  % set the button image
          'Units', 'pixels', ...
          'Position', panelHeight*[0.05 0.55 0.4 0.4],...
          'Tooltip','cancel any mode',...
          'Tag','none');

imgButton = imread('icons/histo.png');
uicontrol('Style', 'togglebutton', ...
          'Parent', bg, ...
          'CData', imgButton, ...  % set the button image
          'Units', 'pixels', ...
          'Position', panelHeight*[0.55 0.55 0.4 0.4],...
          'Tooltip','plot histogram',...
          'Tag','histo');

uicontrol('Style', 'togglebutton', ...
          'Parent', bg, ...
          'String', 'FFT', ...
          'Units', 'pixels', ...
          'Position', panelHeight*[0.55 0.05 0.4 0.4],...
          'Tooltip','plot FFT',...
          'Tag','FFT');

imgButton = imread('icons/Pathcrosscut.png');
uicontrol('Style', 'togglebutton', ...
          'Parent', bg, ...
          'CData', imgButton, ...  % set the button image
          'Units', 'pixels', ...
          'Position', panelHeight*[0.05 0.05 0.4 0.4],...
          'Tooltip','plot crosscut',...
          'Tag','crosscut');



switch tag
    case 'W'
        cb.Label.String = 'nm';
        colormap(hax, Sepia);
        idx = find(strcmp(uic_colormap.String, 'Sepia'), 1);
        uic_colormap.Value = idx;
    otherwise
        cb.Label.String = '';
        colormap(hax, gray);
        idx = find(strcmp(uic_colormap.String, 'gray'), 1);
        uic_colormap.Value = idx;

end


hfig.SizeChangedFcn = @(src,event)resizeFigure(src);



if ~opt.enableClose
    hfig.CloseRequestFcn = @(src, event) [];
end
% addTwinFigure(hfig)
% addTwinFigure(hfig)


%% callbacks

uic_colormap.Callback = @(src, event) updateColorMap(hax,uic_colormap,uic_invert);
uic_invert.Callback =   @(src, event) updateColorMap(hax,uic_colormap,uic_invert);
uic_hold.Callback =   @(src, event)   updateClim(hax, uic_hold, uic_min, uic_max);
uic_min.Callback =   @(src, event)   updateClim(hax, uic_hold, uic_min, uic_max);
uic_max.Callback =   @(src, event)   updateClim(hax, uic_hold, uic_min, uic_max);

%% functions

function resizeFigure(hf)
    % TODO: resizer aussi axe 2 si présent
    panelH = hf.UserData.topPanel.Position(4);
    % move the panel
    hf.UserData.topPanel.Position(4)
    hf.UserData.topPanel.Position(2)  = hf.Position(4)-panelH;
    % redimension the axes
    axesH = hf.Position(4) - panelH;
    imSz = min([hf.Position(3)-120 axesH-80]);
    hf.UserData.hax.Position = [60 40 imSz imSz];
end
%% nested functions
    function updateColorMap(ax,uic_colormap,cb_inv)
        cmap = str2func(uic_colormap.String{uic_colormap.Value});
        if cb_inv.Value
            colormap(ax, flipud(cmap()))
        else
            colormap(ax, cmap())
        end
    end


    function updateClim(hax, uic_hold, uic_min, uic_max)
        if uic_hold.Value
            clim(hax,hax.CLim) % Fix the clim to the current value.
            if isempty(uic_min.String)
%                uic_min.String = sprintf('%.3g',(hax.CLim(1)));
                uic_min.String = format3sig(hax.CLim(1));
            else
                hax.CLim(1) = str2double(uic_min.String);
            end
            if isempty(uic_max.String)
%                uic_max.String = sprintf('%.3g',(hax.CLim(2)));
                uic_max.String = format3sig(hax.CLim(2));
            else
                hax.CLim(2) = str2double(uic_max.String);
            end
%            uic_max.String = num2str(hax.CLim(2));
        else
            hax.CLimMode = 'auto';
            uic_min.String = '';
            uic_max.String = '';
        end

    end

    function TwinImageChanged(src, event)
        hf = src.Parent.Parent;
        initFunc = hf.SizeChangedFcn;
        hf.SizeChangedFcn = [];

        hf.UserData.twinImageType = event.NewValue.Tag;
        ax = findobj(hf, 'Type', 'axes');
        % Shut down the 2nd image in any case before, possibly, opening a new one
        if numel(ax) == 2
            delete(hf.UserData.twinAx);
            hf.Position(3) = hf.Position(3)/2;
            hf.UserData.twinAx = matlab.graphics.axis.Axes.empty();
        end

        ax = findobj(hf, 'Type', 'axes');
        
        switch event.NewValue.Tag
            case {'histo','crosscut'}
                hf.UserData.twinAx = addTwinFigure(hf);
                plot(1,1)
            case 'FFT'
                hf.UserData.twinAx = addTwinFigure(hf);
                imagesc(zeros(size(ax.Children.CData)))
        end


        hf.UserData.twinAx.XColor = 'w';
        hf.UserData.twinAx.YColor = 'w';

        hf.SizeChangedFcn = initFunc;

        
    end    

    function s = format3sig(x)

        if x == 0
            s = '0';
            return
        end

        n = floor(log10(abs(x)));
        ndec = max(0, 3-n-1);

        s = sprintf(['%.' num2str(ndec) 'f'],x);
    end
   
end