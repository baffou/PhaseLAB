%% NPimaging package
% Class that defines an experimental image acquired by QLSI

% author: Guillaume Baffou
% affiliation: CNRS, Institut Fresnel
% date: Jul 31, 2019

classdef ImageQLSI   <   ImageMethods
    
%    properties(GetAccess = public, SetAccess = private)
    properties(Access = public, Hidden)
        T0       % matrix of path
        OPD0     
        DWx0
        DWy0
        % comment
    end

    properties(Dependent)
        T       % Transmittance image
        OPD     % Optical path difference image
        DWx     % OPD gradient along x
        DWy     % OPD gradient along y
    end
    
    properties(GetAccess = public, SetAccess = private)
        %lambda, inherited from ImageMethods
        %pxSize, inherited from ImageMethods
        TfileName
        OPDfileName
        imageNumber
        folder
        % Microscope, inherited from ImageMethods
        % Illumination = Illumination() % Illumination object
        % pxSize0 %hidden actual pxSize that can be modified.
        % processingSoft
    end
    
    properties(SetAccess=private)
        Nx =[]
        Ny =[]
        Npx =[]
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
            
            if nargin==1 %ImageQLSI(n)
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
                        [obj.Ny, obj.Nx]=size(obj.T);
                    elseif isnumeric(INT)
                        if isempty(opt.fileName)
                            error('A filename must be specified')
                        end
                        obj.T0=[opt.remotePath '/' opt.fileName '_T.txt'];
                        obj.TfileName=obj.T0;
                        writematrix(single(INT),obj.T0)
                        [obj.Ny, obj.Nx]=size(INT);
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
                    [obj.Ny, obj.Nx]=size(obj.T0);
                end
                obj.Illumination = IL;
                obj.Microscope = MI;
                
            else
                error('Not the proper number of inputs')
            end
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

        function obj = set.T(obj,val)
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

        function obj = set.OPD(obj,val)
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
         
        function val = Ph(obj)
            val = 2*pi/obj.lambda*obj.OPD;
        end
        
        function obj = OPDhighPass(obj,nCrop)
            if nargin==1
                nCrop = 3;
            end
            %imageT_F=fftshift(fft2(obj.T));
            imageOPD_F = fftshift(fft2(obj.OPD));
            
            ix0 = floor(obj.Nx/2)+1;
            iy0 = floor(obj.Ny/2)+1;
            %imageT_F(iy0-nCrop:iy0+nCrop,ix0-nCrop:ix0+nCrop) = 0;
            imageOPD_F(iy0-nCrop:iy0+nCrop,ix0-nCrop:ix0+nCrop) = 0;
            %imageT2 = real(ifft2(ifftshift(imageT_F)));
            imageOPD2 = real(ifft2(ifftshift(imageOPD_F)));
            %obj.T = 1+imageT2;
            obj.OPD = imageOPD2;
            
            
        end
        
        function obj = ZernikeRemove(obj,n,m,r0)
            if nargin==1
                n = 1;
                m = 1;
            end
            if nargin==2 % if only n specified, remove all the Zernike polynoms up to n
                
                for ii = 1:n
                    for jj = 1:ii
                        m = mod(ii,2)+2*(jj-1);
                        obj.OPD = ZernikeRemoval(obj.OPD,ii,m);
                    end
                end
                
            end
            if nargin==4
                obj.OPD = ZernikeRemoval(obj.OPD,n,m,r0);
            else
                obj.OPD = ZernikeRemoval(obj.OPD,n,m);
            end
            %obj.OPD = ZernikeRemoval(obj.OPD,n,m);
            
        end
        
        function obj = flatten(obj,nmax)
            % Removes Zernike moments up to n = nmax
            if nargin==1
                nmax = 1;
            end
            if ~(round(nmax)==nmax)
                error('The input must be an integer (array).')
            end
            if length(nmax)>=2
                error('The order must be a scalar.')
            end
            
            No = numel(obj);
            for io = 1:No
                temp=obj(io).OPD;
                for n = 1:nmax
                    for m = mod(n,2):2:n
                        temp = ZernikeRemoval(temp,n,m); % use a temp image to avoid writing several times on the HDD in remote mode.
                    end
                end
                obj(io).OPD=temp;
            end
        end
        
        function [objList,coords] = untilt(objList,coords0)
            
            No = numel(objList);
            for io = 1:No
                obj = objList(io);
                if nargin==2
                    coords = coords0;
                else
                    opendx(obj.OPD)
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
                objList(io).OPD = objList(io).OPD-mx*X0-my*Y0-mc;
            
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
            IMout.pxSize0 = IM.pxSize0;
            IMout.TfileName = 'Average images';
            IMout.OPDfileName = 'Average images';
        end
        
        function IM = smooth(IM,nn,hfigInit)
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
                IM(ii).T = imgaussfilt(IM(ii).T,nn);
                IM(ii).OPD = imgaussfilt(IM(ii).OPD,nn);
            end
            if nargin==3
                hfigInit.UserData{5} = IMout;
            end
        end
        
        function obj = crop(obj,opt)
            arguments
                obj
                opt.xy1 = 0
                opt.xy2 = 0
                opt.Center {mustBeMember(opt.Center,{'Auto','Manual','auto','manual'})} = 'Auto'
                opt.Size = 'Manual'
            end
            if opt.xy1~=0 && opt.xy2~=0  % crop('xy1', [a,b], 'xy2', [a,b])
                if numel(opt.xy1)~=2
                    error('First input must be a 2-vector (x,y)')
                end
                if numel(opt.xy2)~=2
                    error('Second input must be a 2-vector (x,y)')
                end
                x1 = min([opt.xy1(1),opt.xy2(1)]);
                x2 = max([opt.xy1(1),opt.xy2(1)]);
                y1 = min([opt.xy1(2),opt.xy2(2)]);
                y2 = max([opt.xy1(2),opt.xy2(2)]);
            else
                if strcmpi(opt.Center,'Manual') % crop('Center','Manual')
                    h = obj(1).figure;
                    [xc, yc] = ginput(1);
                    close(h)
                else
                    xc = obj(1).Nx/2;
                    yc = obj(1).Ny/2;
                end
                if strcmpi(opt.Size,'Manual') % crop('Center','Manual')
                    h = obj(1).figure;
                    h.UserData{12}.getPoint = 0;
                    rr = rectangle();
                    set (h, 'WindowButtonMotionFcn', @(src,event)drawRect(h,rr,xc,yc))
                    set (h, 'WindowButtonDownFcn', @(src,event)getPoint(h))
                    while h.UserData{12}.getPoint==0
                    pause(0.1)
                    end
                    Size = h.UserData{12}.side;
                    close (h)
                    x1 = floor(xc-Size/2+1);
                    x2 = floor(xc-Size/2+Size);
                    y1 = floor(yc-Size/2+1);
                    y2 = floor(yc-Size/2+Size);
                elseif isnumeric(opt.Size)
                    x1 = floor(xc-opt.Size/2+1);
                    x2 = floor(xc-opt.Size/2+opt.Size);
                    y1 = floor(yc-opt.Size/2+1);
                    y2 = floor(yc-opt.Size/2+opt.Size);
                end

            end
            
            for io = 1:numel(obj)
                temp=obj(io).T(y1:y2,x1:x2); % temp variable to avoid importing the matrix twice for the calculation of Nx and Ny when it is stored in a file.
                obj(io).T   = temp; 
                obj(io).OPD = obj(io).OPD(y1:y2,x1:x2);
                [obj.Ny, obj.Nx]=size(temp);
            end

            function drawRect(h,rr,xc,yc)
                C = get (h.UserData{7}(2), 'CurrentPoint');
                side = floor(max(abs([2*(C(1)-xc), 2*(C(3)-yc)])));
                set(rr,'Position',[xc-side/2 yc-side/2 side side])
                h.UserData{12}.side = side;
                disp(side)
            end
            
            function getPoint(h)
                h.UserData{12}.getPoint = 1;
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
                objList(io).T = objList(io).T(y1:y2,x1:x2);
                objList(io).OPD = objList(io).OPD(y1:y2,x1:x2);
            end
            
        end
        
        function objList = phase0(objList,option)
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
                    objList(io).OPD = objList(io).OPD-mean(mean(objList(io).OPD(y1:y2,x1:x2)));
                else
                    objList(io).OPD = objList(io).OPD-mean(objList(io).OPD(:));
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
        
        function obj = binning(obj,n)
            if nargin==1 || n==3 % ie n = 3 by default
                for ii = 1:numel(obj)
                    imT = binning3x3(obj(ii).T);
                    imOPD = binning3x3(obj(ii).OPD);
                    obj(ii).T = imT;
                    obj(ii).OPD = imOPD;
                    [obj.Ny, obj.Nx]=size(imT);
                end
            elseif n==2
                for ii = 1:numel(obj)
                    imT = binning2x2(obj(ii).T);
                    imOPD = binning2x2(obj(ii).OPD);
                    obj(ii).T = imT;
                    obj(ii).OPD = imOPD;
                    [obj.Ny, obj.Nx]=size(imT);
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
 
        function objList = phaseLevel0(objList,option)
            % option = [x1 x2 y1 y2]
            if nargin==1
                    objList.figure
                    roi = drawrectangle;
                    x1 = round(roi.Position(1));
                    x2 = round(roi.Position(1)+roi.Position(3));
                    y1 = round(roi.Position(2));
                    y2 = round(roi.Position(2)+roi.Position(4));
                    mean(mean(objList(1).OPD(y1:y2,x1:x2)))
            elseif nargin==2
                if ~isnumeric(nargin)
                    error('the input must be numeric, and a 4-vector.')
                end
                if length(option)==4
                    x1 = option(1);
                    x2 = option(2);
                    y1 = option(3);
                    y2 = option(4);
                else
                    error('The input must be a 4-vector')
                end
            else
                error('unkown option')
            end
            No = numel(objList);
            for io = 1:No
                objList(io).OPD = objList(io).OPD-mean(mean(objList(io).OPD(y1:y2,x1:x2)));
            end
            
        end
        
        function obj = gauss(obj,nn)
            No = numel(obj);
            for io = 1:No
                obj(io).T = obj(io).T-imgaussfilt(obj(io).T,nn);
                 obj(io).OPD = obj(io).OPD-imgaussfilt(obj(io).OPD,nn);
            end
            
        end
        
        function val = PDCM(obj)
            dxDWy  = imgradientxy(obj.DWy);
            [~, dyDWx] = imgradientxy(obj.DWx);
            val = imgaussfilt(dxDWy-dyDWx,3);
        end

        function val = DM(obj)
            % returns the dry mass density in pg/µm^2
            val=5.56*obj.OPD;
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
    end
    
    
end








