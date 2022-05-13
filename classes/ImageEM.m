%% NPimaging package
% Class that defines an electromagnetic image

% author: Guillaume Baffou
% affiliation: CNRS, Institut Fresnel
% date: Jul 31, 2019

classdef ImageEM  <  ImageMethods
    
    properties(GetAccess=public , SetAccess=private)
        EE0   (1,3) {mustBeNumeric}   % Excitation vector field at the image plane (may be complex if zo~=0)
        Ex
        Ey
        Ez
    end
    
    properties(Access=public)
        %lambda, inherited from ImageMethods
        %pxSize, inherited from ImageMethods
        %dxSize, inherited from ImageMethods
        zoom
        %Microscope, inherited from ImageMethods
    end
    
    properties(Dependent)
        Ph      %Phase
        T       %Transmittance
        OPD
        E
        E2
        Nx
        Ny
        Npx
    end
    
    methods
        function obj=ImageEM(EE0,Ex,Ey,Ez)
            %ImageEM()
            %ImageEM(n)
            %ImageEM(E0,Ex,Ey,Ez)
            if nargin==1
                obj=repmat(ImageEM(),EE0,1);
            elseif nargin==4
                obj.EE0=EE0;
                obj.Ex=Ex;
                obj.Ey=Ey;
                obj.Ez=Ez;
            elseif nargin==0
            else
                error('Wrong number of inputs in the Image constructor.')
            end
        end
        
        function objs=plus(obj1,obj2)
            warning('By summing images of different particles/dipoles, there is no self-consistent optical coupling between these objects. Prefer summing dipoles and then imaging the dipole array, which will run a DDA self consistent calculation of the dipolar moments.')
            if obj1.lambda~=obj2.lambda
                error('You are trying to sum two images corresponding to two different wavelengths.')
            elseif obj1.pxSize~=obj2.pxSize
                error('You are trying to sum two images corresponding to two different pixel sizes.')
            elseif obj1.EE0~=obj2.EE0
                error('You are trying to sum two images corresponding to two different pixel sizes.')
            elseif obj1.zoom~=obj2.zoom
                error('You are trying to sum two images corresponding to two different sizes of field of view (''zoom'' properties differ).')
            elseif obj1.Npx~=obj2.Npx
                error('You are trying to sum two images with different pixel numbers.')
            end
            objs = obj1;
            objs.Ex = obj1.Ex + obj2.Ex - obj1.EE0(1);
            objs.Ey = obj1.Ey + obj2.Ey - obj1.EE0(2);
            objs.Ez = obj1.Ez + obj2.Ez - obj1.EE0(3);
        end
        
        function objs=sum(objList)
            objs=objList(1);
            No=numel(objList);
            for io=2:No
                objs=objs+objList(io);
            end
        end
        
        function val=get.Npx(obj) % the images of the class ImageEM are supposed to be squared anyway: Npx=Nx=Ny
            val = size(obj.Ex)*[1;0];
        end
    
        function val=get.Nx(obj)
            val = size(obj.Ex)*[1;0];
        end
    
        function val=get.Ny(obj)
            val = size(obj.Ex)*[0;1];
        end
    
        function val=get.E2(obj)
            val = abs(obj.Ex).^2+abs(obj.Ey).^2+abs(obj.Ez).^2;
        end
    
        function val=get.E(obj)
            val = sqrt(abs(obj.Ex).^2+abs(obj.Ey).^2+abs(obj.Ez).^2);
        end
    
        function val=get.Ph(obj)
            nor=norm(obj.EE0);
            if nor==0
                nor=[1/sqrt(2) 1/sqrt(2)];
            else
                nor=obj.EE0;
            end
            %v6.0:
            %polar=obj.EE0'/norm(obj.EE0);
            %E_along_polar=obj.Ex*polar(1)+obj.Ey*polar(2)+obj.Ez*polar(3);
            %val = angle(E_along_polar/norm(obj.EE0)); % phase
            %%val = angle(obj.Ex*obj.EE0'/norm(obj.EE0)^2); % phase
            % These expressions only work for scalar polarizabilities:
            Ex_norm=obj.Ex*nor(1)';%enables the phase subtraction of E0x
            Ey_norm=obj.Ey*nor(2)';%enables the phase subtraction of E0y
            
            pha_x = angle(Ex_norm);% phase image of the x-polarized wavefront
            pha_y = angle(Ey_norm);% phase image of the y-polarized wavefront
            
            polar=nor'/norm(nor);
            val=pha_x*abs(polar(1))^2+pha_y*abs(polar(2))^2;% weighted average of the phase images
            
        end
    
        function val=get.OPD(obj)
            k0=2*pi/obj.lambda;
            val = obj.Ph/k0; % Optical path difference
        end

        function val=get.T(obj)
            if norm(obj.EE0)==0 % happens when using crossed polarizers that kill E0 on the image plane.
                nor=1;
            else
                nor=norm(obj.EE0);
            end
            norExtot = obj.Ex/nor;
            norEytot = obj.Ey/nor;
            norEztot = obj.Ez/nor;
            val = abs(norExtot).^2+abs(norEytot).^2+abs(norEztot).^2; % Transmittance
        end
        
        function obj=crop(obj0,Npx0)
            % crop an image to get a Npx0 x Npx0 image
            x1=(obj0(1).Npx-Npx0)/2+1;
            x2=x1+Npx0-1;
            obj=obj0;
            for ii=1: numel(obj0)
                obj(ii).EE0=obj0(ii).EE0;
                obj(ii).Ex=obj0(ii).Ex(x1:x2,x1:x2);
                obj(ii).Ey=obj0(ii).Ey(x1:x2,x1:x2);
                obj(ii).Ez=obj0(ii).Ez(x1:x2,x1:x2);
            end
        end
        
        function val=integral(obj)
            Nim=length(obj);
            val=zeros(Nim,1);
            for iim=1:Nim
                sqrT = sqrt(obj(iim).T);
                expPh = exp(1i*obj(iim).Ph);
                %alphaS = 1i*2*n/(k0*(1+r12*exp(-2*1i*Medium.n*k0*z0)))*(1-sqtT.*expPh);
                alphaS = sqrT.*expPh;
                val(iim) = sum(alphaS(:))*obj(iim).pxSize*obj(iim).pxSize;
            end

        end
        
        function val=crossSections(obj)

            Nim=length(obj);
            val=repmat(NPprop(),Nim,1);
            for iim=1:Nim
                al=obj(iim).alpha();
                n=obj(iim).Microscope.n;% n or nS?
                k0=2*pi/obj(iim).lambda;
                Cext=k0/n*imag(al);
                Csca=k0^4/(6*pi)*abs(al)^2;
                Cabs=Cext-Csca;
                val(iim)=NPprop(al,Cext,Csca,Cabs);
            end
        end
        
        function [IMs,mat]=Jones(IM,varargin)
            Nvar=numel(varargin);
            if mod(Nvar,2)
                error('Must have an even number of inputs')
            end
            
            % Quarter waveplate
                QWP=[1 0;0 1i];
            % Half waveplate
                HWP=[1 0;0 -1];
            % Polarizer
                P=[1 0;0 0];
            % Rotation matrix
                R = @(theta) [cosd(theta) -sind(theta);sind(theta) cosd(theta)];
 
            
            mat=eye(2,2);
            for ii=1:2:Nvar
                if ~ischar(varargin{ii})
                    error('this input must be text: ''P'', ''QWP'' or ''HWP''')
                elseif ~isnumeric(varargin{ii+1})
                    error('this inpust must be a number')
                end
                switch varargin{ii}
                    case 'P'
                        mat=R(varargin{ii+1})*P*R(-varargin{ii+1})*mat;
                    case 'QWP'
                        mat=R(varargin{ii+1})*QWP*R(-varargin{ii+1})*mat;
                    case 'HWP'
                        mat=R(varargin{ii+1})*HWP*R(-varargin{ii+1})*mat;
                end
            end
            IMs=Jones0(IM,mat);
            
        end
        
        function IMs=Jones0(IM,mat)
            IMs=IM;
            Nim=numel(IM);
            for iim=1:Nim
                E_x=IM(iim).Ex*mat(1,1)+IM(iim).Ey*mat(1,2);            
                E_y=IM(iim).Ex*mat(2,1)+IM(iim).Ey*mat(2,2);            
                E0=IM(iim).EE0;
                E0(1)=IM(iim).EE0(1)*mat(1,1)+IM(iim).EE0(2)*mat(1,2);
                E0(2)=IM(iim).EE0(1)*mat(2,1)+IM(iim).EE0(2)*mat(2,2);
                        
                IMs(iim)=IM(iim);
                IMs(iim).EE0=E0;
                IMs(iim).Ex=E_x;
                IMs(iim).Ey=E_y;
                IMs(iim).Ez=IM.Ez*0;  % any wave plate is assumed to kill the polarization along z. It is not important anymway in any case.
            end
        end
        
        function obj=Escat(obj) 
            obj.Ex=obj.Ex-obj.EE0(1);
            obj.Ey=obj.Ey-obj.EE0(2);
            obj.Ez=obj.Ez-obj.EE0(3);
            obj.EE0=[0 0 0];
        end

    end
    
end
