classdef Camera_Andor  <  CameraLive & Camera
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
        imageDimensionsList = { '2560 x 2160','2064 x 2048','1920 x 1080','1392 x 1040','528 x 512','240 x 256','144 x 128', '2560 x 304'};
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

        function obj = Camera_Andor(cam)
            if cam.brand ~= "Andor"
                warning("this Camera is not supposed to be an Andor camera ")
            end

            propList = properties(cam);

            for ip = 1:numel(propList)
                obj.(propList{ip}) = cam.(propList{ip});
            end        

            if cam.model == "Zyla4.2"
                obj.imageDimensionsList = { '2048 x 2048','1920 x 1080','1392 x 1040','528 x 512','240 x 256','144 x 128', '2028 x 304'};
            elseif cam.model == "Zyla5.5"
                obj.imageDimensionsList = { '2560 x 2160','2064 x 2048','1920 x 1080','1392 x 1040','528 x 512','240 x 256','144 x 128', '2560 x 304'};
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
                        AT_FinaliseLibrary()
                        [rc] = AT_InitialiseLibrary();
                    catch
                        warning('Andor SDK not installed, or not properly linked')
                        rcout = -5;
                        return
                    end
                    AT_CheckError(rc);
                    [rc,obj.hndl] = AT_Open(0);
                    AT_CheckError(rc);
                    if nargout
                        rcout = rc;
                    end
                    disp('Camera initialized');
        
                    [rc] = AT_SetBool(obj.hndl, 'SensorCooling', 0);
                    AT_CheckWarning(rc);

                case {'off','Off'}        
                    [rc] = AT_Close(obj.hndl);
                    AT_CheckWarning(rc);
                    [rc] = AT_FinaliseLibrary();
                    AT_CheckWarning(rc);
                    if nargout
                        rcout = rc;
                    end
                    obj.hndl = [];
                    disp('Camera shut down');
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
            
            [rc] = AT_SetFloat(obj.hndl,     'ExposureTime',opt.expTime);
            AT_CheckWarning(rc);
            [rc] = AT_SetEnumString(obj.hndl,'CycleMode',cycleMode);
            AT_CheckWarning(rc);
            [rc] = AT_SetEnumString(obj.hndl,'TriggerMode',triggerMode);
            AT_CheckWarning(rc);
            [rc] = AT_SetEnumString(obj.hndl,'SimplePreAmpGainControl','16-bit (low noise & high well capacity)');
            AT_CheckWarning(rc);
            [rc] = AT_SetEnumString(obj.hndl,'PixelEncoding','Mono16');
            AT_CheckWarning(rc);

            if strcmp(cycleMode,'Fixed')
                [rc] = AT_SetInt(obj.hndl,'FrameCount',opt.Nim);
                AT_CheckWarning(rc);
            end

        end

        function startAcquisition(obj)            
            [rc] = AT_Command(obj.hndl,'AcquisitionStart');
            AT_CheckWarning(rc);
        end
        
        function stopAcquisition(obj)
            [rc] = AT_Command(obj.hndl,'AcquisitionStop');
            AT_CheckWarning(rc);
            
            [rc] = AT_Flush(obj.hndl);
            AT_CheckWarning(rc);
        end

        function buf = acquire_continuous(obj,app)
            [rc] = AT_QueueBuffer(obj.hndl,obj.imagesize);
            AT_CheckWarning(rc);

            [rc] = AT_Command(obj.hndl,'SoftwareTrigger');
            AT_CheckWarning(rc);
            
            [rc,buf] = AT_WaitBuffer(obj.hndl,10000);
            AT_CheckWarning(rc);

            [rc,buf] = AT_ConvertMono16ToMatrix(buf,obj.height,obj.width,obj.stride);
            AT_CheckWarning(rc);
        end

        function buf = acquire_fixed(obj, Nim, app)
            buf = zeros([obj.width, obj.height, Nim]);
            for ii = 1:Nim
                [rc] = AT_QueueBuffer(obj.hndl,obj.imagesize);
                AT_CheckWarning(rc);
                [rc,buf0] = AT_WaitBuffer(obj.hndl,10000);
                AT_CheckWarning(rc);
                [rc, buf(:,:,ii)] = AT_ConvertMono16ToMatrix(buf0,obj.height,obj.width,obj.stride);
                AT_CheckWarning(rc);
            end
        end
        
        function setCameraROI(obj,varargin)
            if nargin == 2 && ischar(varargin{1}) % setCameraROI('2560 x 2160')

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
                        dims.left   = 1 + floor((dims.Nx-str2double(numbers{1}))/2);
                        dims.top    = 1 + floor((dims.Ny-str2double(numbers{2}))/2);
                end

            elseif nargin == 5 && isnumeric([varargin{1:end}]) % setCameraROI(2560,2160)
                        dims.width  = varargin{1};
                        dims.height = varargin{2};
                        dims.top    = varargin{3};
                        dims.left   = varargin{4};
            else
                error('Error in the inputs of setCameraROI')
            end

            rc = AT_SetInt(obj.hndl, 'AOIWidth',  dims.width);
            AT_SetInt(obj.hndl, 'AOIHeight', dims.height);
            AT_SetInt(obj.hndl, 'AOILeft',   dims.left);
            AT_SetInt(obj.hndl, 'AOITop',    dims.top);
            AT_SetInt(obj.hndl, 'AOIVBin',   1);
            AT_SetInt(obj.hndl, 'AOIHBin',   1);
            AT_CheckWarning(rc);
        end

        function setExpTime(obj,val)
            [rc] = AT_SetFloat(obj.hndl,'ExposureTime',val);
            AT_CheckWarning(rc);
        end

        function val = getROI(obj)
            val = [obj.left obj.top obj.left+obj.width-1 obj.top+obj.height-1];
        end


        % get/set methods

        function val = get.expTime(obj)
            val = AT_GetFloat(obj.hndl,'ExposureTime');
        end

        function set.width(obj, val)
            rc= AT_SetInt(obj.hndl, 'AOIWidth', val);
            AT_CheckWarning(rc);
        end

        function val = get.width(obj)
            [rc,val] = AT_GetInt(obj.hndl, 'AOIWidth');
            AT_CheckWarning(rc);
        end

        function set.height(obj, val)
            rc= AT_SetInt(obj.hndl, 'AOIHeight', val);
            AT_CheckWarning(rc);
        end
        
        function val = get.height(obj)
            [rc,val] = AT_GetInt(obj.hndl, 'AOIHeight');
            AT_CheckWarning(rc);
        end

        function set.top(obj, val)
            rc= AT_SetInt(obj.hndl, 'AOITop', val);
            AT_CheckWarning(rc);
        end
        
        function val = get.top(obj)
            [rc,val] = AT_GetInt(obj.hndl, 'AOITop');
            AT_CheckWarning(rc);
        end
        
        function set.left(obj, val)
            rc= AT_SetInt(obj.hndl, 'AOILeft', val);
            AT_CheckWarning(rc);
        end
        
        function val = get.left(obj)
            [rc,val] = AT_GetInt(obj.hndl, 'AOILeft');
            AT_CheckWarning(rc);
        end
        
        function val = get.stride(obj)
            [rc,val] = AT_GetInt(obj.hndl, 'AOIStride');
            AT_CheckWarning(rc);
        end
        
        function val = get.imagesize(obj)
            [rc,val] = AT_GetInt(obj.hndl,'ImageSizeBytes');
            AT_CheckWarning(rc);
        end

   end
    
    methods(Static)
        function setupSDK()
            % ge the root directory of Matlab
        
            addpath(genpath("C:\Program Files\Andor SDK3\")) % AndorSDK installation folder
            addpath(genpath(matlabroot+"\toolbox\AndorSDK3\")) % AndorSDK MATLAB toolbox
            % Detection of the OS
            if ispc
                sdkPath = fullfile(matlabroot, 'toolbox', 'AndorSDK3');
            elseif ismac
                % Build the path for Mac
                sdkPath = fullfile(matlabroot, 'toolbox', 'AndorSDK3');
            else
                error('unsupported OS');
            end
        
            % add the path
            addpath(genpath(sdkPath));
        end
    end
















end