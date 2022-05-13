function figure_callback(hfig,IM,unit,dx0,mix,k)
%hfig: figure handle
%IM: ImageEM or ImageQLSI object
%unit: 'px' or 'µm'
%dx: 'st' or '3D'
%mix: 'mix' or 'duo'
%[k: image number]
%[UIk: gui handle]
hand = hfig.UserData{8};

ha0 = gca;

AxesColor = hfig.UserData{6}.AxesColor;
ButtonOnColor = hfig.UserData{6}.ButtonOnColor;
ButtonOffColor = hfig.UserData{6}.ButtonOffColor;

set(hand.lambda,'String',['\lambda = ' num2str(IM.lambda*1e9) ' nm'])
set(hand.obj,'String',['M = ' num2str(IM.Microscope.Mobj) 'x'])
set(hand.pxSize,'String',['px size: ' num2str(IM.pxSize*1e9) ' nm'])
set(hand.Npx,'String',[num2str(IM.Nx) 'x' num2str(IM.Ny) ' px'])
set(hand.n1,'String',['n1 = ' num2str(IM.Illumination.n)])
set(hand.n2,'String',['n2 = ' num2str(IM.Illumination.nS)])
set(hand.comment,'String',IM.comment)


%dx: 0 (no dx), 1 (mixed single dx image) or 2 (intensity and phase dx images)
if strcmp(dx0,'st') && strcmp(mix,'duo')
    dx = 0;
elseif strcmp(dx0,'st') && strcmp(mix,'mix')
    dx = 1;
elseif strcmp(dx0,'3D') && strcmp(mix,'duo')
    dx = 2;
elseif strcmp(dx0,'3D') && strcmp(mix,'mix')
    dx = 3;
else
    error([duo ' ' mix])
end

if nargin==6 %ie in the case k and UIk are specified
    set(hand.UIk,'string',num2str(k));
end

if (strcmp(unit,'um') || strcmp(unit,'µm')) && (dx==2 || dx==3)
    warning('Sorry, the µm mode cannot be used with a 3D representation.')
    unit = 'px';  % present the µm mode with dx, mess up a bit the image, I don't know why
end
if strcmp(unit,'px') || dx==2 || dx==3  % presents the µm mode with dx
    factorX = 1;
    factorY = 1;
    unit = 'px';  % present the µm mode with dx, mess up a bit the image, I don't know why
elseif strcmp(unit,'um') || strcmp(unit,'µm')
    factorX = IM.pxSize*1e6;
    factorY = IM.pxSize*1e6;
    unit = 'µm';
else
    error('the unit parameter must be ''px'' or ''um''')
end

if strcmp(dx0,'st')
    set(hand.standard,'BackgroundColor',ButtonOnColor)
    set(hand.threeD,'BackgroundColor',ButtonOffColor)
end

if strcmp(dx0,'3D')
    set(hand.standard,'BackgroundColor',ButtonOffColor)
    set(hand.threeD,'BackgroundColor',ButtonOnColor)
end

if strcmp(mix,'duo')
    set(hand.single,'BackgroundColor',ButtonOffColor)
    set(hand.duo,'BackgroundColor',ButtonOnColor)
end

if strcmp(mix,'mix')
    set(hand.single,'BackgroundColor',ButtonOnColor)
    set(hand.duo,'BackgroundColor',ButtonOffColor)
end

if strcmp(unit,'px')
    set(hand.px,'BackgroundColor',ButtonOnColor)
    set(hand.um,'BackgroundColor',ButtonOffColor)
end

if strcmp(unit,'µm')
    set(hand.px,'BackgroundColor',ButtonOffColor)
    set(hand.um,'BackgroundColor',ButtonOnColor)
end


% determine the limits of the image

xLim = get(ha0(1),'XLim');
yLim = get(ha0(1),'YLim');

if min(xLim==[0 1]) && min(yLim==[0 1]) % if it is the first time an image is about to be displayed
    xLim = [0 size(IM.OPD,2)*factorX];
    yLim = [0 size(IM.OPD,1)*factorY];
else % if it is not the first time the image is displayed
    
if strcmp(unit,'px')
    if isempty(hfig.UserData{2}) || strcmp(hfig.UserData{2},'px') % previous was px mode
    else % we come the µm mode.
        xLim = xLim/(IM.pxSize*1e6);
        yLim = yLim/(IM.pxSize*1e6);
    end
