classdef Camera_Thorlabs  <  CameraLive & Camera
    % inherits from two calses, the Camera class and the abstract
    % CameraLive class that contains all the properties and methods for live
    % control of the camera.


    properties(SetAccess = private)
        hndl  % Camera handle. Contains all the properties of the live camera (number of pixels, exp time, trigger mode, etc...)
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
    end

    properties(Hidden) % specific to PolarKiralux
        serialnumber
        tlCameraSDK
    end

    
    methods

        function obj = Camera_Thorlabs(cam)
            if cam.brand ~= "Thorlabs"
                warning("this Camera is not supposed to be a Thorlabs camera ")
            end

            propList = properties(cam);

            for ip = 1:numel(propList)
                obj.(propList{ip}) = cam.(propList{ip});
            end       

            if cam.model == "PolarKiralux"
                obj.imageDimensionsList = {'2448 x 2048','2048 x 2048','1536 x 1536','1024 x 1024','512 x 512'};
            end

            % setup the SDK
            Camera_Thorlabs.setupSDK();

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
                    obj.tlCameraSDK = Thorlabs.TSI.TLCamera.TLCameraSDK.OpenTLCameraSDK;
                    serialNumbers = obj.tlCameraSDK.DiscoverAvailableCameras; % Get serial numbers of connected TLCamera.
                    disp([num2str(serialNumbers.Count), ' camera was discovered.']);

                    if (serialNumbers.Count == 0)
                        delete(serialNumbers);    % Release the serial numbers
                        obj.tlCameraSDK.Dispose;    % Release the TLCameraSDK.
                        delete(obj.tlCameraSDK);
                        rcout = -1;
                        return
                    end
                    obj.serialnumber = serialNumbers.Item(0);
                    % Setting the camera properties
                    obj.hndl = obj.tlCameraSDK.OpenCamera(obj.serialnumber, false);% Open the first camera using the serial number.
                    rcout = 0;

                case {'off','Off'}        
                    disp('Stopping software triggered image acquisition.');
                    obj.hndl.Disarm;
                    
                    % Release the camera
                    disp('Releasing the camera');
                    obj.hndl.Dispose;
                    delete(obj.hndl);
                    
                    % Release the serial numbers
                    delete(obj.serialnumber);
                    
                    % Release the TLCameraSDK.
                    obj.tlCameraSDK.Dispose;
                    delete(obj.tlCameraSDK);
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
            
            obj.hndl.Gain = 0; % Set the Gain
            obj.hndl.MaximumNumberOfFramesToQueue = 10; % Set the FIFO frame buffer size. Default size is 1.
            switch triggerMode
                case {'Software','Internal'}
                    obj.hndl.OperationMode = Thorlabs.TSI.TLCameraInterfaces.OperationMode.HardwareTriggered;
                case 'External'
                    obj.hndl.OperationMode = Thorlabs.TSI.TLCameraInterfaces.OperationMode.SoftwareTriggered;
            end
            
            obj.hndl.FramesPerTrigger_zeroForUnlimited = 0;% Set the number of frames per software trigger
            
            switch cycleMode
                case {'Fixed','Burst'}
                    obj.hndl.FramesPerTrigger_zeroForUnlimited = opt.Nim;% Set the number of frames per software trigger
                case {'Continuous'}
                    obj.hndl.FramesPerTrigger_zeroForUnlimited = 0;% Set the number of frames per software trigger                    
            end
            
            if ~isempty(opt.expTime)
                setExpTime(obj,opt.expTime)
            end        
        end

        function startAcquisition(obj)
            obj.hndl.Arm; % start trigger
        end
        
        function stopAcquisition(obj)
            obj.hndl.Disarm;
        end

        function buf = acquire_continuous(obj,app)

            obj.hndl.IssueSoftwareTrigger; % Each call to Start sends a software trigger.
            while (obj.hndl.NumberOfQueuedFrames == 0)
                % Wait for image buffer to be filled to prevent sending too many software triggers.
                pause(0.01);
            end
        
            % If data processing in Matlab falls behind camera image
            % acquisition, the FIFO image frame buffer could be filled up,
            % which would result in missed frames.
            if (obj.hndl.NumberOfQueuedFrames > 1)
                %disp(['Data processing falling behind acquisition. ' num2str(obj.hndl.NumberOfQueuedFrames) ' remains']);
            end
        
            % Get the pending image frame.
            imageFrame = obj.hndl.GetPendingFrameOrNull;
            if ~isempty(imageFrame)
        
                imageData = imageFrame.ImageData.ImageData_monoOrBGR;        
                Ny = imageFrame.ImageData.Height_pixels;
                Nx = imageFrame.ImageData.Width_pixels;
        
                buf = reshape(imageData.uint16(), [Nx, Ny])';

            end
        
            % Release the image frame
            delete(imageFrame);
        end

        function buf = acquire_fixed(obj, Nim, app)
            buf = zeros([obj.width, obj.height, Nim]);

            for ii = 1:Nim
                obj.hndl.IssueSoftwareTrigger; % Each call to Start sends a software trigger.
                while (obj.hndl.NumberOfQueuedFrames == 0)
                    % Wait for image buffer to be filled to prevent sending too many software triggers.
                    pause(0.01);
                end
            
                % If data processing in Matlab falls behind camera image
                % acquisition, the FIFO image frame buffer could be filled up,
                % which would result in missed frames.
                if (obj.hndl.NumberOfQueuedFrames > 1)
                    %disp(['Data processing falling behind acquisition. ' num2str(obj.hndl.NumberOfQueuedFrames) ' remains']);
                end
            
                % Get the pending image frame.
                imageFrame = obj.hndl.GetPendingFrameOrNull;
                if ~isempty(imageFrame)
            
                    imageData = imageFrame.ImageData.ImageData_monoOrBGR;
            
                    %disp(['Image frame number: ' num2str(imageFrame.FrameNumber)]);
            
                    % TODO: custom image processing code goes here
                    Ny = imageFrame.ImageData.Height_pixels;
                    Nx = imageFrame.ImageData.Width_pixels;
            
                    buf(:,:,ii) = reshape(imageData.uint16(), [Nx, Ny])';
                end
            
                % Release the image frame
                delete(imageFrame);
            end



        end
        
        function setCameraROI(obj,varargin)
            if nargin == 2 && ischar(varargin{1}) % setCameraROI('2560 x 2160')

                numbers = regexp(varargin{1}, '[+-]?\d*\.?\d+', 'match');
                dims.width  = str2double(numbers{1});
                dims.height = str2double(numbers{2});
                dims.left   = 1 + floor((2048-str2double(numbers{1}))/2);
                dims.top    = 1 + floor((2448-str2double(numbers{2}))/2);

            elseif nargin == 5 && isnumeric([varargin{1:end}]) % setCameraROI(2560,2160,1,1)
                        dims.width  = varargin{1};
                        dims.height = varargin{2};
                        dims.top    = varargin{3};
                        dims.left   = varargin{4};
            else
                error('Error in the inputs of setCameraROI')
            end
            
            % Camera must be disarmed
            obj.stopAcquisition();
            
            % Set ROI
            roi = obj.hndl.ROIAndBin;
            roi.ROIOriginX_pixels = dims.left;
            roi.ROIOriginY_pixels = dims.top;
            roi.ROIWidth_pixels = dims.width;
            roi.ROIHeight_pixels = dims.height;
            
            obj.hndl.ROIAndBin = roi;
                     
        end

        function setExpTime(obj,val)
             obj.hndl.ExposureTime_us = val*1e3;% Set exposure time and gain of the camera in us.

        end

        function val = getROI(obj)
            val = [obj.left obj.top obj.left+obj.width-1 obj.top+obj.height-1];
        end


        % get/set methods

        function val = get.expTime(obj)
            val = AT_GetFloat(obj.hndl,'ExposureTime');
        end

        function set.width(obj, val)
            obj.hndl.ROIAndBin.ROIWidth_pixels = val;
        end

        function val = get.width(obj)
            val = obj.hndl.ROIAndBin.ROIWidth_pixels;
        end

        function set.height(obj, val)
            obj.hndl.ROIAndBin.ROIHeight_pixels = val;
        end
        
        function val = get.height(obj)
            val = obj.hndl.ROIAndBin.ROIHeight_pixels;
        end

        function set.top(obj, val)
            obj.hndl.ROIAndBin.ROIOriginX_pixels = val;
        end
        
        function val = get.top(obj)
            val = obj.hndl.ROIAndBin.ROIOriginX_pixels;
        end
        
        function set.left(obj, val)
            obj.hndl.ROIAndBin.ROIOriginY_pixels = val;
        end
        
        function val = get.left(obj)
            val = obj.hndl.ROIAndBin.ROIOriginY_pixels;
        end
        
        function val = get.stride(obj)
            val = [];
        end
        
        function val = get.imagesize(obj)
            val = obj.bitDepth*obj.height*obj.width;
        end

   end
    
    methods(Static)
        function setupSDK()
        
            scriptPath = fileparts(mfilename('fullpath')); % Folder where the current .m file is
            dllPath = fullfile(scriptPath, '..\SDK\ThorCam');     % Folder containing the dll files
            setenv('PATH', [dllPath pathsep getenv('PATH')]); % Add the DLL files to the PATH
            
            NET.addAssembly(fullfile(dllPath, 'Thorlabs.TSI.TLCamera.dll')); % Load the assemblies
            disp('Dot NET assembly loaded.');
            

        end
    end
















end