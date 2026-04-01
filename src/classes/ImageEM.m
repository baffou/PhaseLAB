%% NPimaging package
% Class that defines an electromagnetic image

% author: Guillaume Baffou
% affiliation: CNRS, Institut Fresnel
% date: Jul 31, 2019

classdef ImageEM  <  ImageMethods & matlab.mixin.Copyable

    properties(Dependent, GetAccess = public , SetAccess={?ImageMethods, ?Interfero})
        Ex
        Ey
        Ez
    end

    properties (SetAccess = {?Methods,?ImageQLSI})
        % data:
         % either
        Ex0 (:,:) double
        Ey0 (:,:) double
        Ez0 (:,:) double
         % or
        IM (1,4) ImageQLSI % The difference with an ImageEM object is here. The info of an ImagePolar object is contained within this embedded ImageQLSI object.
                            % A normal ImageEM object could have been made  from the ImageQLSI image, but it would have  duplicate some info in the RAM. And when  working with 100s of image, it is a problem.
    end
    
    properties(GetAccess = public , SetAccess={?ImageMethods, ?Interfero})
        channel (1,:) char {mustBeMember(channel,{'R','G','0','45','90','135','none'})} = 'none'
    end

    properties%(Access = public,NonCopyable)
        Einc ImageEM % to be put back in private
        %Microscope, inherited from ImageMethods
        %Illumination, inherited from ImageMethods
        %comment, inherited from ImageMethods
    end


    properties(Dependent)
        Nx
        Ny
        E2
        E
        Ph
        Ph_coh
        OPD
        OPDnm
        T
    end

    properties(Dependent) % Stokes parameters
        S0
        S1
        S2
        S3
        s1
        s2
        s3
        L   % Q + 1i*U
        absL % |L|
        A   % long radius of the ellipse
        B   % short radius of the ellipse
        thetaEllipse   % tilt of the ellipse [rad]
        thetaEllipseDeg   % tilt of the ellipse; [°]
        thetaEllipsebar % theta*absL
        rgbImage        % theta*absL
        h   % handedness sign(S3)
        e  % ellipticity
        chi % ellipticity angle
        rgbImageEllipse

        ex
        ey

        % biref/retardance params
        theta0
        phibar
        dphi
        Tbar
        dichroism
        thetaT
        Wbar
        retardance
        dW
        %rgbImage
        OPDmean
    end

    properties(GetAccess = public, SetAccess = private)
        retardanceMax (1,1) double = 20 % max amplitude of the retardance on the color map of theta
        e2Max (1,1) double = 0.1 % max amplitude of the squared ellipticity on the color map of thetaEllipse
        dichroMax (1,1) double = 0.1
    end

    properties
        rgb_bg0 char {mustBeMember(rgb_bg0,{'white','black'})} = 'black'
        calcSjMode  char {mustBeMember(calcSjMode,{'Tj','Ej'})} = 'Tj'
        dphi0 = 1 % artificial phase shift on both axes to simulated a missdetermination of the grating camera distance
    end

    methods
        function obj = ImageEM(Ex,Ey,Ez,Eincx,Eincy,Eincz,opt)
            %ImageEM()
            %ImageEM(n=n)
            %ImageEM(Eincx,Eincy,Eincz)
            %ImageEM(Ex,Ey,Ez,Einc||EE0)
            %ImageEM(Ex,Ey,Ez,Eincx,Eincy,Eincz)
            %ImageEM(... ,"Microscope",MI,"Illumination",IL)
            arguments
                Ex {mustBeNumeric} = []
                Ey {mustBeNumeric} = []
                Ez {mustBeNumeric} = []
                Eincx {mustBeNumeric} = []
                Eincy {mustBeNumeric} = []
                Eincz {mustBeNumeric} = []
                opt.n {mustBeNumeric} = []
                opt.Microscope Microscope = Microscope.empty()
                opt.Illumination Illumination = Illumination.empty()
            end
            if nargin==0
                if ~isempty(opt.n) % ImageEM(n=N)
                    obj = repmat(ImageEM(),opt.n,1);
                    for ii = 1:opt.n % to force them to not be identical handles
                        obj(ii) = ImageEM();
                    end
                else % ImageEM()     1 empty object
                    % do nothing
                end
            elseif nargin==1 % ImageEM(n)    n empty objects
                if isnumeric(Ex) && numel(Ex) == 1
                    obj = repmat(ImageEM,Ex,1);
                    for ii = 1:opt.n % to force them to not be identical handles
                        obj(ii) = ImageEM();
                    end
                else
                    error('wrong input parameter')
                end
            elseif nargin<=3 % ImageEM(Eincx,Eincy,Eincz) typically when defining an incident field
                obj.Ex = Ex;
                obj.Ey = Ey;
                obj.Ez = Ez;
            end
            if nargin==4% ImageEM(Ex,Ey,Ez,Einc||E0)    total field
                if numel(Eincx) == 3 % E0 is a vector, meaning that the illumination is uniform and at normal incidence
                    obj.Ex = Ex;
                    obj.Ey = Ey;
                    obj.Ez = Ez;
                    ONE = ones(size(Ex));
                    obj.Einc = ImageEM(Eincx(1).*ONE,Eincx(2).*ONE, Eincx(3).*ONE);
                else
                    error('The 4th argument must be a 3-vector')
                end
            elseif nargin==6% ImageEM(Ex,Ey,Ez,Eincx,Eincy,Eincz)    total field
                obj.Ex = Ex;
                obj.Ey = Ey;
                obj.Ez = Ez;
                obj.Einc = ImageEM();
                obj.Einc.Ex = Eincx;
                obj.Einc.Ey = Eincy;
                obj.Einc.Ez = Eincz;
            end
            if ~isempty(opt.Microscope)
                obj.Microscope=opt.Microscope;
            end
            if ~isempty(opt.Illumination)
                obj.Illumination=opt.Illumination;
            end
        end

        function set.Ex(obj, val)
            %obj.Ex0 = val;
            obj.setE(val,'x');
        end
        function set.Ey(obj, val)
            %obj.Ey0 = val;
            obj.setE(val,'y');
        end
        function set.Ez(obj, val)
            %obj.Ez0 = val;
            obj.setE(val,'z');
        end

        function val = get.Ex(obj)
            val = obj.getE('x');
        end
        function val = get.Ey(obj)
            val = obj.getE('y');
        end
        function val = get.Ez(obj)
            val = obj.getE('z');
        end

        function obj2 = ImageQLSI(obj,opt)
            % transforms an ImageEM object into an ImageQLSI object
            arguments
                obj ImageEM
                opt.imageNumber = []
            end

            Nim = numel(obj);
            obj2 = repmat(ImageQLSI(1),size(obj));
            for ii = 1:Nim
                obj2(ii) = ImageQLSI(obj(ii).T,obj(ii).OPD,obj(ii).Microscope,obj(ii).Illumination);
                obj2(ii).imageNumber = opt.imageNumber;
            end
            
        end

        function objs = plus(obj1,obj2) % coherent sum of the fields
            warning('By summing images of different particles/dipoles, there is no self-consistent optical coupling between these objects. Prefer summing dipoles and then imaging the dipole array, which will run a DDA self consistent calculation of the dipolar moments.')
            if obj1.lambda~=obj2.lambda
                error('You are trying to sum two images corresponding to two different wavelengths.')
            elseif obj1.pxSize~=obj2.pxSize
                error('You are trying to sum two images corresponding to two different pixel sizes.')
            elseif obj1.zoom~=obj2.zoom
                error('You are trying to sum two images corresponding to two different sizes of field of view (''zoom'' properties differ).')
            elseif obj1.Nx~=obj2.Nx || obj1.Ny~=obj2.Ny
                error('You are trying to sum two images with different pixel numbers.')
            end
            objs = copy(obj1);
            objs.Ex = obj1.Ex + obj2.Ex;
            objs.Ey = obj1.Ey + obj2.Ey;
            objs.Ez = obj1.Ez + obj2.Ez;
            objs.Einc = copy(obj1.Einc);
            objs.Einc.Ex = obj1.Einc.Ex + obj2.Einc.Ex;
            objs.Einc.Ey = obj1.Einc.Ey + obj2.Einc.Ey;
            objs.Einc.Ez = obj1.Einc.Ez + obj2.Einc.Ez;
            IL1 = obj1.Illumination;
            IL2 = obj2.Illumination;
            objs.Illumination = Illumination(IL1(1).lambda,IL1(1).Medium,IL1.I+IL2.I,IL1.polar+IL2.polar);
        end

        function objs = mtimes(obj1,obj2)
            % coherent sum of the fields, with a phase shift of pi/2 for the second field
            % or simple multiplication by a scalar            
            if isnumeric(obj1)                        
                objs = copy(obj2);
                val = obj1;
                for ip = 1:numel(objs)
                    objs(ip).Ex = val*obj2(ip).Ex;
                    objs(ip).Ey = val*obj2(ip).Ey;
                    objs(ip).Ez = val*obj2(ip).Ez;
                    objs(ip).Einc = copy(obj2(ip).Einc);
                    objs(ip).Einc.Ex = val*obj2(ip).Einc.Ex;
                    objs(ip).Einc.Ey = val*obj2(ip).Einc.Ey;
                    objs(ip).Einc.Ez = val*obj2(ip).Einc.Ez;
                    objs(ip).Illumination = copy(obj2(ip).Illumination);
                    objs(ip).Illumination.I = obj2(ip).Illumination.I*abs(val)^2;
                end
            elseif isnumeric(obj2)
                objs = copy(obj1);
                val = obj2;
                for ip = 1:numel(objs)
                    objs(ip).Ex = val*obj1(ip).Ex;
                    objs(ip).Ey = val*obj1(ip).Ey;
                    objs(ip).Ez = val*obj1(ip).Ez;
                    objs(ip).Einc = copy(obj1(ip).Einc);
                    objs(ip).Einc.Ex = val*obj1(ip).Einc.Ex;
                    objs(ip).Einc.Ey = val*obj1(ip).Einc.Ey;
                    objs(ip).Einc.Ez = val*obj1(ip).Einc.Ez;
                    objs(ip).Illumination = copy(obj1(ip).Illumination);
                    objs(ip).Illumination.I = obj1(ip).Illumination.I*abs(val)^2;
                end
            else
                objs = copy(obj1);
                objs.Ex = obj1.Ex + 1i*obj2.Ex;
                objs.Ey = obj1.Ey + 1i*obj2.Ey;
                objs.Ez = obj1.Ez + 1i*obj2.Ez;
                objs.Einc = copy(obj1.Einc);
                objs.Einc.Ex = obj1.Einc.Ex + 1i*obj2.Einc.Ex;
                objs.Einc.Ey = obj1.Einc.Ey + 1i*obj2.Einc.Ey;
                objs.Einc.Ez = obj1.Einc.Ez + 1i*obj2.Einc.Ez;
                IL1 = obj1.Illumination;
                IL2 = obj2.Illumination;
                objs.Illumination = Illumination(IL1(1).lambda,IL1(1).Medium,IL1.I+IL2.I,IL1.polar+1i*IL2.polar);
            end
        end



        function objs = mrdivide(obj1,obj2)
            % coherent sum of the fields, with a phase shift of -pi/2 for the second field
            % or simple division by a scalar
            if isnumeric(obj1)
                objs = copy(obj2);
                val = obj1;
                objs.Ex = obj2.Ex/val;
                objs.Ey = obj2.Ey/val;
                objs.Ez = obj2.Ez/val;
                objs.Einc = copy(obj2.Einc);
                objs.Einc.Ex = obj2.Einc.Ex/val;
                objs.Einc.Ey = obj2.Einc.Ey/val;
                objs.Einc.Ez = obj2.Einc.Ez/val;
                objs.Illumination = copy(obj2.Illumination);
                objs.Illumination.I = obj2.Illumination.I/val;
            elseif isnumeric(obj2)
                objs = copy(obj1);
                val = obj2;
                objs.Ex = obj1.Ex/val;
                objs.Ey = obj1.Ey/val;
                objs.Ez = obj1.Ez/val;
                objs.Einc = copy(obj1.Einc);
                objs.Einc.Ex = obj1.Einc.Ex/val;
                objs.Einc.Ey = obj1.Einc.Ey/val;
                objs.Einc.Ez = obj1.Einc.Ez/val;
                objs.Illumination = copy(obj1.Illumination);
                objs.Illumination.I = obj1.Illumination.I/val;
            else
                objs = copy(obj1);
                objs.Ex = obj1.Ex - 1i*obj2.Ex;
                objs.Ey = obj1.Ey - 1i*obj2.Ey;
                objs.Ez = obj1.Ez - 1i*obj2.Ez;
                objs.Einc = copy(obj1.Einc);
                objs.Einc.Ex = obj1.Einc.Ex - 1i*obj2.Einc.Ex;
                objs.Einc.Ey = obj1.Einc.Ey - 1i*obj2.Einc.Ey;
                objs.Einc.Ez = obj1.Einc.Ez - 1i*obj2.Einc.Ez;
                IL1 = obj1.Illumination;
                IL2 = obj2.Illumination;
                objs.Illumination = Illumination(IL1(1).lambda,IL1(1).Medium,IL1.I+IL2.I,IL1.polar-1i*IL2.polar);
            end
        end


        function objs = sum(objList) % coherent sum of the fields
            objs = copy(objList(1));
            objs.Einc = copy(objList(1).Einc);
            No = numel(objList);
            for io = 2:No
                objs = objs+objList(io);
            end
        end

        function T = sumT(objList)
            No = numel(objList);
            T=0;
            for io = 1:No
                T = T+objList(io).T;
            end
        end

        function val = Npx(obj) % the images of the class ImageEM are supposed to be squared anyway: Npx=Nx=Ny
            val = obj.Nx;
        end

        function val = get.Nx(obj)
            val = size(obj.Ex,2);
        end

        function val = get.Ny(obj)
            val = size(obj.Ex,1);
        end

        function val = get.E2(obj)
            val = abs(obj.Ex).^2+abs(obj.Ey).^2+abs(obj.Ez).^2;
        end

        function val = get.E(obj)
            val = sqrt(abs(obj.Ex).^2+abs(obj.Ey).^2+abs(obj.Ez).^2);
        end

        function val = get.Ph(obj)

            Ex_norm = abs(obj.Ex);% remove the .^2 empirically. Works better on a corral!
            Ey_norm = abs(obj.Ey);% remove the .^2 empirically. Works better on a corral!

            if isempty(obj.Einc) % if already an indicent field
                pha_x = angle(obj.Ex);% phase image of the x-polarized wavefront
                pha_y = angle(obj.Ey);% phase image of the y-polarized wavefront
            elseif all(obj.Einc.Ex(:) == 0) && all(obj.Einc.Ey(:) == 0)  % If Einc became 0, eg due to the positioning of polarizing plates
                pha_x = angle(obj.Ex);% phase image of the x-polarized wavefront
                pha_y = angle(obj.Ey);% phase image of the y-polarized wavefront
            else
                pha_x = angle(obj.Ex.*conj(obj.Einc.Ex));% phase image of the x-polarized wavefront
                pha_y = angle(obj.Ey.*conj(obj.Einc.Ey));% phase image of the y-polarized wavefront
            end

        %    val = (pha_x.*Ex_norm + pha_y.*Ey_norm) ./ (Ex_norm+Ey_norm);% weighted average of the phase images
            val  = angle(Ex_norm.*exp(1i*pha_x)  + Ey_norm.*exp(1i*pha_y));
        
        end

        function val = get.OPD(obj)
            if isempty(obj.Ex)
                val = [];
            else
                k0 = 2*pi/obj.lambda;
                val = Unwrap_TIE_DCT_Iter(obj.Ph)/k0; % Optical path difference
            end
        end

        function val = get.OPDnm(obj)
            if isempty(obj.Ex)
                val = [];
            else
                k0 = 2*pi/obj.lambda;
                val = Unwrap_TIE_DCT_Iter(obj.Ph)/k0*1e9; % Optical path difference
            end
        end

        function val = get.T(obj)
            if isempty(obj.Ex)
                val = [];
            else
                if norm(obj.EE0)==0 % happens when using crossed polarizers that kill E0 on the image plane.
                    val = obj.E2; % Transmittance
                else
                    if isprop(obj,'Einc')
                        if ~isempty(obj.Einc)
                            val = obj.E2 ./ obj.Einc.E2; % Transmittance
                        else
                            val = obj.E2;
                        end
                        else
                        val = obj.E2;
                    end
                end
            end
        end

        function val = get.S0(obj)
            val = obj.getS(0);
        end
        function val = get.S1(obj)
            val = obj.getS(1);
        end
        function val = get.S2(obj)
            val = obj.getS(2);
        end
        function val = get.S3(obj)
            val = obj.getS(3);
        end
        
            
        function val = get.s1(obj)
            % 2nd normalized Stokes component
            val = obj.S1./obj.S0;
        end

        function val = get.s2(obj)
            % 3nd normalized Stokes component
            val = obj.S2./obj.S0;
        end

        function val = get.s3(obj)
            % 4th normalized Stokes component
            val = obj.S3./obj.S0;
        end

            
        function val = get.A(obj)
            val = sqrt(0.5*(obj.S0+abs(obj.L)));
        end
        
        function val = get.B(obj)
            val = sqrt(0.5*(obj.S0-abs(obj.L)));
        end
        
        function val = get.thetaEllipse(obj)
            val = mod(0.5*angle(obj.L),pi);
        end

        function val = get.thetaEllipseDeg(obj)
            val = obj.thetaEllipse*180/pi;
        end


        function val = get.L(obj)
            val = obj.S1 + 1i*obj.S2;
        end

        function val = get.absL(obj)
            val = abs(obj.S1 + 1i*obj.S2);
        end


        function val = get.thetaEllipsebar(obj)

            retardanceMax =1e-10;
            black = 1;

            if black == 1
                corr = 1;
            else
                corr = 0;
            end
            hsvImage = zeros(obj.Ny, obj.Nx, 3);
            hsvImage(:,:,1) = obj.thetaEllipse/pi;
            hsvImage(:,:,2+corr) = 1/retardanceMax*obj.absL * obj.Illumination.lambda/(2*pi);
            hsvImage(:,:,3-corr) = ones(obj.Ny,obj.Nx);

            val = hsv2rgb(hsvImage);
        
        end

        function img = get.rgbImage(obj)
            arguments
                obj
            end

            if strcmp(obj.rgb_bg0,'black')
                corr = 1;
            else
                corr = 0;
            end
            hsvImage = zeros(obj.Ny, obj.Nx, 3);
            hsvImage(:,:,1) = obj.theta0/pi;
            hsvImage(:,:,2+corr) = 1/obj.retardanceMax*obj.dphi0 * obj.Illumination.lambda/(2*pi);
            hsvImage(:,:,3-corr) = ones(obj.Ny,obj.Nx);

            img = hsv2rgb(hsvImage);
        end


        function val = get.h(obj)
            val = sign(obj.S3);
        end

        function val = get.e(obj)
            % excentricity
