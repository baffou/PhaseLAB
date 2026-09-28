%% PhaseLAB package
% Class that defines a dipole moment
%
% Dipole(radius,mat,[z]). By default, z=radius.
%  radius: radius of the dipolar, spherical particle
%  mat: material of the Dipole
% author: Guillaume Baffou
% affiliation: CNRS, Institut Fresnel
% date: Jul 31, 2019

classdef Dipole
    properties(SetAccess = private , GetAccess = public)
        mat             % material
        r               % radius of the dipolar nanosphere [m]
        n               % complex refractive index of the nanosphere material
        p               % electric dipolar moment
        E0
        EE0             % incoming E0 field at the dipole location
        EE              % local electric field experienced by the dipole
%    end
%    properties(Access = public)
        x = 0           % x position of the dipole [m]
        y = 0           % y position of the dipole [m]
        z = 0           % z position of the dipole [m]
        n_ext           % refractive index of the surroundings
    end

    properties(Dependent)
        eps
        epsTensor
        chiTensor
        alpha
        alphaTensor
        lambda          % free-space wavelength
        pos             % position vector [x,y,z]
        alphaMie        % Mie complex polarizability
        CextMie         % Mie extinction cross section
        CscaMie         % Mie scattering cross section
        CabsMie         % Mie absorption cross section
    end

    properties(Hidden)
        Illumination
    end

    properties(Access = {?Nanoparticle})
        eps0 = 8.8541878128e-12     % vacuum permittivity
        c = 299792458               % speed of light
        RotMat = [1 0 0 ; 0 1 0 ; 0 0 1]  % Rotation of the nanoparticle, and in particular of any anisotropic optical properties
        nHidden = []
        alphaHidden = []
    end
    
    methods

        function obj = Dipole(mat,radius,z)
            % Dipole('Au', radius, [z]). By default, z = radius.
            % Dipole(n, radius, [z])
            % Dipole(alpha, radius, [z])
            arguments
                mat = 'none'
                radius (1, 1) double = 0
                z (1, 1) double = 0
            end
            if nargin~=0

                obj.r = radius;

                if ischar(mat) % 'Au', 'BK7', ...
                    obj.mat = mat;
                elseif isnumeric(mat) % permittivity or polarizability
                    if abs(mat)>1e-6 % specify an epsilon value
                        %disp('The code understands that you specify directly the refractive index value instead of the material')
                        obj.nHidden = mat;
                        obj.mat = 'user defined - refractive index';
                    else
                        %disp('The code understands that you specify directly the polarisability value instead of the material')
                        obj.alphaHidden = mat;
                        obj.mat = 'user defined - polarisability';
                    end
                end

                if nargin==2
                    obj.z = radius;
                elseif nargin==3
                    obj.z = z;
                end
            end
        end

        function obj = shine(obj,IL)
            % Runs de DDA simulation and returns the Nanoparticle object, updated with the P, EE, EE0 fields. Works with an assembly of dipoles.
            if ~nargout
                warning('an output argument must be specified, otherwise the DI object won''t be modified.')
            end
