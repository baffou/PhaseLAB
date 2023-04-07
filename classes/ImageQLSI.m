%% NPimaging package
% Class that defines an experimental image acquired by QLSI

% author: Guillaume Baffou
% affiliation: CNRS, Institut Fresnel
% date: Jul 31, 2019

classdef ImageQLSI   <   ImageMethods

    %    properties(GetAccess = public, SetAccess = private)
    properties(Dependent)
        T       % Transmittance image
        OPD     % Optical path difference image [m]
        OPDnm   % Optical path difference image [nm]
        DWx     % OPD gradient along x
        DWy     % OPD gradient along y
        Ph      % Phase image
        Nx
        Ny
    end

    properties(Access = public, Hidden)
        T0       % matrix of path
        OPD0
        DWx0
        DWy0
        % comment
    end

    properties(SetAccess={?Interfero})
        ItfFileName
    end

    properties(GetAccess = public, SetAccess = private)
        TfileName
        OPDfileName
        imageNumber
        folder
        % Microscope, inherited from ImageMethods
        % Illumination = Illumination() % Illumination object
        % processingSoft
    end


    properties(Hidden,SetAccess = private)
        Fcrops %3-cell FcropParameters object crops{1:3}
        processingSoftware
    end

    methods
        function obj = ImageQLSI(INT,OPD,MI,IL,opt)
            arguments
                INT = []     % fileName or Matrix
                OPD = []     % fileName or Matrix
                MI  Microscope = Microscope.empty()
                IL  Illumination = Illumination.empty
                opt.remotePath =[]
                opt.fileName =[]
                opt.imageNumber =[]
            end

            obj.imageNumber=opt.imageNumber;
            if isa(INT,'ImageEM')
                objEM=INT;
                obj.T0 = objEM.T;
                obj.OPD0 = objEM.OPD;
                obj.Microscope=objEM.Microscope;
                obj.Illumination=objEM.Illumination;
                

            elseif nargin==1 %ImageQLSI(n)
                if isnumeric(INT)
                    n=INT;
                    obj = repmat(ImageQLSI(),n,1);
                else
                    error('wrong input type')
                end
            elseif nargin==0 %ImageQLSI()
            elseif nargin==4 %ImageQLSI(T,OPD,MI,IL)
                if isnumeric(INT) && isnumeric(OPD) % if both are matrices, they should be of the same size
                    if (sum(size(INT)==size(OPD))~=2)
                        size(INT)
                        size(OPD)
                        error('OPD and T images must have the same size.')
                    end
                end

                if ~isempty(opt.remotePath) % remote yes
                    if ischar(INT)
                        obj.T0=INT;
                        obj.TfileName=INT;
                    elseif isnumeric(INT)
                        if isempty(opt.fileName)
                            error('A filename must be specified')
                        end
                        obj.T0=[opt.remotePath '/' opt.fileName '_T.txt'];
                        obj.TfileName=obj.T0;
                        obj.T0
                        writematrix(single(INT),obj.T0)
                    end

                    if ischar(OPD)
                        obj.OPD0=OPD;
                        obj.OPDfileName=OPD;
                    elseif isnumeric(OPD)
                        if isempty(opt.fileName)
                            error('A filename must be specified')
                        end
                        obj.OPD0=[opt.remotePath '/' opt.fileName '_OPD.txt'];
                        writematrix(single(OPD),obj.OPD0)
                        obj.OPDfileName=obj.OPD0;
                    end

                else % no remote
                    if ischar(INT)
                        obj.T0 = readmatrix(INT);
                        obj.TfileName=INT;
                    elseif isnumeric(INT)
                        obj.T0=INT;
                    else
                        error('wrong input')
                    end

                    if ischar(OPD)
                        obj.OPD0 = readmatrix(OPD);
                        obj.OPDfileName=OPD;
                    elseif isnumeric(OPD)
                        obj.OPD0=OPD;
                    else
                        error('wrong input')
                    end
                end
                obj.Illumination = IL;
                obj.Microscope = MI;

            else
                error('Not the proper number of inputs')
            end
        end

        function val = get.Nx(obj)
            val = size(obj.OPD,2);
        end

        function val = get.Ny(obj)
            val = size(obj.OPD,1);
        end

        function val = get.T(obj)

            if isnumeric(obj.T0) % T is a matrix
                val=obj.T0;
            elseif ischar(obj.T0) % T is a path/fileName
                val=readmatrix(obj.T0);
            else
                error('not a proper input')
            end
        end

        function set.T(obj,val)
            if isnumeric(val) % input is a matrix
                if isnumeric(obj.T0)
                    obj.T0=val;
                elseif ischar(obj.T0) % overwrite the file
                    warning(['file overwriting!: ' obj.T0])
                    writematrix(single(val),obj.T0)
                end
            elseif ischar(val) % input is a file name
                if ischar(obj.T0) % target already a file name
                    obj.T0=val;
                elseif isnumeric(obj.T0) % target a matrix
                    obj.T0=readmatrix(val);
                end
            end
        end

        function val = get.OPD(obj)

            if isnumeric(obj.OPD0) % T is a matrix
                val=obj.OPD0;
            elseif ischar(obj.OPD0) % T is a path/fileName
                val=readmatrix(obj.OPD0);
            else
                error('not a proper input')
            end
        end

        function val = get.OPDnm(obj)

            if isnumeric(obj.OPD0) % T is a matrix
                val=obj.OPD0*1e9;
            elseif ischar(obj.OPD0) % T is a path/fileName
                val=readmatrix(obj.OPD0)*1e9;
            else
                error('not a proper input')
            end
        end

        function val = get.DWx(obj)
            val = obj.DWx0;
        end

        function val = get.DWy(obj)
            val = obj.DWy0;
        end

        function set.OPD(obj,val)
            if isnumeric(val) % input is a matrix
                if isnumeric(obj.OPD0)
                    obj.OPD0=val;
                elseif ischar(obj.OPD0) % overwrite the file
                    warning(['file overwriting!: ' obj.OPD0])
                    writematrix(single(val),obj.OPD0)
                end
            elseif ischar(val) % input is a file name
                if ischar(obj.OPD0) % target already a file name
                    obj.OPD0=val;
                elseif isnumeric(obj.OPD0) % target a matrix
                    obj.OPD0=readmatrix(val);
                end
            end
        end

        function set.OPDnm(obj,val)
            if isnumeric(val) % input is a matrix
                if isnumeric(obj.OPD0)
                    obj.OPD0=val*1e-9;
                elseif ischar(obj.OPD0) % overwrite the file
                    warning(['file overwriting!: ' obj.OPD0])
                    writematrix(single(val),obj.OPD0*1e-9)
                end
            elseif ischar(val) % input is a file name
                if ischar(obj.OPD0) % target already a file name
                    obj.OPD0=val*1e-9;
                elseif isnumeric(obj.OPD0) % target a matrix
                    obj.OPD0=readmatrix(val)*1e-9;
                end
            end
        end

        function val = get.Ph(obj)
            val = 2*pi/obj.lambda*obj.OPD;
        end

        function obj2 = highPassFilter(obj,nCrop)
            arguments
                obj
                nCrop double = 10
            end
            if nargout
                obj2=copy(obj);
            else
                obj2=obj;
            end
            for io=1:numel(obj)
                obj2(io).OPD = highPassFilter(obj(io).OPD,nCrop);
            end

        end

        function obj2 = lowPassFilter(obj,nCrop)
            arguments
                obj
                nCrop double = 10
            end
            if nargout
                obj2=copy(obj);
            else
                obj2=obj;
            end
            for io=1:numel(obj)
                obj2(io).OPD = lowPassFilter(obj(io).OPD,nCrop);
            end

        end

        function obj2 = ZernikeRemove(obj,n,m,r0)
            if nargout
                obj2=copy(obj);
            else
                obj2=obj;
            end

            if nargin==1
                n = 1;
                m = 1;
            end
            if nargin==2 % if only n specified, remove all the Zernike polynoms up to n

                for ii = 1:n
                    for jj = 1:ii
                        m = mod(ii,2)+2*(jj-1);
                        obj2.OPD = ZernikeRemoval(obj.OPD,ii,m);
                    end
                end

            end
            if nargin==4
                obj2.OPD = ZernikeRemoval(obj.OPD,n,m,r0);
            else
                obj2.OPD = ZernikeRemoval(obj.OPD,n,m);
            end
            %obj.OPD = ZernikeRemoval(obj.OPD,n,m);

        end

        function [objList2,coords] = untilt(objList,coords0)
            if nargout
                objList2=copy(objList);
            else
                objList2=objList;
            end

            No = numel(objList);
            for io = 1:No
                obj = objList(io);
                if nargin==2
                    coords = coords0;
                else
                    obj.figure
                    h = gcf;
                    roi = drawrectangle;
                    button = 0;
                    while ~isempty(button)
                        [~,~,button] = ginput(1);
                    end
                    coords = roi.Position;
                    %coords0 = coords;
                    close(h)
                end
                xmin = round(coords(1));
                ymin = round(coords(2));
                xmax = round(xmin+coords(3));
                ymax = round(ymin+coords(4));
                OPDc = obj.OPD(ymin:ymax,xmin:xmax);
                mc = mean(OPDc(:));
                [Nyc,Nxc] = size(OPDc);
                [X,Y] = meshgrid(1:Nxc,1:Nyc);
                X = X-mean(X(:));
                Y = Y-mean(Y(:));
                X = X/sqrt(mean(X(:).*X(:)));
                Y = Y/sqrt(mean(Y(:).*Y(:)));
                mx = mean(mean(OPDc.*X));
                my = mean(mean(OPDc.*Y));

                Xm = max(X(:));
                Ym = max(Y(:));
                [Ny0,Nx0] = size(obj.OPD);
                [X0, Y0] = meshgrid(1:Nx0,1:Ny0);
                X0 = X0-mean(X0(:));
                Y0 = Y0-mean(Y0(:));
                X0 = X0/max(X0(:));
                Y0 = Y0/max(Y0(:));
                X0 = X0*Nx0/Nxc*Xm;
                Y0 = Y0*Ny0/Nyc*Ym;
                objList2(io).OPD = objList(io).OPD-mx*X0-my*Y0-mc;

            end
        end

        function IMout = mean(IM)
            % computes the average image of a list of ImageQLSI objects.
            Nim = numel(IM);
            OPDsum = 0;
            intsum = 0;
            for ii = 1:Nim
                intsum = intsum+IM(ii).T;
                OPDsum = OPDsum+IM(ii).OPD;
            end
            INT = intsum/Nim;
            OPD = OPDsum/Nim;
            IMout = ImageQLSI(INT,OPD,IM(1).Microscope,IM(1).Illumination);
            IMout.Microscope = IM.Microscope;
            IMout.TfileName = 'Average images';
            IMout.OPDfileName = 'Average images';
        end

        function IM2 = smooth(IM,nn,hfigInit)
            if nargout
                IM2=copy(IM);
            else
                IM2=IM;
            end
            %smooth(IM,nn,hfigInit)
            % nn: intensity of the smoothing in pixels
            if nargin>=3
                if ~strcmp(hfigInit.UserData{2},'px')
                    error('Please select px units to use the alpha function')
                end
            end
            if isa(IM,'ImageEM')
                if norm(IM.EE0)==0
                    warning('As E0 is zero at the image plane, the T map is not normalized and the alpha won''t be absolutely measured.')
                end
            end
            if nargin==1
                nn = 4;
            end
            for ii = 1:numel(IM)
                IM2(ii).T = imgaussfilt(IM(ii).T,nn);
                IM2(ii).OPD = imgaussfilt(IM(ii).OPD,nn);
            end
            if nargin==3
                hfigInit.UserData{5} = IMout;
            end
        end

        function objList2 = square(objList)
            if nargout
                objList2=copy(objList);
            else
                objList2=objList;
            end
            No = numel(objList);
            for io = 1:No
                Npx = min(objList(io).Nx,objList(io).Ny);
                x1 = objList(io).Nx/2+1-Npx/2;
                x2 = objList(io).Nx/2  +Npx/2;
                y1 = objList(io).Ny/2+1-Npx/2;
                y2 = objList(io).Ny/2  +Npx/2;
                objList2(io).T = objList(io).T(y1:y2,x1:x2);
                objList2(io).OPD = objList(io).OPD(y1:y2,x1:x2);
            end

        end

        function objList2 = phase0(objList,option)
            if nargout
                objList2=copy(objList);
            else
                objList2=objList;
            end
            manual = 0;
            if nargin==2
                if strcmp(option,'manual')
                    objList.figure
                    manual = 1;
                    roi = drawrectangle;
                    x1 = round(roi.Position(1));
                    x2 = round(roi.Position(1)+roi.Position(3));
                    y1 = round(roi.Position(2));
                    y2 = round(roi.Position(2)+roi.Position(4));
                    mean(mean(objList(1).OPD(y1:y2,x1:x2)))
                else
                    error('unkown option')
                end
            end
            No = numel(objList);
            for io = 1:No
                if manual==1
                    objList2(io).OPD = objList(io).OPD-mean(mean(objList(io).OPD(y1:y2,x1:x2)));
                else
                    objList2(io).OPD = objList(io).OPD-mean(objList(io).OPD(:));
                end
            end

        end

        function obj = setFcrops(obj,crops)
            if ~numel(crops)==3
                error('cropping parameters must be a 3-cell array.')
            end
            c1 = crops(1);
            c2 = crops(2);
            c3 = crops(3);
            if isa(c1,'FcropParameters') && isa(c2,'FcropParameters') && isa(c3,'FcropParameters')
                obj.Fcrops = [c1; c2; c3];
            else
                error('not FcropParameters objects')
            end

        end

        function obj2 = binning(obj,n)
            arguments
                obj
                n {mustBeInteger,mustBeGreaterThan(n,1),mustBeLessThan(n,4)} = 3
            end
            if nargout
                obj2=copy(obj);
            else
                obj2=obj;
            end
            if n==3
                for ii = 1:numel(obj)
                    imT = binning3x3(obj(ii).T);
                    imOPD = binning3x3(obj(ii).OPD);
                    obj2(ii).T = imT;
                    obj2(ii).OPD = imOPD;
                end
            elseif n==2
                for ii = 1:numel(obj)
                    imT = binning2x2(obj(ii).T);
                    imOPD = binning2x2(obj(ii).OPD);
                    obj2(ii).T = imT;
                    obj2(ii).OPD = imOPD;
                end
            else
                error('not a proper binning dimension. Should be 2 or 3.')
            end


        end

        function obj = setProcessingSoftware(obj,name)
            if ~ischar(name)
                error('The processing software must be a string')
            end
            switch name
                case {'PHAST','Phast'}
                    obj.processingSoftware = 'PHAST';
                case {'SID4BIO','Sid4Bio','SID4Bio','Sid4BIO'}
                    obj.processingSoftware = 'Sid4Bio';
                case {'PhaseLab','PhaseLAB'}
                    obj.processingSoftware = 'PhaseLAB';
                otherwise
                    error('This software name is not known')
            end

        end


        
        function [obj, params] = level0(obj0,opt)
            arguments
                obj0
                opt.method (1,:) char {mustBeMember(opt.method,{'mean','average','median','boundary'})}= 'mean'
                % parameters for boxSelection()
                opt.xy1 = []
                opt.xy2 = []
                opt.Center = 'Auto' % 'Auto', 'Manual' or [x, y]
                opt.Size = 'Manual' % 'Auto', 'Manual', d or [dx, dy]
                opt.twoPoints logical = false
                opt.params double = double.empty() % = [x1, x2, y1, y2]
                opt.shape char {mustBeMember(opt.shape,{'square','rectangle','Square','Rectangle'})}= 'square'
                opt.figure = []; % figure uifigure object to be considered in case the image is already open
            end

            if nargout
                obj=copy(obj0);
            else
                obj=obj0;
            end

            sizeIm = [0 0]; 
            for io = 1:numel(obj)
                if sum(sizeIm ~= size(obj(io).OPD)) % if the size of the image is not the same as the previous one
                    if isempty(opt.params)
                        if numel(obj)>1
                            opt.imNumber = io;
                        end
                        [x1, x2, y1, y2] = boxSelection(obj,opt);
                        params=[x1, x2, y1, y2];
                    else
                        x1 = opt.params(1);
                        x2 = opt.params(2);
                        y1 = opt.params(3);
                        y2 = opt.params(4);
                        params=opt.params;
                    end
                end

                sizeIm = size(obj(io).OPD);

                if strcmpi(opt.method,'mean') || strcmpi(opt.method,'average')
                    offsetFunction = @(im) mean(im(:));
                elseif strcmpi(opt.method,'median')
                    offsetFunction = @(im) median(im(:));
                elseif strcmpi(opt.method,'boundary')
                    offsetFunction = @(im) boundaryMedian(im);
                else
                    error('unkown option')
                end

                obj(io).OPD = obj(io).OPD-offsetFunction(obj(io).OPD(y1:y2,x1:x2));
            end

            function val = boundaryMedian(im)
                top=im(end,:);
                bottom=im(1,:);
                left=im(2:end-1,1);
                right=im(2:end-1,end);
                bound=[top(:);bottom(:);left(:);right(:)];
                val = median(bound);
            end
        end        
        
        function obj2 = gauss(obj,nn)
            if nargout
                obj2=copy(obj);
            else
                obj2=obj;
            end
            No = numel(obj);
            for io = 1:No
                obj2(io).T = obj(io).T-imgaussfilt(obj(io).T,nn);
                obj2(io).OPD = obj(io).OPD-imgaussfilt(obj(io).OPD,nn);
            end

        end

        function obj = rot90(obj0,k)
            % rotate the images of the object by k*90°
            arguments
                obj0
                k {mustBeInteger(k)} = 1
            end

            if nargout
                obj=copy(obj0);
            else
                obj=obj0;
            end

            if isnumeric(obj0(1).T0)
                for io=1:numel(obj0)
                    obj(io).T0=rot90(obj0(io).T0,k);
                    obj(io).OPD0=rot90(obj0(io).OPD0,k);
                    obj(io).DWx0=rot90(obj0(io).DWx0,k);
                    obj(io).DWy0=rot90(obj0(io).DWy0,k);
                end
            else
                error('A ImageQLSI object cannot be rotated if it is remote.')
            end

        end            
    
        function obj = mirrorH(obj0)
            % Mirror image with an horizontal mirror

            if nargout
                obj=copy(obj0);
            else
                obj=obj0;
            end

            if isnumeric(obj0(1).T0)
                for io=1:numel(obj0)
                    obj(io).T0  =obj0(io).T0(end:-1:1,:);
                    obj(io).OPD0=obj0(io).OPD0(end:-1:1,:);
                    obj(io).DWx0=obj0(io).DWx0(end:-1:1,:);
                    obj(io).DWy0=obj0(io).DWy0(end:-1:1,:);
                end
            else
                error('A ImageQLSI object cannot be rotated if it is remote.')
            end

        end            
    
        function obj = mirrorV(obj0)
            % Mirror image with an horizontal mirror

            if nargout
                obj=copy(obj0);
            else
                obj=obj0;
            end

            if isnumeric(obj0(1).T0)
                for io=1:numel(obj0)
                    obj(io).T0  =obj0(io).T0(:,end:-1:1);
                    obj(io).OPD0=obj0(io).OPD0(:,end:-1:1);
                    obj(io).DWx0=obj0(io).DWx0(:,end:-1:1);
                    obj(io).DWy0=obj0(io).DWy0(:,end:-1:1);
                end
            else
                error('A ImageQLSI object cannot be rotated if it is remote.')
            end

        end        

        function val = DWnorm(obj)
            if isempty(obj.DWx)
                error('The gradients have not been calculated upon using QLSIprocess. Please use the option saveGradients=1')
            end
            val = sqrt(obj.DWx.^2 + obj.DWy.^2);
        end

        function val = D2Wnorm(obj)
            if isempty(obj.DWx)
                error('The image gradients are not saved during the wavefront retrieval algo.')
            end
            dxDWx  = imgradientxy(obj.DWx);
            [~, dyDWy] = imgradientxy(obj.DWy);
            val = sqrt(dxDWx.^2+dyDWy.^2);
        end

        function val = PDCM(obj)
            dxDWy  = imgradientxy(obj.DWy);
            [~, dyDWx] = imgradientxy(obj.DWx);
            val = imgaussfilt(dxDWy-dyDWx,3);
        end

        function val = DM(obj)
            % returns the dry mass density in pg/µm^2
            val=5.56*1e-3 * obj.OPD*1e9;
        end

        function PDCMdisplay(obj,hfig)
            % plots horizontal and vertical cross cuts.
            if nargin==1
                hfig = obj.figure();
            else
                figure(hfig)
                %if ~strcmp(hfig.UserData{2},'px') % force the unit to be px in case it is µm
                %    figure_callback(hfig,obj,'px',hfig.UserData{3},hfig.UserData{4},str2double(get(hfig.UserData{8}.UIk,'String')),hfig.UserData{8})
                %end
            end
            Image1handle = hfig.UserData{7}(1).Children;
            if isempty(hfig.UserData{5}.DWx)
                error('DWx and DWy where not saved. Use the option saveGradients = true with QLSIprocess.')
            end
            PDCM = hfig.UserData{5}.PDCM;
            Image1handle.CData = PDCM;
            minval = min(PDCM(:));
            maxval = max(PDCM(:));
            caxis(hfig.UserData{7}(1),[minval maxval])

        end

        function obj2List = download(objList)
            No=numel(objList);
            obj2List=ImageQLSI(No);
            for io = 1:No
                obj2List(io)=copy(objList(io));
                obj2List(io).T0=objList(io).T;
                obj2List(io).OPD0=objList(io).OPD;
                %obj2List(io).DWx0=objList(io).DWx;
                %obj2List(io).DWy=objList(io).DWy;
            end
        end

        function save(objList,folder,varargin)
            % save T and/or OPD images as jpg and txt images
            % IM.save('_postprocess')  save only the OPD image
            % IM.save('_postprocess','OPD')
            % IM.save('_postprocess','T')
            % IM.save('_postprocess','T','OPD')
            Nim=numel(objList);
            if ~strcmp(folder(end),'/')
                folder = [folder '/'];
            end
            if nargin ==2
                varargin{1}='OPD';
            end
            for ia = 1:numel(varargin)
                type = varargin{ia}; % 'OPD' or 'T'
                for io = 1:Nim
                    clear imName
                    % Automatic definition of the name of the file
                    if ~isempty(objList(io).OPDfileName)
                        imName = objList(io).OPDfileName;
                    elseif ~isempty(objList(io).ItfFileName)
                        imName = [type '_' objList(io).ItfFileName];
                    elseif ~isempty(objList(io).imageNumber)
                        imName = [type '_' textkkk(objList(io).imageNumber)];
                    else
                        imName = [type '_' textkkk(io)];
                    end
                    imName = removeExtension(imName);
                    imNamejpg = [imName '.jpg'];
                    if strcmpi(varargin{ia},'T')
                        colorM=gray;
                    else
                        colorM=phase1024(256);
                    end
                    imwrite(ImageQLSI.im2int8(objList(io).(type)),colorM,[folder imNamejpg])
                    disp(imNamejpg)
                    imNametxt = [imName '.txt'];
                    writematrix(objList(io).(type),[folder imNametxt])
                    disp(imNametxt)
                end
                %end


            end



        end

        function write(obj,obj_in)
            % makes obj2 = obj, but without giving a new handle
            propList = ["T0","OPD0","DWx0","DWy0","ItfFileName",...
                "TfileName","OPDfileName","imageNumber","folder"...
                "Microscope","Illumination","comment","processingSoft","pxSizeCorrection"];

            if numel(obj) ~= numel(obj_in) 
                error('The input and output image lists must have the same number of elements')
            end
            for io = 1:numel(obj_in)
                for propName = propList
                    obj(io).(propName) = obj_in(io).(propName);
                end
            end
        end
    end

    methods(Static)
        function im0 = im2int8(im)
            img=imgaussfilt(im,2);
            maxim=max(img(:));
            minim=min(img(:));
            im0=uint8(255*(im-minim)/(maxim-minim));
        end

    end


end





