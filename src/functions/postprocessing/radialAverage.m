function profile=radialAverage(obj,opt)
% returns
% profile.T
% profile.W
% profile.data (in case obj is numeric)
% profile.coords
% profile.rCoords
% obj can be Interfero, ImageMethods or a simple image.
% radialAverage(image)
% radialAverage(image,figure = hfig)
% radialAverage(image,figure = hfig, coords = [xc yc; xp yp]) % coordinates of the
                    % center and of a point on the outer circle of the crop
% rCoords is the x-axis coordinates, and xycoords are the clicks coordinates using ginput

arguments
    obj
    opt.figure = []
    opt.rCoords = []
    opt.xyCoords = []
    opt.display (1,1) logical = false
end
% plots the radial average from a clicked point, usually a
% nanoparticle location.
% hfig is optional. If specified, must be the hfig of the main image panel: IM.figure.
QLSIclass = isa(obj,'ImageMethods') || isa(obj,'Interfero');
appClass = isa(obj,'matlab.apps.AppBase');

if QLSIclass
    pxSize=obj.pxSize*1e6;
    if isempty(opt.figure) % radialAverage(IM)  % if no figure defined, open an app
        hfig=[];
        app=PhaseLABgui(obj);
    else  % radialAverage(IM,hfig) % where hfig is not a PhaseLABgui app (to be depreciated at some point)
        app = [];
        hfig = opt.figure;
        figure(hfig)
    end
elseif appClass % radialAverage(app)
    app = obj;
    hfig=[];
    pxSize = app.IMcurrent.pxSize*1e6;
elseif isnumeric(obj) % radialAverage(matrix)
    app = [];
    pxSize = 1;
    if isempty(opt.xyCoords)
        hfig = figure;
        figure(hfig)
        imagesc(obj)
    end
else
    error('not a valid input')
end

if ~isempty(app) % si on travaille avec une PhaseLABgui app
        fhv = app.UIFigure.HandleVisibility;        % Current status
        app.UIFigure.HandleVisibility = 'callback'; % Temp change (or, 'on')
        set(0, 'CurrentFigure', app.UIFigure)       % Make fig current
%            app.UIFigure.HandleVisibility = fhv;    % return original state
        axes(app.AxesLeft)
end

if isempty(opt.xyCoords)
    [cx,cy] = ginput(2);
    opt.xyCoords = [cx,cy];
else
    cx = opt.xyCoords(:,1);
    cy = opt.xyCoords(:,2);
end

if ~isempty(app)
    if strcmpi(app.scale,'px')
        cx_px = cx;
        cy_px = cy;
    else
        cx_px = app.um2px(cx);
        cy_px = app.um2px(cy);
    end        
    app.UIFigure.HandleVisibility = fhv;    % return original state

else
    cx_px = cx;
    cy_px = cy;
end

D = sqrt((cx_px(1)-cx_px(2))^2+(cy_px(1)-cy_px(2))^2);

if QLSIclass
    profile.T  = radialAverage0(obj.T,   [cx_px(1), cy_px(1)], round(D));
    profile.OPD= radialAverage0(obj.OPD, [cx_px(1), cy_px(1)], round(D));
elseif appClass
    profile.T  = radialAverage0(app.IMcurrent.T,   [cx_px(1), cy_px(1)], round(D));
    profile.OPD= radialAverage0(app.IMcurrent.OPD, [cx_px(1), cy_px(1)], round(D));
else
    profile.data = radialAverage0(obj, [cx_px(1), cy_px(1)], round(D));
    profile.T = radialAverage0(obj, [cx_px(1), cy_px(1)], round(D));
end
Np = length(profile.T);
profile.coords = [cx,cy];
profile.rCoords = pxSize*(1:Np);

if opt.display
    figure
    subplot(1,2,1)
    plot((-Np+1:Np-1)*pxSize,[flip(profile.T);profile.T(2:end)],'LineWidth',2)
    if QLSIclass
        xlabel(hfig.UserData{2})
    end
    if ~isempty(app)
        xlabel(app.scale)
    end    
    ylabel('normalized intensity')
    hold on
    ax=gca;
    plot([0 0],ax.YLim,'k--','LineWidth',2);%vertical line
    set(ax,'FontSize',14)
    hold off
    if QLSIclass || appClass
        subplot(1,2,2)
        plot((-Np+1:Np-1)*pxSize,[flip(profile.OPD);profile.OPD(2:end)]*1e9,'LineWidth',2)
        hold on
        ax=gca;
        plot([0 0],ax.YLim,'k--','LineWidth',2);%vertical line
        set(ax,'FontSize',14)
        hold off
        if QLSIclass
            xlabel(hfig.UserData{2})
        end
        ylabel('Optical path difference [nm]')
    end
end

end