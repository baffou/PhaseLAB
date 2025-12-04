classdef Camera_Simu  <  CameraExp & Camera
    % inherits from two calses, the Camera classes and the abstract
    % CameraExp class that contains all the properties and methods for live
    % control of the camera.

    % Each camera type has a specific class, here Simu cameras.
    % See Camera_Hamamatsu
    %     Camera_PCO
    %     Camera_Andor
    %     Camera_Pixelink
    % for the other camera types
    
    properties(SetAccess = private)
        hndl
        %CData double
        imageDimensionsList

        IM0 = []  % raw numerical interferogram
    end

    properties(Dependent, SetAccess = private)
        expTime %exposure time in seconds
        imagesize
        width
        height
        top
        left
        stride
    end



    methods

        function obj = Camera_Simu(cam) % constructor

            propList = properties(cam);

            for ip = 1:numel(propList)
                obj.(propList{ip}) = cam.(propList{ip});
            end

            obj.hndl.cycleMode = 'Continuous';
            obj.hndl.triggerMode = 'Software';
            obj.hndl.width = cam.Nx;
            obj.hndl.height = cam.Ny;
            obj.hndl.top = 1;
            obj.hndl.left = 1;
            obj.hndl.Nim = 1;
            obj.setImageDimensions(cam.Nx,cam.Ny,1,1)

            obj.imageDimensionsList = {[num2str(cam.Nx) ' x ' num2str(cam.Ny)], ...
                [num2str(round(cam.Nx/2)) ' x ' num2str(round(cam.Ny/2))],...
                [num2str(round(cam.Nx/4)) ' x ' num2str(round(cam.Ny/4))]};

        end

        function rc = turn(obj,val)
            % turn on or off the camera
            % Cam.turn('on')
            % Cam.turn('off')
            arguments
                obj
                val {mustBeMember(val,{'on','off'})}
            end

            switch val
                case 'on'
                    rc = 0;
                    disp('Camera initialized');
                case 'off'
                    rc = 0;
                    disp('Camera shutdown');            
            end
        end

        function setMode(obj,cycleMode, triggerMode,opt)
            arguments
                obj
                cycleMode   {mustBeMember(cycleMode,   {'Fixed','Continuous','Burst'})}
                triggerMode {mustBeMember(triggerMode, {'Internal','External','Software'})}
                opt.expTime = []
                opt.Nim = 1 % number of images to be acquiredin Fixed mode
            end
            
            obj.hndl.cycleMode = cycleMode;
            obj.hndl.triggerMode = triggerMode;
            obj.hndl.expTime = opt.expTime;
            obj.hndl.Nim = opt.Nim;

        end

        function startAcquisition(obj)

        end

        function stopAcquisition(obj)

        end

        function updateIM0(obj,app)
            if isempty(obj.IM0)
                processIM0 = 1;
            elseif obj.IM0.Nx ~= obj.height || obj.IM0.Ny ~= obj.width
                processIM0 = 1;
            else
                processIM0 = 0;
            end

            if processIM0
                    
                system = 'NP';
                switch system
                    case 'NP'
                        radius = 500e-9;
                        DI0  =  Dipole('Au',radius);
                        DI = [DI0.moveBy('x',1e-6), DI0.moveBy('x',-1.4e-6,'y',0.7e-6,'z',-0.6e-6), DI0.moveBy('x',3e-6,'y',-3e-6)];
                        DI  =  DI.shine(app.IL);
            
                        obj.IM0 = imaging(DI,app.IL,app.MI,obj.height);
                    case 'noise'
                        obj.IM0(il) = ImageQLSI(ones(Npx),zeros(Npx),MI,IL(il));
                    case 'Gaussian'
                        IMref = ImageQLSI(ones(obj.height,obj.width),zeros(obj.height,obj.width),app.MI,app.IL);
                        Gampl  =  100e-9; % Gaussian profile amplitude [m]
                        Gradius  =  obj.width/10; % Gaussian profile radius [m]
                        [X,Y]  =  meshgrid(1:obj.width,1:obj.height);
                        X  =  X-mean(X(:));
                        Y  =  Y-mean(Y(:));
                        Gauss = exp(-(X.^2+Y.^2)/Gradius.^2);
                        OPD  =  Gampl*Gauss; % (Fig 2f)
                        T = 1-0.1*Gauss;
                        obj.IM0 = ImageEM(ImageQLSI(sqrt(T),OPD,app.MI,app.IL),ImageEM(IMref));
                        
                end            

            end
        end


        function buf = acquire_continuous(obj,app)
            % create or update IM0 if it does not exist, or has the wrong
            % dimensions
            obj.updateIM0(app)
       
            Itf = CGMinSilico(obj.IM0,shotNoise = 1,Nimages = 1);
            buf = Itf.Itf; % app.Itf0 or app.Ref0
        
        end
        
        function buf = acquire_fixed(obj,Nim,app)
            arguments
                obj
                Nim
                app
            end

            obj.updateIM0(app)

            if strcmpi(obj.mode,'ref')
                radius = 0.001e-9;
                DI0 = Dipole('Au',radius);
                DI = [DI0.moveBy('x',1e-6), DI0.moveBy('x',-1.4e-6,'y',0.7e-6,'z',-0.6e-6), DI0.moveBy('x',3e-6,'y',-3e-6)];
                DI = DI.shine(app.IL);

                IM = imaging(DI,app.IL,app.MI,obj.height);

            else
                IM = obj.IM0;
            end
           
            Itf = CGMinSilico(repmat(IM,Nim,1),shotNoise = 1);
            ItfArray = zeros(IM.Ny,IM.Nx,obj.hndl.Nim);
            for ii = 1:obj.hndl.Nim
                ItfArray(:,:,ii) = Itf(ii).Itf;
                buf = ItfArray; % normally app.Itf0, never app.Ref0
            end
        end
        
        function setImageDimensions(obj,varargin)
            if nargin == 2 && ischar(varargin{1}) % setImageDimensions('2560 x 2160')

                switch varargin{1}
                    case '2560 x 2160'
                        obj.width  = 2560;
                        obj.height = 2160;
                        obj.top    = 1;
                        obj.left   = 1;
                    case '2064 x 2048'
                        obj.width  = 2064;
                        obj.height = 2048;
                        obj.top    = 57;
                        obj.left   = 265;
                    case '1920 x 1080'
                        obj.width  = 1920;
                        obj.height = 1080;
                        obj.top    = 537;
                        obj.left   = 337;
                    case '1392 x 1040'
                        obj.width  = 1920;
                        obj.height = 1080;
                        obj.top    = 561;
                        obj.left   = 601;
                    case '528 x 512'
                        obj.width  = 528;
                        obj.height = 512;
                        obj.top    = 825;
                        obj.left   = 1033;
                    case '240 x 256'
                        obj.width  = 240;
                        obj.height = 256;
                        obj.top    = 953;
                        obj.left   = 1177;
                    case '144 x 128'
                        obj.width  = 144;
                        obj.height = 128;
                        obj.top    = 1017;
                        obj.left   = 1225;
                    case '2560 x 304'
                        obj.width  = 2560;
                        obj.height = 304;
                        obj.top    = 929;
                        obj.left   = 1;
                    otherwise
                        numbers = regexp(varargin{1}, '[+-]?\d*\.?\d+', 'match');
                        obj.width  = str2double(numbers{1});
                        obj.height = str2double(numbers{2});
                        obj.left   = 1 + floor((obj.Nx-str2double(numbers{1}))/2);
                        obj.top    = 1 + floor((obj.Ny-str2double(numbers{2}))/2);
                end

            elseif nargin == 5 && isnumeric([varargin{1:end}]) % setImageDimensions(2560,2160)
                        obj.width  = varargin{1};
                        obj.height = varargin{2};
                        obj.top    = varargin{3};
                        obj.left   = varargin{4};
            else
                error('Error in the inputs of setImageDimensions')
            end

        end

        function setExpTime(obj,val)
            arguments
                obj
                val (1,1) double {mustBeNumeric,mustBePositive}
            end
            obj.hndl.expTime = val;
        end


        % get/set methods

        function val = get.expTime(obj)
            val = obj.hndl.expTime;
        end

        function set.width(obj,val)
            if val <= obj.Nx
                obj.hndl.width = val;
            else
                error('width cannot be larger than the camera sensor width Nx')
            end
        end

        function val = get.width(obj)
                val = obj.hndl.width;
        end

        function set.height(obj,val)
            if val <= obj.Ny
                obj.hndl.height = val;
            else
                error('height cannot be larger than the camera sensor height Ny')
            end
        end

        function val = get.height(obj)
            val = obj.hndl.height;
        end

        function set.top(obj,val)
            obj.hndl.top = val;
        end

        function val = get.top(obj)
            val = obj.hndl.top;
        end

        function set.left(obj,val)
            obj.hndl.left = val;
        end

        function val = get.left(obj)
                val = obj.hndl.left;
        end

        function val = get.stride(obj)
            val = obj.hndl.dims.stride;
        end
        
        function val = get.imagesize(obj)
            %val = obj.hndl.dims.imagesize;
        end
    
        % function val = get.cycleMode(obj)
        %     val = obj.hndl.cycleMode;
        % end
        % 
        % function val = get.triggerMode(obj)
        %     val = obj.hndl.triggerMode;
        % end

        function val = getROI(obj)
            val = [obj.left obj.top obj.left+obj.width-1 obj.top+obj.height-1];
        end
   end
    
    methods(Static)
        function setupSDK()

        end
    end




end