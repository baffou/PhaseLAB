classdef Camera_Simu  <  CameraExp & Camera
    % inherits from two calses, the Camera classes and the abstract
    % CameraExp class that contains all the properties and methods for live
    % control of the camera.

    % Each camera type has a specific class, here Andor cameras.
    % See Camera_Hamamatsu
    %     Camera_PCO
    %     Camera_Pixelink
    % for the other camera types
    
    properties(SetAccess = private)
        hndl
        %CData double
        imageDimensionsList
    end

    properties(Dependent, SetAccess = private)
        expTime %exposure time in seconds
        imagesize
        width
        height
        top
        left
        stride
        transformImage
        cycleMode
        triggerMode
    end

    methods

        function obj = Camera_Simu(cam) % constructor

            propList = properties(cam);

            for ip = 1:numel(propList)
                obj.(propList{ip}) = cam.(propList{ip});
            end

            %obj.CData = zeros(cam.Ny,cam.Nx);

            Camera_Simu.setupSDK()

            obj.hndl.cycleMode = 'Continuous';
            obj.hndl.triggerMode = 'Software';
            obj.hndl.width = cam.Nx;
            obj.hndl.height = cam.Ny;
            obj.hndl.top = 1;
            obj.hndl.left = 1;
            obj.hndl.Nim = 1;
            obj.setImageDimensions(cam.Nx,cam.Ny,1,1)

            obj.imageDimensionsList = {['''' num2str(cam.Nx) ' x ' num2str(cam.Ny) ''''], ...
                ['''' num2str(round(cam.Nx/2)) ' x ' num2str(round(cam.Ny/2)) ''''],...
                ['''' num2str(round(cam.Nx/4)) ' x ' num2str(round(cam.Ny/4)) '''']};

        end

        function rc = switchCamera(obj,val)
            arguments
                obj
                val {mustBeMember(val,{'on','off'})}
            end

            switch val
                case 'on'
                    rc = 0;
                    disp('Camera initialized');
                case 'off'
                    disp('Camera shutdown');            
            end
        end

        function setMode(obj,cycleMode, triggerMode,opt)
            arguments
                obj
                cycleMode   {mustBeMember(cycleMode,   {'Fixed','Continuous'})}
                triggerMode {mustBeMember(triggerMode, {'Internal','External','Software'})}
                opt.expTime = []
                opt.Nim = 1 % number of images to be acquiredin Fixed mode
            end

            obj.hndl.cycleMode = cycleMode;
            obj.hndl.triggerMode = triggerMode;
            obj.hndl.expTime = opt.expTime;
            obj.hndl.Nim = opt.Nim;

        end

        function startAcquisition(obj,app,imgType)
            arguments
                obj
                app
                imgType (1,3) char {mustBeMember(imgType,{'Ref','Itf'})} 
            end
            % call the full app to have access to hList, but also to the
            % liveOn property that can suddenly change in app if the user
            % clicks stop.

            app.lampState('Running')

            %% Image simulation

                    
                    
            if strcmp(imgType,'Itf')

                system = 'NP';
                switch system
                    case 'NP'
                        radius = 500e-9;
                        DI0  =  Dipole('Au',radius);
                        DI = [DI0.moveBy('x',1e-6), DI0.moveBy('x',-1.4e-6,'y',0.7e-6,'z',-0.6e-6), DI0.moveBy('x',3e-6,'y',-3e-6)];
                        DI  =  DI.shine(app.IL);
            
                        IM0 = imaging(DI,app.IL,app.MI,obj.height);
                    case 'noise'
                        IM0(il) = ImageQLSI(ones(Npx),zeros(Npx),MI,IL(il));
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
                        IM0 = ImageEM(ImageQLSI(sqrt(T),OPD,app.MI,app.IL),ImageEM(IMref));
                        
                end            
                    
            else
                radius = 0.001e-9;
                DI0  =  Dipole('Au',radius);
                DI = [DI0.moveBy('x',1e-6), DI0.moveBy('x',-1.4e-6,'y',0.7e-6,'z',-0.6e-6), DI0.moveBy('x',3e-6,'y',-3e-6)];
                DI  =  DI.shine(app.IL);
    
                IM0 = imaging(DI,app.IL,app.MI,obj.height);
            end
                    

            if strcmpi(obj.cycleMode,'Fixed')

                if ~app.burstCheckBox.Value
                    Itf = CGMinSilico(IM0,shotNoise = 1,Nimages = app.refAvgEditField.Value);
                else
                    Itf = CGMinSilico(repmat(IM0,obj.hndl.Nim,1),shotNoise = 1);
                    Itf = mean(Itf);
                end
                dt = datetime('now');

                app.([imgType '0']) = Itf.Itf; % app.Itf0 or app.Ref0
                app.(imgType).setParams("timeStamp",dt,...
                                  "expTime",obj.hndl.expTime, ...
                                  "Navg",obj.hndl.Nim, ...
                                  "ROI",app.Cam.getROI())
                    
                if ~strcmp(imgType,'Ref') && any( app.status_hfigList )
                    distributeImages(app)
                end


            elseif strcmpi(obj.cycleMode,'Continuous')
    
        
                if all(app.status_hfigList == 0)
                    return
                end

                disp('Live acquisition in progress...');

                while(app.liveOn)
                    tic
                    %himList.raw.CData = rand(obj.width,obj.height);
                    Itf = CGMinSilico(IM0,shotNoise = 1,Nimages = app.liveAvgEditField.Value);
                    app.([imgType '0']) = Itf.Itf; % app.Itf0 or app.Ref0
                    app.(imgType).setParams("timeStamp",datetime('now'),...
                                      "expTime",obj.hndl.expTime, ...
                                      "Navg",obj.hndl.Nim, ...
                                      "ROI",app.Cam.getROI())
                    
                    
                    % app.Itf.timeStamp = datetime('now');
                    % app.Itf.ROI = app.Cam.getROI();
                    % app.Itf.expTime = obj.hndl.expTime;
                    % app.Itf.Navg = obj.hndl.Nim;

                    %app.himList.raw.CData =Itf.Itf;
                    if any( app.status_hfigList ) 
                        distributeImages(app)
                    end
                                        

                    app.HzEditField.Value = round(1/toc,1);
                end
                app.HzEditField.Value = double.empty();

                %assignin('base', 'liveImage', obj.Itf);

            else
                error('not a proper CycleMode input')
            end



        end

        function stopAcquisition(obj,app)
            app.lampState('On')
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
                        numbers = sscanf(varargin{1}, '%*[^0-9]%d');
                        obj.width  = numbers(1);
                        obj.height = numbers(2);
                        obj.left   = 1 + floor((obj.Nx-numbers(1))/2);
                        obj.top    = 1 + floor((obj.Ny-numbers(2))/2);
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

        function obj = setExpTime(obj,val)
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
    
        function val = get.cycleMode(obj)
            val = obj.hndl.cycleMode;
        end

        function val = get.triggerMode(obj)
            val = obj.hndl.triggerMode;
        end

        function val = getROI(obj)
            val = [obj.left obj.top obj.left+obj.width-1 obj.top+obj.height-1];
        end
   end
    
    methods(Static)
        function setupSDK()

        end
    end




end