function figure2eps(H,fileName, maxNrPatches, BitMapRenderer, forcePainter )
%
% Purpose : This function saves a figure to EPS. It enables the use of 
% different renderers for surfces, patches and other graphical objects.
%
% Axes, text etc are rendered using vector graphics.
%
% The total number of surface patches and patches is determined, if 
% nrPatches < maxNrPatches (default = 1000) then vector graphics is also 
% used for the surfaces; otherwise the specified BitMapRenderer is used.
%
% It is possible to force the use of the painters renderer.
%
% This function also solves the problem that the screen figure is sometimes
% changed when printed.
%
% Two seperate .eps files are generated and then combined using the
% |epscombine.m| tool. 
%
% Use (syntax):
%   figure2eps(H,fileName)
%   figure2eps(H,fileName, maxNrPatches)
%   figure2eps(H,fileName, maxNrPatches, BitMapRenderer)
%   figure2eps(H,fileName, maxNrPatches, BitMapRenderer, forcePainter )
%
% Input Parameters:
%  H:        Handel to the figure which is to be plotted
%  fileName: File name to be used without extension
%  maxNrPatches: The maximum number of patches for which the painter
%           renderer is automatically used.
%  BitMapRenderer: [{'-zbuffer'}, '-opengl'] 
%           comment: I have problems with '-opengl' that the transparent
%           patches are not alway correctly rendered
%  forcePainter: [true, {false}] if true forces the use of the painter
%           renderer
%
%------------------------------------------------------------------------
% I would like to thank Will Robertson for his contribution |epscombine.m|
% at Matlab File Exchange. I wish to acknowledge that without his
% contribution I would not have been able to implement this code.
%
% For convenience the epscombine.m code is included in package.
%------------------------------------------------------------------------
%
% Author :  Matthew Harker and Paul O'Leary
% Date :    26. June 2013
% Version : 1.0
%
% (c) 2013 Matthew Harker and Paul O'Leary, 
% Chair of Automation, University of Leoben, Leoben, Austria
% email: office@harkeroleary.org, 
% url: www.harkeroleary.org
%
% History:
%   Date:           Comment:
%

%% Setup the default paramaters
if nargin < 3
    maxNrPatches = 1000;
end;
%
if nargin < 4
    BitMapRenderer = '-zbuffer';
end;
%
if nargin < 5
    forcePainter = false;
end;
%%
% Test if the figure contains surfaces and or patches
%
if (isempty(findobj( H, 'Type', 'surface')) && ...
        isempty(findobj( H, 'Type', 'patch')))|| forcePainter
    %
    % If no surfaces or patches then use the painters renderer
    %
    figure(H);
    drawnow;
    print('-depsc','-loose','-r300','-painter',fileName);
