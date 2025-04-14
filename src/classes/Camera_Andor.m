classdef Camera_Andor  <  CameraExp & Camera
    % inherits from two calses, the Camera classes and the abstract
    % CameraExp class that contains all the properties and methods for live
    % control of the camera.

    % Each camera type has a specific class, here Andor cameras.
    % See Camera_Hamamatsu
    %     Camera_PCO
    %     Camera_Pixelink
    % for the other camera types

    properties(SetAccess = private)
        hndl  % Camera handle. Contains all the properties of the live camera (number of pixels, exp time, trigger mode, etc...)
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

        function obj = Camera_Andor(cam)
            if cam.brand ~= "Andor"
                warning("this Camera is not supposed to be an Andor camera ")
            end

            propList = properties(cam);

            for ip = 1:numel(propList)
                obj.(propList{ip}) = cam.(propList{ip});
            end

            obj.CData = zeros(cam.Ny,cam.Nx);

            Camera_Andor.setupSDK()

        end

        function rcout = switchCamera(obj,val)
            arguments
                obj
                val {mustBeMember(val,{'on','off','On','Off'})}
            end

            try
                AT_InitialiseLibrary()
            catch
                disp('The Andor library could not be found')
                rcout = -1;
                return
            end

            switch val
                case {'on','On'}
                    [rc] = AT_InitialiseLibrary();
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
                    disp('Camera shutdown');     
            end
        end

        function setExpTime(obj)
            [rc] = AT_SetFloat(obj.hndl,'ExposureTime',obj.expTime);
            AT_CheckWarning(rc);
        end

        function setMode(obj,cycleMode, triggerMode,opt)
            arguments
                obj
                cycleMode   {mustBeMember(cycleMode,   ['Fixed','Continuous'])}
                triggerMode {mustBeMember(triggerMode, ['Internal','External','Software'])}
                opt.Nim = 1 % number of images to be acquiredin Fixed mode
            end


            [rc] = AT_SetFloat(obj.hndl,     'ExposureTime',obj.expTime);
            AT_CheckWarning(rc);
            [rc] = AT_SetEnumString(obj.hndl,'CycleMode',cycleMode);
            AT_CheckWarning(rc);
            [rc] = AT_SetEnumString(obj.hndl,'TriggerMode',triggerMode);
            AT_CheckWarning(rc);
            [rc] = AT_SetEnumString(obj.hndl,'SimplePreAmpGainControl','16-bit (low noise & high well capacity)');
            AT_CheckWarning(rc);
            [rc] = AT_SetEnumString(obj.hndl,'PixelEncoding','Mono16');
            AT_CheckWarning(rc);
            
            obj.setImageDimensions()  


            if strcmp(cycleMode,'Fixed')
                [rc] = AT_SetInt(obj.hndl,'FrameCount',opt.Nim);
                AT_CheckWarning(rc);
            end

        end

        function startAcquisition(obj,him)
            arguments
                obj
                him = []
            end

            [rc] = AT_Command(obj.hndl,'AcquisitionStart');
            AT_CheckWarning(rc);
            if strcmpi(obj.cycleMode,'Fixed')
                obj.CData = zeros(obj.width, obj.height, obj.Nim);
                if strcmpi(obj.triggerMode,'External')
                    disp('Waiting for the TTL comb...')
                elseif  strcmpi(obj.triggerMode,'Internal')
                    tic
                end
                for ii = 1:AT_GetInt(obj.hndl,'FrameCount')

                    [rc] = AT_QueueBuffer(obj.hndl,obj.imagesize);
                    AT_CheckWarning2(rc);
                    
                    try
                        [rc,buf] = AT_WaitBuffer(obj.hndl,10000);
                        AT_CheckWarning2(rc);
    
                        if rc ~= 0 % in case no TTL signal is received and it simply gives rise to rc=13 error.
                            disp('Aborted. No TL signal received')
                            obj.CData(:,:,ii) = 0;
                            break
                        else
                            [rc, obj.CData(:,:,ii)] = AT_ConvertMono16ToMatrix(buf,obj.height,obj.width,obj.stride);
                            AT_CheckWarning2(rc);
                            assignin('base', 'imageSequence', obj.CData);
                            disp([num2str(ii) ' images saved'])
                        end

                    catch  % in case no TTL is received and it gives rise to an error

                            disp('Aborted. No TL signal received')
                            obj.CData(:,:,ii) = 0;
                    end

                end
                if  strcmpi(obj.triggerMode,'Internal')
                    txt = toc;
                    disp(['Aquisition performde in ' num2str(txt*1000) ' ms'])
                end
        
            elseif strcmpi(obj.cycleMode,'Continuous')
    
        
                    %%
                him.CData = zeros(obj.width,obj.height);
    
                %%

                disp('Live acquisition in progress...');

                while(ishandle(him))
                    tic;
                    [rc] = AT_SetFloat(obj.hndl, 'ExposureTime', obj.expTime);
                    AT_CheckWarning2(rc);
                    [rc] = AT_QueueBuffer(obj.hndl,obj.imagesize);
                    AT_CheckWarning2(rc);
                    [rc] = AT_Command(obj.hndl,'SoftwareTrigger');
                    AT_CheckWarning2(rc);
                    [rc,buf] = AT_WaitBuffer(obj.hndl,10000);
                    AT_CheckWarning2(rc);
                
                    [rc,him.CData] = AT_ConvertMono16ToMatrix(buf,obj.height,obj.width,obj.stride);
                    AT_CheckWarning2(rc);
                    drawnow
                end
                %assignin('base', 'liveImage', obj.Itf);

            else
                error('not a proper CycleMode input')
            end

        end
        
        function stopAcquisition(obj)
            disp('Acquisition complete');
            [rc] = AT_Command(obj.hndl,'AcquisitionStop');
            AT_CheckWarning(rc);
            [rc] = AT_Flush(obj.hndl);
            AT_CheckWarning(rc);
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

            rc = AT_SetInt(obj.hndl, 'AOIWidth',  dims.width);
            AT_SetInt(obj.hndl, 'AOIHeight', dims.height);
            AT_SetInt(obj.hndl, 'AOILeft',   dims.left);
            AT_SetInt(obj.hndl, 'AOITop',    dims.top);
            AT_SetInt(obj.hndl, 'AOIVBin',   1);
            AT_SetInt(obj.hndl, 'AOIHBin',   1);
            AT_CheckWarning(rc);
        end

 

        % get/set methods

        function set.expTime(obj,val)
            arguments
                obj
                val (1,1) double {mustBeNumeric,mustBePositive}
            end
            AT_SetFloat(obj.hndl,'ExposureTime',val*1e3);
        end

        function val = get.expTime(obj)
            val = AT_GetFloat(obj.hndl,'ExposureTime');
        end

        function val = get.width(obj)
            [rc,val] = AT_GetInt(obj.hndl, 'AOIWidth');
            AT_CheckWarning(rc);
        end

        function val = get.height(obj)
            [rc,val] = AT_GetInt(obj.hndl, 'AOIHeight');
            AT_CheckWarning(rc);
        end

        function val = get.top(obj)
            [rc,val] = AT_GetInt(obj.hndl, 'AOITop');
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

        function val = get.cycleMode(obj)
            val = AT_GetEnumString(obj.hndl,'CycleMode');
        end
    
        function val = get.triggerMode(obj)
            val = AT_GetEnumString(obj.hndl,'TriggerMode');
        end
    
   end
    
    methods(Static)
        function setupSDK()
            % ge the root directory of Matlab
            matlabRootPath = matlabroot;
        
            % Detection of the OS
            if ispc
                % bBuild the path for Windows
                sdkPath = fullfile(matlabRootPath, 'toolbox', 'AndorSDK3');
            elseif ismac
                % Build the path for Mac
                sdkPath = fullfile(matlabRootPath, 'toolbox', 'AndorSDK3');
            else
                error('unsupported OS');
            end
        
            % add the path
            addpath(genpath(sdkPath));
        end
    end




end