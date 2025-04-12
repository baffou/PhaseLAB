classdef Camera_Andor  <  Camera
    
    properties
        expTime %exposure time in seconds
    end
    properties(SetAccess = private)
        hndl
        CData
    end

    properties(Dependent, Access = private)
        imagesize
        width
        height
        top
        left
        stride
        transformImage
    end


    methods

        function obj = Camera_Andor(cam)
            if obj.brand ~= "Andor"
                warning("this Camera is not supposed to be an Andor camera ")
            end

            propList = properties(cam);
            for ii = 1:numel(propList)
                obj.(propList{ii}) = cam.(propList{ii});
            end

            obj.CData = zeros(Ny,Nx);

            Camera_Andor.setupSDK()

        end

        function startCamera(obj)
            [rc] = AT_InitialiseLibrary();
            AT_CheckError(rc);
            [rc,obj.hndl] = AT_Open(0);
            AT_CheckError(rc);
            disp('Camera initialized');

            [rc] = AT_SetBool(obj.hndl, 'SensorCooling', 0);
            AT_CheckWarning(rc);
        end

        function stopCamera(obj)
            [rc] = AT_Close(obj.hndl);
            AT_CheckWarning(rc);
            [rc] = AT_FinaliseLibrary();
            AT_CheckWarning(rc);
            disp('Camera shutdown');            
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
            cycleMode = AT_GetEnumString(obj.hndl,'CycleMode');
            if strcmpi(cycleMode,'Fixed')
                obj.CData = zeros(obj.width, obj.height, obj.Nim);
                triggerMode = AT_GetEnumString(obj.hndl,'TriggerMode');
                if strcmpi(triggerMode,'External')
                    disp('Waiting for the TTL comb...')
                elseif  strcmpi(triggerMode,'Internal')
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
                if  strcmpi(triggerMode,'Internal')
                    txt = toc;
                    disp(['Aquisition performde in ' num2str(txt*1000) ' ms'])
                end
        
            elseif strcmpi(cycleMode,'Continuous')
    
        
                    %%
                him.CData = zeros(obj.width,obj.height);
    
                %%

                obj.message('Live acquisition in progress...');

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
            AT_CheckWarning2(rc);
        end

 

        % get/set methods

        function set.expTime(obj,val)
            arguments
                obj
                val (1,1) double {mustBeNumeric,mustBePositive}
            end
            obj.expTime = val;
        end

        function val = get.width(app)
            [rc,val] = AT_GetInt(app.hndl, 'AOIWidth');
            AT_CheckWarning2(rc,app.TextArea);
        end

        function val = get.height(app)
            [rc,val] = AT_GetInt(app.hndl, 'AOIHeight');
            AT_CheckWarning2(rc,app.TextArea);
        end

        function val = get.top(app)
            [rc,val] = AT_GetInt(app.hndl, 'AOITop');
            AT_CheckWarning2(rc,app.TextArea);
        end
        
        function val = get.left(app)
            [rc,val] = AT_GetInt(app.hndl, 'AOILeft');
            AT_CheckWarning2(rc,app.TextArea);
        end
        
        function val = get.stride(app)
            [rc,val] = AT_GetInt(app.hndl, 'AOIStride');
            AT_CheckWarning2(rc,app.TextArea);
        end
        
        function val = get.imagesize(app)
            [rc,val] = AT_GetInt(app.hndl,'ImageSizeBytes');
            AT_CheckWarning2(rc,app.TextArea);
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