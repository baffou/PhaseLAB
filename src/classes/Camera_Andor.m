classdef Camera_Andor  <  CameraExp & Camera
    % inherits from two calses, the Camera classes and the abstract
    % CameraExp class that contains all the properties and methods for live
    % control of the camera.

    % Each camera type has a specific class, here Andor cameras.
    % See Camera_Hamamatsu
    %     Camera_PCO
    %     Camera_Pixelink
    % for t
    % 
    % 
    % 
    % 
    % he other camera types

    properties(SetAccess = private)
        hndl  % Camera handle. Contains all the properties of the live camera (number of pixels, exp time, trigger mode, etc...)
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

        function obj = Camera_Andor(cam)
            if cam.brand ~= "Andor"
                warning("this Camera is not supposed to be an Andor camera ")
            end

            propList = properties(cam);

            for ip = 1:numel(propList)
                obj.(propList{ip}) = cam.(propList{ip});
            end        
        
        end

        function rcout = turn(obj,val)
            % switch on or off the camera
            % Cam.turn('on')
            % Cam.turnh('off')
            arguments
                obj
                val {mustBeMember(val,{'on','off','On','Off'})}
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
            
            obj.setImageDimensions()  


            if strcmp(cycleMode,'Fixed')
                [rc] = AT_SetInt(obj.hndl,'FrameCount',opt.Nim);
                AT_CheckWarning(rc);
            end

        end

        function startAcquisition(obj,app,imgType,mode)
            arguments
                obj
                app
                imgType (1,3) char {mustBeMember(imgType,{'Ref','Itf'})}
                mode char {mustBeMember(mode,{'live','burst','snap','timeLapse'})} = 'snap'
            end
            % call the full app to have access to hList, but also to the
            % liveOn property that can suddenly change in app if the user
            % clicks stop.

            app.lampState('Running')

            %% Image simulation

                    
                    
            [rc] = AT_Command(obj.hndl,'AcquisitionStart');
            AT_CheckWarning(rc);

            if strcmpi(obj.cycleMode,'Fixed')

                Nim = AT_GetInt(obj.hndl,'FrameCount'); % should already be properly set to NavgRef or NavgSnap before calling this function, in the LIVE app

                if strcmpi(mode,'burst')
                    dt = datetime('now');
                    ItfArray = zeros(IM0.Ny,IM0.Nx,obj.hndl.Nim);
    
                        
                    for ii = 1:AT_GetInt(obj.hndl,'FrameCount')
    
                        [rc] = AT_QueueBuffer(obj.hndl,obj.imagesize);
                        AT_CheckWarning2(rc);
                        
                        try
                            [rc,buf] = AT_WaitBuffer(obj.hndl,10000);
                            AT_CheckWarning2(rc);
        
                            if rc ~= 0 % in case no TTL signal is received and it simply gives rise to rc=13 error.
                                error('Aborted. No TL signal received')
                            else
                                [rc, ItfArray(:,:,ii)] = AT_ConvertMono16ToMatrix(buf,obj.height,obj.width,obj.stride);
                                AT_CheckWarning2(rc);
                            end
    
                        catch  % in case no TTL is received and it gives rise to an error
                                error('Aborted. No TL signal received')
                        end
    
                    end                    
                    
                    
                else % snap or timeLapse => average the Itfs
                    [rc,buf] = AT_WaitBuffer(obj.hndl,10000);
                    AT_CheckWarning2(rc);
                    [rc, bufm] = AT_ConvertMono16ToMatrix(buf,obj.height,obj.width,obj.stride);
                    AT_CheckWarning2(rc);
                    dt = datetime('now');
                    app.([imgType '0']) = mean(bufm, 3);   % app.Itf0 or app.Ref0
                end

                app.(imgType).setParams("timeStamp",dt,...
                                  "expTime",obj.hndl.expTime, ...
                                  "Navg",obj.hndl.Nim, ...
                                  "ROI",app.Cam.getROI())
                    
                if ~strcmp(imgType,'Ref') && any( app.status_hfigList )
                    app.computeImages(mode)
                    app.updateImages()
                end


            elseif strcmpi(obj.cycleMode,'Continuous')
        
                if all(app.status_hfigList == 0) && strcmpi(mode,'live') % if live mode (and not timeLapse) and nothing to display stop
                    return
                end

                if strcmpi(mode,'timeLapse')
                    appTL = timeLapsePanel();
                    if ~isvalid(appTL)
                        return
                    end
                    N = appTL.N;
                    dt = appTL.dt;
                    % Parameters
                    dt = seconds(dt);         % Interval between successive images
                end
    
        
                % if all(app.status_hfigList == 0)
                %     return
                % end

                disp('Live acquisition in progress...');
                k = 0;
                while(app.liveOn)
                    tic
                    [rc] = AT_SetFloat(obj.hndl, 'ExposureTime', obj.expTime);
                    AT_CheckWarning2(rc);
                    [rc] = AT_QueueBuffer(obj.hndl,obj.imagesize);
                    AT_CheckWarning2(rc);
                    [rc] = AT_Command(obj.hndl,'SoftwareTrigger');
                    AT_CheckWarning2(rc);
                    [rc,buf] = AT_WaitBuffer(obj.hndl,10000);
                    AT_CheckWarning2(rc);
                
                    [rc,app.([imgType '0'])] = AT_ConvertMono16ToMatrix(buf,obj.height,obj.width,obj.stride);
                    % LA IL FAUDRAIT MOYENNER LES IMAGES RECUES. EST CE QUE
                    % BUF EST UNE Nx*Ny*Nim matrice ?
                    AT_CheckWarning2(rc);
                    drawnow
                    
                   
                    if strcmpi(mode,'timeLapse')
                        if ~exist('t0','var')
                            t0 = datetime('now');
                            nextTime = t0;
                        end
                        if isvalid(appTL)
                            appTL.setNextImageTime(nextTime)
                        end
                        if datetime('now') >= nextTime && k<N
                            k = k+1;
                            nextTime = t0 + k*dt;
                            app.saveCurrentImage()
                            if isvalid(appTL)
                                appTL.setImageNumber(k)
                            end
                        elseif k>=N
                            if isvalid(appTL)
                                appTL.setImageNumber(k)
                            end
                            appTL.setNextImageTime('0')
                            app.liveOn = 0;
                        end
                    end

                    if any( app.status_hfigList ) 
                        app.computeImages()
                        app.updateImages()
                    else
                        drawnow
                    end
                                        

                    app.HzEditField.Value = round(1/toc,1);
                end
                app.HzEditField.Value = double.empty();

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

        function setExpTime(obj)
            [rc] = AT_SetFloat(obj.hndl,'ExposureTime',obj.expTime);
            AT_CheckWarning(rc);
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

        function val = get.cycleMode(obj)
            val = AT_GetEnumString(obj.hndl,'CycleMode');
        end
    
        function val = get.triggerMode(obj)
            val = AT_GetEnumString(obj.hndl,'TriggerMode');
        end
    
        function val = getROI(obj)
            val = [obj.left obj.top obj.left+obj.width-1 obj.top+obj.height-1];
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