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
        TFapo    = []% tells wether the TF has been calculated with an apodization (equals the width of the apodization)
        color (1,:) char {mustBeMember(color,{'R','G','none'})} = 'none'
    end

    properties
        comment  % Any comment to leave to this image
    end

    properties (Dependent)
        Itf     (:,:) double
    end

    properties(SetAccess = private)
        fileName char % Interferogram name on the computer
        path char
        Nx {mustBeInteger,mustBePositive}% Number of pixel of the image in the horizontal direction
        Ny {mustBeInteger,mustBePositive}% Number of pixel of the image in the vertical direction
        imageNumber
    end

    properties(Dependent)
        software char % software used to acquire the interferogram image
        CGcam CGcamera % CGcamera object with which the images were acquired
        pxSize double% pixel size at the sample plane
    end

    properties(Hidden)
        Fimc   (3,1) cell % 3-cell containing the 3 demodulated images
        Microscope Microscope
        Fcrops  FcropParameters = FcropParameters.empty(3,0)
        crops
        remote {mustBeInteger,mustBeLessThanOrEqual(remote,1),mustBeGreaterThanOrEqual(remote,0)}  % 1 if images are not stored (only path/fileName), 0 if images are stored
    end

    methods
        function obj = Interfero(fileName,MI,opt)
            arguments
                fileName =[]  % fileName or matrix
                MI = Microscope.empty()
                opt.N (1,1) {mustBeInteger} = 0
                opt.imageNumber =[]
                opt.remote (1,1) {mustBeInteger,mustBeGreaterThanOrEqual(opt.remote,0),mustBeLessThanOrEqual(opt.remote,1)} = 0
                opt.color (1,:) char {mustBeMember(opt.color,{'R','G','none'})} = 'none'
            end

            obj.remote = opt.remote;
            obj.imageNumber=opt.imageNumber;

            if opt.N~=0 % Interfero(N=3) : create 3 blanck interferos
                obj = repmat(Interfero(),opt.N,1);
                return
            end

            if ~strcmpi(opt.color,'none') && MI.CGcam.Camera.colorChannels == 1
                warning('You are trying to extract a color channel while the microscope does not include a color camera.')
            end



            %% Interfero(3)  Interfero(fileName,MI).
            if nargin==1 % Interfero(3)
                if isnumeric(fileName)
                    if numel(fileName)==1
                        obj=Interfero(N=fileName);
                        return
                    else
                        error('the input microscope is missing')
                    end
                else
                    error('the input microscope is missing')
                end
            end
            if nargin>=2
                % Interfero(fileName,MI)
                % fileName: char that is the txt of tif file name of the interferogram to be read and imported.
                % MI:       Microscope object. Represents the microscope used to acquire the image

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
                    if ~strcmp(fileName(end-2:end),'tif') && ~strcmp(fileName(end-3:end),'tiff') && ~strcmp(fileName(end-2:end),'txt')
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
                            Itf0 = Itf0-2^15-100;% Removes the offset of Phasics, and removes the offset of the camera
                        end
                        if ~strcmpi(opt.color,'none')
                            obj.color = opt.color;
                            switch opt.color
                                case {'G','R'}
                                    obj.Itf0=colorInterpolation(Itf0,opt.color);
                                case 'GR'
                                    obj.Itf0 = Itf0;
                            end
                        else
                            obj.Itf0 = Itf0;
                        end
                    elseif obj.remote==1
                        obj.Itf0 = 'remote';
                        if ~strcmpi(opt.color,'none')
                            obj.color = opt.color;
                        end
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
            if ischar(obj.Itf0) % remote mode
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

            if ~strcmpi(obj.color,'none')
                switch obj.color
                    case {'R','G'}
                        val = colorInterpolation(val,obj.color);
                end
            end


        end

        function val = get.software(obj)
            val = obj.Microscope.software;
        end

        function val = get.CGcam(obj)
            val = obj.Microscope.CGcam;
        end

        function val = get.pxSize(obj)
            val = obj.Microscope.pxSize();
        end

        function deleteFcrops(obj)
            obj.Fcrops = [FcropParameters(); FcropParameters(); FcropParameters()];
            obj.Ref.Fcrops = [FcropParameters(); FcropParameters(); FcropParameters()];
        end

        function [obj,params] = crop(obj0,opt)
            arguments
                obj0
                opt.xy1 = []
                opt.xy2 = []
                opt.Center = 'Auto' % 'Auto', 'Manual' or [x, y]
                opt.Size = 'Manual' % 'Auto', 'Manual', d or [dx, dy]
                opt.twoPoints logical = false
                opt.params double = double.empty()
                opt.shape char {mustBeMember(opt.shape,{'square','rectangle','Square','Rectangle'})}= 'square'
                opt.app = []; % figure uifigure object to be considered in case the image is already open
            end
            if nargout>=1
                fprintf('copying the object')
                obj=copy(obj0);
            else
                obj=obj0;
            end

            if isempty(opt.params)
                [x1, x2, y1, y2] = boxSelection(obj,'xy1',opt.xy1, ...
                    'xy2',opt.xy2, ...
                    'Center',opt.Center, ...
                    'Size',opt.Size, ...
                    'twoPoints',opt.twoPoints, ...
                    'params',opt.params, ...
                    'shape',opt.shape);
                params=[x1, x2, y1, y2];
            else
                x1 = opt.params(1);
                x2 = opt.params(2);
                y1 = opt.params(3);
                y2 = opt.params(4);
                params=opt.params;
            end

            for io = 1:numel(obj)
                printLoop(io,numel(obj))
                obj(io).Itf0 = obj(io).Itf(y1:y2,x1:x2);
                if ~isempty(obj(io).Ref)
                    if ~exist('Ref0','var')
                        Ref0 = obj(io).Ref;
                        Ref0im=Ref0.Itf;
                    elseif Ref0 ~= obj(io).Ref
                        Ref0 = copy(obj(io).Ref);
                        Ref0im=Ref0.Itf;
                    end
                    obj(io).Ref=Ref0;
                    obj(io).Ref = copy(obj(io).Ref);
                    obj(io).Ref.Itf0 = Ref0im(y1:y2,x1:x2);
                    obj(io).Ref.TF = fftshift(fft2(obj(io).Ref.Itf));
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
            if isnumeric(val)
                No = numel(obj);
                for io = 1:No
                    obj(io).Ref = Interfero(val,obj(io).Microscope);
                end
            elseif numel(val)==numel(obj)
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
                        error('not the same software in Itf and Ref')
                    elseif val.CGcam~=obj(io).CGcam
                        val.CGcam
                        error('not the same CGcam in Itf and Ref')
                    elseif val.Nx~=obj(io).Nx || val.Ny~=obj(io).Ny
                        error('not the same image size in Itf and Ref')
                    end
                    obj(io).Ref = val;
                end
            end
            if isempty(obj(1).Ref.TF)
                %obj(1).Ref.TF = fftshift(fft2(obj(1).Ref.Itf));
                obj(1).Ref.computeTF();
            end

        end

        function obj=computeTF(obj,apoNpx) % Computes the TF of an interfero and store it in the TF property
            if nargin == 1
                obj.TF = fftshift(fft2(obj.Itf));
            elseif nargin == 2
                obj.TF = fftshift(fft2(apodization(obj.Itf,apoNpx)));
                obj.TFapo=apoNpx;
            end
        end

        function clearTF(objList) % Clear the computed TF of the Ref.
            for io=1:numel(objList)
                objList(io).Ref.TF = [];
            end
        end

        function obj = mean(objList)
            No = numel(objList);
            if No == 1
                obj = objList;
            else
                obj = Interfero();

                sumObj = objList(1).Itf;
                for io = 2:No
                    if objList(1).Microscope~=objList(io).Microscope
                        warning('Mean of Interfero objects that were not built using the same Microscope.')
                    end
                    sumObj = sumObj+objList(io).Itf;
                end
                obj.Itf0 = sumObj/No;

                if ~isempty(objList(1).Ref)
                    obj.Ref = objList(1).Ref;
                    if ~([objList.Ref]==objList(1).Ref) % If all the references are pointing to the same object.
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
                obj.color = objList(1).color;
            end
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

        function val=getAreaMean(obj,Narea,hfig)
            if nargin==1
                obj.figure()
                Narea=1;
            end

            val=zeros(Narea,2);
            valstd=zeros(Narea,2);
            for ia=1:Narea

                [x,y]=ginput(2);
                xmin=round(min(x));
                xmax=round(max(x));
                ymin=round(min(y));
                ymax=round(max(y));

                valItf=mean(mean(obj.Itf(ymin:ymax,xmin:xmax)));
                valRef=mean(mean(obj.Ref.Itf(ymin:ymax,xmin:xmax)));
                val(ia,1)=valItf;
                val(ia,2)=valRef;

                valstdItf=std2(obj.Itf(ymin:ymax,xmin:xmax));
                valstdRef=std2(obj.Ref.Itf(ymin:ymax,xmin:xmax));
                valstd(ia,1)=valstdItf;
                valstd(ia,2)=valstdRef;

                if nargin==3
                    UIresult=hfig.UserData{8}.UIresult;
                    set(UIresult,'String',[sprintf('%.4g',valItf) '\pm' sprintf('%.4g',valstdItf) ', ' sprintf('%.3g',1e9*valRef) '\pm' sprintf('%.4g',valstdRef) ' nm']);
                end

            end
            hfig.UserData{10}=val;

            hc=figure;
            subplot(1,2,1)
            plot(val(:,1),'o-')
            title('Interfero')
            subplot(1,2,2)
            plot(val(:,2),'o-')
            title('Reference')

            if get(hfig.UserData{8}.autosave,'value')
                saveData(hfig,hc)
            end


        end

        function distance(obj,hfig)
            % measures a distance between two points.
            if nargin==1
                hfig=obj.figure('µm');
            else
                figure(hfig)
                figure_callback(hfig,obj,'µm',hfig.UserData{3},hfig.UserData{4},'1')
                %if ~strcmp(hfig.UserData{2},'px') % force the unit to be px in case it is µm
                %    figure_callback(hfig,obj,'px',hfig.UserData{3},hfig.UserData{4},str2double(get(hfig.UserData{8}.UIk,'String')),hfig.UserData{8})
                %end
            end
            hp=drawpolyline;
            dist=lineLength(hp);
            %clipboard('copy',sprintf([hfig.UserData{5}.OPDfileName '\t%.4g\t' hfig.UserData{2}],dist))

            %             if nargin==2
            %                 if strcmp(hfig.UserData{2},'µm')
            %                     factorAxis=obj.pxSize*1e6;
            %                 elseif strcmp(hfig.UserData{2},'px')
            %                     factorAxis=1;
            %                 end
            %             else
            %                 factorAxis=1;
            %             end
            UIresult=hfig.UserData{8}.UIresult;
            set(UIresult,'String',[sprintf('%.4g',dist) ' ' hfig.UserData{2}]);
            hfig.UserData{10}=dist;

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

        function obj = clearFcrops(obj)
            Nim=numel(obj);
            for ii=1:Nim
                obj(ii).Ref.Fcrops(1)=FcropParameters();
                obj(ii).Ref.Fcrops(2)=FcropParameters();
                obj(ii).Ref.Fcrops(3)=FcropParameters();
            end
        end

        function [ImG,ImR]=splitColors(Im)
            % Im comes from a 2-color camera
            % These function creates to Interfero objects, for each colors
            % Use interpolation to keep the same number of pixels
            arguments
                Im Interfero
            end
            No=numel(Im);
            ImG=Interfero(No);
            ImR=Interfero(No);
            for io=1:No
                ImG(io)=copy(Im(io));
                ImR(io)=copy(Im(io));

                ImG(io).Itf0=colorInterpolation(Im(io).Itf,'g');
                ImG(io).color = 'G';
                ImR(io).Itf0=colorInterpolation(Im(io).Itf,'r');
                ImR(io).color = 'R';
                if ~isempty(ImG(io).Ref)
                    ImG(io).Ref.Itf0=colorInterpolation(Im(io).Ref.Itf,'g');
                    ImG(io).Ref.color = 'G';
                    ImR(io).Ref.Itf0=colorInterpolation(Im(io).Ref.Itf,'r');
                    ImG(io).Ref.color = 'R';
                end
            end
        end

        function [objG2, objR2] = crosstalkCorrection(obj1List, obj2List)
            arguments
                obj1List Interfero
                obj2List Interfero
            end

            Nim = numel(obj1List);
            if numel(obj2List)~=Nim % if not the same number of elements
                error('The two image lists must have the same number of images')
            end

            objG2 = Interfero(Nim);
            objR2 = Interfero(Nim);

            for im = 1:Nim

                if obj1List(im).Microscope ~= obj2List(im).Microscope
                    error('The two interferograms must have been taken with the same microscope')
                end

                cam = obj1List(im).Microscope.CGcam.Camera;

                if cam.colorChannels == 2
                    betag = cam.crosstalk12;
                    betar = cam.crosstalk21;
                else
                    error('You try to correct the cross talk between two images that were not acquired with a color camera')
                end

                if strcmpi(obj1List(im).color(1),'r')
                    if ~strcmpi(obj2List(im).color(1),'g')
                        error('the second image should be green')
                    end
                    objR = obj1List(im);
                    objG = obj2List(im);
                elseif strcmpi(obj1List(im).color(1),'g')
                    if ~strcmpi(obj2List(im).color(1),'r')
                        error('the second image should be red')
                    end
                    objG = obj1List(im);
                    objR = obj2List(im);
                end

                if nargout == 2
                    objG2(im) = copy(objG); % copy and not duplicate to keep the same Microscope
                    objR2(im) = copy(objR);
                elseif nargout == 0
                    objG2(im) = objG;
                    objR2(im) = objR;
                else
                    error('not the proper number of outputs. Should be 0 or 2')
                end

                % correcting crosstalk of the images
                correctedRimage = (1+betar)*objR2(im).Itf -     betag*objG2(im).Itf;
                correctedGimage =   - betar*objR2(im).Itf + (1+betag)*objG2(im).Itf;
                objR2(im).Itf0 = correctedRimage;
                objG2(im).Itf0 = correctedGimage;

            end

            if ~isempty(objR(1).Ref)
                [RefListR, nListR] = independentObjects([objR.Ref]);
                [RefListG, nListG] = independentObjects([objG.Ref]);
                if nListR ~= nListG
                    error('There is an inconsistency between the Refs or G and R images')
                end
                crosstalkCorrection(RefListG,RefListR);
            end

        end

        function obj2 = backgroundCorrection(obj,val)
            arguments
                obj Interfero
                val
            end
            if nargout
                obj2 = copy(obj);
            else
                obj2 = obj;
            end
            No = numel(obj);
            for io = 1:No
                if nargin == 1  % automatic background subtraction
                    offset = mean(obj(io).Ref.Itf);
                    obj2(io).Itf0 = obj(io).Itf - offset;
                elseif isa(val,'Interfero') % Itf.subtractBackground(Itf_bkg)
                    obj2(io).Itf0 = obj(io).Itf - val.Itf;
                elseif isnumeric(val) % Itf.subtractBackground(matrix or number)
                    obj2(io).Itf0 = obj(io).Itf0 - val;
                end
            end

            if ~isempty(obj(1).Ref)
                RefList = independentObjects([obj.Ref]);
                RefList.backgroundCorrection(val)
            end
        end

        function obj = plus(obj1,obj2)
            obj=copy(obj1);
            obj.Ref=copy(obj1.Ref);
            obj.clearTF()
            obj.Itf0 = obj1.Itf() + obj2.Itf();
            obj.Ref.Itf0 = obj1.Ref.Itf() + obj2.Ref.Itf();
        end

        function obj = sum(objList)
            No=numel(objList);
            obj=copy(objList(1));
            for io = 2:No
                obj=obj+objList(io);
            end
        end

    end
end


