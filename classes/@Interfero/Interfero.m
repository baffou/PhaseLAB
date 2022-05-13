%% Handle class of the PhaseLAB package
% Represents QLSI interferogram objects
%
% Guillaume Baffou
% CNRS, Institut Fresnel
% May 24, 2020

classdef Interfero < handle & matlab.mixin.Copyable
    
    properties(SetAccess = private)
        Itf0     % interferogram (matrix or path)
        Ref      Interfero % interfero object corresponding to the reference image
        TF       % Fourier transform of the interfero
    end
    
    properties (Dependent)
        Itf     (:,:) double
    end
    
    properties(SetAccess = private)
        fileName char % Interferogram name on the computer
        path char
        Nx {mustBeInteger,mustBePositive}% Number of pixel of the image in the horizontal direction
        Ny {mustBeInteger,mustBePositive}% Number of pixel of the image in the vertical direction
    end
    
    properties(Dependent)
        software char % software used to acquire the interferogram image
        CGcam CGcamera % CGcamera object with which the images were acquired
        pxSize double% pixel size at the sample plane
    end
    
    properties(Hidden)
        Fimc   (3,1) cell % 3-cell containing the 3 demodulated images
        Microscope Microscope
        Fcrops  (3,1) FcropParameters
        crops
        remote {mustBeInteger,mustBeLessThanOrEqual(remote,1),mustBeGreaterThanOrEqual(remote,0)}  % 1 if images are not stored (only path/fileName), 0 if images are stored
    end
        
    methods
        function obj = Interfero(fileName,MI,opt)
            arguments
                fileName = []
                MI = []
                opt.remote (1,1) {mustBeInteger,mustBeGreaterThanOrEqual(opt.remote,0),mustBeLessThanOrEqual(opt.remote,1)} = 0
                opt.N (1,1) {mustBeInteger} = 0
            end
            
            obj.remote = opt.remote;

            if opt.N~=0 % Interfero(3) : create 3 blanck interferos
                if nargin==1
                    obj = repmat(Interfero(),opt.N,1);
                    return
                else
                    error('When specifying a number of blank interfero, N must be the only parameter')
                end
            end


            
            %% Interfero(fileName,MI). fileName: char that is the txt of tif file name of the interferogram to be read and imported. MI:       Microscope object. Represents the microscope used to acquire the image
            if nargin>=2
                obj.Microscope = MI;
                if isnumeric(fileName)  % directly enter a matrix
                    if obj.remote==1
                        error('Does not make sense to use the remote option if not specifying a file location but a matrix.')
                    end
                    [obj.Ny,obj.Nx] = size(fileName);
                    if strcmp(MI.software,'PHAST') || strcmp(MI.software,'Sid4Bio')
                        obj.Itf0 = double(fileName)-2^15-100;% Removes the offset of Phasics, and removes the offset of the camera
                        %obj.Itf0 = double(fileName)-2^15;% Removes the offset of Phasics, and removes the offset of the camera

                    else

                        obj.Itf0 = double(fileName);
                    end
                elseif ~isa(fileName,'char')
                    error('The first input, the file name of the interferogram, must be a string')
                else
                    if ~strcmp(fileName(end-2:end),'tif') && ~strcmp(fileName(end-2:end),'txt')
                        warning('Be carful. Interferogram image considered as a tif image')
                        fileName = [fileName '.tif'];
                    end
                    
                    slashpos = find(fileName=='/');
                    if isempty(slashpos) % specified file name
                        obj.fileName = fileName;
                        obj.path = [pwd '/'];
                    else                 % specified path + file name, and in this case, has to remove the path
                        obj.fileName = fileName(max(slashpos)+1:end);
                        obj.path = fileName(1:max(slashpos));
                    end

                    if obj.remote==0
                        if strcmp(fileName(end-2:end),'txt')
                            Itf0 = dlmread(fileName);
                        elseif strcmp(fileName(end-2:end),'tif') || strcmp(fileName(end-3:end),'tiff')
                            Itf0 = double(imread(fileName));
                        else
                            error('An interferogram image must be a txt of tif file')
                        end
                        [obj.Ny,obj.Nx] = size(Itf0);
                        if strcmp(MI.software,'PHAST') || strcmp(MI.software,'Sid4Bio')
                            obj.Itf0 = Itf0-2^15-100;% Removes the offset of Phasics, and removes the offset of the camera

                        else
                            obj.Itf0 = Itf0;
                        end
                    elseif obj.remote==1
                        obj.Itf0 = 'remote';
                    end
                end
            end

            obj.TF = [];
            obj.Fcrops = [FcropParameters(); FcropParameters(); FcropParameters()];

        end

        function val = get.Nx(obj)
            if isnumeric(obj.Itf0)
                val = size(obj.Itf0,2);
            elseif isempty(obj.Nx)
                obj.Itf; % go read the interferogram, that will automatically update Nx
                val = obj.Nx;
            else
                val = obj.Nx;
            end
        end
        
        function val = get.Ny(obj)
            if isnumeric(obj.Itf0)
                val = size(obj.Itf0,1);
            elseif isempty(obj.Ny)
                obj.Itf; % go read the interferogram, that will automatically update Nx
                val = obj.Ny;
            else
                val = obj.Ny;
            end
        end
              
        function val = get.Itf(obj)
            if ischar(obj.Itf0)
                if strcmp(obj.fileName(end-2:end),'txt')
                    val = dlmread([obj.path obj.fileName]);
                    [obj.Ny,obj.Nx] = size(val);
                    
                elseif strcmp(obj.fileName(end-2:end),'tif') || strcmp(obj.fileName(end-3:end),'tiff')
                    val = double(imread([obj.path obj.fileName]));
                    [obj.Ny,obj.Nx] = size(val);
                end
                if strcmp(obj.software,'PHAST') || strcmp(obj.software,'Sid4Bio')
                    val = val-2^15-100;% Removes the offset of Phasics, and removes the offset of the camera
                end
            elseif isnumeric(obj.Itf0)
                val = obj.Itf0;
            end
        end
 
        function val = get.software(obj)
            val = obj.Microscope.software;
        end
        
        function val = get.CGcam(obj)
            val = obj.Microscope.CGcam;
        end
        
        function val = get.pxSize(obj)
            val = obj.Microscope.pxSizeItf();
        end
        
        function deleteFcrops(obj)
            obj.Fcrops = [FcropParameters(); FcropParameters(); FcropParameters()];
            obj.Ref.Fcrops = [FcropParameters(); FcropParameters(); FcropParameters()];
        end

        function objListout = crop(objList,xy1,xy2)
            objListout = copy(objList);
            No = numel(objList);
            for io = 1:No
                obj = objListout(io);
                if nargin==3
                    if numel(xy1)~=2
                        error('First input must be a 2-vector (x,y)')
                    end
                    if numel(xy2)~=2
                        error('Second input must be a 2-vector (x,y)')
                    end
                    x1 = min([xy1(1),xy2(1)]);
                    x2 = max([xy1(1),xy2(1)]);
                    y1 = min([xy1(2),xy2(2)]);
                    y2 = max([xy1(2),xy2(2)]);
                elseif nargin==2 %crop(Npx)
                    N = xy1;
                    x1 = (obj.Nx-N)/2+1;
                    x2 = (obj.Nx-N)/2+N;
                    y1 = (obj.Ny-N)/2+1;
                    y2 = (obj.Ny-N)/2+N;
                elseif nargin==1
                    figure,imagegb(obj.Itf);
                    [x10,y10] = ginput(1);
                    [x20,y20] = ginput(1);
                    x1 = round(min([x10,x20]));
                    x2 = round(max([x10,x20]));
                    y1 = round(min([y10,y20]));
                    y2 = round(max([y10,y20]));
                else
                    error('Wrong number of inputs')
                end
                obj.Itf0 = obj.Itf(y1:y2,x1:x2);
                if io==1
                    obj.Ref = copy(obj.Ref);
                    obj.Ref.Itf0 = obj.Ref.Itf(y1:y2,x1:x2);
                    obj.Ref.TF = fftshift(fft2(obj.Ref.Itf));
                else  % if the Ref handle has not been croped already
                    obj.Ref = objListout(1).Ref;
                end
            end
        end

        function objList = square(objList)
            No = numel(objList);
            for io = 1:No
                Npx = min(objList(io).Nx,objList(io).Ny);
                x1 = objList(io).Nx/2+1-Npx/2;
                x2 = objList(io).Nx/2  +Npx/2;
                y1 = objList(io).Ny/2+1-Npx/2;
                y2 = objList(io).Ny/2  +Npx/2;
                objList(io).Itf = objList(io).Itf(y1:y2,x1:x2);
                if ~isempty(objList(io).Ref)
                    objList(io).Ref.square();
                end
            end
            
        end
        
        function obj = Reference(obj,val)
            if numel(val)==numel(obj)
                No = numel(obj);
                for io = 1:No        
                    if ~strcmp(val(io).software,obj(io).software)
                        error('')
                    elseif ~strcmp(val(io).CGcam,obj(io).CGcam)
                        error('')
                    %elseif val(io).Nx~=obj(io).Nx || val(io).Ny~=obj(io).Ny
                    %    error('')
                    end
                    obj(io).Ref = val(io);
                end
            elseif numel(val)==1
                No = numel(obj);
                for io = 1:No        
                    if ~strcmp(val.software,obj(io).software)
                        error('')
                    elseif ~strcmp(val.CGcam,obj(io).CGcam)
                        error('')
                    elseif val.Nx~=obj(io).Nx || val.Ny~=obj(io).Ny
                        error('')
                    end
                    obj(io).Ref = val;
                end
            end

            if isempty(obj(1).Ref.TF)
                obj(1).Ref.TF = fftshift(fft2(obj(1).Ref.Itf));
            end
            
        end
        
        function set.Microscope(obj,val)
            if isa(val,'Microscope')
                obj.Microscope = val;
            else
                error('the input must be a Microscope object')
            end
        end
        
        function obj = mean(objList)
            obj = Interfero();
            obj.Ref = Interfero();
            No = numel(objList);
            if No==1
                warning('Only one object to average. Not consistent.')
            end
            
            sumObj = objList(1).Itf;
            for io = 2:No
                if objList(1).Microscope~=objList(io).Microscope
                    warning('Mean of Interfero objects that were not built using the same Microscope.')
                end
                sumObj = sumObj+objList(io).Itf;
            end
            obj.Itf0 = sumObj/No;

            if ~isempty(objList(1).Ref)
                if [objList.Ref]==objList(1).Ref % If all the references are pointing to the same object.
                    obj.Ref = objList(1).Ref;
                else
                    sumObj = objList(1).Ref.Itf;
                    for io = 2:No
                        if isempty(objList(io).Ref.Itf)
                            error(['Ref #' num2str(io) ' is empty, while the first one is not'])
                        end
                        if objList(1).Microscope~=objList(io).Microscope
                            warning('Mean of Interfero objects that were not built using the same Microscope.')
                        end
                        sumObj = sumObj+objList(io).Ref.Itf;
                    end
                    obj.Ref.Itf0 = sumObj/No;
                    obj.Ref.fileName = ['Mean ' objList(1).Ref.fileName ' to '  objList(end).Ref.fileName];
                end
            end
            obj.fileName = ['Mean ' objList(1).fileName ' to '  objList(end).fileName];
            obj.Microscope = objList(1).Microscope;
        end
        
        function fig = figure2(obj)
            fig = figure;
            
            pan = uibuttongroup(fig, 'Title', 'Select Itf or Ref', 'position', [0 0.7 0.1 0.08]);
            
            button1 = uicontrol('Parent',pan,'Style','radiobutton',...
               'String', 'Interferogram',...
               'Position', [10 35 120 15], 'Tag', 'timeop1');
            button2 = uicontrol('Parent',pan, 'Style', 'radiobutton',...
               'String', 'Reference',...
               'position', [10 10 120 15], 'Tag', 'invisibutton');
            set(button1, 'callback',{@(src,event)figure2_callback(obj,fig,'Itf')});
            set(button2, 'callback',{@(src,event)figure2_callback(obj,fig,'Ref')});
            
            fig.UserData = imagegb(obj.Itf);
            fullscreen
        end
        
        function figure2_callback(obj,fig,type)
            if strcmpi(type,'Itf')
                fig.UserData.CData = obj.Itf;
            elseif strcmpi(type,'Ref')
                fig.UserData.CData = obj.Ref.Itf;
            end
            
        end

        function mask0 = spotRemoval(obj,mask)
            
            if nargin==1 % no predfined mask
            

                h = figure;
                %% zoom on the spot of interest
                button = 1;
                mask = ones(obj.Ny,obj.Nx);
                Zlim = 0;
                while(button==1)
                    TF = fftshift(fft2(obj.Itf));
                    TFref = fftshift(fft2(obj.Ref.Itf));
                    imagegb(log(abs(TF)))
                    if Zlim==0
                        Zlim = get(gca,'CLim');
                    else
                        set(gca,'CLim',Zlim);
                    end
                    title('Click on the center of the spot to be removed')

                    [x1,y1,button] = ginput(1);
                    if button==1
                        set(gcf,'CurrentCharacter',char(0))
                        zoom out
                        title('Click further away to define a crop radius around this spot')
                        [x2,y2] = ginput(1);

                        % radius
                        ex = obj.Nx/obj.Ny; % the ellipse excentricity
                        R(1) = sqrt((x2-x1)^2+ex^2*(y2-y1)^2);
                        R(2) = R(1)/ex;


                        h = drawCircle(x1,y1,R,h);
                        pause (1.6)
                        cropParamsout = FcropParameters(x1,y1,R,obj.Nx,obj.Ny);

                        if length(R)==1
                            rx = R;
                            ry = R;
                        else
                            rx = R(1);
                            ry = R(2);
                        end    

                        [xx,yy] = meshgrid(1:obj.Nx, 1:obj.Ny);

                        R2C = (xx  -obj.Nx/2-1-cropParamsout.shiftx).^2/rx^2 + (yy - obj.Ny/2-1-cropParamsout.shifty).^2/ry^2;
                        circle1 = (R2C >= 1); %mask circle for each iteration
                        R2C = (xx  -obj.Nx/2-1+cropParamsout.shiftx).^2/rx^2 + (yy - obj.Ny/2-1+cropParamsout.shifty).^2/ry^2;
                        circle2 = (R2C >= 1); %mask circle for each iteration
                        % demodulation in the Fourier space
                        mask = mask.*double(circle1.*circle2);
                        imagegb(log(abs(TF.*mask)))
                        drawnow
                        obj.Itf = ifft2(ifftshift(TF.*circle1.*circle2)); 
                        obj.Ref.Itf = ifft2(ifftshift(TFref.*circle1.*circle2)); 
                    end
                end
                if nargout
                    mask0 = mask;
                end
                close(h)
            elseif nargin==2
                TF = fftshift(fft2(obj.Itf));
                TFref = fftshift(fft2(obj.Ref.Itf));
                obj.Itf = ifft2(ifftshift(TF.*mask)); 
                obj.Ref.Itf = ifft2(ifftshift(TFref.*mask)); 
            else
                error('not the proper number of inputs')
            end
            
        end
        
        function val = sizeof(IM)
            Nim = numel(IM);
            val = 0;
            for j = 1:Nim
                props = properties(IM(j));
                totSize = 0;
                
                for ii = 1:length(props)
                    currentProperty = getfield(IM(j), char(props(ii)));
                    s = whos('currentProperty');
                    totSize = totSize + s.bytes;
                end
                
                val = val+totSize;
            end
            fprintf('%.3g Ko\n',val)
        end

        function obj = mask(obj,M)
            obj.Itf0 = obj.Itf.*M.im;
            obj.Ref.Itf0 = obj.Ref.Itf.*M.im;
        end
            
        function obj2 = copy2(obj)
            obj2 = copy(obj);
            obj2.Reference(copy(obj.Ref));
        end

    end
end
        
        
        