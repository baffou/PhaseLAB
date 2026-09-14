classdef Camera_pixelinkimaq  <  CameraLive & Camera
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
        imageDimensionsList = { '5472 x 3648', '4096 x 3072', '2448 x 2048','2048 x 2048','1920 x 1080','1392 x 1040','528 x 512','240 x 256','144 x 128', '2448 x 304'};
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

        function obj = Camera_pixelinkimaq(cam) % constructor
            % Copy all the properties of the PhaseLAB Camera object into
            % the daughter Camera_pixelink object

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
                        obj.hndl.vid = videoinput('pixelinkimaq',1,'MONO16_5472x3648');
%                        obj.hndl.vid = videoinput('pixelinkimaq',1,'MONO8_5472x3648');
                        rcout = 0;
                    catch
                        error('SDK not properly installed, or camera not plugged')
                    end
                    
                    triggerconfig(obj.hndl.vid,'immediate')
                    obj.hndl.vid.FramesPerTrigger = 1;
                    obj.hndl.vid.TriggerRepeat = 0;

                    disp('Camera initialized');
        
                case {'off','Off'}        
                    delete(obj.hndl.vid)
                    obj.hndl= [];
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
            isrun = strcmp(obj.hndl.Running,'on');
            stop(obj.hndl)

            src = getselectedsource(obj.hndl.vid);
            if ~isempty(opt.expTime)
                src.Exposure = opt.expTime;
            end

            if strcmpi(cycleMode,'Fixed') % fixed
                triggerconfig(obj.hndl.vid,'immediate');
                obj.hndl.vid.FramesPerTrigger = opt.Nim;
                obj.hndl.vid.TriggerRepeat = 0;
            elseif strcmpi(cycleMode,'Continuous') % continuous
                triggerconfig(obj.hndl.vid,'immediate');
                obj.hndl.vid.FramesPerTrigger = 1;
                obj.hndl.vid.TriggerRepeat = Inf;
            end

            if isrun
                start(obj.hndl)
            end

        end

        function startAcquisition(obj)            
            start(obj.hndl.vid)
        end
        
        function stopAcquisition(obj)
            stop(obj.hndl.vid)
        end

        function buf = acquire_continuous(obj,app)
            try
                buf = getsnapshot(obj.hndl.vid);
                flushdata(obj.hndl.vid);
            catch % in case of insufficient free physical memory due to Matlab memory leak, or camera
                obj.stopAcquisition
                obj.startAcquisition
                buf = getsnapshot(obj.hndl.vid);
                flushdata(obj.hndl.vid);
            end
                %buf = getdata(obj.hndl.vid);
            %preview(vid,him)
        end

        function buf = acquire_fixed(obj, Nim, app)
            wait(obj.hndl.vid)
%            wait(obj.hndl.vid,10)
            buf = squeeze(getdata(obj.hndl.vid, Nim));
        end
        
        function setImageDimensions(obj,varargin)
            isrun = strcmp(obj.hndl.Running,'on');
            stop(obj.hndl)
            if nargin == 2 && ischar(varargin{1}) % setImageDimensions('2560 x 2160')
                Nx = 5472;
                Ny = 3648;
                numbers = regexp(varargin{1}, '[+-]?\d*\.?\d+', 'match');
                dims.width  = str2double(numbers{1});
                dims.height = str2double(numbers{2});
                dims.top   = floor((Nx-str2double(numbers{1}))/2);
                dims.left    = floor((Ny-str2double(numbers{2}))/2);

            elseif nargin == 5 && isnumeric([varargin{1:end}]) % setImageDimensions(2560,2160,1,1)
                        dims.width  = varargin{1};
                        dims.height = varargin{2};
                        dims.top    = varargin{3}-1;
                        dims.left   = varargin{4}-1;
            else
                error('Error in the inputs of setImageDimensions')
            end

            obj.hndl.vid.ROIPosition = [dims.left, dims.top, dims.width, dims.height];

            if isrun
                start(obj.hndl)
            end
        end

        function setExpTime(obj,val)
            arguments
                obj
                val  % in [s]
            end
            src = getselectedsource(obj.hndl.vid);
            src.Exposure = val; % converted in us
        end

 

        % get/set methods

        function val = get.expTime(obj)
            src = getselectedsource(obj.hndl.vid);
            val = src.Exposure*1e-6;
        end

        function set.width(obj, val)
            obj.hndl.vid.ROIposition = [obj.left, obj.top, val, obj.height];
        end

        function val = get.width(obj)
            vec = obj.hndl.vid.ROIposition;
            val = vec(3);
        end

        function set.height(obj, val)
            obj.hndl.vid.ROIposition = [obj.left, obj.top, obj.width, val];
        end
        
        function val = get.height(obj)
            vec = obj.hndl.vid.ROIposition;
            val = vec(4);
        end

        function set.top(obj, val)
            obj.hndl.vid.ROIposition = [obj.left, val, obj.width, obj.height];
        end
        
        function val = get.top(obj)
            vec = obj.hndl.vid.ROIposition;
            val = vec(2);
        end
        
        function set.left(obj, val)
            obj.hndl.vid.ROIposition = [val, obj.top, obj.width, obj.height];
        end
        
        function val = get.left(obj)
            vec = obj.hndl.vid.ROIposition;
            val = vec(1);
        end
        
        function val = get.stride(obj)
            val = [];
        end
        
        function val = get.imagesize(obj)
            %[rc,val] = AT_GetInt(obj.hndl.vid,'ImageSizeBytes');
            %AT_CheckWarning(rc);
            val = [];
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