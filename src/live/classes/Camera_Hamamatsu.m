classdef Camera_Hamamatsu  <  CameraExp & Camera
    % inherits from two calses, the Camera classes and the abstract
    % CameraExp class that contains all the properties and methods for live
    % control of the camera.

    % Each camera type has a specific class, here Hamamatsu cameras.
    % See Camera_nador
    %     Camera_PCO
    %     Camera_Pixelink
    % for the other camera types

    properties(SetAccess = private)
        hndl  % Camera handle. Contains all the properties of the live camera (number of pixels, exp time, trigger mode, etc...)
        imageDimensionsList = { '2048 x 2048','1728 x 1728','1440x 1440','1024 x 1024','768 x 768','512 x 512','256 x 256','144 x 144'};
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

        function obj = Camera_Hamamatsu(cam)
            if cam.brand ~= "Hamamatsu"
                warning("this Camera is not supposed to be a Hamamatsu camera ")
            end

            propList = properties(cam);

            for ip = 1:numel(propList)
                obj.(propList{ip}) = cam.(propList{ip});
            end        


            if cam.model == "OrcaFlash"
                obj.imageDimensionsList = { '2048 x 2048','1728 x 1728','1440x 1440','1024 x 1024','768 x 768','512 x 512','256 x 256','144 x 144'};
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

                        obj.hndl = struct();
                        obj.hndl.Video = videoinput('hamamatsu', 1, "MONO16_2048x2048_Std"); % initializes the hamamatsu camera
                        obj.hndl.Source = getselectedsource(obj.hndl.Video);
                        if isfield(propinfo(obj.hndl.Source),'CameraName')
                            disp(['Camera connected : ' obj.hndl.Source.CameraName]);
                        else 
                            disp(['Camera connected : anonymous one, using linker : ' obj.linker]);
                        end
    
%                        obj.hndl.Source.ExposureTime = obj.defaultAcquisitionTime_seconds;
%                        obj.hndl.Video.FramesPerTrigger = 1;
                         triggerconfig(obj.hndl.Video,'manual');
    
%                        FOV = obj.hndl.Video.ROIPosition;
%                        obj.Resolution_Height = FOV(3);
%                        obj.Resolution_Width = FOV(4);
%                        obj.Offset_Height = FOV(1);
%                        obj.Offset_Width = FOV(2);
    
%                        obj.setMode_continuous(1);  % necessary ?
                  
                    catch
                        warning('Hamamatsu SDK not installed, or not properly linked')
                        rcout = -5;
                        return
                    end

                    disp('Camera initialized');

                case {'off','Off'}        
                    stop(obj.hndl.Video)
                    delete(obj.hndl.Video)
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
           
            obj.expTime = opt.expTime;

            if strcmp(cycleMode,'Continuous')
                triggerconfig(obj.hndl.Video, 'manual');
            elseif strcmp(cycleMode,'Fixed')
                triggerconfig(obj.hndl.Video, 'immediate'); % waits for trigger(vid) command to collect frame
                obj.hndl.Source.TriggerSource = 'internal';
            end

        end

        function startAcquisition(obj)            
            %start(obj.hndl.Video);
        end
        
        function stopAcquisition(obj)
            %stop(obj.hndl.Video);
            flushdata(obj.hndl.Video);
        end

        function buf = acquire_continuous(obj,app)
            
            buf = double(getsnapshot(obj.hndl.Video));

        end

        function buf = acquire_fixed(obj, Nim, app)
            start(obj.hndl.Video)

            while obj.hndl.Video.FramesAvailable < Nim
                pause(0.01)
            end
            data = (getdata(obj.hndl.Video, obj.hndl.Video.FramesAvailable));
            stop(obj.hndl.Video)
            obj.isAcquisitionStarted = false;
            buf = squeeze(data);
            buf = mean(buf,3);
        end
        
        function setImageDimensions(obj,varargin)
            if nargin == 2 && ischar(varargin{1}) % setImageDimensions('2560 x 2160')

                numbers = regexp(varargin{1}, '[+-]?\d*\.?\d+', 'match');
                dims.width  = str2double(numbers{1});
                dims.height = str2double(numbers{2});
                dims.left   = 1 + floor((dims.Nx-str2double(numbers{1}))/2);
                dims.top    = 1 + floor((dims.Ny-str2double(numbers{2}))/2);

            elseif nargin == 5 && isnumeric([varargin{1:end}]) % setImageDimensions(2560,2160)
                dims.width  = varargin{1};
                dims.height = varargin{2};
                dims.top    = varargin{3};
                dims.left   = varargin{4};
            else
                error('Error in the inputs of setImageDimensions')
            end

                    % Formalisme is not the same :
                    imaqHandW = [dims.width dims.height];

                    ROIInfos = propinfo(obj.hndl.Video,'ROI');
                    ROIMax = ROIInfos.DefaultValue(3:4);
                    if isempty(wOffset) || isempty(hOffset)
                        offSetHAndW = floor((ROIMax - imaqHandW)/2);
                    else
                        offSetHAndW = round([hOffset wOffset]);
                    end
                    obj.hndl.Video.ROI = [offSetHAndW imaqHandW];
                    

        end

        function setExpTime(obj,val)
            expInfos = propinfo(obj.hndl.Source,'ExposureTime');
           
            expLims = expInfos.ConstraintValue;
            if val > expLims(1) && val < expLims(2)
                obj.hndl.Source.ExposureTime = val;
            else
                warning('ExposureTime is out of bound - thus not modified')
            end

        end

 

        % get/set methods

        function val = get.expTime(obj)
            val = obj.hndl.Source.ExposureTime;

        end

        function set.width(obj, val)
            obj.hdl.Video.ROI(4) = val;
        end

        function val = get.width(obj)
            FOV = obj.hndl.Video.ROIPosition;
            val = FOV(4);
        end

        function set.height(obj, val)
            obj.hdl.Video.ROI(3) = val;
        end
        
        function val = get.height(obj)
            FOV = obj.hndl.Video.ROIPosition;
            val = FOV(3);
        end

        function set.top(obj, val)
            obj.hdl.Video.ROI(1) = val;
        end
        
        function val = get.top(obj)
            FOV = obj.hndl.Video.ROIPosition;
            val = FOV(1);
        end
        
        function set.left(obj, val)
            obj.hdl.Video.ROI(2) = val;
        end
        
        function val = get.left(obj)
            FOV = obj.hndl.Video.ROIPosition;
            val = FOV(2);
        end
        
        function val = get.stride(obj)

        end
        
        function val = get.imagesize(obj)
        end

        function val = getROI(obj)
            val = [obj.left obj.top obj.left+obj.width-1 obj.top+obj.height-1];
        end
   end
    
    methods(Static)
        function setupSDK()

            imaqhwinfo hamamatsu;
            imaqregister(ans.AdaptorDllName);
            imaqreset % resets the image acquisition environment

        end
    end


end