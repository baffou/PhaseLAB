classdef Camera_GenTL  <  CameraLive & Camera
    % inherits from two calses, the Camera classes and the abstract
    % CameraLive class that contains all the properties and methods for live
    % control of the camera.

    % Each camera type has a specific class, here Andor cameras.
    % See Camera_Hamamatsu
    %     Camera_PCO
    %     Camera_Pixelink
    % for the other camera types

    properties(SetAccess = private)
        hndl  % Camera handle. Contains all the properties of the live camera (number of pixels, exp time, trigger mode, etc...)
        imageDimensionsList = { '2448 x 2048','2048 x 2048','1920 x 1080','1392 x 1040','528 x 512','240 x 256','144 x 128', '2448 x 304'};
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

        function obj = Camera_GenTL(cam)

            propList = properties(cam);

            for ip = 1:numel(propList)
                obj.(propList{ip}) = cam.(propList{ip});
            end        

        end

        function rcout = turn(obj,val)
            % switch on or off the camera
            % Cam.turn('on')
            % Cam.turn('off')
            arguments
                obj
                val {mustBeMember(val,{'on','off','On','Off'})}
            end

            switch val
                case {'on','On'} % turn on the camera
                    obj.setupSDK()

                    try
                        obj.hndl = videoinput('gentl',1,'Mono16');
                        rcout = 0;
                    catch
                        error('SDK not properly installed, or camera not plugged')
                        rcout = -5;
                        return
                    end

                    disp('Camera initialized');
        
                case {'off','Off'}        
                    delete(obj.hndl)
                    obj.hndl = [];
                    imaqreset
                    disp('Camera shut down');
                    rcout = 0;
            end
        end

        function setMode(obj,cycleMode, triggerMode,opt)
            arguments
                obj
                cycleMode   {mustBeMember(cycleMode,   {'Fixed','Continuous','Burst'})}
                triggerMode {mustBeMember(triggerMode, {'Internal','External','Software'})} = 'Internal'
                opt.expTime = [] % in [s]
                opt.Nim = 1 % number of images to be acquiredin Fixed mode
            end
            src = getselectedsource(obj.hndl);

            if ~isempty(opt.expTime)
                src.ExposureTime = opt.expTime*1e6;
            end

            if strcmpi(cycleMode,'Fixed')
                triggerconfig(obj.hndl,'manual')
                obj.hndl.FramesPerTrigger = opt.Nim;
            else
                triggerconfig(obj.hndl,'manual')
                obj.hndl.FramesPerTrigger = Inf;
            end


        end

        function startAcquisition(obj)            
            start(obj.hndl)
        end
        
        function stopAcquisition(obj)
            stop(obj.hndl)
        end

        function buf = acquire_continuous(obj,app)
            buf = getsnapshot(obj.hndl);
        end

        function buf = acquire_fixed(obj, Nim, app)
            trigger(obj.hndl)
            buf = squeeze(getdata(obj.hndl, Nim));
        end
        
        function setImageDimensions(obj,varargin)
            if nargin == 2 && ischar(varargin{1}) % setImageDimensions('2560 x 2160')

                switch varargin{1}
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
                        dims.width  = 1392;
                        dims.height = 1040;
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
                    otherwise
                        numbers = regexp(varargin{1}, '[+-]?\d*\.?\d+', 'match');
                        dims.width  = str2double(numbers{1});
                        dims.height = str2double(numbers{2});
                        dims.left   = 1 + floor((dims.height-str2double(numbers{1}))/2);
                        dims.top    = 1 + floor((dims.width-str2double(numbers{2}))/2);
                end

            elseif nargin == 5 && isnumeric([varargin{1:end}]) % setImageDimensions(2560,2160)
                        dims.width  = varargin{1};
                        dims.height = varargin{2};
                        dims.top    = varargin{3};
                        dims.left   = varargin{4};
            else
                error('Error in the inputs of setImageDimensions')
            end

            obj.hndl.ROIposition = [dims.left-1, dims.top-1, dims.width, dims.height];
        end

        function setExpTime(obj,val)
            arguments
                obj
                val  % in [s]
            end
            src = getselectedsource(obj.hndl);
            src.ExposureTime = val*1e6; % converted in us
        end

 

        % get/set methods

        function val = get.expTime(obj)
            src = getselectedsource(obj.hndl);
            val = src.ExposureTime*1e-6;
        end

        function set.width(obj, val)
            obj.hndl.ROIposition = [obj.left, obj.top, val, obj.height];
        end

        function val = get.width(obj)
            vec = obj.hndl.ROIposition;
            val = vec(3);
        end

        function set.height(obj, val)
            obj.hndl.ROIposition = [obj.left, obj.top, obj.width, val];
        end
        
        function val = get.height(obj)
            vec = obj.hndl.ROIposition;
            val = vec(4);
        end

        function set.top(obj, val)
            obj.hndl.ROIposition = [obj.left, val, obj.width, obj.height];
        end
        
        function val = get.top(obj)
            vec = obj.hndl.ROIposition;
            val = vec(2);
        end
        
        function set.left(obj, val)
            obj.hndl.ROIposition = [val, obj.top, obj.width, obj.height];
        end
        
        function val = get.left(obj)
            vec = obj.hndl.ROIposition;
            val = vec(1);
        end
        
        function val = get.stride(obj)
            [rc,val] = AT_GetInt(obj.hndl, 'AOIStride');
            AT_CheckWarning(rc);
        end
        
        function val = get.imagesize(obj)
            [rc,val] = AT_GetInt(obj.hndl,'ImageSizeBytes');
            AT_CheckWarning(rc);
        end

        function val = getROI(obj)
            val = [obj.left obj.top obj.left+obj.width-1 obj.top+obj.height-1];
        end
   end
    
    methods(Static)
        function setupSDK()
            imaqreset
        end
    end
















end