%            val = 1-(obj.B./obj.A).^2;
            val = obj.h*obj.B./obj.A;
        end

        function val = get.chi(obj)
            % ellipticity angle
            %  tan(chi) = e
            val = atan(obj.e);
        end

        function val = zoom(obj)
            val=obj.Microscope.CGcam.zoom;
        end

        function obj2 = binning(obj,n)
            arguments
                obj
                n = 3
            end
            if nargout
                obj2=Methods.duplicate(obj);
            else
                obj2=obj;
            end
            if n==3 % ie n = 3 by default
                binfun=@binning3x3;
            elseif n==2
                binfun=@binning2x2;
            elseif n==4
                binfun=@(x) binning2x2(binning2x2(x));
            elseif n==6
                binfun=@(x) binning3x3(binning2x2(x));
            elseif n==12
                binfun=@(x) binning3x3(binning2x2(binning2x2(x)));
            elseif n==1
                binfun=@(x) x; % identity
            else
                error('not a proper binning dimension. Should be 2 or 3.')
            end
            for ii = 1:numel(obj)
                imEx = binfun(obj(ii).Ex);
                imEy = binfun(obj(ii).Ey);
                imEz = binfun(obj(ii).Ez);
                obj2(ii).Ex = imEx;
                obj2(ii).Ey = imEy;
                obj2(ii).Ez = imEz;
                imEx = binfun(obj(ii).Einc.Ex);
                imEy = binfun(obj(ii).Einc.Ey);
                imEz = binfun(obj(ii).Einc.Ez);
                obj2(ii).Einc.Ex = imEx;
                obj2(ii).Einc.Ey = imEy;
                obj2(ii).Einc.Ez = imEz;
                obj2(ii).binningFactor=obj2(ii).binningFactor*n;
            end

        end
        
        function val = integral(obj)
            Nim = length(obj);
            val = zeros(Nim,1);
            for iim = 1:Nim
                sqrT = sqrt(obj(iim).T);
                expPh = exp(1i*obj(iim).Ph);
                %alphaS = 1i*2*n/(k0*(1+r12*exp(-2*1i*Medium.n*k0*z0)))*(1-sqtT.*expPh);
                alphaS = sqrT.*expPh;
                val(iim) = sum(alphaS(:))*obj(iim).pxSize*obj(iim).pxSize;
            end

        end

        function val = crossSections(obj)

            Nim = length(obj);
            val = repmat(NPprop(),Nim,1);
            for iim = 1:Nim
                al = obj(iim).alpha();
                n = obj(iim).Microscope.n;% n or nS?
                k0 = 2*pi/obj(iim).lambda;
                Cext = k0/n*imag(al);
                Csca = k0^4/(6*pi)*abs(al)^2;
                Cabs = Cext-Csca;
                val(iim) = NPprop(al,Cext,Csca,Cabs);
            end
        end

        function obj2 = FFT(obj)
            obj2 = Methods.duplicate(obj);
            obj2.Ex0 = ifftshift(fft2(obj.Ex));
            obj2.Ey0 = ifftshift(fft2(obj.Ey));
            obj2.Ez0 = ifftshift(fft2(obj.Ez));
            obj2.Ex0(end/2+1,end/2+1) = 0.25*(obj2.Ex0(end/2,end/2+1)+obj2.Ex0(end/2+2,end/2+1) + obj2.Ex0(end/2+1,end/2)+obj2.Ex0(end/2+1,end/2+2));
            obj2.Ey0(end/2+1,end/2+1) = 0.25*(obj2.Ey0(end/2,end/2+1)+obj2.Ey0(end/2+2,end/2+1) + obj2.Ey0(end/2+1,end/2)+obj2.Ey0(end/2+1,end/2+2));
            obj2.Ez0(end/2+1,end/2+1) = 0.25*(obj2.Ez0(end/2,end/2+1)+obj2.Ez0(end/2+2,end/2+1) + obj2.Ez0(end/2+1,end/2)+obj2.Ez0(end/2+1,end/2+2));
            if ~isempty(obj2.Einc)
                obj2.Einc.Ex0 = ifftshift(fft2(obj.Einc.Ex));
                obj2.Einc.Ey0 = ifftshift(fft2(obj.Einc.Ey));
                obj2.Einc.Ez0 = ifftshift(fft2(obj.Einc.Ez));
                obj2.Einc.Ex0(end/2+1,end/2+1) = 0.25*(obj2.Einc.Ex0(end/2,end/2+1)+obj2.Einc.Ex0(end/2+2,end/2+1) + obj2.Einc.Ex0(end/2+1,end/2)+obj2.Einc.Ex0(end/2+1,end/2+2));
                obj2.Einc.Ey0(end/2+1,end/2+1) = 0.25*(obj2.Einc.Ey0(end/2,end/2+1)+obj2.Einc.Ey0(end/2+2,end/2+1) + obj2.Einc.Ey0(end/2+1,end/2)+obj2.Einc.Ey0(end/2+1,end/2+2));
                obj2.Einc.Ez0(end/2+1,end/2+1) = 0.25*(obj2.Einc.Ez0(end/2,end/2+1)+obj2.Einc.Ez0(end/2+2,end/2+1) + obj2.Einc.Ez0(end/2+1,end/2)+obj2.Einc.Ez0(end/2+1,end/2+2));
            end                
        end

        function [IMs,mat] = Jones(IM,varargin)
            
            Nim = numel(IM);
            IMs = ImageEM(Nim);
            for iim = 1:Nim
                [E_x, E_y, mat] = Jones0(IM(iim).Ex, IM(iim).Ey, varargin);
                if ~isempty(IM(iim).Einc)
                    [Einc_x, Einc_y] = Jones0(IM(iim).Einc.Ex, IM(iim).Einc.Ey, mat);
                    IMs(iim) = ImageEM(E_x,E_y,IM(iim).Ez*0,Einc_x,Einc_y,IM(iim).Ez*0);
                else
                    IMs(iim) = ImageEM(E_x,E_y,IM(iim).Ez*0);
                end
                IMs(iim).Microscope = IM(iim).Microscope;
                IMs(iim).Illumination = IM(iim).Illumination;
                IMs(iim).comment = IM(iim).comment;

            end
        end

        function objList = Escat(objList0)
            objList = copy(objList0);

            No=numel(objList0);
            for io=1:No
                objList(io).Ex = objList0(io).Ex-objList0(io).Einc.Ex;
                objList(io).Ey = objList0(io).Ey-objList0(io).Einc.Ey;
                objList(io).Ez = objList0(io).Ez-objList0(io).Einc.Ez;
            end
        end

        function val = EE0(obj,num)
            arguments
                obj
                num {mustBeInteger(num)} = 1:3; % return all the components by default
            end
            % complex vectorial incident field at the center of the image
            if isempty(obj.Einc) % if the object is already an incident field
                valx=obj.Ex(ceil(end/2),ceil(end/2));
                valy=obj.Ey(ceil(end/2),ceil(end/2));
                valz=obj.Ez(ceil(end/2),ceil(end/2));
                val0 = [valx, valy, valz];
            else % take the EE0 of the Einc
                val0 = obj.Einc.EE0;
            end
            val = val0(num);
        end

        function val = EE0n(obj)
            % norm of the incident field
            if isempty(obj.Einc) % if the object if already an incident field
                val=sqrt(mean(mean(abs(obj.Ex).^2+abs(obj.Ey).^2+abs(obj.Ez).^2)));
            else % take the EE0 of the Einc
                val = obj.Einc.EE0n();
            end
        end

        function obj = applyPCmask(objList,Plist)
            % Recalculate a field when an annular mask is implemented in the
            % objective back aperture.
            % BackFourierTranform the field, apply an annular
            % intensity/phase mask ,and Fourier transform. Used to model
            % Phase Contrast or SLIM images.
            arguments
                objList ImageEM
                Plist PCmask
            end
            No=numel(objList);
            if numel(Plist)==1
                P=repmat(Plist,No,1);
            elseif numel(Plist)==No
                P=Plist;
            else
                error('wrong number of PCmask or ImageEM')
            end
            obj = ImageEM(n=No);
            for io=1:No
                FEx = fftshift(fft2(objList(io).Ex));
                FEy = fftshift(fft2(objList(io).Ey));
                FEz = fftshift(fft2(objList(io).Ez));
                FEincx = fftshift(fft2(objList(io).Einc.Ex));
                FEincy = fftshift(fft2(objList(io).Einc.Ey));
                FEincz = fftshift(fft2(objList(io).Einc.Ez));

                FExm =  FEx .* P(io).mask(objList(io));
                FEym =  FEy .* P(io).mask(objList(io));
                FEzm =  FEz .* P(io).mask(objList(io));
                FEincxm =  FEincx .* P(io).mask(objList(io));
                FEincym =  FEincy .* P(io).mask(objList(io));
                FEinczm =  FEincz .* P(io).mask(objList(io));

                Exm = ifft2(ifftshift(FExm));
                Eym = ifft2(ifftshift(FEym));
                Ezm = ifft2(ifftshift(FEzm));
                Eincxm = ifft2(ifftshift(FEincxm));
                Eincym = ifft2(ifftshift(FEincym));
                Einczm = ifft2(ifftshift(FEinczm));

                obj(io) = ImageEM(Exm,Eym,Ezm,Eincxm,Eincym,Einczm,...
                    "Illumination",objList(io).Illumination,"Microscope",objList(io).Microscope);
            end
        end

        function obj = rot90(obj0,k)
            % rotate the images of the object by k*90°
            arguments
                obj0
                k {mustBeInteger(k)} = 1
            end

            if nargout
                obj = copy(obj0);
                obj.Einc = copy(obj0.Einc);
            else
                obj=obj0;
            end
            for io=1:numel(obj0)
                obj(io).Ex=rot90(obj0(io).Ex,k);
                obj(io).Ey=rot90(obj0(io).Ey,k);
                obj(io).Ez=rot90(obj0(io).Ez,k);
                obj(io).Einc.Ex=rot90(obj0(io).Einc.Ex,k);
                obj(io).Einc.Ey=rot90(obj0(io).Einc.Ey,k);
                obj(io).Einc.Ez=rot90(obj0(io).Einc.Ez,k);
            end

        end   

        function obj = flipud(obj0)
            % Mirror image with an horizontal mirror

            if nargout
                obj=copy(obj0);
                obj.Einc=copy(obj0.Einc);
            else
                obj=obj0;
            end

            for io=1:numel(obj0)
                obj(io).Ex=obj0(io).Ex(end:-1:1,:);
                obj(io).Ey=obj0(io).Ey(end:-1:1,:);
                obj(io).Ez=obj0(io).Ez(end:-1:1,:);
                obj(io).Einc.Ex=obj0(io).Einc.Ex(end:-1:1,:);
                obj(io).Einc.Ey=obj0(io).Einc.Ey(end:-1:1,:);
                obj(io).Einc.Ez=obj0(io).Einc.Ez(end:-1:1,:);
            end

        end            
    
        function obj = fliplr(obj0)
            % Mirror image with an horizontal mirror

            if nargout
                obj=copy(obj0);
                obj.Einc=copy(obj0.Einc);
            else
                obj=obj0;
            end

            for io=1:numel(obj0)
                obj(io).Ex=obj0(io).Ex(:,end:-1:1);
                obj(io).Ey=obj0(io).Ey(:,end:-1:1);
                obj(io).Ez=obj0(io).Ez(:,end:-1:1);
                obj(io).Einc.Ex=obj0(io).Einc.Ex(:,end:-1:1);
                obj(io).Einc.Ey=obj0(io).Einc.Ey(:,end:-1:1);
                obj(io).Einc.Ez=obj0(io).Einc.Ez(:,end:-1:1);
            end

        end     

        function obj = rotField45(obj0,orientation)
            % rotate the vectors by 45°. Amounts to changing from (u1,u3)
            % basis to (u2,u4) (or reciprocally)
            arguments
                obj0
                orientation (1,1) double {mustBeMember(orientation, [-1 1])} = 1
            end

            if nargout
                obj = copy(obj0);
                obj.Einc = copy(obj0.Einc);
            else
                obj = obj0;
            end
            for io=1:numel(obj0)
                Ex2 = (obj(io).Ex+obj(io).Ey)/sqrt(2);
                Ey2 = (-orientation*obj(io).Ex+obj(io).Ey)/sqrt(2);
                obj(io).Ex = Ex2;
                obj(io).Ey = Ey2;
                obj(io).Ez = obj0(io).Ez;
                if ~isempty(obj(io).Einc)
                    Ex2 = (obj(io).Einc.Ex+obj(io).Einc.Ey)/sqrt(2);
                    Ey2 = (-orientation*obj(io).Einc.Ex+obj(io).Einc.Ey)/sqrt(2);
                    obj(io).Einc.Ex = Ex2;
                    obj(io).Einc.Ey = Ey2;
                    obj(io).Einc.Ez = obj0(io).Einc.Ez;
                end
            end

        end   

        function objList = applyPhaseShift(objList0,phi)
            % applies a phase shift to all the components of a field, but
            % not to its Einc. Useful to articially simulate SLIM imaging.
            if nargout
                objList=copy(objList0);
            else
                objList=objList0;
            end
            No=numel(objList0);
            for io=1:No
                objList(io).Ex=objList0(io).Ex*exp(1i*phi);
                objList(io).Ey=objList0(io).Ey*exp(1i*phi);
                objList(io).Ez=objList0(io).Ez*exp(1i*phi);
            end
        end

        function I = FT(obj)
            FEx = fftshift(fft2(obj.Ex));
            FEy = fftshift(fft2(obj.Ey));
            I = abs(FEx).^2 + abs(FEy).^2;
        end

        function IM = polarMask(IM0)
            IM = copy(IM0);
            No = numel(IM0);
            for io = 1:No
                IM(io).Ex(1:2:end,1:2:end) = 0;
                IM(io).Ey(2:2:end,2:2:end) = 0;
                IM(io).Ex(2:2:end,1:2:end) = ( IM0(io).Ex(2:2:end,1:2:end)+IM0(io).Ey(2:2:end,1:2:end))/2;
                IM(io).Ey(2:2:end,1:2:end) = ( IM0(io).Ex(2:2:end,1:2:end)+IM0(io).Ey(2:2:end,1:2:end))/2;
                IM(io).Ex(1:2:end,2:2:end) = (+IM0(io).Ex(1:2:end,2:2:end)-IM0(io).Ey(1:2:end,2:2:end))/2;
                IM(io).Ey(1:2:end,2:2:end) = (-IM0(io).Ex(1:2:end,2:2:end)+IM0(io).Ey(1:2:end,2:2:end))/2;
                if ~isempty(IM(io).Einc)
                    IM(io).Einc = IM(io).Einc.polarMask();
                end
            end
        end

        function IM = polarMask2(IM0)
            IM = copy(IM0);
            IM.Ey(1:2:end,1:2:end) = 0;
            IM.Ex(2:2:end,2:2:end) = 0;
            IM.Ex(2:2:end,1:2:end) = (+IM0.Ex(2:2:end,1:2:end)-IM0.Ey(2:2:end,1:2:end))/2;
            IM.Ey(2:2:end,1:2:end) = (-IM0.Ex(2:2:end,1:2:end)+IM0.Ey(2:2:end,1:2:end))/2;
            IM.Ex(1:2:end,2:2:end) = ( IM0.Ex(1:2:end,2:2:end)+IM0.Ey(1:2:end,2:2:end))/2;
            IM.Ey(1:2:end,2:2:end) = ( IM0.Ex(1:2:end,2:2:end)+IM0.Ey(1:2:end,2:2:end))/2;
            if ~isempty(IM.Einc)
                IM.Einc = IM.Einc.polarMask2();
            end
        end


        function IMout = propagation(IM, z, opt)
            % numerical propagation over the distance z
            arguments
                IM
                z      {mustBeNumeric}
                opt.n  {mustBeNumeric} = [] % refractive index of the propagation medium
            
                opt.dx {mustBeNumeric} = 0 % dx and dy shift the phase of the image by dx and dy pixels
                opt.dy {mustBeNumeric} = 0 %  (not necessarily integers)
            end

            if nargout
                IMout = Methods.duplicate(IM); % not copy(), to also duplicate the Einc
            else
                IMout = IM;
            end

            No = numel(IM);
            for io = 1:No
                if isempty(opt.n)
                    n = IM(io).Illumination.Medium.nS;
                else
                    n = opt.n;
                end
                %image=sqrt(IM(io).T).*exp(1i*IM(io).Ph);
                ex = IM(io).Ex;
                ey = IM(io).Ey;
                ex0 = IM(io).Einc.Ex;
                ey0 = IM(io).Einc.Ey;
                IMout(io).Ex = imProp(ex,IM(io).pxSize,IM(io).Illumination.lambda,z,'n',n,'dx',opt.dx,'dy',opt.dy);
                IMout(io).Ey = imProp(ey,IM(io).pxSize,IM(io).Illumination.lambda,z,'n',n,'dx',opt.dx,'dy',opt.dy);
                IMout(io).Einc.Ex = imProp(ex0,IM(io).pxSize,IM(io).Illumination.lambda,z,'n',n,'dx',opt.dx,'dy',opt.dy);
                IMout(io).Einc.Ey = imProp(ey0,IM(io).pxSize,IM(io).Illumination.lambda,z,'n',n,'dx',opt.dx,'dy',opt.dy);
            end
        end

        function bool = is_empty(obj)
            % return 1 if the object is empty, or if all the properties are empty
            No = numel(obj);
            val = zeros(No,1);
            for io = 1:No
                if isempty(obj(io))
                    val(io) = 1;
                else
                    val(io) = isempty(obj(io).Ex);
                end
            end
            bool = logical(val);
        end


        function app = figurePolar(obj)
            if nargout
                app = figurePolarGUI(obj);
            else
                figurePolarGUI(obj)
            end
        end
        
        
        
        function IMout = imaging(obj)
            % Compute the image of an ImageEM object defined at the object plane,
            % applying the blurring effect due to the NA of the detection
            
            IL = obj.Illumination;
            MI = obj.Microscope;
            % imaging(DIs,IL,MI[,ImSize,Npx])
            % DIs: array of Dipole objects, or Nanoparticle object
            % IL: Illumination object
            % MI: Objective or Microscope object, Objetive being a superclass of Microscope
            
            fEx = fftshift(fft2(obj.Ex));
            fEy = fftshift(fft2(obj.Ey));
            fE0x = fftshift(fft2(obj.Einc.Ex));
            fE0y = fftshift(fft2(obj.Einc.Ey));
            
            
            if isa(MI,'Microscope')
            elseif isa(MI,'Objective')
                MI = Microscope(MI);
            else
                error('The third input must be either an Objective or a Microscope object')
            end
            
            pxSize = MI.pxSize;
            ImSize = [obj.Ny, obj.Nx]*pxSize;
            
            %% Microscope paramaters
            
            if isempty(IL.n)
                error('A medium object needs to be assigned to the Illumination object for this kind of calculation. Please use Illumination(lambda,ME), not just Illumination(lambda).')
            end
            
            if MI.NA>IL.nS
                error('NA should be smaller than n')
            end
            
            %% excitation field
            
            k0 = IL.k0;            % wavevector in vacuum
            
            %r12 = (n-nS)/(n+nS);           % reflection coefficient at the interface
            kmaxy = pi*obj.Ny/ImSize(1);
            kmaxx = pi*obj.Nx/ImSize(2);
            
            %dk = kmax/(Npx);        % other valid expression
            dkx = 2*pi/ImSize(2);        % pixel size in Fourier space
            dky = 2*pi/ImSize(1);        % pixel size in Fourier space
            kxx = -kmaxx:dkx:kmaxx-dkx; % x component of wavevector
            kyy = -kmaxy:dky:kmaxy-dky; % y component of wavevector
            
            
            [Kx,Ky] = meshgrid(kxx, kyy);
            
            %% Computation of the scattered field at Fourier plane
            
            mask = sqrt(Kx.*Kx + Ky.*Ky) < MI.NA*k0;     % cutoff filter; taking into account the numerical aperture of the objective
            
            fEx = fEx.*mask;
            fEy = fEy.*mask;
            fE0x = fE0x.*mask;
            fE0y = fE0y.*mask;
            
            ex = ifft2(ifftshift(fEx));
            ey = ifft2(ifftshift(fEy));
            e0x = ifft2(ifftshift(fE0x));
            e0y = ifft2(ifftshift(fE0y));
            
            IMout = ImageEM(ex, ey, obj.Ez, e0x, e0y, obj.Einc.Ez, "Microscope", obj.Microscope, "Illumination", obj.Illumination);
            

        end



        function val = get.Wbar(obj)
            val = obj.phibar*obj.Illumination.lambda/(2*pi); 
        end

        function val = get.retardance(obj)
            val = obj.dphi*obj.Illumination.lambda/(2*pi); 
        end

        function val = get.dW(obj)
            val = obj.retardance; 
        end



        function val = get.rgbImageEllipse(obj)

            if strcmp(obj.rgb_bg0,'black')
                corr = 1;
            else
                corr = 0;
            end
            hsvImage = zeros(obj.Ny, obj.Nx, 3);
            hsvImage(:,:,1) = obj.thetaEllipse/pi;
            hsvImage(:,:,2+corr) = obj.e/obj.e2Max;
            hsvImage(:,:,3-corr) = ones(obj.Ny,obj.Nx);

            val = hsv2rgb(hsvImage);
        
        end


                
        function img = get.phibar(obj)
            arguments
                obj
            end

            % img = (obj.IM(1).Ph + obj.IM(2).Ph ...
            %      + obj.IM(3).Ph + obj.IM(4).Ph)/4*obj.dphi0;
            img = angle(sqrt(obj.Ex.*obj.Ey));
        end

        function img = get.Tbar(obj)
            arguments
                obj
            end

            img = (obj.IM(1).T + obj.IM(2).T ...
                 + obj.IM(3).T + obj.IM(4).T)/4;

        end

        function img = get.theta0(obj)
            arguments
                obj
            end

            img = mod(0.5*angle((obj.IM(1).Ph*obj.dphi0-obj.IM(3).Ph*obj.dphi0) ...
                   + 1i*(obj.IM(2).Ph*obj.dphi0-obj.IM(4).Ph*obj.dphi0)),pi);

        end

        function img = get.thetaT(obj)
            arguments
                obj
            end

            img = mod(0.5*angle((obj.IM(1).T-obj.IM(3).T) ...
                   + 1i*(obj.IM(2).T-obj.IM(4).T)),pi);

        end

        function img = get.dphi(obj)
            arguments
                obj
            end
            phib = obj.phibar;
            img = sqrt(abs((obj.IM(4).Ph*obj.dphi0-phib) ...
                         .*(obj.IM(2).Ph*obj.dphi0-phib) ...
                         + (obj.IM(3).Ph*obj.dphi0-phib) ...
                         .*(obj.IM(1).Ph*obj.dphi0-phib)));

        end

        function img = get.dichroism(obj)
            arguments
                obj
            end
            Tb = obj.Tbar;
            img = sqrt(abs((obj.IM(4).T-Tb) ...
                         .*(obj.IM(2).T-Tb) ...
                         + (obj.IM(3).T-Tb) ...
                         .*(obj.IM(1).T-Tb)));

        end


        function set.retardanceMax(obj, val)
            % converts in [m] in case the norm factor is entered in [nm]
            obj.retardanceMax = convert_nm(val);
        end

        function set.dichroMax(obj, val)
            % converts in [m] in case the norm factor is entered in [nm]
            obj.dichroMax = val;
        end

        function set_retMax(obj, val)
            if val >1e-3 % value in [nm]
                val = val*1e-9; % conversion in [m]
            end
            Nim = numel(obj);
            for nim = 1:Nim
                obj(nim).retardanceMax = val;
            end
        end

        function set_e2Max(obj, val)
            Nim = numel(obj);
            for nim = 1:Nim
                obj(nim).e2Max = val;
            end
        end

        function set_dichroMax(obj, val)
            Nim = numel(obj);
            for nim = 1:Nim
                obj(nim).dichroMax = val;
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
                    imName = [type '_' textkkk(io)];
                    imNamejpg = [imName '.jpg'];
                    imwrite(ImageQLSI.im2int8(objList(io).(type)),phase1024(256),[folder imNamejpg])
                    disp(imNamejpg)
                    imNametxt = [imName '.txt'];
                    writematrix(objList(io).(type),[folder imNametxt])
                    disp(imNametxt)
                end
                %end


            end



        end

        function write(obj,obj_in)
            % makes obj = obj,_in but without giving a new handle
            propList = ["Ex","Ey","Ez","Einc",...
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

    methods(Access = protected)

        function setE(obj,val,ax)
            arguments
                obj
                val
                ax {mustBeMember(ax,{'x','y','z'})}
            end
            switch ax
                case 'x'
                    obj.Ex0 = val;
                case 'y'
                    obj.Ey0 = val;
                case 'z'
                    obj.Ez0 = val;
            end
        end

        function val = getE(obj,ax)
            if obj.IM(1).Nx == 0 % no embedded ImageQLSI object IM
                switch ax
                    case 'x'
                        val = obj.Ex0;
                    case 'y'
                        val = obj.Ey0;
                    case 'z'
                        val = obj.Ez0;
                end
            else % embedded IM object
                switch ax
                    case 'x'
                        val = sqrt(obj.IM(1).T).*exp(1i*obj.IM(1).Ph*obj.dphi0);
                    case 'y'
                    s = -sign(obj.Illumination.S3/obj.Illumination.S0); % negative sign, because it seems that this way the ellipse turns in the right direction, according to the rotation of the sample
                    val = s * 1i * sqrt(obj.IM(3).T).*exp(1i*obj.IM(3).Ph*obj.dphi0);
                    case 'z'
                        val = obj.IM(1).T*0;
                end
            end                
        end


    
        function val = getS(obj,num)
    
            arguments
                obj
                num {mustBeMember(num,[0,1,2,3])}
            end
            if num == 0  % 1st Stokes component
                switch obj.calcSjMode
                    case 'Tj'
                        val = (obj.IM(1).T + obj.IM(3).T)/2;
                    case 'Ej'
                        val = (abs(obj.Ex).^2 + abs(obj.Ey).^2)/2;
                end
            elseif num == 1 % 2nd Stokes component
                switch obj.calcSjMode
                    case 'Tj'
                        val = (obj.IM(1).T - obj.IM(3).T)/2;
                    case 'Ej'
                        val = (abs(obj.Ex).^2 - abs(obj.Ey).^2)/2;
                end            
            elseif num == 2 % 3nd Stokes component
                switch obj.calcSjMode
                    case 'Tj'
                        val = (obj.IM(2).T - obj.IM(4).T)/2;
                    case 'Ej'
                        val = real(obj.Ex.*conj(obj.Ey));
                end
            elseif num == 3 % 4th Stokes component
                switch obj.calcSjMode
                    case 'Tj'
                        hel = -sign(obj.Illumination.S3);
                        val = hel*sqrt(obj.S0.^2-obj.S1.^2-obj.S2.^2);
                    case 'Ej'
                        val = -imag(obj.Ex.*conj(obj.Ey));
                end
            end

        end
    end

end