else
    % The decision to use psinter of a bitmap render is now made depending
    % on the total number of patches present in the figure.
    %
    % count the patches
    %
    nrPatches = countNrPatchesPerAxis( H );
    totalNrPatches = sum( nrPatches );
    %
    % make the decision
    %
    if totalNrPatches < maxNrPatches
        % for a low number of patches use painters
        %
        % The figure is copied to ensure that the screen figure is not
        % changed during printing. It was commonly observed that the
        % surface colours were lost when printing. Taking the copy solves
        % this problem.
        %
        tempName = [fileName, 'temp.fig'];
        hgsave(H, tempName);
        f1 = hgload(tempName);
        figure(f1);
        drawnow;
        %
        print('-depsc','-loose','-r300','-painter',fileName);
        delete(tempName);
        close(f1);
    else
        %
        % At this point the decision to use a bitmap render has been made
        % Two copies of the figure are now made. In the first the axes are
        % presented and the second the surfaces and patches
        %
        tempName = [fileName, 'temp.fig'];
        hgsave(H, tempName);
        %-------------------------------------------------------------
        % Output the axes to an eps file using the painters renderer
        %
        f1 = hgload(tempName);
        figure(f1);
        drawnow;
        %
        Hs = findobj( f1, 'Type', 'surface');
        Hp = findobj( f1, 'Type', 'patch');
        %
        % make the surfaces and patches invisible
        %
        for k=1:length(Hs)
            set(Hs(k),'visible','off')
        end;
        %
        for k=1:length(Hp)
            set(Hp(k),'visible','off')
        end;
        %
        % Switch the grid off on each axis, make the backround color
        % transparent and switch the box off.
        %
        Ha = findobj( f1, 'Type', 'axes');
        %
        for k=1:length(Ha)
            set(Ha(k),'XGrid', 'off', ...
                'YGrid', 'off', ...
                'ZGrid', 'off', ...
                'XMinorGrid', 'off', ...
                'YMinorGrid', 'off', ...
                'ZMinorGrid', 'off');
            HaS = isempty(findobj( Ha(k), 'Type', 'surface'));
            HaP = isempty(findobj( Ha(k), 'Type', 'patch'));
            if ~( HaS && HaP )
                set(Ha(k),'color','none');
                set(Ha(k),'box','off');
            end;
        end;
        %
        % Make the figure background invisible
        %
        set(f1,'color','none','inverthardcopy','off');
        %
        print('-depsc2','-loose','-r300','-painter',[fileName,'Axes']);
        %-------------------------------------------------------------
        % Save all the rest
        %
        f2 = hgload(tempName);
        figure(f2);
        drawnow;
        %
        % Make everything which in not a patch or surface invisible.
        %
        % Get all axes
        Ha = findobj( f2, 'Type', 'axes');
        % find all axes which have surfaces or patches
        Hs = findobj( Ha, 'Type', 'surface');
        Hp = findobj( Ha, 'Type', 'patch');
        %
        Hon1 = findobj( get(Ha,'parent'), 'Type', 'axes');
        Hon2 = findobj( get(Hp,'parent'), 'Type', 'axes');
        Hon = unique( [Hon1, Hon2] );
        %
        % Switch off all other axes
        %
        Hall = findobj( f2 );
        Hoff = setdiff(setdiff(setdiff( Hall, Hs), Hp ),Hon);
        %
        for k=1:length(Hoff)
            set(Hoff(k),'visible','off');
        end;
        %
        % Remove the anotation from the axes
        %
        for k=1:length(Ha)
            set(Ha(k),'ZTickLabel',[]);
            set(Ha(k),'XTickLabel',[]);
            set(Ha(k),'YTickLabel',[]);
            axes(Ha(k));
            xlabel('');
            ylabel('');
            zlabel('');
            title('');
        end;
        %
        print('-depsc2','-loose','-r300',BitMapRenderer,[fileName,'Rest']);
        %
        % Merge the files as required
        %
        epscombine([fileName,'Axes.eps'],[fileName,'Rest.eps'],[fileName,'.eps'])
        delete([fileName,'Axes.eps']);
        delete([fileName,'rest.eps']);
        delete(tempName);
        close(f1);
        close(f2);
    end;
end;

function nrPatches = countNrPatchesPerAxis( H )
%
% Determine the total number of surface patches per axis
%
Ha = findobj( H, 'Type', 'axes');
nHa = length( Ha );
%
nrPatches = zeros( nHa, 1 );
%
for k = 1:nHa
    % Count the surface patches
    tempCount = 0;
    Has = findobj( Ha(k), 'Type', 'surface');
    for j = 1: length(Has )
        temp = get( Has(j) );
        [n, m] = size( temp.ZData );
        tempCount = tempCount + n * m;
    end;
    %
    Hap = findobj( Ha(k), 'Type', 'patch');
    for j = 1: length(Hap )
        temp = get( Hap(j) );
        [n, m] = size( temp.ZData );
        tempCount = tempCount + n * m;
    end;
    %
    nrPatches(k) = tempCount;
end;
%
