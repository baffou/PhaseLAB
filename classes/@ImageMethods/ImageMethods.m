%% NPimaging package
% Superclass that gathers common methods to ImageQLSI and ImageEM classes.
% such as the methods related to image display and image processing

% author: Guillaume Baffou
% affiliation: CNRS, Institut Fresnel
% date: Feb 23, 2020

classdef ImageMethods  <  handle & matlab.mixin.Copyable

    properties(SetAccess=private)
        comment   % any comment regarding the image
        pxSize    % pixel size at the focal plane
        dxSize    % pixel size at the image plane, i.e. dexel size of the camera
    end

    properties(Dependent)
        lambda % = Illumination.lambda
    end

    properties(Hidden)
        Microscope Microscope
        Illumination Illumination % Illumination object
        processingSoft
        pxSizeCorrection = 1
    end

    methods

        function val=get.lambda(obj)
            val=obj.Illumination.lambda;
        end

        function HVcrosscuts(obj,hfig)
            % plots horizontal and vertical cross cuts.
            if nargin==1
                hfig=obj.figure('px');
            else
                figure(hfig)
                %if ~strcmp(hfig.UserData{2},'px') % force the unit to be px in case it is �m
                %    figure_callback(hfig,obj,'px',hfig.UserData{3},hfig.UserData{4},str2double(get(hfig.UserData{8}.UIk,'String')),hfig.UserData{8})
                %end
            end
            linkaxes(hfig.UserData{7},'off');
            linkaxes(hfig.UserData{7},'x');

            [x0,y0]=ginput(1);
            x0=round(x0);
            y0=round(y0);
            if nargin==2
                if strcmp(hfig.UserData{2},'�m')
                    factorAxis=obj.pxSize*1e6;
                elseif strcmp(hfig.UserData{2},'px')
                    factorAxis=1;
                end
            else
                factorAxis=1;
            end
            subplot(1,2,1)
            plot((1:obj.Nx)*factorAxis-x0,obj.T(round(y0/factorAxis),:),'LineWidth',2);
            if nargin==2
                xlabel(hfig.UserData{2})
            else
                xlabel('px')
            end
            ylabel('normalized intensity')
            hold on
            plot((1:obj.Ny)*factorAxis-y0,obj.T(:,round(x0/factorAxis)),'LineWidth',2);
            set(gca,'fontsize', 18)
            legend({'horizontal','vertical'})
            ax=gca;
            plot([0 0],ax.YLim,'b');%vertical line
            set(ax,'FontSize',14)
            hold off
            subplot(1,2,2)
            plot((1:obj.Nx)*factorAxis-x0,1e9*obj.OPD(round(y0/factorAxis),:),'LineWidth',2);
            if nargin==2
                xlabel(hfig.UserData{2})
            else
                xlabel('px')
            end
            ylabel('Optical path difference [nm]')
            hold on
            plot((1:obj.Ny)*factorAxis-y0,1e9*obj.OPD(:,round(x0/factorAxis)),'LineWidth',2);
            set(gca,'fontsize', 18)
            legend({'horizontal','vertical'})
            ax=gca;
            plot([0 0],ax.YLim,'b');%vertical line
            set(ax,'FontSize',14)
            hold off
        end

        function crosscut(obj,hfig)
            % plots horizontal and vertical cross cuts.
            if nargin==1
                hfig=obj.figure('px');
            else
                figure(hfig)
                %if ~strcmp(hfig.UserData{2},'px') % force the unit to be px in case it is �m
                %    figure_callback(hfig,obj,'px',hfig.UserData{3},hfig.UserData{4},str2double(get(hfig.UserData{8}.UIk,'String')),hfig.UserData{8})
                %end
            end
            linkaxes(hfig.UserData{7},'off');
            linkaxes(hfig.UserData{7},'x');

            [cx,cy,c]=improfile(100);
            dist=0;
            for ni=1:length(cx)-1
                dist=dist+sqrt((cx(ni)-cx(ni+1))^2+(cy(ni)-cy(ni+1))^2);
            end
            figure,
            crossplot=c;%obj.lambda*c*1e9/(2*pi);
            hp=plot(  crossplot);
            hp.XData=hp.XData/max(hp.XData)*dist;
            xlabel(hfig.UserData{2})
            ylabel('OPD [nm]')
            size(hp.XData')
            size(crossplot')
            hfig.UserData{10}=[hp.XData',crossplot];

        end

        function distance(obj,hfig)
            % measures a distance between two points.
            if nargin==1
                hfig=obj.figure('�m');
            else
                figure(hfig)
                figure_callback(hfig,obj,'�m',hfig.UserData{3},hfig.UserData{4},'1')
                %if ~strcmp(hfig.UserData{2},'px') % force the unit to be px in case it is �m
                %    figure_callback(hfig,obj,'px',hfig.UserData{3},hfig.UserData{4},str2double(get(hfig.UserData{8}.UIk,'String')),hfig.UserData{8})
                %end
            end
            hp=drawpolyline;
            dist=lineLength(hp);
            clipboard('copy',sprintf([hfig.UserData{5}.OPDfileName '\t%.4g\t' hfig.UserData{2}],dist))

            %             if nargin==2
            %                 if strcmp(hfig.UserData{2},'�m')
            %                     factorAxis=obj.pxSize*1e6;
            %                 elseif strcmp(hfig.UserData{2},'px')
            %                     factorAxis=1;
            %                 end
            %             else
            %                 factorAxis=1;
            %             end
            UIresult=hfig.UserData{8}.UIresult;
            set(UIresult,'String',[sprintf('%.4g',dist) ' ' hfig.UserData{2}]);
            hfig.UserData{10}=dist;

        end

        function profile=radialAverage(obj,hfig)
            % plots the radial average from a clicked point, usually a
            % nanoparticle location.
            % hfig is optional. If specified, must be the hfig of the main image panel: IM.figure.
            if nargin==1
                hfig=obj.figure('px');
            else
                figure(hfig)
                linkaxes(hfig.UserData{7},'off');
                linkaxes(hfig.UserData{7},'x');
            end
            linkaxes(hfig.UserData{7},'off');
            linkaxes(hfig.UserData{7},'x');

            [cx,cy]=ginput(2);
            if nargin==2
                if strcmp(hfig.UserData{2},'�m')
                    factorAxis=obj.pxSize*1e6;
                elseif strcmp(hfig.UserData{2},'px')
                    factorAxis=1;
                end
            else
                factorAxis=1;
            end
            D=sqrt((cx(1)-cx(2))^2+(cy(1)-cy(2))^2);
            w=1:obj.Npx;
            profile.T  =radialAverage0(obj.T,   [cx(1)/factorAxis, cy(1)/factorAxis], round(D/factorAxis));
            profile.OPD=radialAverage0(obj.OPD, [cx(1)/factorAxis, cy(1)/factorAxis], round(D/factorAxis));

            Np=length(profile.T);
            size(profile.T)
            subplot(1,2,1)
            plot((-Np+1:Np-1)*factorAxis,[flip(profile.T);profile.T(2:end)],'LineWidth',2)
            xlabel(hfig.UserData{2})
            ylabel('normalized intensity')
            hold on
            ax=gca;
            plot([0 0],ax.YLim,'k--','LineWidth',2);%vertical line
            set(ax,'FontSize',14)
            hold off
            subplot(1,2,2)
            plot((-Np+1:Np-1)*factorAxis,[flip(profile.OPD);profile.OPD(2:end)]*1e9,'LineWidth',2)
            hold on
            ax=gca;
            plot([0 0],ax.YLim,'k--','LineWidth',2);%vertical line
            set(ax,'FontSize',14)
            hold off
            xlabel(hfig.UserData{2})
            ylabel('Optical path difference [nm]')
        end

        function val=getPixel(obj,hfig)
            if nargin==1
                obj.figure()
            end

            [x,y]=ginput(1);

            valT=obj.T(round(y),round(x));
            valOPD=obj.OPD(round(y),round(x));
            val=[valT;valOPD];

            if nargin==2
                UIresult=hfig.UserData{8}.UIresult;
                set(UIresult,'String',[sprintf('%.4g',valT) ', ' sprintf('%.3g',1e9*valOPD) ' nm']);
                hfig.UserData{10}=[valT;valOPD];
            end
        end

        function val=get.dxSize(obj)
            val=obj.Microscope.dxSize();
        end

        function val=get.pxSize(obj)
            val=obj.pxSizeCorrection*obj.Microscope.pxSize;
        end

        function val=getAreaMean(obj,Narea,hfig)
            if nargin==1
                obj.figure()
                Narea=1;
            end

            val=zeros(Narea,3);
            valstd=zeros(Narea,3);
            for ia=1:Narea

                [x,y]=ginput(2);
                xmin=round(min(x));
                xmax=round(max(x));
                ymin=round(min(y));
                ymax=round(max(y));

                valT=mean(mean(obj.T(ymin:ymax,xmin:xmax)));
                valOPD=mean(mean(obj.OPD(ymin:ymax,xmin:xmax)));
                valPh=mean(mean(obj.Ph(ymin:ymax,xmin:xmax)));
                val(ia,1)=valT;
                val(ia,2)=valOPD;
                val(ia,3)=valPh;

                valstdT=std2(obj.T(ymin:ymax,xmin:xmax));
                valstdOPD=std2(obj.OPD(ymin:ymax,xmin:xmax));
                valstdPh=std2(obj.Ph(ymin:ymax,xmin:xmax));
                valstd(ia,1)=valstdT;
                valstd(ia,2)=valstdOPD;
                valstd(ia,3)=valstdPh;

                if nargin==3
                    UIresult=hfig.UserData{8}.UIresult;
                    set(UIresult,'String',[sprintf('%.4g',valT) '\pm' sprintf('%.4g',valstdT) ', ' sprintf('%.3g',1e9*valOPD) '\pm' sprintf('%.4g',valstdOPD) ' nm']);
                end

            end
            hfig.UserData{10}=val;

            hc=figure;
            subplot(1,3,1)
            plot(val(:,1),'o-')
            title('intensity')
            subplot(1,3,2)
            plot(val(:,2),'o-')
            title('OPD (nm)')
            subplot(1,3,3)
            plot(val(:,3)*180/pi,'o-')
            title('phase(degrees)')

            if get(hfig.UserData{8}.autosave,'value')
                saveData(hfig,hc)
            end


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

        function hfig=overview(IMlist,numbers)
            Nim=numel(IMlist);
            if nargin==1
                numbers=1:Nim;
            end
            Nimx=2+floor(sqrt(2*Nim)); % +1 to elongate a bit horizontally, because of screen shape.
            if mod(Nimx,2) % the number of images horizontally is not even
                Nimx=ceil(sqrt(2*Nim));
            end
            if mod(Nimx,2) % If taking the ceil did not solve the problem. Occurs if Nimx is a perfect square.
                Nimx=Nimx+1;
            end
            Nimy=ceil(2*Nim/Nimx); % number of lines

            hfig=figure();
            screenSz = get(groot,'ScreenSize');
            set(hfig,'position',[0 0 ceil(screenSz(3)) ceil(screenSz(4))]);

            iim=1;
            for iy=1:Nimy
                for ix=1:Nimx
                    if iim <= Nim
                        subplot(Nimy,Nimx,ix+Nimx*(iy-1))
                        if mod(ix,2)
                            imagesc(IMlist(iim).T)
                            colormap(gca,'gray(1024)')
                            title(['T #' num2str(numbers(iim))])
                        else
                            imagesc(IMlist(iim).OPD)
                            colormap(gca,'phase1024')
                            title(['OPD #' num2str(numbers(iim))])
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

        function set.Illumination(obj,val)
            if isa(val,'Illumination')
                obj.Illumination=val;
            else
                error('Illumination property must by an Illumination object')
            end
        end

        function set.Microscope(obj,val)
            if isa(val,'Microscope')
                obj.Microscope=val;
            else
                error('Microscope property must by an Microscope object')
            end
        end

        function opendx(obj,opt)
            arguments
                obj
                opt.persp = 1
                opt.phi = 45
                opt.theta = 45
                opt.ampl = 10
                opt.zrange = []
                opt.colorMap =  parulaNeuron
                opt.title (1,:) char = char.empty()
                opt.factor = 1 % correction factor, for instance 5.55e-3 to convert the OPD color scale into dry mass
                opt.label (1,:) char = 'Optical path difference (nm)'
            end
            % zrange in nm
            EL_camera=90-opt.theta;
            [Ny,Nx]=size(obj.OPD);
            fac=opt.factor;

            if isempty(opt.zrange)
                zrange=1e9*[min(obj.OPD(:)) max(obj.OPD(:))]*fac;
            else
                zrange=opt.zrange;
            end
            DZ=zrange(2)-zrange(1);
            factor=obj.pxSize*1e6;
            [X,Y] = meshgrid(0:Nx-1,0:Ny-1);
            X=X*factor;
            Y=Y*factor;

            if opt.persp==1
                DZ=DZ/opt.ampl;
            end

            %% handling the number of parameters
            coloringMap=obj.OPD*1e9*fac;

            %colormap(gca,colorScale);
            %% Display
            surf(X,Y,obj.OPD*1e9*fac,coloringMap,'FaceColor','interp',...
                'EdgeColor','none',...
                'FaceLighting','phong')
            if ~isempty(opt.title)
                figTitle=opt.title;
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
            colormap(gca,opt.colorMap)
            set(gca,'ztick',[])
            set(gca,'XLim',[0 obj.Nx*factor])
            set(gca,'YLim',[0 obj.Ny*factor])
            %axis tight
            %view(0,90)
            %camlight left
            %camlight(AZ, EL)
            if opt.phi==0 &&  opt.theta==0
                cb=colorbar(FontSize=20);
                cb.Label.String = opt.label;
                view(2)
                AZ_light=30;
                EL_light=25;
            else
                cb=colorbar('southoutside',FontSize=16);
                a =  cb.Position; %gets the positon and size of the color bar
                set(cb,'Position',[a(1) a(2) a(3)/4 a(4)])% To change size
                cb.Label.String = opt.label;
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
            drawnow
        end

        function makeMovie(IM,videoName,rate)
            %makeMovie(IM,videoName,rate)

            if 1 % fixed scale
                minPhL=zeros(numel(IM),1);
                maxPhL=zeros(numel(IM),1);
                for u=1:numel(IM)
                    phaseImage=IM(u).Ph-mean(IM(u).Ph(:));
                    IMg=imgaussfilt(phaseImage,2);
                    minPhL(u)=min(IMg(:));
                    maxPhL(u)=max(IMg(:));
                end
                minPh=min(minPhL);
                maxPh=max(maxPhL);
            end

            if nargin==2
                rate=1;
            elseif nargin==3
            else
                error('Number of input must be 1 or 2')
            end

            % create the video writer with 1 fps
            writerObj = VideoWriter(videoName);
            writerObj.FrameRate = rate;
            % open the video writer
            open(writerObj);
            % write the frames to the video
            AxesColor=[0 0 0];
            unit='�m';
            for u=1:numel(IM)
                % convert the image to a frame
                factorX=IM(u).pxSize*1e6;
                factorY=IM(u).pxSize*1e6;

                hfig=figure;
                hfig.Position=[1 1 1000 500];
                %% 1st image

                ha(1)=subplot(1,2,1);
                ha(1).XColor='w';
                xx=[0 IM(u).Nx*factorX];
                yy=[0 IM(u).Ny*factorY];
                imagesc(xx,yy,IM(u).T);
                axis equal
                colormap(gca,gray(1024))
                cb.T=colorbar;
                cb.T.Color=AxesColor;


                minT=min(IM(u).T(:));
                maxT=max(IM(u).T(:));

                if minT<1 && maxT>1
                    cb.T.Ticks = [minT,1,maxT];
                else
                    cb.T.Ticks = [minT,maxT];
                end

                if isa(IM(u),'ImageEM')
                    if norm(IM(u).EE0)==0
                        cb.T.Label.String = 'Intensity';
                    else
                        cb.T.Label.String = 'Normalized intensity';
                    end
                else
                    cb.T.Label.String = 'Normalized intensity';
                end

                cb.T.Label.FontSize = 14;
                axis([0 IM(u).Nx*factorX 0 IM(u).Ny*factorY])
                if isa(IM(u),'ImageQLSI')
                    title(IM(u).TfileName, 'Interpreter', 'none','FontSize',12)
                else
                    title('Norm. tranmission image','FontSize',12)
                end


                xlabel(unit,'FontSize',14);
                set(gca,'FontSize',14)
                set(ha(1),'XColor',AxesColor);
                set(ha(1),'YColor',AxesColor);
                ha(1).YDir = 'normal';

                %% 2nd image
                ha(2)=subplot(1,2,2);

                ha(1).Position(3)=ha(2).Position(3);
                ha(1).Position(1)=ha(1).Position(1)*1.2;
                phaseImage=IM(u).Ph-mean(IM(u).Ph(:));
                imagesc(xx,yy,phaseImage);
                axis equal
                colormap(gca,phase1024());
                cb.Ph=colorbar;
                ax = gca;
                ax.YDir = 'normal';
                cb.Ph.Color=AxesColor;

                % to avoid bright pixels distorting the colorscale
                %vec=sort(IM.Ph(:));
                %Nv=numel(vec);
                %caxis([vec(500) vec(Nv-500) ]);

                caxis([minPh maxPh]);




                cb.Ph.Label.String = 'Phase (rad)';
                cb.Ph.Label.FontSize = 14;
                cb.OPD=colorbar('westoutside');
                cb.OPD.Label.String = 'OPD (nm)';
                cb.OPD.Label.FontSize = 14;
                cb.OPD.Color=AxesColor;
                camlight(90,180,'infinite')
                axis([0 IM(u).Nx*factorX 0 IM(u).Ny*factorY])
                if isa(IM(u),'ImageQLSI')
                    title(IM(u).OPDfileName, 'Interpreter', 'none','FontSize',12)
                else
                    title('OPD/Phase image','FontSize',14)
                end
                xlabel(unit,'FontSize',14);
                set(gca,'FontSize',14);
                cb.OPD.TickLabels=round(100*cb.Ph.Ticks*IM(u).lambda/(2*pi)*1e9)/100;


                linkaxes(ha, 'xy');
                set(ha(2),'XColor',AxesColor);
                set(ha(2),'YColor',AxesColor);


                ha(1).Position(3)=ha(2).Position(3);


                frame=getframe(hfig);
                pause(0.5)
                writeVideo(writerObj, frame);
                close(hfig)


            end
            % close the writer object
            close(writerObj);

        end

        function makeMovie2(IM,videoName,opt)
            arguments
                IM
                videoName
                opt.rate = 25
                opt.zrange = []
                opt.colorMap =  phase1024
            end

            % create the video writer with 1 fps
            writerObj = VideoWriter(videoName);
            writerObj.FrameRate = opt.rate;
            % open the video writer
            open(writerObj);
            % write the frames to the video
            for u=1:numel(IM)
                % convert the image to a frame
                fac=5.6e-3;
                hfig=figure;
                imagesc(1e6*IM(1).pxSize*[0:IM(1).Nx-1],1e6*IM(1).pxSize*[0:IM(1).Ny-1],fac*IM(u).OPD*1e9)
                set(gca,'FontSize',16)
                xlabel('�m')
                set(gca,'ytick',[])
                set(gca,'YDir','normal')
                caxis(fac*opt.zrange)
                set(gca,'dataAspectRatio',[1 1 1])
                colormap(gca,opt.colorMap)
                cc=colorbar('fontSize',16);
                cc.Label.String='dry mass (pg/�m^2)';
                annotation ('textbox',[.2 .8 .1 .1],'String',sprintf('%.1f s',(u-1)*0.4),'FontSize',16,'LineStyle','none','HorizontalAlignment','right')
                drawnow
                frame=getframe(hfig);
                writeVideo(writerObj, frame);
                close(hfig)
            end
            % close the writer object
            close(writerObj);

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
                opt.colorMap =  parulaNeuron
                opt.title (1,:) char = char.empty()
                opt.factor = 1 % correction factor, for instance 5.55e-3 to convert the OPD color scale into dry mass
                opt.label (1,:) char = 'Optical path difference (nm)'
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
                if isempty(opt.zrange)
                    opendx(IM(u),persp=opt.persp,phi=opt.phi,theta=opt.theta,...
                        ampl=opt.ampl,colorMap=opt.colorMap,title=opt.title,factor=opt.factor,label=opt.label)
                else
                    opendx(IM(u),persp=opt.persp,phi=opt.phi,theta=opt.theta,...
                        ampl=opt.ampl,zrange=opt.zrange,colorMap=opt.colorMap,title=opt.title,factor=opt.factor,label=opt.label)
                end
                frame=getframe(hfig);
                drawnow
                writeVideo(writerObj, frame);
                close(hfig)


            end
            % close the writer object
            close(writerObj);

        end

        function val=sizeof(IM)
            Nim=numel(IM);
            val=0;
            for j=1:Nim
                props = properties(IM(j));
                totSize = 0;

                for ii=1:length(props)
                    currentProperty = getfield(IM(j), char(props(ii)));
                    s = whos('currentProperty');
                    totSize = totSize + s.bytes;
                end

                val=val+totSize;
            end
            fprintf('%.3g Ko\n',val)
        end
    end

    methods
        function obj = crop(obj0,opt)
            arguments
                obj0
                opt.xy1 = []
                opt.xy2 = []
                opt.Center {mustBeMember(opt.Center,{'Auto','Manual','auto','manual'})} = 'Auto'
                opt.Size = 'Manual'
                opt.twoPoints logical = false
            end

            if nargout
                obj=copy(obj0);
            else
                obj=obj0;
            end

            if opt.twoPoints
                obj(1).figure
                [xx,yy]=ginput(2);
                x1=min(xx);
                x2=max(xx);
                y1=min(yy);
                y2=max(yy);
                x1=max([1;x1]);
                x2=min([obj(1).Nx;x2]);
                y1=max([1;y1]);
                y2=min([obj(1).Ny;y2]);
            elseif ~isempty(opt.xy1) && ~isempty(opt.xy2)  % crop('xy1', [a,b], 'xy2', [a,b])
                if numel(opt.xy1)~=2
                    error('First input must be a 2-vector (x,y)')
                end
                if numel(opt.xy2)~=2
                    error('Second input must be a 2-vector (x,y)')
                end
                x1 = min([opt.xy1(1),opt.xy2(1)]);
                x2 = max([opt.xy1(1),opt.xy2(1)]);
                y1 = min([opt.xy1(2),opt.xy2(2)]);
                y2 = max([opt.xy1(2),opt.xy2(2)]);
            else
                if strcmpi(opt.Center,'Manual') % crop('Center','Manual')
                    h = obj(1).figure;
                    [xc, yc] = ginput(1);
                    close(h)
                else
                    xc = obj(1).Nx/2;
                    yc = obj(1).Ny/2;
                end
                if strcmpi(opt.Size,'Manual') % crop('Center','Manual')
                    h = obj(1).figure;
                    h.UserData{12}.getPoint = 0;
                    rr = rectangle();
                    set (h, 'WindowButtonMotionFcn', @(src,event)drawRect(h,rr,xc,yc))
                    set (h, 'WindowButtonDownFcn', @(src,event)getPoint(h))
                    while h.UserData{12}.getPoint==0
                        pause(0.1)
                    end
                    Size = h.UserData{12}.side;
                    close (h)
                    x1 = floor(xc-Size/2+1);
                    x2 = floor(xc-Size/2+Size);
                    y1 = floor(yc-Size/2+1);
                    y2 = floor(yc-Size/2+Size);
                elseif isnumeric(opt.Size)
                    x1 = floor(xc-opt.Size/2+1);
                    x2 = floor(xc-opt.Size/2+opt.Size);
                    y1 = floor(yc-opt.Size/2+1);
                    y2 = floor(yc-opt.Size/2+opt.Size);
                end

            end
            for io = 1:numel(obj)
                if isa (obj,'ImageQLSI')
                    temp=obj(io).T(y1:y2,x1:x2); % temp variable to avoid importing the matrix twice for the calculation of Nx and Ny when it is stored in a file.
                    obj(io).T   = temp;
                    obj(io).OPD = obj(io).OPD(y1:y2,x1:x2);
                    [obj(io).Ny, obj(io).Nx]=size(temp);
                    if ~isempty(obj(io).DWx)
                        obj(io).DWx0=obj(io).DWx(y1:y2,x1:x2);
                        obj(io).DWy0=obj(io).DWy(y1:y2,x1:x2);
                    end
                else
                    obj(io).Ex = obj0(io).Ex(x1:x2,x1:x2);
                    obj(io).Ey = obj0(io).Ey(x1:x2,x1:x2);
                    obj(io).Ez = obj0(io).Ez(x1:x2,x1:x2);
                end
            end


            function drawRect(h,rr,xc,yc)
                C = get (h.UserData{7}(2), 'CurrentPoint');
                side = floor(max(abs([2*(C(1)-xc), 2*(C(3)-yc)])));
                set(rr,'Position',[xc-side/2 yc-side/2 side side])
                h.UserData{12}.side = side;
                disp(side)
            end

            function getPoint(h)
                h.UserData{12}.getPoint = 1;
            end

        end
    end

end