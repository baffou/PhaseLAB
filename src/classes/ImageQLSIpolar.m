classdef ImageQLSIpolar   <   handle & matlab.mixin.Copyable
    % Class that deals with **experimental** polar-CGM data.
    % It contains the 4 QLSI images corresponding to the 4 polarizations.
    
    properties(GetAccess = public, SetAccess = {?Methods})
        IM (1,4) ImageQLSI
    end
    
    properties(GetAccess = public, SetAccess = private)
        retardanceMax (1,1) double = 10e-9 % max amplitude of the retardance on the color map of theta
        eLim (1,1) double = 0.1 % min ellipiticity to be displayed
        dichroMax (1,1) double = 0.1
        thetaShift = 0
    end

    properties
        calcSjMode  char {mustBeMember(calcSjMode,{'Tj','Ej'})} = 'Tj'
        dphi0 = 1 % artificial phase shift on both axes to simulated a missdetermination of the grating camera distance
    end

    properties (Access = {?Methods})
        IM0 (1,4) ImageQLSI % raw image
    end

    properties(Dependent)
        Ny
        Nx
        Ex
        Ey

        % Stokes props
        S0
        S1
        S2
        S3
        L

        % Ellipse props
        e % ellipticity
        A % major-axis length
        B % minor-axis length
        thetaEllipse % orientation angle of the polarization ellipse
        thetaEllipseDeg % same in degrees
        h % handedness +1 or -1 values
        rgbImageEllipse 


        % biref/retardance params
        theta0 % birefringence angle (if the material is purely birefringent
        phibar
        dphi
        Tbar
        dichroism
        thetaT
        Wbar
        retardance
        dW
        rgbImage
        OPDmean

        Illumination
        Microscope
    end

    methods

        function obj = ImageQLSIpolar(IM)
            arguments
                IM  (:,4) ImageQLSI = ImageQLSI.empty(0,4)
            end
            if nargin % else, create an empty object

                Nim = size(IM,1);
                if Nim == 1
                    obj.IM0 = IM; % copy of the handle. No duplication.

                else
                    obj = repmat(ImageQLSIpolar(),Nim,1);
                    for nim = 1:Nim
                        obj(nim) = ImageQLSIpolar(IM(nim,:)); % copy of the handle. No duplication.
                    end
                end
                obj.updateIM()
            end
        end

        function app = figure(obj)
            if nargout
                app = figurePolarGUI2(obj);
%                app = figurePolarGUI(obj);
            else
                figurePolarGUI2(obj)
%                figurePolarGUI(obj)
            end
        end

        function setCalcSjMode(obj,val)
            arguments
                obj
                val char {mustBeMember(val,{'Tj','Ej'})} = 'Tj'
            end
            Nim = numel(obj);
            for ii = 1:Nim
                obj(ii).calcSjMode = val;
            end
        end

        function adjustPolarOffsets(obj,opt)
            arguments
                obj
                opt.method {mustBeMember(opt.method,{'manual','auto'})} = 'auto'
                opt.displayC (1,1) logical = false
            end

            [Nim, Nch] = size(obj);

            for ii = 1:Nim
                if strcmpi(opt.method,'auto')
                    
                    for jch = 1:Nch
    
        
                        T1 = obj(ii,jch).IM(1).T;
                        T2 = obj(ii,jch).IM(2).T;
                        T3 = obj(ii,jch).IM(3).T;
                        T4 = obj(ii,jch).IM(4).T;
        
                        Phi1 = obj(ii,jch).IM(1).Ph;
                        Phi2 = obj(ii,jch).IM(2).Ph;
                        Phi3 = obj(ii,jch).IM(3).Ph;
                        Phi4 = obj(ii,jch).IM(4).Ph;
        
                        if ~obj(ii,jch).Illumination.isCircular
                            error('the illumination is not circularly polarized')
                        end
                        S3ill = obj(ii,jch).Illumination.S3;
                        if S3ill <0
                            C = 0.5*(T2-T4)./sqrt(T1.*T3);
                        else
                            C = -0.5*(T2-T4)./sqrt(T1.*T3);
                        end
    
                        if opt.displayC
                            asinC = asin(C);
                            dph = Phi1-Phi3;
                            asinC = asinC-mean(asinC(:));
                            dph = dph - mean(dph(:));
                            figure
                            subplot(1,3,1)
                            % plot(0.64*mean(real(asinC(end/2-10:end/2+10,:))),'b','LineWidth',1.5)
                            plot(mean(real(asinC(end/2-10:end/2+10,:))),'b','LineWidth',1.5)
                            hold on
                            plot(mean(dph(end/2-10:end/2+10,:)),'r-.','LineWidth',2)
                            legend({'asinC','Phi1-Phi3'})
                            lims = [-1 1];
                            ylim(lims)
                            %%
                            subplot(1,3,2)
                            imagesc(real(asinC)),clim(lims),colorbar
                            
                            subplot(1,3,3)
                            imagesc(dph),clim(lims),colorbar%,clim([-0.05 0.05])
                            fullwidth
                            title(ii+"/"+Nim)
                            drawnow
                            pause(1)
                        end
    
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
                        dPhi3map = Phi3-Phi1+asin(C);
                        dPhi3 = median(dPhi3map(:));
                        %dPhi3 = Phi3-Phi1+acos(C);
        
                        phi1 = obj(ii,jch).IM(1).Ph;
                        phi3 = obj(ii,jch).IM(3).Ph - dPhi3;
        
                        %% setting the right offset to the first image to make sure the background is zero in OPD
                        %phi1 = phi1 - mean(mean(phi1(1,1:end-1)+phi1(1:end-1,end)+phi1(2:end,1)+phi1(end,2:end)))/4;
        
                        %% other polars 2 & 4
                        E1 = sqrt(T1);
                        E3 = sqrt(T3);
                        dPhi2 = median(median(Phi2+unwrap(  pi/4-angle( E1.*exp(1i*phi1)+1i*E3.*exp(1i*phi3)))));
                        dPhi4 = median(median(Phi4+unwrap(3*pi/4-angle(-E1.*exp(1i*phi1)+1i*E3.*exp(1i*phi3)))));
        
                        %% New OPD images, with the right shift
                        lambda = obj(ii,jch).IM(1).Illumination.lambda;
                        % IM(ii, 1).OPD = phi1*lambda/(2*pi); % useless
                        obj(ii,jch).IM(2).OPD = obj(ii,jch).IM(2).OPD - dPhi2*lambda/(2*pi);
                        obj(ii,jch).IM(3).OPD = obj(ii,jch).IM(3).OPD - dPhi3*lambda/(2*pi);
                        obj(ii,jch).IM(4).OPD = obj(ii,jch).IM(4).OPD - dPhi4*lambda/(2*pi);
                    end
                else % manual set of the area of the image that should be zero on each image
                    hfig = figure; imageph(obj(ii,1).Wbar)
                    [x, y] = ginput(2);
                    close(hfig)
                    for jch = 1:Nch
                        obj(ii,jch).IM.level0("params", [min(x), max(x), min(y), max(y)])
                    end
                end
            end
        end

        function setThetaShift(obj, val)
            % converts in [m] in case the norm factor is entered in [nm]
            for io = 1:numel(obj)
                obj(io).thetaShift = val;
            end
        end

        function set_retMax(obj, val)
            if val >1e-3 % value in [nm]
                val = val*1e-9; % conversion in [m]
            end
            Nim = numel(obj);
            for nim = 1:Nim
                obj(nim).retardanceMax = val;
            end
        end

        function set_eLim(obj, val)
            Nim = numel(obj);
            for nim = 1:Nim
                obj(nim).eLim = val;
            end
        end

        function set_dichroMax(obj, val)
            Nim = numel(obj);
            for nim = 1:Nim
                obj(nim).dichroMax = val;
            end
        end

        function updateIM(obj)
            Nim = numel(obj);
            for nim = 1:Nim
                obj(nim).IM = obj(nim).IM0;
            end
        end

        function J = im2J(obj1, obj2)
            arguments
                obj1 ImageQLSIpolar % [pImL, pImR]
                obj2 ImageQLSIpolar % [pImL, pImR]
            end
            % J = im2J(pImL, pImR)
            % J = im2J([pImL, pImR])
            if nargin == 2 % im2J(pImL, pImR)
                Nim = size(obj1,1);
                Nim2 = size(obj2,1);
                if Nim ~= Nim2
                    error('The two ImageQLSIpolar inputs don''t have the same size')
                end
                obj = [obj1,obj2];
            elseif nargin == 1 % im2J([pImL, pImR])
                if size(obj1,2) ~=2
                    error('The input should be a 2-column ImageQLSIpolar array. Or specify two 1-colum inputs.')
                end
                obj = obj1;
            end
            J = ImageJonesMatrix(Nim);
            for ii = 1:Nim
                J(ii) = IM_to_J(obj(ii,1).IM,obj(ii,2).IM);
                J(ii).Microscope = obj(ii,1).Microscope;
                J(ii).Illumination = obj(ii,1).Illumination;
            end
        end

        function T = im2T(obj)
            arguments
                obj (:,2) ImageQLSIpolar % [pImL, pImR]
            end
            Nim = size(obj,1);
            T = repmat(ImageTransmittance, Nim, 1);
            for ii = 1:Nim
                T(ii) = IM_to_T(obj(ii,1).IM,obj(ii,2).IM);
            end
        end


        % set/get methods
        function val = get.Ex(obj)
           % switch obj.calcSjMode
           %      case 'Tj'
           %          val = obj.IM(1).T + obj.IM(3).T;
           %      case 'Ej'
                    val = sqrt(obj.IM(1).T).*exp(1i*obj.IM(1).Ph*obj.dphi0);
           % end
        end

        function val = get.Ey(obj)
            s = -sign(obj.Illumination.S3/obj.Illumination.S0); % negative sign, because it seems that this way the ellipse turns in the right direction, according to the rotation of the sample
            val = s * 1i * sqrt(obj.IM(3).T).*exp(1i*obj.IM(3).Ph*obj.dphi0);
        end

        function val = get.S0(obj)
            switch obj.calcSjMode
                case 'Tj'
                    val = (obj.IM(1).T + obj.IM(3).T)/2;
                case 'Ej'
                    val = (abs(obj.Ex).^2 + abs(obj.Ey).^2)/2;
            end
        end
        
        function val = get.S1(obj)
            switch obj.calcSjMode
                case 'Tj'
                    val = (obj.IM(1).T - obj.IM(3).T)/2;
                case 'Ej'
                    val = (abs(obj.Ex).^2 - abs(obj.Ey).^2)/2;
            end
        end
        
        function val = get.S2(obj)
            switch obj.calcSjMode
                case 'Tj'
                    val = (obj.IM(2).T - obj.IM(4).T)/2;
                case 'Ej'
                    val = real(obj.Ex.*conj(obj.Ey));
            end
        end
        
        function val = get.S3(obj)
            switch obj.calcSjMode
                case 'Tj'
                    hel = sign(obj.IM0(1).Illumination.S3);
                    val = hel*sqrt(obj.S0.^2-obj.S1.^2-obj.S2.^2);
                case 'Ej'
                    val = imag(obj.Ex.*conj(obj.Ey));
            end
        end
        
        function val = get.L(obj)
            val = obj.S1 + 1i*obj.S2;
        end
        
        function val = get.A(obj)
            val = sqrt(0.5*(obj.S0+abs(obj.L)));
        end
        
        function val = get.B(obj)
            val = sqrt(0.5*(obj.S0-abs(obj.L)));
        end
        
        function val = get.thetaEllipse(obj)
            val = mod(0.5*angle(obj.L) + obj.thetaShift,pi);
        end

        function val = get.thetaEllipseDeg(obj)
            val = obj.thetaEllipse*180/pi;
        end

        function val = get.rgbImageEllipse(obj)

            hsvImage = zeros(obj.Ny, obj.Nx, 3);

            if obj.Illumination.S3 < 0 % S3 < 0, e < 0
                cmin = -1;
                cmax = -obj.eLim;
                corr = 1;
                hsvImage(:,:,1) = obj.thetaEllipse/pi;
                hsvImage(:,:,2+corr) = (obj.e-cmin)/(cmax-cmin);
                hsvImage(:,:,3-corr) = ones(obj.Ny,obj.Nx);
            else % S3 > 0, e > 0
                cmax = 1;
                cmin = obj.eLim;
                corr = 0;
                hsvImage(:,:,1) = obj.thetaEllipse/pi;
                hsvImage(:,:,2+corr) = 1-(obj.e-cmin)/(cmax-cmin);
                hsvImage(:,:,3-corr) = ones(obj.Ny,obj.Nx);
            end

            val = hsv2rgb(hsvImage);
        end

        function val = get.h(obj)
            val = sign(obj.S3);
        end
        
        function val = get.e(obj)
            val = sign(obj.S3).*obj.B./obj.A;
%           val = 2*abs(obj.L)./(obj.S0+abs(obj.L));
        end
        
        function img = get.phibar(obj)
            arguments
                obj
            end

            img = (obj.IM(1).Ph + obj.IM(2).Ph ...
                 + obj.IM(3).Ph + obj.IM(4).Ph)/4*obj.dphi0;

        end

        function img = get.Tbar(obj)
            arguments
                obj
            end

            img = (obj.IM(1).T + obj.IM(2).T ...
                 + obj.IM(3).T + obj.IM(4).T)/4;

        end

        function img = get.theta0(obj)
            arguments
                obj
            end

            img = mod(0.5*angle((obj.IM(1).Ph*obj.dphi0-obj.IM(3).Ph*obj.dphi0) ...
                   + 1i*(obj.IM(2).Ph*obj.dphi0-obj.IM(4).Ph*obj.dphi0)),pi);

        end

        function img = get.thetaT(obj)
            arguments
                obj
            end

            img = mod(0.5*angle((obj.IM(1).T-obj.IM(3).T) ...
                   + 1i*(obj.IM(2).T-obj.IM(4).T)),pi);

        end

        function img = get.dphi(obj)
            % valid for a purely birefringent sample
            arguments
                obj
            end
            phib = obj.phibar;
            img = sqrt(abs((obj.IM(4).Ph*obj.dphi0-phib) ...
                         .*(obj.IM(2).Ph*obj.dphi0-phib) ...
                         + (obj.IM(3).Ph*obj.dphi0-phib) ...
                         .*(obj.IM(1).Ph*obj.dphi0-phib)));

        end

        function img = get.dichroism(obj)
            % Valid for a purely dichroic sample
            arguments
                obj
            end
            Tb = obj.Tbar;
            img = sqrt(abs((obj.IM(4).T-Tb) ...
                         .*(obj.IM(2).T-Tb) ...
                         + (obj.IM(3).T-Tb) ...
                         .*(obj.IM(1).T-Tb)));

        end

        function img = get.rgbImage(obj)
            arguments
                obj
            end

            if obj.Illumination.S3 < 0
                corr = 1;
            else
                corr = 0;
            end
            hsvImage = zeros(obj.Ny, obj.Nx, 3);
            hsvImage(:,:,1) = obj.theta0/pi;
            hsvImage(:,:,2+corr) = 1/obj.retardanceMax*obj.dphi0 * obj.Illumination.lambda/(2*pi);
            hsvImage(:,:,3-corr) = ones(obj.Ny,obj.Nx);

            img = hsv2rgb(hsvImage);
        end

        function img = get.OPDmean(obj)
            img = obj.Wbar;
        end

        function val = get.Wbar(obj)
            val = obj.phibar*obj.Illumination.lambda/(2*pi); 
        end

        function val = get.retardance(obj)
            % valid for a purely birefringent sample
            val = obj.dphi*obj.Illumination.lambda/(2*pi); 
        end

        function val = get.dW(obj)
            val = obj.retardance; 
        end

        function set.retardanceMax(obj, val)
            % converts in [m] in case the norm factor is entered in [nm]
            obj.retardanceMax = convert_nm(val);
        end

        function set.dichroMax(obj, val)
            % converts in [m] in case the norm factor is entered in [nm]
            obj.dichroMax = val;
        end

        function val = get.Nx(obj)
            val = obj.IM.Nx;
        end
        
        function val = get.Ny(obj)
            val = obj.IM.Ny;
        end

        function val = get.Illumination(obj)
            val = obj.IM(1).Illumination;
        end

        function val = get.Microscope(obj)
            val = obj.IM(1).Microscope;
        end

        function export(obj,path,opt)
            arguments
                obj
                path
                opt.formats string {mustBeMember(opt.formats,["eps","png","jpg","fig","txt","pdf"])}
                opt.types string {mustBeMember(opt.types,["OPDmean","retardance","rgbImage","e","rgbImageEllipse","Wbar","phibar","theta0","thetaEllipse","dphi","dW"])}
                opt.num = []
                opt.colormap = parula
                opt.clim = []
            end

            path = char(path);
            if path(end) == '/'
                path = path(1:end-1); % remove the last "/"
            end
        
            for im = 1:numel(obj)
                for iif = 1:numel(opt.formats)
                    switch opt.formats(iif)
                        case {"eps","png","jpg","fig","epsc","pdf"}
                            if opt.formats(iif) == "eps",opt.formats(iif)="epsc";end
                            ext = char(opt.formats(iif));
                            Nt = numel(opt.types);
                            if Nt == 0
                                error('You must select at least one output type')
                            elseif Nt > 1
                                if ~exist('hfig','var')
                                    hfig = figure;
                                    Nt = numel(opt.types);
                                    for it = 1:Nt
                                        ax(it) = subplot(1,3,it);
                                        imageph(obj(im).(opt.types(iit)))
                                        title(opt.types(iit))
                                    end
                                    fullwidth
                                end
                                sb = Scalebar(20e-6, obj(im).IM(1).pxSize);
                                sb.insert(ax(1))
                                if isempty(opt.num)
                                    num = im;
                                else
                                    num = opt.num;
                                end
                                saveas(hfig, path + "/overview_" + textkkk(num) + "." + ext(1:3), ext);
                            else
                                exportImage(obj(im).(opt.types), path + "/" + opt.types + "_" + textkkk(im) + "." + ext(1:3),"colormap",opt.colormap,"clim",opt.clim);
                            end

    
                        case "txt"
                            for iit = 1:numel(opt.types)
                                dlmwrite(path + "/" + opt.types(iit) + "_" + textkkk(opt.num) + ".txt", obj(im).(opt.types(iit)),' ');
                            end                        
                    end
                end
                if exist('hfig','var'),close(hfig),end
                clear hfig
            end
        end

    end




end