%            obj = DDA(obj,IL);
            obj = DDA_aniso(obj,IL);
        end
        
        function obj = rotate(obj,thetad,opt)
            %obj.rotate(thetaDeg,axis,point)
            arguments
                obj
                thetad double
                opt.axis {mustBeMember(opt.axis,["x","y","z"])} = "z"
                opt.center = []
            end

            if thetad*1000 ~= round(thetad*1000)
                warning('The rotation angle input must be in degrees, not in radians. Are you sure it is?')
            end

            if isempty(opt.center)
                opt.center = 0;
                for ic = 1:numel(obj)
                    opt.center = opt.center + obj(ic).pos/numel(obj);
                end
            end
            
            switch char(opt.axis)
                case 'x'
                    R = ...
                    [1 0           0
                     0 cosd(thetad) -sind(thetad)
                     0 sind(thetad)  cosd(thetad)];
                case 'y'
                    R = ...
                    [cosd(thetad) 0 sind(thetad)
                     0          1 0
                    -sind(thetad) 0 cosd(thetad)];
                case 'z'
                    R = ...
                    [cosd(thetad) -sind(thetad) 0
                     sind(thetad)  cosd(thetad) 0
                     0           0          1];
            end
            obj = obj.moveBy(-opt.center);
            for ic = 1:numel(obj)
                obj(ic).pos = (R*obj(ic).pos(:)).';
                obj(ic).RotMat = R*obj(ic).RotMat;
            end
            obj = obj.moveBy(opt.center);

            % rotate the permittivity tensor of the unit cells as well
            % switch numel(obj.eps)
            %     case 3
            %         obj.epsHidden = RotMat.*[obj.eps(1) 0 0; 0 obj.eps(2) 0;0 0 obj.eps(3)];
            %     case 9
            %         obj.epsHidden = RotMat.*obj.eps;
            % end
        end
                
        function obj = moveTo(obj,varargin)
            No = numel(obj);
            for io = 1:No
                if nargin==2
                    if ~isnumeric(varargin{1})
                        error('the position must be a number')
                    end
                    if length(varargin{1})~=3
                        error('when specifying a single input of the moveTo function, it must be a 3-vector')
                    end
                    targetPos = varargin{1};
                    obj(io).x = targetPos(1);
                    obj(io).y = targetPos(2);
                    obj(io).z = targetPos(3);
                elseif nargin==4
                    if isnumeric(varargin{1}) && isnumeric(varargin{2}) && isnumeric(varargin{3})
                        obj(io).x = varargin{1};
                        obj(io).y = varargin{2};
                        obj(io).z = varargin{3};
                    else
                        error('error in the method ''moveTo'' of Dipole. Not a number.')
                    end
                elseif nargin==3 || nargin==5 || nargin==7 
                    for iv = 1:(nargin-1)/2
                        if ischar(varargin{2*iv-1})
                            if strcmp(varargin{2*iv-1},'x')
                                if isnumeric(varargin{2*iv})
                                    obj(io).x = varargin{2*iv};
                                else
                                    error('error in the method ''moveTo'' of Dipole. Not a number.')
                                end
                            elseif strcmp(varargin{2*iv-1},'y')
                                if isnumeric(varargin{2*iv})
                                    obj(io).y = varargin{2*iv};
                                else
                                    error('error in the method ''moveTo'' of Dipole. Not a number.')
                                end
                            elseif strcmp(varargin{2*iv-1},'z')
                                if isnumeric(varargin{2*iv})
                                    obj(io).z = varargin{2*iv};
                                else
                                    error('error in the method ''moveTo'' of Dipole. Not a number.')
                                end
                            end
                        else
                            error('error in the method ''moveTo'' of Dipole. Not a char.')
                        end
                    end
                end
                if ~all([obj(io).x obj(io).y obj(io).z]<0.01)
                    warning('Are you sure the positions are in [nm]?')
                end
            end
  
        end

        function obj = moveBy(obj,varargin)
            % obj2 = obj.moveBy([x, y, z]);  % moves the dipoles by 1 µm in the x direction
            % obj2 = obj.moveBy(x, y, z);  % moves the dipoles by 1 µm in the x direction
            % obj2 = obj.moveBy(Name, Value); % where Name is 'x', 'y', or 'z'

            No = numel(obj);
            for io = 1:No
                if nargin==2
                    if ~isnumeric(varargin{1})
                        error('the position must be a number')
                    end
                    if length(varargin{1})~=3
                        error('when specifying a single input of the moveTo function, it must be a 3-vector')
                    end
                    targetPos = varargin{1};
                    obj(io).x = obj(io).x+targetPos(1);
                    obj(io).y = obj(io).y+targetPos(2);
                    obj(io).z = obj(io).z+targetPos(3);
                elseif nargin==4
                    if isnumeric(varargin{1}) && isnumeric(varargin{2}) && isnumeric(varargin{3})
                        obj(io).x = obj(io).x+varargin{1};
                        obj(io).y = obj(io).y+varargin{2};
                        obj(io).z = obj(io).z+varargin{3};
                    else
                        error('error in the method ''moveTo'' of Dipole. Not a number.')
                    end
                elseif nargin==3 || nargin==5 || nargin==7 
                    for iv = 1:(nargin-1)/2
                        if ischar(varargin{2*iv-1})
                            if strcmp(varargin{2*iv-1},'x')
                                if isnumeric(varargin{2*iv})
                                    obj(io).x = obj(io).x+varargin{2*iv};
                                else
                                    error('error in the method ''moveTo'' of Dipole. Not a number.')
                                end
                            elseif strcmp(varargin{2*iv-1},'y')
                                if isnumeric(varargin{2*iv})
                                    obj(io).y = obj(io).y+varargin{2*iv};
                                else
                                    error('error in the method ''moveTo'' of Dipole. Not a number.')
                                end
                            elseif strcmp(varargin{2*iv-1},'z')
                                if isnumeric(varargin{2*iv})
                                    obj(io).z = obj(io).z+varargin{2*iv};
                                else
                                    error('error in the method ''moveTo'' of Dipole. Not a number.')
                                end
                            end
                        else
                            error('error in the method ''moveTo'' of Dipole. Not a string.')
                        end
                    end
                end
                if ~all([obj(io).x obj(io).y obj(io).z]<0.01)
                    warning('Are you sure the positions are in [m]?')
                end  
            end
        end

        function figure(obj)
            % obj.figure()
            % display the geometry of the dipole(s) system
            NDI = numel(obj);
            [xs,ys,zs] = sphere;
            hold on 
            posList = reshape([obj.pos],3,NDI).';
            for is = 1:NDI
                a = obj(is).r;
                surf((a*xs+posList(is,1))*1e6,(a*ys+posList(is,2))*1e6,(a*zs+posList(is,3))*1e6, 'FaceColor', [0.7 0.3 0.2], 'FaceAlpha',0.9,'EdgeAlpha', 0)
            end
            light
            axis equal
            ecart = max( max(5*[obj.r]) , 50e-9);
            [X, Y] = meshgrid(-ecart+min(min(posList(:,1))):1e-7:ecart+max(max(posList(:,1))) , -ecart+min(min(posList(:,2))):1e-7:ecart+max(max(posList(:,2))));
            Z = 0.*X + 0.*Y;
            surf(X*1e6,Y*1e6,Z*1e6,'FaceColor','w','EdgeColor','w');
            colormap(Pradeep)
            view(14,28)
            camproj('perspective')
            xlabel('µm');
            ylabel('µm');
            zlabel('µm');

