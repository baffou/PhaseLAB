%% NPimaging package
% Superclass that gathers common methods to ImageQLSI and ImageEM classes.
% such as the methods related to image display and image processing

% author: Guillaume Baffou
% affiliation: CNRS, Institut Fresnel
% date: Feb 23, 2020

classdef ImageMethods  <  handle & matlab.mixin.Copyable

    properties
        Microscope Microscope
        Illumination Illumination % Illumination object
    end

    properties
        comment char = char.empty()   % any comment regarding the image
    end

    properties(Hidden)
        processingSoft
        pxSizeCorrection = 1
        binningFactor = 1 % tells how much the image was binned compared with the original image size. Used to compute the pxSize of the image, and not simply consider the Microscope pixel size.
    end

    methods

        function app = figure_old(IM)
            if nargout
                app=PhaseLABgui(IM);
            else
                PhaseLABgui(IM);
            end
        end

        function app = figure(IM)
            if nargout
                app=PhaseLABgui_multiCanal(IM);
            else
                PhaseLABgui_multiCanal(IM);
            end
        end

        function val=lambda(obj)
            val=obj.Illumination.lambda;
        end

        function val=dxSize(obj)
            val=obj.Microscope.CGcam.dxSize;
        end

        function val=pxSize(obj)
            val=obj.pxSizeCorrection*obj.Microscope.pxSize*obj.binningFactor;
        end

        function imageHSV(obj)
            Hue=(obj.OPD-min(obj.OPD(:)))/(max(obj.OPD(:))-min(obj.OPD(:)));
            Sat=obj.T/max(obj.T(:));
            imHSV(:,:,1)=Hue;
            imHSV(:,:,2)=Sat;
            imHSV(:,:,3)=1;
            imRGB=hsv2rgb(imHSV);
            imagesc(imRGB)
            axis equal
        end

        function hfig=overview(IMlist,opt)
            % displays all the images of the object list within a single
            % figure
            arguments
                IMlist
                opt.numbers double = 1:numel(IMlist)
                opt.types cell = {'OPD','T'}
            end
            Nim=numel(IMlist);
            Nt = numel(opt.types);

            numbers=opt.numbers;

            Nimx=2+floor(sqrt(Nt*Nim)); % +1 to elongate a bit horizontally, because of screen shape.
            if mod(Nimx,2) % the number of images horizontally is not even
                Nimx=ceil(sqrt(2*Nim));
            end
            if mod(Nimx,2) % If taking the ceil did not solve the problem. Occurs if Nimx is a perfect square.
                Nimx=Nimx+1;
            end
            Nimy=ceil(Nt*Nim/Nimx); % number of lines

            if nargout
                hfig=figure();
            else
                figure()
            end
            screenSz = get(groot,'ScreenSize');
            set(gcf,'position',[0 0 ceil(screenSz(3)) ceil(screenSz(4))]);

            iim=1;
            for iy=1:Nimy
                for ix=1:Nimx
                    if iim <= Nim
                        subplot(Nimy,Nimx,ix+Nimx*(iy-1))
                        if mod(ix,Nt)
                            imagesc(IMlist(iim).(opt.types{2}))
                            colormap(gca,'gray(1024)')
                            title(sprintf(['T #' num2str(numbers(iim)) '\n' IMlist(iim).comment]))
                        else
                            imagesc(IMlist(iim).(opt.types{1}))
                            colormap(gca,'phase1024')
                            title(sprintf(['OPD #' num2str(numbers(iim)) '\n' IMlist(iim).comment]))
                            iim=iim+1;
                        end
                        axis equal
                        axis off
                        set(gca,'YDir','normal')
                        %set(gca,'visible','off')
                        drawnow
                    end
                end
            end
        end

        function set.Microscope(objList,MI)
            No=numel(objList);
            for io=1:No
                objList(io).Microscope=MI;
            end
        end

        function set.Illumination(objList,IL)
            No=numel(objList);
            for io=1:No
                objList(io).Illumination=IL;
            end
        end

        function add(IMlist0,IM,pos)
            % Add an object IM to the list IMlist0, at position n
            % unsolved function. Does not seem to be possible to do that...
            arguments
                IMlist0 ImageMethods
                IM ImageMethods
                pos = []
            end
            Nim = numel(IMlist0);
            if isempty(pos)
                pos = Nim;
            end

            if pos == Nim % add at the end
                IMlist0(end+1 : end+numel(IM)) = IM;
            else
                nim=numel(IM);
                % 1 2 3 X X X 4 5      nim = 3    pos = 4    end = 5
                if nargout
                    IMlist = duplicate(IMlist0(1:pos) + IM + IMlist0(pos+1:end));
                else
                    IMlist=IMlist0;
                    IMlist(end+nim-(pos-nim):end+nim)=IMlist(end-(pos-nim):end)
                    IMlist(pos:pos+nim-1) = IM;
                end
            end

        end

        function opendx(obj,opt)
            arguments
                obj
                opt.persp = 1
                opt.phi = 0
                opt.theta = 0
                opt.ampl = 10
                opt.zrange = []
                opt.colorMap =  []
                opt.title = []
                opt.factor = 1 % correction factor, for instance 5.55e-3 to convert the OPD color scale into dry mass
                opt.label = 'Optical path difference (nm)'
                opt.imType = 'OPD'
                opt.axisDisplay (1,1) logical = true
                opt.displayedTime = string.empty()
                opt.timeUnit char {mustBeMember(opt.timeUnit,{'s','min','h'})}= 's'
                opt.timeFontSize = []
                opt.timeFontColor = []
            end
            % zrange in nm
            EL_camera=90-opt.theta;
            [Ny,Nx]=size(obj.OPD);

            % make sure some variables are in cell type
            if ~isa(opt.imType,'cell')
                opt.imType={opt.imType};
            end

            Nim=numel(opt.imType);

            % convert all the options into cells:
            if ~isa(opt.ampl,'cell')
                val=opt.ampl;
                opt.ampl=cell(1,Nim);
                opt.ampl(:)={val};
            end
            if ~isa(opt.zrange,'cell')
                val=opt.zrange;
                opt.zrange=cell(1,Nim);
                opt.zrange(:)={val};
            end
            if ~isa(opt.colorMap,'cell')
                val=opt.colorMap;
                opt.colorMap=cell(1,Nim);
                opt.colorMap(:)={val};
            end
            if ~isa(opt.title,'cell')
                val=opt.title;
                opt.title=cell(1,Nim);
                opt.title(:)={val};
            end
            if ~isa(opt.factor,'cell')
                val=opt.factor;
                opt.factor=cell(1,Nim);
                opt.factor(:)={val};
            end
            if ~isa(opt.label,'cell')
                val=opt.label;
                opt.label=cell(1,Nim);
                opt.label(:)={val};
            end


            for ii=1:Nim
                if ~isempty(opt.imType{ii})
                    fac=opt.factor{ii};

                    img = obj.(opt.imType{ii});

                    if strcmpi(opt.imType{ii},'OPD')
                        img=img*1e9;
                    end

                    if isempty(opt.zrange{ii})
                        zrange=[min(img(:)) max(img(:))]*fac;
                    else
                        zrange=opt.zrange{ii};
                    end
                    DZ=zrange(2)-zrange(1);
                    factor=obj.pxSize*1e6;
                    [X,Y] = meshgrid(0:Nx-1,0:Ny-1);
                    X=X*factor;
                    Y=Y*factor;

                    if opt.persp==1
                        DZ=DZ/opt.ampl{ii};
                    end

                    %% handling the number of parameters
                    coloringMap=img*fac;

                    %colormap(gca,colorScale);
                    %% Display
                    if Nim<=3
                        nRow=1;
                        nCol=Nim;
                    else
                        nRow=2;
                        nCol=ceil(Nim/2);
                    end
                    subplot(nRow,nCol,ii)
                    if opt.persp == 1
                        surf(X,Y,img*fac,coloringMap,'FaceColor','interp',...
                            'EdgeColor','none',...
                            'FaceLighting','phong')
                    else
                        imagesc(X(1,:),Y(:,1),img)
                        set(gca,'DataAspectRatio',[1, 1, 1])
                    end


                    if ~isempty(opt.title{ii})
                        figTitle=opt.title{ii};
                    elseif isprop(obj,'OPDfileName') % ie if ImageQLSI object
                        figTitle=obj.OPDfileName;
                    else
                        figTitle=' ';
                    end
                    title(figTitle, 'Interpreter','none')
                    posS=get(0, 'Screensize');
                    daspect([factor factor DZ/10])
                    set(gcf,'color','w');
                    set(gcf,'Position',[posS(1) posS(2) 2*posS(3)/3 posS(4)])% To change size
                    set(gca,'ztick',[])
                    set(gca,'XLim',[0 obj.Nx*factor])
                    set(gca,'YLim',[0 obj.Ny*factor])
                    if ~isempty(opt.colorMap{ii})
                        try
                            colormap(gca,opt.colorMap{ii});
                        catch % if the colormal is defined as a function, like Pradeep(Nval)
                            funColorMap = str2func(opt.colorMap{ii});
                            colormap(gca,funColorMap(1024));
                        end
                    else
                        if strcmp(opt.imType{ii},'OPD')
                            opt.colorMap{ii}=phase1024;
                        else
                            opt.colorMap{ii}=gray;
                        end
                        colormap(gca,opt.colorMap{ii});

                    end
                    %axis tight
                    %view(0,90)
                    %camlight left
                    %camlight(AZ, EL)
                    if opt.phi==0 &&  opt.theta==0
                        cb=colorbar(FontSize=20);
                        cb.Label.String = opt.label{ii};
                        view(2)
                        AZ_light=30;
                        EL_light=25;
                    else
                        cb=colorbar('southoutside',FontSize=16);
                        a =  cb.Position; %gets the positon and size of the color bar
                        set(cb,'Position',[a(1) a(2) a(3)/4 a(4)])% To change size
                        cb.Label.String = opt.label{ii};
                        cb.Label.FontSize = 20;
                        view(opt.phi,EL_camera)
                        camPos=get(gca,"CameraPosition");
                        set(gca,'CameraPosition',camPos/2)
                        camproj('perspective')
                        AZ_light=30;
                        EL_light=45;
                    end
                    %camlight(az,el)
                    camlight(AZ_light,EL_light)
                    %light('Position',[-1 0 0],'Style','local')
                    %axis off
                    xlabel('�m','FontSize',20), ylabel('�m','FontSize',20)
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
                        A=get(gcf,'Position');
                        Mmax = max(A(3:4));
                        set(gcf,'Position',Mmax*axisDimensions);
                        set(gca, 'Position', [0 0 1 1]);
                    end

                    if ~isempty(opt.displayedTime)
                        dims = get(gcf,'Position');
                        Nmax = dims(4);
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
                        text(Nmax/10, Nmax/10, ...
                            sprintf("%.2f",round(opt.displayedTime/timeFac,2))+" "+opt.timeUnit, ...
                            'Units','pixels', ...
                            'FontSize',timeFontSize, 'Color', opt.timeFontColor)
                    end
                    drawnow
                end
            end
        end


        function makeMoviedx(IM,videoName,opt)
            arguments
                IM
                videoName
                opt.rate = 25
                opt.persp = 1
                opt.phi = 45
                opt.theta = 45
                opt.ampl = 3
                opt.zrange = []
                opt.colorMap =  []
                opt.title = []
                opt.factor = 1 % correction factor, for instance 5.55e-3 to convert the OPD color scale into dry mass
                opt.label = 'Optical path difference (nm)'
                opt.imType  = 'OPD'
                opt.axisDisplay  (1,1) logical = true
                opt.frameTime = []  % if empty, nothing is displayed, if numeric value, the time is displayed on each frame
                opt.timeUnit char {mustBeMember(opt.timeUnit,{'s','min','h'})} = 's'
                opt.timeFontSize = []
                opt.timeFontColor = [0, 0, 0]
            end

            % create the video writer with 1 fps
            writerObj = VideoWriter(videoName);
            writerObj.FrameRate = opt.rate;
            % open the video writer
            open(writerObj);
            % write the frames to the video
            for u=1:numel(IM)
                % convert the image to a frame

                hfig=figure;
                fullscreen
                %                hfig.Position=[1 1 1800 800];

                opendx(IM(u),'persp',opt.persp,'phi',opt.phi,'theta',opt.theta,...
                    'ampl',opt.ampl,'zrange',opt.zrange,'colorMap',opt.colorMap, ...
                    'title',opt.title,'factor',opt.factor,'label',opt.label,'imType',opt.imType, ...
                    'axisDisplay',opt.axisDisplay,'displayedTime',opt.frameTime*u, ...
                    'timeUnit',opt.timeUnit,'timeFontSize',opt.timeFontSize, 'timeFontColor', opt.timeFontColor)

                frame=getframe(hfig);
                drawnow
                writeVideo(writerObj, frame);
                close(hfig)


            end
            % close the writer object
            close(writerObj);

        end

        function val = sizeof(IM)
            Nim=numel(IM);
            val0 = 0;
            for j=1:Nim
                props = properties(IM(j));
                totSize = 0;

                for ii=1:length(props)
                    currentProperty = IM(j).(props{ii});
                    s = whos('currentProperty');
                    totSize = totSize + s.bytes;
                end

                val0=val0+totSize;
            end
            if val0 < 1e6
                fprintf('%.4g Kb\n',val0/1024)
            else
                fprintf('%.4g Mb\n',val0/1024/1024)
            end

            if nargout
                val = val0;
            end
        end

        function val = dmd(obj)
            % returns the dry mass density in pg/�m^2
            val = 5.56*1e-3 * obj.OPD*1e9;
        end

        function [obj, params] = crop(obj0,opt)
            arguments
                obj0
                opt.xy1 = []
                opt.xy2 = []
                opt.Center = 'Auto' % 'Auto', 'Manual' or [x, y]
                opt.Size = 'Manual' % 'Auto', 'Manual', d or [dx, dy]
                opt.twoPoints logical = false
                opt.params double = double.empty()
                opt.shape char {mustBeMember(opt.shape,{'square','rectangle','Square','Rectangle'})}= 'square'
                opt.app = [] % figure uifigure object to be considered in case the image is already open
                opt.displayT logical = false
                opt.colormap = parula
            end

            if nargout
                obj=copy(obj0);
            else
                obj=obj0;
            end

            sizeIm = [0 0];
            for io = 1:numel(obj)
                if sum(sizeIm ~= size(obj(io).OPD)) % if the size of the image is not the same as the previous one
                    if isempty(opt.params)
                        if ~isempty(opt.app)
                            boxObj = opt.app;
                        else
                            boxObj = obj(io);
                        end

                        [x1, x2, y1, y2] = boxSelection(boxObj,'xy1',opt.xy1, ...
                            'xy2',opt.xy2, ...
                            'Center',opt.Center, ...
                            'Size',opt.Size, ...
                            'twoPoints',opt.twoPoints, ...
                            'params',opt.params, ...
                            'shape',opt.shape, ...
                            'displayT',opt.displayT, ...
                            'colormap',opt.colormap);
                        params=[x1, x2, y1, y2];
                    else
                        x1 = opt.params(1);
                        x2 = opt.params(2);
                        y1 = opt.params(3);
                        y2 = opt.params(4);
                        params=opt.params;
                    end
                end

                sizeIm = size(obj(io).OPD);


                if isa (obj,'ImageQLSI')
                    temp=obj(io).T(y1:y2,x1:x2); % temp variable to avoid importing the matrix twice for the calculation of Nx and Ny when it is stored in a file.
                    obj(io).T   = temp;
                    obj(io).OPD = obj(io).OPD(y1:y2,x1:x2);
                    if ~isempty(obj(io).DWx0)
                        obj(io).DWx0=obj(io).DWx(y1:y2,x1:x2);
                        obj(io).DWy0=obj(io).DWy(y1:y2,x1:x2);
                    end
                elseif isa (obj,'ImageEM')
                    obj(io).Ex = obj0(io).Ex(y1:y2,x1:x2);
                    obj(io).Ey = obj0(io).Ey(y1:y2,x1:x2);
                    obj(io).Ez = obj0(io).Ez(y1:y2,x1:x2);
                    obj(io).Einc = copy(obj(io).Einc);
                    obj(io).Einc.Ex = obj0(io).Einc.Ex(y1:y2,x1:x2);
                    obj(io).Einc.Ey = obj0(io).Einc.Ey(y1:y2,x1:x2);
                    obj(io).Einc.Ez = obj0(io).Einc.Ez(y1:y2,x1:x2);
                elseif isa (obj,'ImageT')
                    obj(io).T = obj0(io).T(y1:y2,x1:x2);
                    obj(io).OPD = obj0(io).OPD(y1:y2,x1:x2);
                    obj(io).HSD = obj0(io).HSD(y1:y2,x1:x2);
                    obj(io).TMP = obj0(io).TMP(y1:y2,x1:x2);
                end
            end


        end

        function im = Rytov(obj)
            im = obj.lambda*obj.Illumination.n/pi*abs( log(obj.T)/2+1i*obj.Ph ).^2;
        end

        function bool = is_empty(obj)
            % return 1 is the object is empty, or if all the properties are empty
            No = numel(obj);
            val = zeros(No,1);
            for io = 1:No
                if isempty(obj(io))
                    val(io) = 1;
                else
                    val(io) = isempty(obj(io).OPD);
                end
            end
            bool = logical(val);
        end

        function IM = adjustPolarOffsets(IM0)

            [Nim, Nch] = size(IM0);
            if Nch ~= 4
                error('this method assumes that the input is an N*4 array of objects, where the 4 columns are the 4 polarisation measurements')
            end

            if nargout
                IM = copy(IM0);
            else
                IM = IM0;
            end

            for ii = 1:Nim

                T1 = IM(ii,1).T;
                T2 = IM(ii,2).T;
                T3 = IM(ii,3).T;
                T4 = IM(ii,4).T;

                Phi1 = IM(ii,1).Ph;
                Phi2 = IM(ii,2).Ph;
                Phi3 = IM(ii,3).Ph;
                Phi4 = IM(ii,4).Ph;

                C = 0.5*(T2-T4)./sqrt(T1.*T3);

                while any(abs(C(:)) > 1)
                    warning('some pixels feature a C>1')
                    list = find(abs(C(:))>1);
                    for io = 1:numel(list) % take the average of the neighfor pixels, because these problematic pixels are isolated in general
                        C(list(io)) = (C(list(io)-1)+C(list(io)+1))/2;
                    end
                end
                % C almost equal zero.
                % since C = cos(phi_x - ph_y), it means that phi_x and phi_y are in
                % quadratude, which is true because of the circular polarization !

                %figure,imagegb(Phi3-Phi1+acos(C));
                %clim([-1.57 0])
                dPhi3map = Phi3-Phi1+acos(C);
                dPhi3 = mean(dPhi3map(:));
                %dPhi3 = Phi3-Phi1+acos(C);

                phi1 = IM(ii,1).Ph;
                phi3 = IM(ii,3).Ph - dPhi3;

                %% setting the right offset to the first image to make sure the background is zero in OPD
                %phi1 = phi1 - mean(mean(phi1(1,1:end-1)+phi1(1:end-1,end)+phi1(2:end,1)+phi1(end,2:end)))/4;

                %% other polars 2 & 4
                E1 = sqrt(T1);
                E3 = sqrt(T3);
                dPhi2 = mean(mean(Phi2-unwrap(angle(E1.*exp(1i*phi1)+E3.*exp(1i*phi3)))));
                dPhi4 = mean(mean(Phi4-unwrap(angle(-E1.*exp(1i*phi1)+E3.*exp(1i*phi3)))));

                %% New OPD images, with the right shift
                lambda = IM(ii, 1).Illumination.lambda;
                IM(ii, 1).OPD = phi1*lambda/(2*pi);
                IM(ii, 2).OPD = IM(ii, 2).OPD - dPhi2*lambda/(2*pi);
                IM(ii, 3).OPD = IM(ii, 3).OPD - dPhi3*lambda/(2*pi);
                IM(ii, 4).OPD = IM(ii, 4).OPD - dPhi4*lambda/(2*pi);

            end

        end

        function polarImages = extractPolarImages(IM)

            [Nim, Nch] = size(IM);
            if Nch ~= 4
                error('this method assumes that the input is an N*4 array of objects, where the 4 columns are the 4 polarisation measurements')
            end

            % Preallocate the structure array
            polarImages(Nim).phibar = [];
            polarImages(Nim).theta0 = [];
            polarImages(Nim).dphi = [];
            polarImages(Nim).Illumination = [];
            polarImages(Nim).Microscope = [];
            polarImages(Nim).rgbImage = [];

            for ii = 1:Nim
                tphi1 = IM(ii,1).Ph;
                tphi2 = IM(ii,2).Ph + pi/4;
                tphi3 = IM(ii,3).Ph + pi/2;
                tphi4 = IM(ii,4).Ph + 3*pi/4;

                polarImages(ii).theta0 = angle((tphi1-tphi3)+1i*(tphi2-tphi4));

                polarImages(ii).phibar = (tphi1+tphi2+tphi3+tphi4)/4;

                %deltaphi = sqrt(-(tphi4-phibar).*(tphi2-phibar)-(tphi3-phibar).*(tphi1-phibar));
                polarImages(ii).dphi = sqrt(abs((tphi4-polarImages(ii).phibar).*(tphi2-polarImages(ii).phibar)+(tphi3-polarImages(ii).phibar).*(tphi1-polarImages(ii).phibar)));

                polarImages(Nim).Illumination = IM(ii,1).Illumination;
                polarImages(Nim).Microscope = IM(ii,1).Microscope;

                [Ny, Nx] = size(polarImages(ii).dphi);
                hsvImage = zeros(Ny, Nx, 3);
                hsvImage(:,:,1) = polarImages(ii).theta0/pi/2+0.5;
                hsvImage(:,:,2) = 1.2*polarImages(ii).dphi/max(polarImages(ii).dphi(:));
                hsvImage(:,:,3) = ones(Ny,Nx);

                polarImages(ii).rgbImage = hsv2rgb(hsvImage);


            end
        end

        function  polarImages = CGMpolar(IM)
            polarImages = extractPolarImages( adjustPolarOffsets(IM) );
        end
    end

end