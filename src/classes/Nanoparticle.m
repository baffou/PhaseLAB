%% NPimaging package
% Class that defines a meshed nanoparticle for DDA simulations

% author: Guillaume Baffou
% affiliation: CNRS, Institut Fresnel
% date: Jul 31, 2019

classdef Nanoparticle

    properties(Access = public)
        DIs         % Array of Dipole objects
        geom        % geometry type of the nanoparticle
        params      % parameters of the geometry
        V           % volume of the nanoparticle
        a           % lattice parameter
    end

    properties(Dependent)
        pos     % (Nx3) array of the positions of the cells
        E0      % Incident polarization vector amplitude
        EE0     % incoming E0 field at the dipole location
        EE      % Local E field in each cell
        p       % polarization vector of each cell

        mat         % material of the nanoparticle
        n_ext       % complex refractive index of the surroundings
        N           % number of Dipoles

        lambda      % free-space wavelength of illumination
        n           % complex refractive index of the nanoparticle material
        eps         % permittivity of the nanoparticle material
        epsTensor   % permittivity tensor of the nanoparticle material
        alpha       % complex polarizability calculated by DDA
        Cext        % Extinction cross section
        Csca        % Scattering cross section, defined form a formula
        Csca2       % Scattering cross section, defined from ext-abs
        Csca0       % Scattering cross section, defined from p^2
        Cabs        % Absorption cross section, defined from ext-sca
        Cabs2       % Absorption cross section, defined from a formula
    end

    properties(Hidden,Dependent)
        Illumination
    end
    
    properties(Access = private, Dependent)
        eps0
        c0
        RotMat
    end
    
    methods
        function obj = Nanoparticle(mat,varargin)

            if nargin>1
                if ischar(varargin{1})
                    obj.geom = varargin{1};
                else
                    error('The geometry specification must be a string.')
                end
                if strcmp(obj.geom,'sphere')
                    if nargin==2
                        error('The sphere radius must be defined as a 3rd input')
                    end
                    if varargin{2}>1
                        warning('The radius you specified does not look to be in m, rather in nm. Make sure this is what you want.')
                    end
                    obj.params(1) = varargin{2}; % Rsphere
                    obj.V = 4*pi/3*varargin{2}^3;
                    if nargin==3 % no mesh_parameter specified
                        a = obj.params(1)/4;
                        pos = spher(obj.params(1),a);
                    elseif nargin==4
                        a = varargin{3}; % Lattice parameter of the meshing.
                        pos = spher(obj.params(1),a);
                    elseif nargin==5
                        a = varargin{3}; % Lattice parameter of the meshing.
                        pos = spher(obj.params(1),a,varargin{4});
                    else                        
                        error('Not the proper number of arguments for a sphere.')
                    end
                    a_adjusted = (4*pi/3/size(pos,1))^(1/3)*obj.params(1);
                    pos = pos*a_adjusted/a;
                    a = a_adjusted;
                elseif strcmp(obj.geom,'ellipsoid')
                    if nargin==2
                        error('The sphere radius must be defined as a 3rd input')
                    end
                    if length(varargin{2})~=3
                        error('A ellipsoid demands a parameter that is a 3-vector')
                    end
                    obj.params(1) = varargin{2}(1); % Rsphere
                    obj.params(2) = varargin{2}(2); % Rsphere
                    obj.params(3) = varargin{2}(3); % Rsphere
                    obj.V = 4*pi/3*obj.params(1)*obj.params(2)*obj.params(3);
                    if nargin==3
                        a = obj.params(1)/4;
                        pos = ellipsoid(obj.params,a);
                    elseif nargin==4
                        a = varargin{3}; % Lattice parameter of the meshing.
                        pos = ellipsoid(obj.params,a);
                    elseif nargin==5
                        a = varargin{3}; % Lattice parameter of the meshing.
                        pos = ellipsoid(obj.params,a,varargin{4});
                    else                        
                        error('Not the proper number of arguments for a sphere.')
                    end
                    a_adjusted = (4*pi/3/size(pos,1))^(1/3)*obj.params(1);
                    pos = pos*a_adjusted/a;
                    a = a_adjusted;
                elseif  strcmp(obj.geom,'cube')
                    obj.params = varargin{2}; % Side length of the cube
                    if nargin==3
                        a = obj.params/4;
                        pos = cube(obj.params,a);
                    elseif nargin==4
                        a = varargin{3};
                        pos = cube(obj.params,a);
                    elseif nargin==5
                        a = varargin{3};
                        pos = cube(obj.params,a,varargin{4});
                    else
                        error('Not the proper number of arguments for a cube.')
                    end
                    obj.V = obj.params^3;
                elseif  strcmp(obj.geom,'cuboid')
                    obj.params(1) = varargin{2}(1); % x Side length
                    obj.params(2) = varargin{2}(2); % y Side length
                    obj.params(3) = varargin{2}(3); % z Side length
                    if nargin==3
                        a = min(obj.params)/4;
                        pos = cuboid(obj.params,a);
                    elseif nargin==4
                        a = varargin{3};
                        pos = cuboid(obj.params,a);
                    elseif nargin==5
                        a = varargin{3};
                        pos = cuboid(obj.params,a,varargin{4});
                    else
                        error('Not the proper number of arguments for a cube.')
                    end
                    obj.V = obj.params(1)*obj.params(2)*obj.params(3);
                elseif  strcmp(obj.geom,'cylinder')
                    obj.params(1) = varargin{2}(1); % diameter in px
                    obj.params(2) = varargin{2}(2); % thickness in px
                    if nargin==3
                        a = min(obj.params)/4;
                        pos = cylinder(obj.params,a);
                    elseif nargin==4
                        a = varargin{3};
                        pos = cylinder(obj.params,a);
                    elseif nargin==5
                        a = varargin{3};
                        pos = cylinder(obj.params,a,varargin{4});
                    else
                        error('Not the proper number of arguments for a cube.')
                    end
                    obj.V = pi*(obj.params(1))^2*obj.params(2);
                elseif  strcmp(obj.geom,'rod')
                    obj.params(1) = varargin{2}(1); % Total longitudinal length of the rod (along x)
                    obj.params(2) = varargin{2}(2); % transverse radius
                    L0 = obj.params(1);
                    r0 = obj.params(2);
                    a = varargin{3}; % Lattice parameter of the meshing.
                    if nargin==3
                        a = min(obj.params)/4; %No lattice param specified
                        pos = rod(obj.params,a);
                    elseif nargin==4
                        pos = rod(obj.params,a);
                    elseif nargin==5
                        pos = rod(obj.params,a,varargin{4});
                    else
                        error('Not the proper number of arguments for a cube.')
                    end                
                    obj.V = 4/3*pi*r0^3+pi*r0^2*(L0-2*r0);
                else
                    error(['The geometry ''' varargin{1} ''' is not known.'])
                end
                obj.DIs = repmat(Dipole(mat,a/2),size(pos,1),1);
                for ip = 1:obj.N
                    obj.DIs(ip).pos = pos(ip,:);
                end
                obj.a = a;
                fprintf(['Meshing with ' num2str(size(pos,1)) ' cells.\n'])
            end

        end

        function val = get.pos(obj)
            val = zeros(obj.N,3);
            for ip = 1:obj.N
                val(ip,:) = obj.DIs(ip).pos;
            end
        end

        function val = get.mat(obj)
            val = obj.DIs(1).mat;
        end

        function val = get.N(obj)
            val = numel(obj.DIs);
        end

        function val = get.eps(obj)
            val = obj.DIs(1).eps;
        end

        function val = get.EE(obj)
            if ~isempty(obj.DIs(1).EE)
                val = zeros(obj.N,3);
                for ip = 1:obj.N
                    val(ip,:) = obj.DIs(ip).EE;
                end
            else
                val = [];
            end
        end

        function val = get.EE0(obj)
            if ~isempty(obj.DIs(1).EE0)
                val = zeros(obj.N,3);
                for ip = 1:obj.N
                    val(ip,:) = obj.DIs(ip).EE0;
                end
            else
                val = [];
            end
        end

        function val = get.E0(obj)
            val = obj.DIs(1).E0;
        end

        function val = get.p(obj)
            val = zeros(obj.N,3);
            for ip = 1:obj.N
                val(ip,:) = obj.DIs(ip).p;
            end
        end

        function val = get.eps0(obj)
            val = obj.DIs(1).eps0;
        end

        function val = get.c0(obj)
            val = obj.DIs(1).c0;
        end

        function val = get.RotMat(obj)
            val = obj.DIs(1).RotMat;
        end


        
        function obj = shine(obj,IL)
            % Runs de DDA simulation and returns the Nanoparticle object updated with the P, EE, EE0 fields.
            obj = GDT(obj,IL);
            %obj = DDA(obj,IL)
        end

        function obj = moveTo(obj,varargin)
            %moveTo([x0,y0,z0])
            %moveTo(x0,y0,z0)
            %moveTo('x',val)
            %moveTo('y',val)
            %moveTo('z',val)
            %moveTo('x',x0,'y',y0)
            %etc
            if nargin==2
                if ~isnumeric(varargin{1})
                    error('the position must be a number')
                end
                if length(varargin{1})~=3
                    error('when specifying a single input of the moveTo function, it must be a 3-vector')
                end
                targetPos = varargin{1};
                obj = obj.moveTo('x',targetPos(1),'y',targetPos(2),'z',targetPos(3));
            elseif nargin==4
                if isnumeric(varargin{1}) && isnumeric(varargin{2}) && isnumeric(varargin{3})
                    obj = obj.moveTo('x',varargin{1},'y',varargin{2},'z',varargin{3});
                else
                    error('error in the method ''move'' of Nanoparticle. Not a number.')
                end
            elseif nargin==3 || nargin==5 || nargin==7 
                M = obj.meanPos;
                for iv = 1:(nargin-1)/2
                    if ischar(varargin{2*iv-1})
                        if strcmp(varargin{2*iv-1},'x')
                            if isnumeric(varargin{2*iv})
                                for id = 1:obj.N
                                    dx = varargin{2*iv}-M(1);
                                    obj.pos(id,1) = obj.pos(id,1)+dx;
                                end
                            else
                                error('error in the method ''moveTo'' of Nanoparticle. Not a number.')
                            end
                        elseif strcmp(varargin{2*iv-1},'y')
                            if isnumeric(varargin{2*iv})
                                for id = 1:obj.N
                                    dy = varargin{2*iv}-M(2);
                                    obj.pos(id,2) = obj.pos(id,2)+dy;
                                end
                            else
                                error('error in the method ''move'' of Dipole. Not a number.')
                            end
                        elseif strcmp(varargin{2*iv-1},'z')
                            if isnumeric(varargin{2*iv})
                                for id = 1:obj.N
                                    dz = varargin{2*iv}-M(3);
                                    obj.pos(id,3) = obj.pos(id,3)+dz;
                                end
                            else
                                error('error in the method ''move'' of Dipole. Not a number.')
                            end
                        end
                    else
                        error('error in the method ''move'' of Dipole. Not a string.')
                    end
                end
            end
        end

        function obj = rotate(obj,theta,opt)
            %obj.rotate(theta,axis,point)
            arguments
                obj
                theta double
                opt.axis {mustBeMember(opt.axis,["x","y","z"])} = "z"
                opt.center = obj.meanPos
            end

            if theta*1000~=round(theta*1000)
                warning('The rotation angle input must be in degrees, not in radians. Are you sure it is?')
            end
            
            switch char(opt.axis)
                case 'x'
                    rotMat = ...
                    [1 0           0
                     0 cosd(theta) -sind(theta)
                     0 sind(theta)  cosd(theta)];
                case 'y'
                    rotMat = ...
                    [cosd(theta) 0 sind(theta)
                     0          1 0
                    -sind(theta) 0 cosd(theta)];
                case 'z'
                    rotMat = ...
                    [cosd(theta) -sind(theta) 0
                     sind(theta)  cosd(theta) 0
                     0           0          1];
            end
            obj = obj.moveBy(-opt.center);
            for ip = 1:obj.N
                obj.DIs(ip).pos = (rotMat*obj.pos(ip,:).').';
                obj.DIs(ip).RotMat = obj.DIs(ip).RotMat*rotMat;
            end
            obj = obj.moveBy(opt.center);

            % rotate the permittivity tensor of the unit cells as well
            % switch numel(obj.eps)
            %     case 3
            %         obj.epsHidden = rotMat.*[obj.eps(1) 0 0; 0 obj.eps(2) 0;0 0 obj.eps(3)];
            %     case 9
            %         obj.epsHidden = rotMat.*obj.eps;
            % end
        end
        
        function obj = moveBy(obj,varargin)
            %moveBy(dx,dy,dz)
            %moveBy('x',val)
            %moveBy('y',val)
            %moveBy('z',val)
            %moveBy('x',dx,'y',dy)
            %etc
            if nargin==4
                if isnumeric(varargin{1}) && isnumeric(varargin{2}) && isnumeric(varargin{3})
                    obj = obj.moveBy('x',varargin{1},'y',varargin{2},'z',varargin{3});
                else
                    error('error in the method ''move'' of Nanoparticle. Not a number.')
                end
            elseif nargin==3 || nargin==5 || nargin==7 
                for iv = 1:(nargin-1)/2
                    if ischar(varargin{2*iv-1})
                        if strcmp(varargin{2*iv-1},'x')
                            if isnumeric(varargin{2*iv})
                                for id = 1:obj.N
                                    obj.pos(id,1) = obj.pos(id,1)+varargin{2*iv};
                                end
                            else
                                error('error in the method ''move'' of Dipole. Not a number.')
                            end
                        elseif strcmp(varargin{2*iv-1},'y')
                            if isnumeric(varargin{2*iv})
                                for id = 1:obj.N
                                    obj.pos(id,2) = obj.pos(id,2)+varargin{2*iv};
                                end
                            else
                                error('error in the method ''move'' of Dipole. Not a number.')
                            end
                        elseif strcmp(varargin{2*iv-1},'z')
                            if isnumeric(varargin{2*iv})
                                for id = 1:obj.N
                                    obj.pos(id,3) = obj.pos(id,3)+varargin{2*iv};
                                end
                            else
                                error('error in the method ''move'' of Dipole. Not a number.')
                            end
                        end
                    else
                        error('error in the method ''move'' of Dipole. Not a string.')
                    end
                end
            end
                
        end

        function val = meanPos(obj)
            val = 0;
            for ip = 1:obj.N
                val = val + obj.DIs(ip).pos;
            end
            val = val/obj.N;
        end

        function obj = Jones(obj,varargin)
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
 
            
            matr = eye(2,2);
            for ii = 1:2:Nvar
                if ~ischar(varargin{ii})
                    error('this input must be text: ''P'', ''QWP'' or ''HWP''')
                elseif ~isnumeric(varargin{ii+1})
                    error('this inpust must be a number')
                end
                switch varargin{ii}
                    case 'P'
                        matr = R(varargin{ii+1})*P*R(-varargin{ii+1})*matr;
                    case 'QWP'
                        matr = R(varargin{ii+1})*QWP*R(-varargin{ii+1})*matr;
                    case 'HWP'
                        matr = R(varargin{ii+1})*HWP*R(-varargin{ii+1})*matr;
                end
            end
            
            for ip = 1:obj.N
                pol2 = [obj.p(ip,1);obj.p(ip,2)];
                pol = matr*pol2;
                obj.p(ip,1) = pol(1);
                obj.p(ip,2) = pol(2);
            end
        end
        
        function val = get.epsTensor(obj)
            val = obj.DIs(1).epsTensor;
        end

        function val = chiTensor(obj)
            val = obj.DIs(1).chiTensor;
        end


        function val = get.alpha(obj)
            % computes and returns the dependent property alpha (complex polarizability of the nanoparticle).

            if isempty(obj.E0)
                error('obj.E0 should not be empty for the calculation of alpha')
            else
                val = 1/(obj.eps0*norm(obj.E0)^2)*...
                trace(conj(obj.EE0)*obj.p.');
            end

            %for il = 1:Nl
            %    E0mean = mean(obj.EE0);
            %    val(il) = sum(obj.p*E0mean.')/(obj.eps0*(norm(obj.E0)));
            %end
        end
        
        function val = get.lambda(obj)
            val = obj.Illumination.lambda;
        end
        
        function val = get.n(obj)
            val = obj.DIs(1).n;
        end
         
        function obj = set.n(obj,val)
            for ip = 1:obj.N
                obj.DIs(ip).n = val;
            end
        end

        function val = get.n_ext(obj) 
            val = obj.DIs(1).n_ext;
        end

        function obj = set.n_ext(obj, val)
            for ip = 1:obj.N
                obj.DIs(ip).n_ext = val;
            end
        end

        function val = get.Cext(obj)
            % Sets Cext (ext cross section).
            val = 2*pi/(obj.n_ext*obj.eps0*obj.lambda*norm(obj.E0)^2)*...
                trace(imag(conj(obj.EE0)*obj.p.')); % le obj.n au dénumérateur a été rajouté en tatonnant pour faire coller DDA et Mie.
        end

        function val = get.Csca(obj)
            val = (2*pi/obj.lambda)^4/(6*pi*obj.eps0^2*norm(obj.E0)^4)*...
                trace(abs(conj(obj.EE0)*obj.p.')^2);
        end

        function val = get.Csca0(obj)
            val =(2*pi/obj.lambda)^4/(3*pi*obj.eps0^2*obj.n_ext*norm(obj.E0)^2)*...
                trace(abs(obj.p*obj.p'));
        end

        function val = get.Cabs(obj)
            val = obj.Cext-obj.Csca;
        end
 
        function val = get.Cabs2(obj)
            val = 2*pi/(obj.eps0*obj.lambda*norm(obj.E0)^2)*...
                trace( imag(obj.p*obj.EE') - (2*pi/obj.lambda)^3*abs(obj.p*obj.p')/(6*pi*obj.eps0) );
            %rr = trace( imag(obj.p*obj.EE'))
            %tt = trace(2/3*(2*pi/obj.lambda)^3*abs(obj.p*obj.p')/obj.eps0 )
        end

        function val = get.Csca2(obj)
            val = obj.Cext-obj.Cabs2;
        end
     
        function val = get.Illumination(obj)
            val = obj.DIs(1).Illumination;
        end
        
        function obj = set.Illumination(obj, IL)
            for ip = 1:obj.N
                obj.DIs(ip).Illumination = IL;
            end
        end
                
        function figure(obj)
            [xs,ys,zs] = sphere;
            figure
            if ~isempty(obj.EE)
                EEint = sqrt(sum(obj.EE.*conj(obj.EE),2));
                %figure
                hold on 
                for is = 1:obj.N
                    col = (EEint(is)-min(EEint))/(max(EEint)-min(EEint));
%                    if nargin==2
%                        if strcmp(varargin{1},'cut') && pos(is,1)>0
                            surf(obj.a/2*xs+obj.pos(is,1),obj.a/2*ys+obj.pos(is,2),obj.a/2*zs+obj.pos(is,3), 'FaceColor', [col 0 0], 'FaceAlpha',0.9,'EdgeAlpha', 0)
%                        elseif ~strcmp(varargin{1},'cut')
%                            error([varargin{1} ' is not a known parameter.'])
%                        end
                    %else
                    %    surf(a*xs+pos(is,1),a*ys+pos(is,2),a*zs+pos(is,3), 'FaceColor', [col 0 0], 'FaceAlpha',0.9,'EdgeAlpha', 0)
                    %end 
                end
                light
                axis equal
            else  %if the Nanoparticle does not contain any mesh for the moment.
                %figure
                hold on 
                for is = 1:obj.N
                    surf(obj.a/2*xs+obj.pos(is,1),obj.a/2*ys+obj.pos(is,2),obj.a/2*zs+obj.pos(is,3), 'FaceColor', [0.7 0.3 0.2], 'FaceAlpha',0.9,'EdgeAlpha', 0)
                end
                light
                axis equal
            end
            % plot the plane:
            ecart = 5*obj.a;
            [x, y] = meshgrid(-ecart+min(min(obj.pos(:,1))):10e-9:ecart+max(max(obj.pos(:,1))) , -ecart+min(min(obj.pos(:,2))):10e-9:ecart+max(max(obj.pos(:,2))));
            z = 0.*x + 0.*y;
            color = z*0+1;
            surf(x,y,z,color);
            view(14,28)
        end
                
        function val = matList(obj)
            % returns the list of available cameras
            matList = dir([obj.NPpath '/../materials/*.txt']);
            Nc = numel(matList);
            val = cell(Nc,1);
            for ic = 1:Nc
                val{ic} = matList(ic).name(1:end-4);
            end
        end    
        
    end
    
    
    methods(Static,Hidden)

        function val = NPpath()
            val = fileparts(which('Nanoparticle.m'));
        end
        
    end
end