% Ajout d'un titre 
        end

        function prop = MieTheory(DIlist)
            
            N = numel(DIlist); % number of dipoles
            
            Nn = length(DIlist(1).n);
            prop = repmat(NPprop(),N);
            
            for io = 1:N
                DI = DIlist(io);
                r0 = DI.r;

                alpha0 = zeros(Nn, 1);
                Cabs = zeros(Nn, 1);
                Cext = zeros(Nn, 1);
                Csca = zeros(Nn, 1);
                for ii = 1:Nn

                    n_DI = DI.n(ii);
                    m = n_DI/DI.n_ext;
                    k = 2*pi*DI.n_ext/DI.lambda;
                    x0 = k*r0;
                    z0 = m*x0;
                    N = round(2+x0+4*x0.^(1/3));
                
                    % computation
                
                    j = (1:N);
                
                    sqr = sqrt(pi*x0/2);
                    sqrm = sqrt(pi*z0/2);
                
                    phi = sqr.*besselj(j+0.5,x0);
                    xi = sqr.*(besselj(j+0.5,x0)+1i*bessely(j+0.5,x0));
                    phim = sqrm.*besselj(j+0.5,z0);
                
                    phi1 = [sin(x0), phi(1:N-1)];
                
                    phi1m = [sin(z0), phim(1:N-1)];
                    y0 = sqr*bessely(j+0.5,x0);
                
                    y1 = [-cos(x0), y0(1:N-1)];
                
                    phip = (phi1-j/x0.*phi);
                    phimp = (phi1m-j/z0.*phim);
                    xip = (phi1+1i*y1)-j/x0.*(phi+1i*y0);
                
                    aj = (m*phim.*phip-phi.*phimp)./(m*phim.*xip-xi.*phimp);
                    bj = (phim.*phip-m*phi.*phimp)./(phim.*xip-m*xi.*phimp);
                
                    Csca(ii) = sum( (2*j+1).*(abs(aj).*abs(aj)+abs(bj).*abs(bj)) );
                    Cext(ii) = sum( (2*j+1).*real(aj+bj) );    
                
                    Cext(ii) = Cext(ii)*2*pi/(k*k);
                    Csca(ii) = Csca(ii)*2*pi/(k*k);
                    Cabs(ii) = Cext(ii)-Csca(ii);
                
                    alpha0(ii) = 1i*6*pi*DI.n_ext*DI.n_ext*aj(1)/(k*k*k);
                

                end
                prop(io) = NPprop(alpha0,sum(Cext),sum(Csca),sum(Cabs));
            
            end

        end
        
        function objs = plus(obj1,obj2)
            if ~isempty(obj1(1).Illumination) && ~isempty(obj2(1).Illumination)
                if obj1(1).Illumination ~=obj2(1).Illumination
                    error('You are trying to sum two images corresponding to two different wavelengths.')
                end
            end
            if obj1(1).n_ext~=obj2(1).n_ext
                error('You are trying to sum two images corresponding to two different surrounding media.')
            end
            N1 = length(obj1);
            N2 = length(obj2);
            DI0 = Dipole();
            objs = repmat(DI0,1,N1+N2);
            objs(1:N1) = obj1;
            objs(N1+1:N1+N2) = obj2;
        end
        

        % set / get methods

        function val = get.n(obj)
            % returns the refractive index tensor (diagonal)
            if ~isempty(obj.nHidden)
                val = obj.nHidden;
            else
                val = indexRead(obj.mat,obj.lambda);   % dielectric function of the nanoparticle 
            end

            if numel(val) == 1
                val = [val , val, val];
            end
        end
        
        function val = get.alphaMie(obj)
            prop = MieTheory(obj);
            val = prop.alpha;
        end

        function val = get.alpha(obj)
            if isempty(obj.alphaHidden)
                val = obj.alphaMie;
            else
                val = obj.alphaHidden;
            end
        end

        function val = get.CextMie(obj)
            prop = MieTheory(obj);
            val = prop.Cext;
        end

        function val = get.CabsMie(obj)
            prop = MieTheory(obj);
            val = prop.Cabs;
        end

        function val = get.CscaMie(obj)
            prop = MieTheory(obj);
            val = prop.Csca;
        end

        function val = get.chiTensor(obj) 
            if length(obj.eps) == 1
                tens = [obj.eps-obj.n_ext^2 0 0
                        0 obj.eps-obj.n_ext^2 0
                        0 0 obj.eps-obj.n_ext^2];
            elseif length(obj.eps) == 3
                tens = [obj.eps(1)-obj.n_ext^2 0 0
                        0 obj.eps(2)-obj.n_ext^2 0
                        0 0 obj.eps(3)-obj.n_ext^2];
            end
            val = obj.RotMat*tens*transpose(obj.RotMat);
        end

        function val = get.alphaTensor(obj) 
            if numel(obj.alpha) == 1
                tens = [obj.alpha 0 0
                        0 obj.alpha 0
                        0 0 obj.alpha];
            elseif numel(obj.alpha) == 3
                tens = [obj.alpha(1) 0 0
                        0 obj.alpha(2) 0
                        0 0 obj.alpha(3)];
            elseif numel(obj.alpha) == 9
                tens = obj.alpha;
            end
            val = transpose(obj.RotMat)*tens*obj.RotMat;
        end

        function val = get.eps(obj)
            val = obj.n.^2;
        end

        function val = get.epsTensor(obj)
            if length(obj.eps) == 1
                tens = [obj.eps 0 0
                        0 obj.eps 0
                        0 0 obj.eps];
            elseif length(obj.eps) == 3
                tens = [obj.eps(1) 0 0
                        0 obj.eps(2) 0
                        0 0 obj.eps(3)];
            end
            val = obj.RotMat*tens*transpose(obj.RotMat);
        end

        function val = get.pos(obj)
            val = [obj.x,obj.y,obj.z];
        end

        function obj = set.pos(obj,val)
            obj.x = val(1);
            obj.y = val(2);
            obj.z = val(3);
        end

        function val = get.lambda(obj)
            val = obj.Illumination.lambda;
        end

        function val = getpos(objList)
            val = zeros(numel(objList),3);
            for io = 1:numel(objList)
                val(io,:) = [objList(io).x,objList(io).y,objList(io).z];
            end
        end

        function obj = setp(obj,p)
            % Sets the dipole moment p
            arguments
                obj
                p (:,3) double
            end

            if ~isnumeric(p)
                error('p must be a number')
            elseif size(p,2)~=3
                error('p must be an Nx3 array')
            end

            if size(p,1) ~= numel(obj)
                error('The number of positions must equal the number of dipoles')
            end

            for ip = 1:numel(obj)
                obj(ip).p = p(ip,:);   % dipole moment of the nanoparticle 
            end
        end

        function obj = setEE(obj,val)
            % Sets the EE field
            arguments
                obj
                val (:,3) double
            end

            if ~isnumeric(val)
                error('EE must be a number')
            elseif size(val,2)~=3
                error('EE must be an Nx3 array')
            end

            if size(val,1) ~= numel(obj)
                error('The number of positions must equal the number of dipoles')
            end

            for ip = 1:numel(obj)
                obj(ip).EE = val(ip,:);
            end
        end

        function obj = setEE0(obj,val)
            % Sets the EE0 field
            arguments
                obj
                val (:,3) double
            end

            if size(val,1) ~= numel(obj)
                error('The number of positions must equal the number of dipoles')
            end

            for ip = 1:numel(obj)
                obj(ip).EE0 = val(ip,:);
            end
        end

        function obj = setE0(obj,val)
            % Sets the E0 value
            arguments
                obj
                val (1,3) double
            end

            for ip = 1:numel(obj)
                obj(ip).E0 = val;
            end
        end

        function obj = set.Illumination(obj,val)
            if ~isa(val,'Illumination') % val is the wavelength
                obj.Illumination = Illumination(val);
            end
            obj.Illumination = val;
        end
        
        function val = matList(obj)
            % returns the list of available material
            matList = dir([obj(1).DIpath '/../materials/*.txt']);
            Nc = numel(matList);
            if nargout
                val = cell(Nc,1);
                for ic = 1:Nc
                    val{ic} = matList(ic).name(2:end-4);
                end
            else
                for ic = 1:Nc
                    disp(" "+matList(ic).name(2:end-4))
                end
            end                
        end    
        
    end
    
    
    methods(Static,Hidden)

        function val = DIpath()
            val = fileparts(which('Dipole.m'));
        end
        
        
        
    end
    
 
end