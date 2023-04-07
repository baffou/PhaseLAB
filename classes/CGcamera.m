classdef CGcamera  <  handle & matlab.mixin.Copyable
    properties(NonCopyable)
        Camera   Camera %Camera object
        RL       RelayLens % RelayLens object
        CG       CrossGrating %CrossGrating object
    end
    properties
        fileName char  = 'sC8-944'% fileName of the CGcamera, if any
        CGangle  (1,1) {mustBeNumeric} = 0 % grating angle
        CGpos    (1,1) {mustBeNumeric} % grating position
    end

    properties(Dependent)
        dxSize   % apparent dexel size p'=p*Z, can be different from the actual dexel size p=Camera.dxSize
        zeta
        zoom (1,1) {mustBeNumeric}
    end

    %properties(SetAccess = public,GetAccess = private)
    %    distance0 % tampon, value of distance in case it is achromatic.
    %end

    methods

        function obj = CGcamera(varargin)
            %CGcamera('Zyla')
            %CGcamera('Zyla')
            %CGcamera('sc8-944')
            %CGcamera('Zyla','P4')
            %CGcamera('Zyla','P4',zoom)
            %CGcamera(Camera(),CrossGrating())
            if nargin==0 % CGcamera()
                obj = CGcamera('Zyla');
            end
            if nargin==1 % CGcamera('sc8-830') or %CGcamera('Zyla')
                if istext(varargin{1})
                    fileName = varargin{1};
                    if istext(fileName) % check if it is text, only option.
                        fid = fopen(strcat(fileName,'.txt'));
                        if fid==-1
                            fid = fopen(strcat(fileName,'.json'));
                            if fid==-1
                                error(['The file ' fileName '.json or .txt does not exist'])
                            else
                                camType = class(Camera);
                            end
                        else
                            camType = class(CGcamera);
                        end
                        if strcmpi(camType,'CGcamera')
                            line = fgetl(fid);
                            chromatic = 0;
                            while ~isnumeric(line)
                                colPos = find(line==':');
                                parameter = line(1:colPos-1);
                                if strcmp(parameter,'camera pixel size')
                                    eval(['pxSizeCamera=' line(colPos+1:end) ';'])
                                elseif strcmp(parameter,'Gamma')
                                    eval(['Gamma=' line(colPos+1:end) ';']) % only for Phasics camera images
                                elseif strcmp(parameter,'relaylens zoom')
                                    eval(['RL_Zoom=' line(colPos+1:end) ';'])
                                elseif strcmp(parameter,'Nx')
                                    eval(['Nx=' line(colPos+1:end) ';'])
                                elseif strcmp(parameter,'Ny')
                                    eval(['Ny=' line(colPos+1:end) ';'])
                                elseif strcmp(parameter,'CGdepth')
                                    eval(['CGdepth=' line(colPos+1:end) ';'])
                                elseif strcmp(parameter,'CGangle')
                                    eval(['CGangle=' line(colPos+1:end) ';'])
                                elseif strcmp(parameter,'distance')
                                    eval(['dCG=' line(colPos+1:end) ';']) % if line(colPos+1:end)=='chromatic', dCG = 0
                                end
                                line = fgetl(fid);
                            end

                            cam = Camera(pxSizeCamera,Nx,Ny);
                            CrGr = CrossGrating(Gamma=Gamma,depth=CGdepth);
                            obj = CGcamera(cam,CrGr);
                            obj.fileName = fileName;
                            obj.CGangle = CGangle;
                            if exist('RL_Zoom','var')
                                obj.RL.zoom = RL_Zoom;
                            end
                            if exist('dCG','var')
                                if dCG~=0
                                    obj.CGpos = dCG;
                                else
                                    obj.RL.chromatic = 1;
                                end
                            else
                                obj.CGpos = [];
                            end

                        elseif strcmpi(camType,'Camera') % the input is just a Camera, not a CGcamera
                            obj.Camera = Camera(varargin{1});
                            obj.CG = CrossGrating.empty();
                        else
                            error('not a proper input for a CGcamera')
                        end
                    end
                elseif isa(varargin{1},'Camera')
                    obj.Camera=varargin{1};
                else
                    error('When only one input, must be a text or a camera')
                end
            elseif nargin>=2
                if istext(varargin{1}) %CGcamera('Zyla','P4',zoom)
                    obj.Camera = Camera(varargin{1});
                elseif isa(varargin{1},'Camera') %CGcamera(Cam)
                    obj.Camera = varargin{1};
                else
                    error('Not a proper input to define a camera')
                end
                if istext(varargin{2}) || isnumeric(varargin{2})
                    obj.CG = CrossGrating(varargin{2});
                elseif isa(varargin{2},'CrossGrating')
                    obj.CG = varargin{2};
                else
                    error('Not a proper input to define a CG grating')
                end
                obj.fileName = [];
            end
            if nargin==3
                obj.RL = RelayLens(1); % By default, when a custom CG is used, a relay lens is used as well.
                obj.RL.zoom = varargin{3};
            end

        end

        function val = alpha2(obj,varargin) % old version to calculate alpha, from an alpha value of the CGcamera files
            % alpha()    ->either reads alpha0 or the file .txt
            % alpha(lambda)
            %if ~isempty(obj.alpha0) % the user already defined a custom alpha
            %    val = obj.alpha0;
            %else % the alpha value is supposed to be found in a CGcamera txt file.
            if nargin==2
                lambda = varargin{1};
                if ~isnumeric(lambda)
                    error('lambda must be a number')
                end
                if lambda>1
                    lambda = lambda*1e-9;
                end
            else
                lambda = 550e-9;
            end
            camPath = fileparts(which('CGcamera.m'));
            fid = fopen([camPath '/../CGcameras/' obj.fileName '.txt']);
            if fid==-1
                error(['The file' [camPath '/../CGcameras/' obj.fileName '.txt'] 'does not exist, certainly because the CG+camera association has been done manually, not by calling a CGcamera file. In that case, alpha has to be set by the user using the setalpha function.'])
            end
            line = fgetl(fid);
            while ~isnumeric(line)
                colPos = find(line==':');
                parameter = line(1:colPos-1);
                if strcmp(parameter,'phase factor')
                    if contains(line(colPos+1:end),'chromatic')
                        line = fgetl(fid);
                        ii = 0;
                        while ~strcmp(line,'end')
                            line = strtrim(line);
                            if max(ismember(num2str(0:9),line(1)))
                                ii = ii+1;
                                spacePos1 = find(line==' ',1,'first');
                                spacePos2 = find(line==char(9),1,'first');
                                spacePos = min([spacePos1,spacePos2]);
                                eval(['lambdaList(ii)=' line(1:spacePos-1) ';'])
                                if lambdaList(ii)>1
                                    lambdaList(ii) = lambdaList(ii)*1e-9;
                                end
                                line = strtrim(line(spacePos:end));
                                eval(['factorList(ii)=' line ';'])
                            end
                            line = fgetl(fid);
                        end
                        val = interp1(lambdaList,factorList,lambda,'spline');
                        % rajouter ici une interpolation à partir de la valeur de lambda.
                        % Si elle n'est pas présente, rappeler à l'utilisateur qu'on doit
                        % munir Microscope d'une illumination pour cette caméra.
                    else
                        eval(['val0=' line(colPos+1:end) ';'])
                        val = val0;
                    end
                end
                line = fgetl(fid);
            end
            %end
        end

        function val = alpha(obj,lambda) % this second version of alpha calculates alpha from the distance specified in the CGcamera file
            if nargin==2
                if ~isnumeric(lambda)
                    error('lambda must be a number')
                end
                if lambda>1
                    lambda = lambda*1e-9;
                end
                dist = distance(obj,lambda);
            else
                dist = distance(obj);
            end
            Gamma = obj.CG.Gamma;
            p_p = obj.dxSize;
            val = Gamma*p_p/(4*pi*dist);  % sign "-" because thick object (OPD>0) create a delay (phi<0)
        end

        function val = distance(obj,lambda)
            % distance()    ->either reads distance0 or the file .txt
            % distance(lambda) -> calculate the distance in case a relay lens is used
            if isempty(obj.RL) % if no Relay Lens
                val = obj.CGpos;
            elseif ~obj.RL.chromatic % Relay lens, but considered as achromatic, mostly to deal with numerical simuations, not for real experimental data.
                val = obj.CGpos;% * obj.RL.zoom^2;
            else % distance0 is empty, so the distance value is supposed to be found in a CGcamera txt file.
                %if nargin~=2
                %    error('No CG-camera distance has been specified when creating the object')
                %end
                if ~isnumeric(lambda)
                    error('lambda must be a number')
                end
                if lambda>1
                    lambda = lambda*1e-9;
                end
                camPath = fileparts(which('CGcamera.m'));
                fid = fopen([camPath '/../CGcameras/' obj.fileName '.txt']);
                if fid==-1
                    error(['The file' [camPath '/../CGcameras/' obj.fileName '.txt'] 'does not exist, certainly because the CG+camera association has been done manually, not by calling a CGcamera file. In that case, the distance has to be set manually.'])
                end
                line = fgetl(fid);
                while ~isnumeric(line)
                    colPos = find(line==':');
                    parameter = line(1:colPos-1);
                    if strcmp(parameter,'distance')
                        if contains(line(colPos+1:end),'chromatic')
                            line = fgetl(fid);
                            ii = 0;
                            while  ~strcmp(line,'end')
                                line = strtrim(line);
                                if max(ismember(num2str(0:9),line(1)))
                                    ii = ii+1;
                                    spacePos1 = find(line==' ',1,'first');
                                    spacePos2 = find(line==char(9),1,'first');
                                    spacePos = min([spacePos1,spacePos2]);
                                    eval(['lambdaList(ii)=' line(1:spacePos-1) ';'])
                                    if lambdaList(ii)>1
                                        lambdaList(ii) = lambdaList(ii)*1e-9;
                                    end
                                    line = strtrim(line(spacePos:end));
                                    eval(['factorList(ii)=' line ';'])
                                end
                                line = fgetl(fid);
                            end
                            val = interp1(lambdaList,factorList,lambda,'spline');
                            % rajouter ici une interpolation à partir de la valeur de lambda.
                            % Si elle n'est pas présente, rappeler à l'utilisateur qu'on doit
                            % munir Microscope d'une illumination pour cette caméra.
                        else
                            eval(['val0=' line(colPos+1:end) ';'])
                            val = val0;%*obj.RL.zoom^2; %
                        end
                    end
                    line = fgetl(fid);
                end
            end
        end

        function obj = setDistance(obj,val)
            % to manually set distance, in case the CGcamera object is built
            % from a camera and a CrossGrating object, and not from a
            % CGcamera file.
            if isnumeric(val)
                obj.CGpos = val;
            else
                error('The input must be an number')
            end
        end

        function val = get.zeta(obj)
            val = abs(obj.CG.Gamma/(2*obj.dxSize)); % Gamma/(2*p')
        end

        function val=get.dxSize(obj)
            val=obj.Camera.dxSize/abs(obj.zoom);
        end

        function val = get.zoom(obj)
            if isempty(obj.RL)
                val = 1;
            else
                val = -abs(obj.RL.zoom);
            end
        end

        function obj = removeRL(obj)
            obj.RL = RelayLens.empty(0,0);
        end

    end

end