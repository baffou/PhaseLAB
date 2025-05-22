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
        %CData double
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
        transformImage
    end

    properties(SetAccess = {?LIVE})
        mode (1,:) char {mustBeMember(mode,{'live','stop','snap','timeLapse','ref','burst','external'})} = 'stop'
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
            % Cam.turn('off')
            arguments
                obj
                val {mustBeMember(val,{'on','off','On','Off'})}
            end

            switch val
                case {'on','On'} % turn on the camera
                    addpath(genpath("C:\Program Files\Andor SDK3\")) % AndorSDK installation folder
                    addpath(genpath(matlabroot+"\toolbox\AndorSDK3\")) % AndorSDK MATLAB toolbox

                    try
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

            if strcmp(cycleMode,'Fixed')
                [rc] = AT_SetInt(obj.hndl,'FrameCount',opt.Nim);
                AT_CheckWarning(rc);
            end

        end

        function startAcquisition(obj,app)
            arguments
                obj
                app
                %mode char {mustBeMember(mode,{'live','burst','snap','timeLapse','ref'})} = 'snap'
            end
            % call the full app to have access to hList, but also to the
            % mode property that can suddenly change in app if the user
            % clicks stop.

            if strcmp(obj.mode,'ref')
                imgType = 'Ref';
            else
                imgType = 'Itf';
            end

            app.lampState('Running')

            %%


            if ~strcmp(obj.mode,'live') && ~strcmp(obj.mode,'timeLapse')% Camera Cyclemode: Fixed

                app.Cam.setMode('Fixed', 'Internal',"expTime",app.expTime,"Nim",app.refAvgEditField.Value)
                [rc] = AT_Command(obj.hndl,'AcquisitionStart');
                AT_CheckWarning(rc);

                if strcmp(obj.mode, 'ref')
                    Nim = app.refAvgEditField.Value;
                elseif  strcmp(obj.mode, 'snap') || strcmp(obj.mode, 'burst')
                    Nim = app.snapAvgEditField.Value;
                end
                rc = AT_SetFloat(obj.hndl, 'ExposureTime', app.expTime);

                AT_SetInt(obj.hndl,'FrameCount',Nim);
                AT_CheckWarning(rc);
                
%                [rc] = AT_Command(obj.hndl,'SoftwareTrigger');
%                AT_CheckWarning(rc);
                buf = zeros([obj.width, obj.height, Nim]);
                for ii = 1:Nim
                    [rc] = AT_QueueBuffer(obj.hndl,obj.imagesize);
                    AT_CheckWarning(rc);
                    [rc,buf0] = AT_WaitBuffer(obj.hndl,10000);
                    AT_CheckWarning(rc);
                    [rc, buf(:,:,ii)] = AT_ConvertMono16ToMatrix(buf0,obj.height,obj.width,obj.stride);
                    AT_CheckWarning(rc);
                end
                dt = datetime('now');

                if strcmpi(obj.mode,'burst')
                    app.([imgType '0']) = buf;
                    
                else % snap or timeLapse => average the Itfs
                    app.([imgType '0']) = mean(buf, 3);   % app.Itf0 or app.Ref0
                end

                app.(imgType).setParams("timeStamp",dt,...
                                  "expTime",app.expTime, ...
                                  "Navg",size(buf,3), ...
                                  "ROI",app.Cam.getROI())
                    
                if ~strcmp(imgType,'Ref') && any( app.status_hfigList )
                    app.computeImages(obj.mode)
                    app.updateImages()
                end


            else % Camera Cyclemode: Continous

                app.Cam.setMode('Continuous', 'Software',"expTime",app.expTime,"Nim",app.refAvgEditField.Value)
                [rc] = AT_Command(obj.hndl,'AcquisitionStart');
                AT_CheckWarning(rc);
                
        
                if all(app.status_hfigList == 0) && strcmpi(obj.mode,'live') % if live mode (and not timeLapse) and nothing to display stop
                    return
                end

        
                % if all(app.status_hfigList == 0)
                %     return
                % end

                disp('Live acquisition in progress...');
                k = 0;
                while(~strcmp(obj.mode,'stop')) % as long as it is not stop, run live

                    tic
                    [rc] = AT_QueueBuffer(obj.hndl,obj.imagesize);
                    AT_CheckWarning(rc);
                    [rc] = AT_Command(obj.hndl,'SoftwareTrigger');
                    AT_CheckWarning(rc);
                    [rc,buf] = AT_WaitBuffer(obj.hndl,10000);
                    AT_CheckWarning(rc);

                    [rc,app.([imgType '0'])] = AT_ConvertMono16ToMatrix(buf,obj.height,obj.width,obj.stride);
                    % LA IL FAUDRAIT MOYENNER LES IMAGES RECUES. EST CE QUE
                    % BUF EST UNE Nx*Ny*Nim matrice ?
                    AT_CheckWarning(rc);

                    app.(imgType).setParams("timeStamp",datetime('now'),...
                                      "expTime",obj.expTime, ...
                                      "Navg",1, ...      % TO BE MODIFIED BY THE NUMBER OF AVERAGED IMAGES
                                      "ROI",app.Cam.getROI())                    

                    drawnow
                    
                    % in case the camera mode changed to
                    % timeLapse, ref or snap during live

                    switch obj.mode
                        case 'timeLapse'
                            if ~exist('appTL','var')
                                appTL = timeLapsePanel(app);
                            elseif ~isvalid(appTL)
                                appTL = timeLapsePanel(app);
                            end
                            
                            if ~isempty(appTL.t0) % if the time t0 has been created by pressing the start button of the appTL panel
                                if k == 0 % first time, first image
                                    nextTime = appTL.t0;
                                    dt = appTL.dt;
                                    % Parameters
                                    dt = seconds(dt);         % Interval between successive images
                                end
                                if isvalid(appTL)
                                    appTL.setNextImageTime(nextTime)
                                end
                                if datetime('now') >= nextTime && k<appTL.N
                                    k = k+1;
                                    nextTime = appTL.t0 + k*dt;
                                    app.saveCurrentImage()
                                    if isvalid(appTL)
                                        appTL.setImageNumber(k)
                                    end
                                elseif k>=appTL.N
                                    k=0;
                                    if isvalid(appTL)
                                        appTL.setImageNumber(k)
                                    end
                                    appTL.setNextImageTime('0')
                                    if all(app.status_hfigList == 0) % if all the windows are closed
                                        app.setAcqMode('stop')
                                    else
                                        app.setAcqMode('live')
                                    end
                                    app.toggleSavePanel(true)
                                    appTL.t0 = [];
                                    appTL.toogleStartButton('start')

                                end
                            end
                        case 'ref'
                            obj.stopAcquisition(app)
                            app.Cam.startAcquisition(app)
                            app.Cam.stopAcquisition(app)
                            app.setAcqMode('live')
                            app.Cam.setMode('Continuous', 'Software',"expTime",app.expTime,"Nim",app.refAvgEditField.Value)
                            [rc] = AT_Command(obj.hndl,'AcquisitionStart');
                            AT_CheckWarning(rc);

                        case 'snap'
                            obj.stopAcquisition(app)
                            app.Cam.startAcquisition(app)
                            app.setAcqMode('stop')
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

            end


        end
        
        function stopAcquisition(obj, app)
            disp('Acquisition complete');
            [rc] = AT_Command(obj.hndl,'AcquisitionStop');
            AT_CheckWarning(rc);
            [rc] = AT_Flush(obj.hndl);
            AT_CheckWarning(rc);

            app.lampState('On')
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
                        dims.left   = 1 + floor((dims.Nx-str2double(numbers{1}))/2);
                        dims.top    = 1 + floor((dims.Ny-str2double(numbers{2}))/2);
                end

            elseif nargin == 5 && isnumeric([varargin{1:end}]) % setImageDimensions(2560,2160)
                        dims.width  = varargin{1};
                        dims.height = varargin{2};
                        dims.top    = varargin{3};
                        dims.left   = varargin{4};
            else
                error('Error in the inputs of setImageDimensions')
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

        % function val = get.cycleMode(obj)
        %     [rc,val] = AT_GetEnumStringByIndex(obj.hndl,'CycleMode',1,30);
        %     AT_CheckWarning(rc);
        % end
        % 
        % function val = get.triggerMode(obj)
        %     [rc,val] = AT_GetEnumStringByIndex(obj.hndl,'TriggerMode',1,30);
        %     AT_CheckWarning(rc);
        % end
        % 
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