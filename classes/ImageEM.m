%% NPimaging package
% Class that defines an electromagnetic image

% author: Guillaume Baffou
% affiliation: CNRS, Institut Fresnel
% date: Jul 31, 2019

classdef ImageEM  <  ImageMethods & matlab.mixin.Copyable

    properties(GetAccess = public , SetAccess={?ImageMethods})
        Ex
        Ey
        Ez
        Einc ImageEM
    end

    properties(Access = public)
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
        Ph0 % Ph image not normalized by the phase of the reference image
        OPD
        T
    end

    methods
        function obj = ImageEM(Ex,Ey,Ez,Eincx,Eincy,Eincz,opt)
            arguments
                Ex {mustBeNumeric} =[]
                Ey {mustBeNumeric} =[]
                Ez {mustBeNumeric} =[]
                Eincx {mustBeNumeric} =[]
                Eincy {mustBeNumeric} =[]
                Eincz {mustBeNumeric} =[]
                opt.n {mustBeNumeric} = []
                opt.Microscope Microscope = Microscope.empty()
                opt.Illumination Illumination = Illumination.empty()
            end
            %ImageEM()
            %ImageEM(n=n)
            %ImageEM(Eincx,Eincy,Eincz)
            %ImageEM(Ex,Ey,Ez,Einc||EE0)
            %ImageEM(Ex,Ey,Ez,Eincx,Eincy,Eincz)
            if nargin==0
                if ~isempty(opt.n) % ImageEM(n=N)
                    obj = repmat(ImageEM(),opt.n,1);
                else % ImageEM()     1 empty object
                    % do nothing
                end
            elseif nargin==1 % ImageEM(n)    n empty objects
                obj = repmat(ImageEM,Ex,0);
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
            objs.Einc.Ex = obj1.Einc.Ex + obj2.Einc.Ex;
            objs.Einc.Ey = obj1.Einc.Ey + obj2.Einc.Ey;
            objs.Einc.Ez = obj1.Einc.Ez + obj2.Einc.Ez;
        end

        function objs = sum(objList) % coherent sum of the fields
            objs = copy(objList(1));
            No = numel(objList);
            for io = 2:No
                objs = objs+objList(io);
            end
        end

        function T = sumT(objList) % coherent sum of the fields
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

            Ex_norm = abs(obj.Ex).^2;%enables the phase subtraction of E0x
            Ey_norm = abs(obj.Ey).^2;%enables the phase subtraction of E0y

            if isempty(obj.Einc) % if already an indicent field
                pha_x = angle(obj.Ex);% phase image of the x-polarized wavefront
                pha_y = angle(obj.Ey);% phase image of the y-polarized wavefront
            else
                pha_x = angle(obj.Ex.*conj(obj.Einc.Ex));% phase image of the x-polarized wavefront
                pha_y = angle(obj.Ey.*conj(obj.Einc.Ey));% phase image of the y-polarized wavefront
            end

            val0 = pha_x.*Ex_norm+pha_y.*Ey_norm;% weighted average of the phase images
            val = val0./(Ex_norm+Ey_norm);
        end

        function val = get.Ph0(obj)

            Ex_norm = abs(obj.Ex).^2;%enables the phase subtraction of E0x
            Ey_norm = abs(obj.Ey).^2;%enables the phase subtraction of E0y
            tic
            pha_x = angle(obj.Ex);% phase image of the x-polarized wavefront
            pha_y = angle(obj.Ey);% phase image of the y-polarized wavefront
            toc
            % ERREUR : cette formule est fausse si on illumine avec un
            % angle. Q: que mesure-t-on en QLSI alors ???
            val0 = pha_x.*Ex_norm+pha_y.*Ey_norm;% weighted average of the phase images
            
            val = val0./(Ex_norm+Ey_norm);
        end

        function val = get.OPD(obj)
            k0 = 2*pi/obj.lambda;
            val = obj.Ph/k0; % Optical path difference
        end

        function val = get.T(obj)
            if norm(obj.EE0)==0 % happens when using crossed polarizers that kill E0 on the image plane.
                nor = 1;
            else
                nor = obj.EE0n();
            end
            norExtot = obj.Ex/nor;
            norEytot = obj.Ey/nor;
            norEztot = obj.Ez/nor;
            val = abs(norExtot).^2+abs(norEytot).^2+abs(norEztot).^2; % Transmittance
        end

        function val = zoom(obj)
            val=obj.Microscope.CGcam.zoom;
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

        function [IMs,mat] = Jones(IM,varargin)
            Nvar = numel(varargin);
            if mod(Nvar,2)
                error('Must have an even number of inputs')
            end

            % Quarter waveplate
            QWP = [1 0;0 1i];
            % Half waveplate
            HWP = [1 0;0 -1];
            % Polarizer
            P = [1 0;0 0];
            % Rotation matrix
            R = @(theta) [cosd(theta) -sind(theta);sind(theta) cosd(theta)];


            mat = eye(2,2);
            for ii = 1:2:Nvar
                if ~ischar(varargin{ii})
                    error('this input must be text: ''P'', ''QWP'' or ''HWP''')
                elseif ~isnumeric(varargin{ii+1})
                    error('this inpust must be a number')
                end
                switch varargin{ii}
                    case 'P'
                        mat = R(varargin{ii+1})*P*R(-varargin{ii+1})*mat;
                    case 'QWP'
                        mat = R(varargin{ii+1})*QWP*R(-varargin{ii+1})*mat;
                    case 'HWP'
                        mat = R(varargin{ii+1})*HWP*R(-varargin{ii+1})*mat;
                end
            end
            IMs = Jones0(IM,mat);

        end

        function IMs = Jones0(IM,mat)
            IMs = IM;
            Nim = numel(IM);
            for iim = 1:Nim
                E_x = IM(iim).Ex*mat(1,1)+IM(iim).Ey*mat(1,2);
                E_y = IM(iim).Ex*mat(2,1)+IM(iim).Ey*mat(2,2);
                E0 = IM(iim).EE0;
                E0(1) = IM(iim).EE0(1)*mat(1,1)+IM(iim).EE0(2)*mat(1,2);
                E0(2) = IM(iim).EE0(1)*mat(2,1)+IM(iim).EE0(2)*mat(2,2);

                IMs(iim) = IM(iim);
                IMs(iim).EE0 = E0;
                IMs(iim).Ex = E_x;
                IMs(iim).Ey = E_y;
                IMs(iim).Ez = IM.Ez*0;  % any wave plate is assumed to kill the polarization along z. It is not important anymway in any case.
            end
        end

        function objList = Escat(objList0)
            if nargout
                objList=copy(objList0);
            else
                objList=objList0;
            end
            No=numel(objList0);
            for io=1:No
                objList(io).Ex = objList0(io).Ex-objList0(io).Einc.Ex;
                objList(io).Ey = objList0(io).Ey-objList0(io).Einc.Ey;
                objList(io).Ez = objList0(io).Ez-objList0(io).Einc.Ez;
            end
        end

        function val = EE0(obj)
            % complex vectorial incident field at the center of the image
            if isempty(obj.Einc) % if the object if already an incident field
                valx=obj.Ex(end/2,end/2);
                valy=obj.Ey(end/2,end/2);
                valz=obj.Ez(end/2,end/2);
                val = [valx, valy, valz];
            else % take the EE0 of the Einc
                val = obj.Einc.EE0;
            end
        end

        function val = EE0n(obj)
            % norm of the incident field
            if isempty(obj.Einc) % if the object if already an incident field
                val=mean(mean(sqrt(abs(obj.Ex).^2+abs(obj.Ey).^2+abs(obj.Ez).^2)));
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

        function objList = applyPhaseShift(objList0,phi)
            % applies of phase shift to all the components of a field, but
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





    end

end
