classdef ImagePolar   <   handle & matlab.mixin.Copyable
    % class to deal with polar QLSI images
    
    properties(GetAccess = public, SetAccess = {?Methods})
        IM (1,4) ImageQLSI  % smoothed if smoothing ≠ 0
    end
    
    properties(GetAccess = public, SetAccess = private)
        retardanceMax (1,1) double = 20 % max amplitude of the retardance on the color map of theta
        smoothing (1,1) double {mustBeGreaterThanOrEqual(smoothing,0)} = 0 % Gaussian filter of the OPD images. None if  = 0
    end

    properties
        rgb_bg0 char {mustBeMember(rgb_bg0,{'white','black'})} = 'black'  % smoothed if smoothing ≠ 0
    end
    properties(Hidden)
        Microscope
        Illumination
    end

    properties (Access = {?Methods})
        IM0 (1,4) ImageQLSI % raw image
    end

    properties(Dependent)
        Ny
        Nx
        theta0
        phibar
        dphi
        Wbar
        retardance
        dW
        rgbImage
        OPDmean
    end

    methods

        function obj = ImagePolar(IM,norm)
            arguments
                IM  = ImageQLSI.empty()
                norm = 10e-9 % 10 nm of retardance
            end
            if nargin % else, create an empty object

                Nim = size(IM,1);
                if Nim == 1
                    obj.IM0 = IM; % copy of the handle. No duplication.
                    obj.retardanceMax = norm;
                    obj.Illumination = IM(1).Illumination;
                    obj.Microscope = IM(1).Microscope;

                else
                    obj = repmat(ImagePolar(),Nim,1);
                    for nim = 1:Nim
                        obj(nim) = ImagePolar(IM(nim,:), norm); % copy of the handle. No duplication.
                        obj(nim).Illumination = IM(1).Illumination;
                        obj(nim).Microscope = IM(1).Microscope;
                    end
                end
                obj.updateIM() % apply the IM, that includes the smoothing
            end
        end

        function img = get.phibar(obj)
            arguments
                obj
            end

            img = (obj.IM(1).Ph + obj.IM(2).Ph ...
                 + obj.IM(3).Ph + obj.IM(4).Ph)/4;

        end

        function img = get.theta0(obj)
            arguments
                obj
            end

            img = mod(0.5*angle((obj.IM(1).Ph-obj.IM(3).Ph) ...
                   + 1i*(obj.IM(2).Ph-obj.IM(4).Ph)),pi);

        end

        function img = get.dphi(obj)
            arguments
                obj
            end
            phib = obj.phibar;
            img = sqrt(abs((obj.IM(4).Ph-phib) ...
                         .*(obj.IM(2).Ph-phib) ...
                         + (obj.IM(3).Ph-phib) ...
                         .*(obj.IM(1).Ph-phib)));

        end

        function img = get.rgbImage(obj)
            arguments
                obj
            end

            if strcmp(obj.rgb_bg0,'black')
                corr = 1;
            else
                corr = 0;
            end
            hsvImage = zeros(obj.Ny, obj.Nx, 3);
            hsvImage(:,:,1) = obj.theta0/pi;
            hsvImage(:,:,2+corr) = 1/obj.retardanceMax*obj.dphi * obj.Illumination.lambda/(2*pi);
            hsvImage(:,:,3-corr) = ones(obj.Ny,obj.Nx);

            img = hsv2rgb(hsvImage);
        end

        function img = get.OPDmean(obj)
            img = obj.Wbar;
        end

        function app = figure(obj)
            if nargout
                app = figurePolar(obj);
            else
                figurePolar(obj)
            end
        end

        function val = get.Wbar(obj)
            val = obj.phibar*obj.Illumination.lambda/(2*pi); 
        end

        function val = get.retardance(obj)
            val = obj.dphi*obj.Illumination.lambda/(2*pi); 
        end

        function val = get.dW(obj)
            val = obj.retardance; 
        end


        function set.retardanceMax(obj, val)
            % converts in [m] in case the norm factor is entered in [nm]
            obj.retardanceMax = convert_nm(val);
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

        function set_smoothing(obj, val)
            Nim = numel(obj);
            for nim = 1:Nim
                obj(nim).smoothing = val;
                obj(nim).updateIM()
            end
        end

        function updateIM(obj)
            Nim = numel(obj);
            for nim = 1:Nim
                if obj(nim).smoothing ~= 0
                    obj(nim).IM = obj(nim).IM0.flatten("Gaussian","nGauss",obj.smoothing,"display",0);
                else
                    obj(nim).IM = obj(nim).IM0;
                end
            end
        end

        function val = get.Nx(obj)
            val = obj.IM.Nx;
        end
        
        function val = get.Ny(obj)
            val = obj.IM.Ny;
        end

        function rgb_bg(obj, val)
            Nim = numel(obj);
            for ii = 1:Nim
                obj(ii).rgb_bg0 = val;
            end
        end

        function export(obj,path,opt)
            arguments
                obj
                path
                opt.formats string {mustBeMember(opt.formats,["eps","png","jpg","fig","txt"])}
                opt.types string {mustBeMember(opt.types,["OPDmean","retardance","rgbImage","Wbar","phibar","theta0","dphi","dW"])}
                opt.num = []
            end

            path = char(path);
            if path(end) == '/'
                path = path(1:end-1); % remove the last "/"
            end
        
            for im = 1:numel(obj)
                for iif = 1:numel(opt.formats)
                    switch opt.formats(iif)
                        case {"eps","png","jpg","fig","epsc"}
                            if opt.formats(iif) == "eps",opt.formats(iif)="epsc";end
                            ext = char(opt.formats(iif));
                            if ~exist('hfig','var')
                                hfig = figure;
                                ax1 = subplot(1,3,1);
                                imageph(obj(im).OPDmean*1e9)
                                title('OPDmean')
                                subplot(1,3,2)
                                imageph(obj(im).retardance*1e9)
                                title('retardance')
                                clim([0 obj(im).retardanceMax*1e9])
                                subplot(1,3,3)
                                imagehsv(obj(im).rgbImage)
                                title('theta')
                                fullwidth
                            end
                            sb = Scalebar(20e-6, obj(im).IM(1).pxSize);
                            sb.insert(ax1)
                            if isempty(opt.num)
                                num = im;
                            else
                                num = opt.num;
                            end
                            saveas(hfig, path + "/overview_" + textkkk(num) + "." + ext(1:3), ext);
                            
    
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