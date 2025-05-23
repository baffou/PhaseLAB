function ax2 = addTwinFigure(hfig)
arguments
    hfig
end

%% --- Mise à jour de la figure pour ajouter un second axe (right axes) ---
% Get the current figure position

% Update the left axes position (keeping its height and vertical position)
ax = findobj(hfig, 'Type', 'axes');
posFig = get(hfig, 'Position');   % pos = [x, y, width, height]

if numel(ax) == 1 % no other twin figure for the moment
    hfig.Position(3) = posFig(3) * 2;      % double the width of the figure
else
    return % if ==2, let this way, the space is alreay created for the second figure
end

% Define margins (you can adjust these values as needed)
verticalMargin   = 40; % bottom margin
horizontalMargin = 140;

%set(ax, 'Position', [leftMargin, verticalMargin, axesWidth, axesHeight-60]);
ax1Pos = ax(end).Position; % position of the firstly defined figure
% Create the right axes at the proper location:
% Its x position is leftMargin + axesWidth + horizontalSpacing
ax2 = axes('Parent', hfig, ...
           'Units', 'pixels', ...
           'Position', [ax1Pos(1)+ax1Pos(3)+horizontalMargin, verticalMargin, ax1Pos(3), ax1Pos(4)], ...
           'Color', 'k', ...      % black background
           'XColor','w',...
           'YColor','w',...
           'Box', 'on');


ax2.XColor = 'w';
ax2.YColor = 'w';