else % µm mode
    if isempty(hfig.UserData{2}) || strcmp(hfig.UserData{2},'px') % all the limits are integers, ie the previous mode was the px mode.
        xLim = xLim*(IM.pxSize*1e6);
        yLim = yLim*(IM.pxSize*1e6);
    end
end    
end

hfig.UserData{9}.xLim = xLim;
hfig.UserData{9}.yLim = yLim;


%% 1st image

ha(1) = subplot(1,2,1);
ha(1).Units = 'pixels';
ha(1).XColor = 'w'; 

imPhase = IM.Ph;

xx = [0 IM.Nx*factorX];
yy = [0 IM.Ny*factorY];
if dx==0  %normal imagesc display
    imagesc(xx,yy,IM.T);

    axis equal
    colormap(gca,gray(1024))
    cb.T = colorbar;
    cb.T.Color = AxesColor;
    imsm = imgaussfilt(IM.T,4);
    maxVal = max(imsm(:));
    minVal = min(imsm(:));
    caxis([minVal maxVal]);
    minT = min(IM(1).T(:));
    maxT = max(IM(1).T(:));
    
    if minT<1 && maxT>1
        cb.T.Ticks = [minT,1,maxT];
    elseif maxT==minT
    else
        cb.T.Ticks = [minT,maxT];
    end

    if isa(IM,'ImageEM')
        if norm(IM.EE0)==0
            cb.T.Label.String = 'Intensity';
        else
            cb.T.Label.String = 'Normalized intensity';
        end
    else
        cb.T.Label.String = 'Normalized intensity';
    end
    
    cb.T.Label.FontSize = 14;
    axis([xLim yLim])

    if isa(IM,'ImageQLSI')
        title(IM.TfileName, 'Interpreter', 'none','FontSize',12)
    else
        title('Norm. tranmission image','FontSize',12)
    end
    ha(1).Position = [ 188.2000   78.0000  353.2469  570.5000];
    ha(1).YDir = 'normal';


elseif dx==1 % standard mix

%     imagesc(xx,yy,IM.T);
%     axis equal
%     colormap(gca,gray(1024))
%     cb.T = colorbar;
%     ax = gca;
%     ax.YDir = 'normal';

    colorScale = colorPhaseMap(imPhase);

    imagesc(xx,yy,IM(1).Ph)
    axis equal

    colormap(gca,colorScale);

    cb.Ph = colorbar;
    cb.Ph.Label.String = 'Phase (rad)';
    cb.Ph.Label.FontSize = 14;
    cb.Ph.Color = AxesColor;
    axis([0 IM.Nx*factorX 0 IM.Ny*factorY])
    if isa(IM,'ImageQLSI')
        title({IM.TfileName,IM.OPDfileName}, 'Interpreter', 'none')
    elseif isa(IM,'ImageEM')
        title({'Norm. intensity + phase','mixed representation'})
    end

elseif dx==2  %3D duo
    cb.T = opendx2(xx,yy,IM.T,gray(1024));
    
    cb.T.Color = AxesColor;
%    colormap(gca,gray(1024))


elseif dx==3  %3D mix

    %c = opendx(IM.T,IM.Ph);
    c = opendx2(xx,yy,IM.T,imPhase);
    cb.Ph = c;
    cb.Ph.Color = AxesColor;
    cb.Ph.Label.String = 'Phase (rad)';
    cb.Ph.Label.FontSize = 14;
    cb.T = colorbar('westoutside');
    cb.T.Label.String = 'Normalized intensity';
    cb.T.Color = AxesColor;
    colormap(cb.T,gray(1024))
    minT = min(IM(1).T(:));
    maxT = max(IM(1).T(:));
    if minT>1 && maxT<1
        cb.T.Ticks = [minT,1,maxT];
    else
        cb.T.Ticks = [minT,maxT];
    end
    cb.T.Limits = [min(IM.T(:)) max(IM.T(:))];

    if isa(IM,'ImageQLSI')
        title({IM.TfileName,IM.OPDfileName}, 'Interpreter', 'none')
    elseif isa(IM,'ImageEM')
        title({'Norm. intensity + phase','mixed representation'})
    end


end

%imagesc(IM.T);



