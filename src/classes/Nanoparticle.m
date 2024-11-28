%% NPimaging package
% Class that defines a meshed nanoparticle for DDA simulations

% author: Guillaume Baffou
% affiliation: CNRS, Institut Fresnel
% date: Jul 31, 2019

classdef Nanoparticle

    properties(Access = public)
        mat        % material of the nanoparticle
        geom        % geometry type of the nanoparticle
        params      % parameters of the geometry
        mesh        % Meshing object
        V           % volume of the nanoparticle
        n_ext       % complex refractive index of the surroundings
    end

    properties(Dependent)
        lambda      % free-space wavelength of illumination
        n       % complex refractive index of the nanoparticle material
        eps     % permittivity of the nanoparticle material
        alpha   % complex polarizability calculated by DDA
        Cext    % Extinction cross section
        Csca    % Scattering cross section, defined form a formula
        Csca2    % Scattering cross section, defined from ext-abs
        Csca0    % Scattering cross section, defined from p^2
        Cabs    % Absorption cross section, defined from ext-sca
        Cabs2    % Absorption cross section, defined from a formula
    end

    properties(Hidden)
        Illumination
    end
    
    properties(Access = private)
        eps0 = 8.854187817e-12;
        c0 = 299792458;
        epsHidden
    end
    
    methods
        function obj = Nanoparticle(mat,varargin)
            % (mat,'geometry type',param1, param2)
            if ischar(mat)
                obj.mat = mat;
            elseif isnumeric(mat)
                obj.epsHidden = mat;
                obj.mat = 'user defined';
            end

            obj.mesh = Meshing;
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
                        obj.mesh.pos = spher(obj.params(1),a);
                    elseif nargin==4
                        a = varargin{3}; % Lattice parameter of the meshing.
                        obj.mesh.pos = spher(obj.params(1),a);
                    elseif nargin==5
                        a = varargin{3}; % Lattice parameter of the meshing.
                        obj.mesh.pos = spher(obj.params(1),a,varargin{4});
                    else                        
                        error('Not the proper number of arguments for a sphere.')
                    end
                    a_adjusted = (4*pi/3/obj.mesh.N)^(1/3)*obj.params(1);
                    obj.mesh.pos = obj.mesh.pos*a_adjusted/a;
                    obj.mesh.a = a_adjusted;
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
                        obj.mesh.pos = ellipsoid(obj.params,a);
                    elseif nargin==4
                        a = varargin{3}; % Lattice parameter of the meshing.
                        obj.mesh.pos = ellipsoid(obj.params,a);
                    elseif nargin==5
                        a = varargin{3}; % Lattice parameter of the meshing.
                        obj.mesh.pos = ellipsoid(obj.params,a,varargin{4});
                    else                        
                        error('Not the proper number of arguments for a sphere.')
                    end
                    a_adjusted = (4*pi/3/obj.mesh.N)^(1/3)*obj.params(1);
                    obj.mesh.pos = obj.mesh.pos*a_adjusted/a;
                    obj.mesh.a = a_adjusted;
                elseif  strcmp(obj.geom,'cube')
                    obj.params = varargin{2}; % Side length of the cube
                    if nargin==3
                        a = obj.params/4;
                        obj.mesh.pos = cube(obj.params,a);
                    elseif nargin==4
                        a = varargin{3};
                        obj.mesh.pos = cube(obj.params,a);
                    elseif nargin==5
                        a = varargin{3};
                        obj.mesh.pos = cube(obj.params,a,varargin{4});
                    else
                        error('Not the proper number of arguments for a cube.')
                    end
                    obj.mesh.a = a;
                    obj.V = obj.params^3;
                elseif  strcmp(obj.geom,'cuboid')
                    obj.params(1) = varargin{2}(1); % x Side length
                    obj.params(2) = varargin{2}(2); % y Side length
                    obj.params(3) = varargin{2}(3); % z Side length
                    obj.mesh.a = varargin{3}; % Lattice parameter of the meshing.
                    if nargin==3
                        a = min(obj.params)/4;
                        obj.mesh.pos = cuboid(obj.params,a);
                    elseif nargin==4
                        a = varargin{3};
                        obj.mesh.pos = cuboid(obj.params,a);
                    elseif nargin==5
                        a = varargin{3};
                        obj.mesh.pos = cuboid(obj.params,a,varargin{4});
                    else
                        error('Not the proper number of arguments for a cube.')
                    end
                    obj.mesh.a = a;
                    obj.V = obj.params(1)*obj.params(2)*obj.params(3);
                elseif  strcmp(obj.geom,'cylinder')
                    obj.params(1) = varargin{2}(1); % diameter in px
                    obj.params(2) = varargin{2}(2); % thickness in px
                    if nargin==3
                        a = min(obj.params)/4;
                        obj.mesh.pos = cylinder(obj.params,a);
                    elseif nargin==4
                        a = varargin{3};
                        obj.mesh.pos = cylinder(obj.params,a);
                    elseif nargin==5
                        a = varargin{3};
                        obj.mesh.pos = cylinder(obj.params,a,varargin{4});
                    else
                        error('Not the proper number of arguments for a cube.')
                    end
                    obj.mesh.a = a;
                    obj.V = pi*(obj.params(1))^2*obj.params(2);
                elseif  strcmp(obj.geom,'rod')
                    obj.params(1) = varargin{2}(1); % Total longitudinal length of the rod (along x)
                    obj.params(2) = varargin{2}(2); % transverse radius
                    L0 = obj.params(1);
                    r0 = obj.params(2);
                    obj.mesh.a = varargin{3}; % Lattice parameter of the meshing.
                    if nargin==3
                        a = min(obj.params)/4;
                        obj.mesh.pos = rod(obj.params,a);
                    elseif nargin==4
                        a = varargin{3};
                        obj.mesh.pos = rod(obj.params,a);
                    elseif nargin==5
                        a = varargin{3};
                        obj.mesh.pos = rod(obj.params,a,varargin{4});
                    else
                        error('Not the proper number of arguments for a cube.')
                    end                
                    obj.V = 4/3*pi*r0^3+pi*r0^2*(L0-2*r0);
                else
                    error(['The geometry ''' varargin{1} ''' is not known.'])
                end
            end
            if obj.mesh.N~=0
                fprintf(['Meshing with ' num2str(obj.mesh.N) ' cells.\n'])
            end
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
                M = mean(obj.mesh.pos);
                for iv = 1:(nargin-1)/2
                    if ischar(varargin{2*iv-1})
                        if strcmp(varargin{2*iv-1},'x')
                            if isnumeric(varargin{2*iv})
                                for id = 1:obj.mesh.N
                                    dx = varargin{2*iv}-M(1);
                                    obj.mesh.pos(id,1) = obj.mesh.pos(id,1)+dx;
                                end
                            else
                                error('error in the method ''moveTo'' of Nanoparticle. Not a number.')
                            end
                        elseif strcmp(varargin{2*iv-1},'y')
                            if isnumeric(varargin{2*iv})
                                for id = 1:obj.mesh.N
                                    dy = varargin{2*iv}-M(2);
                                    obj.mesh.pos(id,2) = obj.mesh.pos(id,2)+dy;
                                end
                            else
                                error('error in the method ''move'' of Dipole. Not a number.')
                            end
                        elseif strcmp(varargin{2*iv-1},'z')
                            if isnumeric(varargin{2*iv})
                                for id = 1:obj.mesh.N
                                    dz = varargin{2*iv}-M(3);
                                    obj.mesh.pos(id,3) = obj.mesh.pos(id,3)+dz;
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

        function obj = rotate(obj,axis,theta,point)
            %rotate(theta,axis,point)
            if nargin==3
                point=mean(obj.mesh.pos);
            elseif nargin~=4
                error('number of input for the method rotate must be 2 or 3')
            end
            if ~isnumeric(theta)
                error('theta mush be a number')
            elseif length(theta)~=1
                error('theta should not be a vector, but a scalar')
            elseif theta*1000~=round(theta*1000)
                theta*1000
                round(theta*1000)
                warning('are you sure the input of rotation() is in degres and not in radian?')
                
            end
            if ~ischar(axis)
                error('the axis parameter must be a string')
            elseif strcmp(axis,'x')
                RotMat = ...
                [1 0           0
                 0 cosd(theta) -sind(theta)
                 0 sind(theta)  cosd(theta)];
            elseif strcmp(axis,'y')
                RotMat = ...
                [cosd(theta) 0 sind(theta)
                 0          1 0
                -sind(theta) 0 cosd(theta)];
            elseif strcmp(axis,'z')
                RotMat = ...
                [cosd(theta) -sind(theta) 0
                 sind(theta)  cosd(theta) 0
                 0           0          1];
            else
                error('The axis must be ''x'', ''y'' or ''z''')
            end
            point0 = mean(obj.mesh.pos);
            obj = obj.moveTo(point);
            for ic = 1:obj.mesh.N
                obj.mesh.pos(ic,:) = (RotMat*obj.mesh.pos(ic,:).').';
            end
            obj = obj.moveTo(point0);
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
                                for id = 1:obj.mesh.N
                                    obj.mesh.pos(id,1) = obj.mesh.pos(id,1)+varargin{2*iv};
                                end
                            else
                                error('error in the method ''move'' of Dipole. Not a number.')
                            end
                        elseif strcmp(varargin{2*iv-1},'y')
                            if isnumeric(varargin{2*iv})
                                for id = 1:obj.mesh.N
                                    obj.mesh.pos(id,2) = obj.mesh.pos(id,2)+varargin{2*iv};
                                end
                            else
                                error('error in the method ''move'' of Dipole. Not a number.')
                            end
                        elseif strcmp(varargin{2*iv-1},'z')
                            if isnumeric(varargin{2*iv})
                                for id = 1:obj.mesh.N
                                    obj.mesh.pos(id,3) = obj.mesh.pos(id,3)+varargin{2*iv};
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
            
            for ip = 1:obj.mesh.N
                pol2 = [obj.mesh.p(ip,1);obj.mesh.p(ip,2)];
                pol = matr*pol2;
                obj.mesh.p(ip,1) = pol(1);
                obj.mesh.p(ip,2) = pol(2);
            end
        end
        
        function val = get.eps(obj)
            if strcmp(obj.mat,'user defined')
                val = obj.epsHidden;
            else
                val = epsReadDDA(obj.lambda,obj.mat);   % dielectric function of the nanoparticle 
            end
        end

        function val = get.alpha(obj)
            % computes and returns the dependent property alpha (complex polarizability of the nanoparticle).

            if isempty(obj.mesh.E0)
                error('obj.mesh.E0 should not be empty for the calculation of alpha')
            else
                val = 1/(obj.eps0*norm(obj.mesh.E0)^2)*...
                trace(conj(obj.mesh.EE0)*obj.mesh.p.');
            end

            %for il = 1:Nl
            %    E0mean = mean(obj.mesh(il).EE0);
            %    val(il) = sum(obj.mesh(il).p*E0mean.')/(obj.eps0*(norm(obj.mesh(il).E0)));
            %end
        end
        
        function val = get.lambda(obj)
            val = obj.Illumination.lambda;
        end
        
        function val = get.n(obj)
            % computes and returns the dependent property n (complex refractive index of the material).
            if isnumeric(obj.mat)
                val = sqrt(obj.mat);
            else
                val = indexReadDDA(obj.lambda,obj.mat);
            end
        end
         
        function obj = set.n_ext(obj,n) 
            obj.n_ext = n;
        end

        function val = get.Cext(obj)
            % Sets Cext (ext cross section).
            val = 2*pi/(obj.n_ext*obj.eps0*obj.lambda*norm(obj.mesh.E0)^2)*...
                trace(imag(conj(obj.mesh.EE0)*obj.mesh.p.')); % le obj.n au dénumérateur a été rajouté en tatonnant pour faire coller DDA et Mie.
        end
        function val = get.Csca(obj)
            val = (2*pi/obj.lambda)^4/(6*pi*obj.eps0^2*norm(obj.mesh.E0)^4)*...
                trace(abs(conj(obj.mesh.EE0)*obj.mesh.p.')^2);
        end
        function val = get.Csca0(obj)
            val =(2*pi/obj.lambda)^4/(3*pi*obj.eps0^2*obj.n_ext*norm(obj.mesh.E0)^2)*...
                trace(abs(obj.mesh.p*obj.mesh.p'));
        end
        function val = get.Cabs(obj)
            val = obj.Cext-obj.Csca;
        end
        function val = get.Cabs2(obj)
            val = 2*pi/(obj.eps0*obj.lambda*norm(obj.mesh.E0)^2)*...
                trace( imag(obj.mesh.p*obj.mesh.EE') - (2*pi/obj.lambda)^3*abs(obj.mesh.p*obj.mesh.p')/(6*pi*obj.eps0) );
            %rr = trace( imag(obj.mesh.p*obj.mesh.EE'))
            %tt = trace(2/3*(2*pi/obj.lambda)^3*abs(obj.mesh.p*obj.mesh.p')/obj.eps0 )
        end
        function val = get.Csca2(obj)
            val = obj.Cext-obj.Cabs2;
        end
     
        function obj = set.Illumination(obj,val)
            if ~isa(val,'Illumination')
                error('The input should be an Illumination object')
            end
            obj.Illumination = val;
        end
        
        function figure(obj)
            [xs,ys,zs] = sphere;
            if ~isempty(obj.mesh.EE)
                EEint = sqrt(sum(obj.mesh.EE.*conj(obj.mesh.EE),2));
                %figure
                hold on 
                for is = 1:obj.mesh.N
                    col = (EEint(is)-min(EEint))/(max(EEint)-min(EEint));
                    a = obj.mesh.a/2;
                    pos = obj.mesh.pos;
%                    if nargin==2
%                        if strcmp(varargin{1},'cut') && pos(is,1)>0
                            surf(a*xs+pos(is,1),a*ys+pos(is,2),a*zs+pos(is,3), 'FaceColor', [col 0 0], 'FaceAlpha',0.9,'EdgeAlpha', 0)
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
                for is = 1:obj.mesh.N
                    a = obj.mesh.a/2;
                    pos = obj.mesh.pos;
                    surf(a*xs+pos(is,1),a*ys+pos(is,2),a*zs+pos(is,3), 'FaceColor', [0.7 0.3 0.2], 'FaceAlpha',0.9,'EdgeAlpha', 0)
                end
                light
                axis equal
            end
            ecart = 5*obj.mesh.a;
            [x, y] = meshgrid(-ecart+min(min(obj.mesh.pos(:,1))):10e-9:ecart+max(max(obj.mesh.pos(:,1))) , -ecart+min(min(obj.mesh.pos(:,2))):10e-9:ecart+max(max(obj.mesh.pos(:,2))));
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