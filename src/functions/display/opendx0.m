function opendx0(img,opt)
arguments
    img (:,:) double
    opt.persp = 1
    opt.phi = 0
    opt.theta = 0
    opt.ampl = 10
    opt.zrange = []
    opt.colorMap =  Sepia
    opt.title = []
    opt.factor = 1 % correction factor, for instance 5.55e-3 to convert the OPD color scale into dry mass
    opt.clabel = ''
    opt.pxSize = []
    opt.figTitle = ''
    opt.axisDisplay (1,1) logical = true
    opt.displayedTime = string.empty()
    opt.timeUnit char {mustBeMember(opt.timeUnit,{'s','min','h'})}= 's'
    opt.timeFontSize = []
    opt.timeFontColor = []
end

% zrange in nm
EL_camera=90-opt.theta;
[Ny,Nx] = size(img);

% make sure some variables are in cell type



    fac = opt.factor;

    if isempty(opt.zrange)
        zrange = [min(img(:)) max(img(:))];
    else
        zrange = opt.zrange;
    end

    if isempty(opt.pxSize)
        label = 'px';
        opt.pxSize = 1e-6;
    else
        label = 'µm';
    end

    DZ = zrange(2)-zrange(1);

    factor = opt.pxSize*1e6;
    [X,Y] = meshgrid(0:Nx-1,0:Ny-1);
    X = X*factor;
    Y = Y*factor;

    if opt.persp == 1
        DZ = DZ/opt.ampl;
    end

    %% handling the number of parameters
    coloringMap = img*fac;

    %colormap(gca,colorScale);
    %% Display
    if opt.persp == 1
        surf(X,Y,img*fac,coloringMap,'FaceColor','interp',...
            'EdgeColor','none',...
            'FaceLighting','phong')
    else
        imagesc(X(1,:),Y(:,1),img)
        set(gca,'DataAspectRatio',[1, 1, 1])
    end

    title(opt.figTitle, 'Interpreter','none')
    daspect([factor factor DZ/10])
    set(gcf,'color','w');
    %posS = get(0, 'Screensize');
    %set(gcf,'Position',[posS(1) posS(2) 2*posS(3)/3 posS(4)])% To change size
    set(gca,'ztick',[])
    set(gca,'XLim',[0 Nx*factor])
    set(gca,'YLim',[0 Ny*factor])
    try
        colormap(gca,opt.colorMap);
    catch % if the colormal is defined as a function, like Pradeep(Nval)
        funColorMap = str2func(opt.colorMap);
        colormap(gca,funColorMap(1024));
    end
    if opt.phi==0 &&  opt.theta==0
        cb = colorbar(FontSize=20);
        cb.Label.String = opt.clabel;
        view(2)
        AZ_light = 30;
        EL_light = 25;
    else
        cb = colorbar('southoutside',FontSize=16);
        a = cb.Position; %gets the positon and size of the color bar
        set(cb,'Position',[a(1) a(2) a(3)/4 a(4)])% To change size
        cb.Label.String = opt.clabel;
        cb.Label.FontSize = 20;
        view(opt.phi,EL_camera)
        camPos=get(gca,"CameraPosition");
        set(gca,'CameraPosition',camPos/2)
        camproj('perspective')
        AZ_light = 30;
        EL_light = 45;
    end
    %camlight(az,el)
    camlight(AZ_light,EL_light)
    %light('Position',[-1 0 0],'Style','local')
    %axis off
    xlabel(label,'FontSize',20), ylabel(label,'FontSize',20)
    clim(zrange)
    set(gca,'FontSize',18)


    if ~opt.axisDisplay % if axes display should be removed
        hf = gcf;
        Nc = numel(hf.Children);
        for ic = 1:Nc
            hf.Children(ic).Visible = "off";
        end

        Nmax = max([obj.Nx, obj.Ny]);
        axisDimensions = [0 0 obj.Nx/Nmax obj.Ny/Nmax];
        A = get(gcf,'Position');
        Mmax = max(A(3:4));
        set(gcf,'Position',Mmax*axisDimensions);
        set(gca, 'Position', [0 0 1 1]);
    end

    if ~isempty(opt.displayedTime)
        dims = get(gcf,'Position');
        Nmax = min(dims(3:4));
        switch opt.timeUnit
            case 's'
                timeFac = 1;
            case 'min'
                timeFac = 60;
            case {'h', 'hour'}
                timeFac = 3600;
        end
        if isempty(opt.timeFontSize)
            timeFontSize = Nmax/15;
        else
            timeFontSize = opt.timeFontSize;
        end
        text(10, 10, ...
            sprintf("%.2f",round(opt.displayedTime/timeFac,2))+" "+opt.timeUnit, ...
            'Units','points', ...
            'FontSize',timeFontSize, 'Color', opt.timeFontColor)
    end
    drawnow