if dx==0 || dx==2  %duo
    minT = min(IM(1).T(:));
    maxT = max(IM(1).T(:));
    
    if minT<1 && maxT>1
        cb.T.Ticks = [minT,1,maxT];
    elseif maxT==minT
    else
        cb.T.Ticks = [minT,maxT];
    end

    if isa(IM,'ImageEM')
        if norm(IM.EE0)== 0
            cb.T.Label.String = 'Intensity';
        else
            cb.T.Label.String = 'Normalized intensity';
        end
    else
        cb.T.Label.String = 'Normalized intensity';
    end

    cb.T.Label.FontSize = 14;
%    axis([0 IM.Nx*factorX 0 IM.Ny*factorY])
    if isa(IM,'ImageQLSI')
        title(IM.TfileName, 'Interpreter', 'none','FontSize',12)
    else
        title('Norm. tranmission image','FontSize',12)
    end

end

xlabel(unit,'FontSize',14);
set(gca,'FontSize',14)
set(ha(1),'XColor',AxesColor);
set(ha(1),'YColor',AxesColor);

%% 2nd image
ha(2) = subplot(1,2,2);
ha(2).Units = 'pixels';
ha(2).Position = [822   78  482  570];
xx = [0 IM.Nx*factorX];
yy = [0 IM.Ny*factorY];

if dx==0 || dx==2  %if duo. To make sure the two images have the same size.
    
%    ha(1).Position(3)=ha(2).Position(3);
%    ha(1).Position(1)=ha(1).Position(1)*1.2;
end


if dx==0  %normal imagesc display
    imagesc(xx,yy,imPhase);
    axis equal
    colormap(gca,phase1024());
    cb.Ph = colorbar;
    ax = gca;
    ax.YDir = 'normal';
    cb.Ph.Color = AxesColor;
    
    % to avoid bright pixels distorting the colorscale
    %vec = sort(IM.Ph(:));
    %Nv = numel(vec);
    %caxis([vec(500) vec(Nv-500) ]);
    
    IMg = imgaussfilt(imPhase,2);
    caxis([min(IMg(:)) max(IMg(:))]);
    
    
    
elseif dx==1 || dx==3 %3D mix
    delete(ha(2))
elseif dx==2  %3D duo
    cb.Ph = opendx2(xx,yy,imPhase,phase1024,15); % opendx2(iamge,colorScale,camLightAngle)
    cb.Ph = colorbar;
    cb.Ph.Color = AxesColor;
end


if dx==0 || dx==2 % duo image mode

    cb.Ph.Label.String = 'Phase (rad)';
    cb.Ph.Label.FontSize = 14;
    cb.OPD = colorbar('westoutside');
    cb.OPD.Label.String = 'OPD (nm)';
    cb.OPD.Label.FontSize = 14;
    cb.OPD.Color = AxesColor;
    camlight(90,180,'infinite')
    axis([xLim yLim])
    if isa(IM,'ImageQLSI')
        title(IM.OPDfileName, 'Interpreter', 'none','FontSize',12)
    else
        title('OPD/Phase image','FontSize',14)
    end
    xlabel(unit,'FontSize',14);
    set(gca,'FontSize',14);

    cb.OPD.TickLabels = round(100*cb.Ph.Ticks*IM(1).lambda/(2*pi)*1e9)/100;
    
    linkaxes(ha, 'xy');      
    set(ha(2),'XColor',AxesColor);
    set(ha(2),'YColor',AxesColor);
end

%%



%if dx==0 || dx==2  %if duo. To make sure the two images have the same size.
%ha(1).Position(3)=ha(2).Position(3);
%end

hfig.UserData{9}.xLim = get(ha(1),'XLim');
hfig.UserData{9}.yLim = get(ha(1),'YLim');



%%hfig.UserData
%1: colorbar
%2: primary unit
%3: other alternative unit
%4: 3D rendering 0, 1, or 2
%5: current image
%6: colors
%7: subplots axes

hfig.UserData{1} = cb;

hfig.UserData{2} = unit;
hfig.UserData{3} = dx0;
hfig.UserData{4} = mix;

hfig.UserData{5} = IM;
hfig.UserData{7} = ha;
hfig.UserData{8} = hand;


hfig.UserData{8}.UIk;

hfig.UserData{9}.XYLim = [get(gca,'XLim') get(gca,'YLim')];






