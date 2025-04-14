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
        CData double
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

        function obj = Camera_Simu(cam)

            propList = properties(cam);

            for ip = 1:numel(propList)
                obj.(propList{ip}) = cam.(propList{ip});
            end

            obj.CData = zeros(cam.Ny,cam.Nx);

            Camera_Simu.setupSDK()

            obj.hndl.cycleMode = 'Continuous';
            obj.hndl.triggerMode = 'Software';
            obj.setImageDimensions('1392 x 1040')

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
                cycleMode   {mustBeMember(cycleMode,   ['Fixed','Continuous'])}
                triggerMode {mustBeMember(triggerMode, ['Internal','External','Software'])}
                opt.Nim = 1 % number of images to be acquiredin Fixed mode
            end

            obj.setImageDimensions()  
            obj.hndl.cycleMode = cycleMode;
            obj.hndl.triggerMode = triggerMode;
            obj.hndl.Nim = opt.Nim;

        end

        function startAcquisition(obj,app)
            arguments
                obj
                app
            end

            % call the full app to have access to hList, but also to the
            % liveOn property that can suddenly change in app if the user
            % clicks stop.

            himList = app.himList;

            if strcmpi(obj.cycleMode,'Fixed')
                himList.raw.CData = zeros(obj.width, obj.height, obj.Nim);
                for ii = 1:obj.Nim
                    himList.raw.CData(:,:,ii) = rand(obj.width, obj.height);

                end
            elseif strcmpi(obj.cycleMode,'Continuous')
    
        
                    %%
                himList.raw.CData = zeros(obj.width,obj.height);
    
                %%

                disp('Live acquisition in progress...');
                Itf = Interfero(himList.raw.CData,app.Ref,app.MI);
                while(app.liveOn)
                    try % in case the user closes him meanwhile
                        himList.raw.CData = rand(obj.width,obj.height);
                        Itf.Itf = himList.raw.CData;
                        drawnow
                        if any( app.status_hfigList(2:end) )  % if any other window than raw is open 
                            distributeImage(himList,Itf)
                        end
                    end
                end
                %assignin('base', 'liveImage', obj.Itf);

            else
                error('not a proper CycleMode input')
            end

        end

        function stopAcquisition(obj)
        end

        function setImageDimensions(obj,str)

            switch str
                case '2560 x 2160'
                    dims.width  = 2560;
                    dims.height = 2160;
                    dims.top    = 1;
                    dims.left   = 1;
                case '2064 x 2048'
                    dims.width  = 2064;
                    dims.height = 2048;
                    dims.top    = 57;
                    dims.left   = 265;
                case '1920 x 1080'
                    dims.width  = 1920;
                    dims.height = 1080;
                    dims.top    = 537;
                    dims.left   = 337;
                case '1392 x 1040'
                    dims.width  = 1920;
                    dims.height = 1080;
                    dims.top    = 561;
                    dims.left   = 601;
                case '528 x 512'
                    dims.width  = 528;
                    dims.height = 512;
                    dims.top    = 825;
                    dims.left   = 1033;
                case '240 x 256'
                    dims.width  = 240;
                    dims.height = 256;
                    dims.top    = 953;
                    dims.left   = 1177;
                case '144 x 128'
                    dims.width  = 144;
                    dims.height = 128;
                    dims.top    = 1017;
                    dims.left   = 1225;
                case '2560 x 304'
                    dims.width  = 2560;
                    dims.height = 304;
                    dims.top    = 929;
                    dims.left   = 1;
            end
            obj.hndl.dims = dims;
        end

        function obj = setExpTime(obj,val)
            arguments
                obj
                val (1,1) double {mustBeNumeric,mustBePositive}
            end
            obj.expTime = val;
        end

        % get/set methods

        function val = get.expTime(obj)
            val = obj.expTime;
        end

        function val = get.width(obj)
            val = obj.hndl.dims.width;
        end

        function val = get.height(obj)
            val = obj.hndl.dims.height;
        end

        function val = get.top(obj)
            val = obj.hndl.dims.top;
        end
        
        function val = get.left(obj)
            val = obj.hndl.dims.left;
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
   end
    
    methods(Static)
        function setupSDK()

        end
    end




end