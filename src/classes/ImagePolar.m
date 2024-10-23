classdef ImagePolar   <   handle & matlab.mixin.Copyable
    % class to deal with polar QLSI images
    properties
        IM (1,4) ImageQLSI
        retardanceMax (1,1) double % max amplitude of the retardance on the color map of theta
        smoothing = [] % Gaussian filter of the OPD images
        Microscope
        Illumination
    end

    properties(Dependent)
        Ny
        Nx
        theta0
        phibar
        dphi
        Wbar
        retardance
        rgbImage
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
                    obj.IM = IM; % copy of the handle. No duplication.
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

            img = angle((obj.IM(1).Ph-obj.IM(3).Ph) ...
                   + 1i*(obj.IM(2).Ph-obj.IM(4).Ph));

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


 
            hsvImage = zeros(obj.Ny, obj.Nx, 3);
            hsvImage(:,:,1) = obj.theta0/pi/2+0.5;
            hsvImage(:,:,2) = 1/obj.retardanceMax*obj.dphi * obj.Illumination.lambda/(2*pi);
            hsvImage(:,:,3) = ones(obj.Ny,obj.Nx);

            img = hsv2rgb(hsvImage);
        end

        function val = get.Wbar(obj)
            val = obj.phibar*obj.Illumination.lambda/(2*pi); 
        end

        function val = get.retardance(obj)
            val = obj.dphi*obj.Illumination.lambda/(2*pi); 
        end


        function set.retardanceMax(obj, val)
            % converts in [m] in case the norm factor is entered in [nm]
            obj.retardanceMax = convert_nm(val);
        end

        function set_retMax(obj, val)
            Nim = numel(obj);
            for nim = 1:Nim
                obj(nim).retardanceMax = val;
            end
        end



        function val = get.Nx(obj)
            val = obj.IM.Nx;
        end
        
        function val = get.Ny(obj)
            val = obj.IM.Ny;
        end
        
    end




end