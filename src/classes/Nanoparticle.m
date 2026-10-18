%% NPimaging package
% Class that defines a meshed nanoparticle for DDA simulations

% author: Guillaume Baffou
% affiliation: CNRS, Institut Fresnel
% date: Jul 31, 2019

classdef Nanoparticle

    properties(SetAccess = private)
        DIs    (:,1) Dipole % Array of Dipole objects
        geom   char         % geometry type of the nanoparticle
        params double       % parameters of the geometry
        a      (1,1) double % lattice parameter
        V      (1,1) double % volume of the nanoparticle
    end

    properties(Dependent)
        pos (:,3) double    % (Nx3) array of the positions of the cells
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
        pos_nm    % (Nx3) array of the positions of the cells

    end
    
    properties(Access = private, Dependent)
        eps0
        c0
        RotMat
    end
    
    methods
        function obj = Nanoparticle(mat, geom, dims, opt)
            arguments
                mat = []
                geom {mustBeMember(geom,{'sphere','ellipsoid','cube','cuboid','cylinder','rod'})} = 'sphere'
                dims (1,:) double = []
                opt.meshParam = []
            end
            if nargin == 0
                return
            elseif nargin == 1 % Nanoparticle(N)
                obj = repmat(Nanoparticle(),mat,1);
                return
            end
            % mat : material or refractive index
            obj.geom = geom;
            switch obj.geom
                case 'sphere'
                    if isscalar(dims)
                        obj.params(1) = dims; % Rsphere
                    else
                        error('The dimension parameter must be a scalar, the sphere radius')
                    end
                    obj.V = 4*pi/3*dims^3;
                    if isempty(opt.meshParam) % no mesh_parameter specified
                        a = obj.params(1)/4;
                    else
                        a = opt.meshParam; % Lattice parameter of the meshing.
                    end
                    Ncell = obj.V/a^3;
                    if Ncell > 1800
                        disp("approximated number of cells: "+Ncell)
                    end
                    pos = spher(obj.params(1),a);
                    a_adjusted = (4*pi/3/size(pos,1))^(1/3)*obj.params(1);
                    pos = pos*a_adjusted/a;
                    a = a_adjusted;
                case 'ellipsoid'
                    if numel(dims) ~=3
                        error('An ellipsoid demands a parameter that is a 3-vector')
                    end
                    obj.params(1) = dims(1);
                    obj.params(2) = dims(2);
                    obj.params(3) = dims(3);
                    obj.V = 4*pi/3*obj.params(1)*obj.params(2)*obj.params(3);
                    if isempty(opt.meshParam)
                        a = obj.params(1)/4;
                    else
                        a = opt.meshParam; % Lattice parameter of the meshing.
                    end
                    Ncell = obj.V/a^3;
                    if Ncell > 1800
                        disp("approximated number of cells: "+Ncell)
                    end
                    pos = ellipsoid(obj.params,a);
                    a_adjusted = (4*pi/3/size(pos,1))^(1/3)*obj.params(1);
                    pos = pos*a_adjusted/a;
                    a = a_adjusted;
                case 'cube'
                    if isscalar(dims)
                        obj.params(1) = dims; % Rsphere
                    else
                        error('The dimension parameter must be a scalar, the cube edge size')
                    end
                    obj.V = obj.params^3;
                    if isempty(opt.meshParam)
                        a = obj.params/4;
                    else
                        a = opt.meshParam;
                    end
                    Ncell = obj.V/a^3;
                    if Ncell > 1800
                        disp("approximated number of cells: "+Ncell)
                    end
                    pos = cube(obj.params,a);
                case 'cuboid'
                    if numel(dims) ~=3
                        error('A cuboid demands a parameter that is a 3-vector')
                    end
                    obj.params(1) = dims(1);
                    obj.params(2) = dims(2);
                    obj.params(3) = dims(3);
                    obj.V = obj.params(1)*obj.params(2)*obj.params(3);
                    if isempty(opt.meshParam)
                        a = min(obj.params)/4;
                    else
                        a = opt.meshParam;
                    end
                    Ncell = obj.V/a^3;
                    if Ncell > 1800
                        disp("approximated number of cells: "+Ncell)
                    end
                    pos = cuboid(obj.params,a);
                case 'cylinder'
                    if numel(dims) ~=2
                        error('A cylinder demands a parameter that is a 2-vector')
                    end
                    obj.params(1) = dims(1); % radius in px
                    obj.params(2) = dims(2); % thickness in px
                    if isempty(opt.meshParam)
                        a = min(obj.params)/4;
                    else
                        a = opt.meshParam;
                    end
                    Ncell = obj.V/a^3;
                    if Ncell > 1800
                        disp("approximated number of cells: "+Ncell)
                    end
                    pos = cylinder(obj.params,a);
                case 'rod'
                    if numel(dims) ~=2
                        error('A cylinder demands a parameter that is a 2-vector')
                    end
                    obj.params(1) = dims(1); % length
                    obj.params(2) = dims(2); % radius
                    L0 = obj.params(1);
                    r0 = obj.params(2);
                    obj.V = 4/3*pi*r0^3+pi*r0^2*(L0-2*r0);
                    if isempty(opt.meshParam)
                        a = min(obj.params)/4; %No lattice param specified
                    else
                        a = opt.meshParam;
                    end                
                    Ncell = obj.V/a^3;
                    if Ncell > 1800
                        disp("approximated number of cells: "+Ncell)
                    end
                    pos = rod(obj.params,a);
                otherwise
                    error(['The geometry ''' obj.geom ''' is not known.'])
            end
            obj.DIs = repmat(Dipole(mat,a/2),size(pos,1),1);
            for ip = 1:obj.N
                obj.DIs(ip).pos = pos(ip,:);
            end
            obj.a = a;
            fprintf(['Meshing with ' num2str(size(pos,1)) ' cells.\n'])
        end
     
        function NP = shine_old(obj,IL)
            NP = obj;
            
            if isempty(IL.n)
                error('A Medium object needs to be assigned to the Illumination object in this kind of calculation')
            end
            
            NP.DIs.setE0( IL.E0 );
            NP.Illumination = IL;
            n0 = IL.n;
            nS = IL.nS;
            NP.n_ext = n0;
            direct = IL.direct;
            posList = NP.pos;
            Np = NP.N;
            
            kk = direct*2*pi/NP.lambda;
            k0 = norm(kk);
            % chi = (epsmat - n*n*eye(3))*a*a*a;
            a0 = NP.a;
            kan = k0*a0*n0;
            chi = NP.chiTensor;
            
            
            %% incoming electric field
            % r12 = (n-nS)/(n+nS);
            % EE0 = zeros(3*N,1);
            % for ii = 1:N
            %     %EE0(3*ii-2:3*ii) = E0*exp(1i*n*kk*pos(ii,:)');
            %     EE0(3*ii-2:3*ii) = E0*exp(1i*n*kk*pos(ii,:)') + r12*E0*exp(-1i*n*kk*pos(ii,:)');
            % end
            
            EE0list = Eincident(IL,posList,'reshape',false);
            %% Construction of the Matrix to be inverted
            Id = eye(3);
            S0 = zeros(3*Np,3*Np);
            for ny = 1:Np
                for nx = 1:Np
                    if ny ~= nx
                        Rn = (posList(nx,:)-posList(ny,:))/a0;
                        dn = sqrt(Rn*Rn');
                        T1 =    (   Rn'*Rn  - dn^2*Id)/(dn*dn*dn);
                        T2 =    (3*(Rn'*Rn) - dn^2*Id)/(dn*dn*dn*dn) ;
                        T3 =    (3*(Rn'*Rn) - dn^2*Id)/(dn*dn*dn*dn*dn);
                        S0(3*ny-2:3*ny,3*nx-2:3*nx) = chi*(-kan^2*T1-1i*kan*T2+T3)*exp(1i*kan*dn);
                    else
                        %S0(3*ny-2:3*ny,3*nx-2:3*nx) = -4*pi*chi/(3*a*a*a)*Id;
                        
                        % Correction suggested by ChatGPT:
                        S0(3*ny-2:3*ny,3*nx-2:3*nx) = (-4*pi*chi/3 + 1i*2*(kan/n0)^3/3*chi) ;
                                                           
                    end
                end
            end
            
            S0 = S0/(4*pi*NP.eps0*n0*n0);
            
            if nS~=n0
                Ssurf = zeros(3*Np,3*Np);
                for ny = 1:Np
                    for nx = 1:Np
                        Rn = (posList(nx,:)-posList(ny,:).*[1,1,-1])/a0;
                        dn = sqrt(Rn*Rn');
                        T3 = (3*(Rn'*Rn)-dn^2*Id)/(dn*dn*dn*dn*dn);
                        Ssurf(3*ny-2:3*ny,3*nx-2:3*nx) = chi * T3*[[-1 0 0];[0 -1 0];[0 0 1]];
                %        Ssurf(3*ny-2:3*ny,3*nx-2:3*nx) = T3*[[-1 0 0];[0 -1 0];[0 0 1]]*exp(1i*n*k0*d);  % in principle this exp is not put. Just to check the difference
                    end
                end
                Ssurf = (nS*nS-n0*n0)/(nS*nS+n0*n0)*Ssurf/(4*pi*NP.eps0);
                S0 = S0+Ssurf;
            end
            
            %% Calculation
            fprintf('DDA matrix inversion. Please wait...\n')
            EElist = (eye(3*Np)-NP.eps0*S0)\EE0list;
            fprintf('Done.\n')
            
            
            NP.DIs = NP.DIs.setEE( reshape(EElist,[3,Np]).' );
            NP.DIs = NP.DIs.setEE0( reshape(EE0list,[3,Np]).' );
            NP.DIs = NP.DIs.setE0( IL.E0 );
            NP.DIs = NP.DIs.setp( NP.eps0*NP.EE*transpose(NP.chiTensor * a0 * a0 * a0) );
            NP.Illumination = IL;

        end

        function NP = shine(obj,IL)
            NP = obj;
            NP.DIs.setE0( IL.E0 );
            NP.Illumination = IL;
            NP.n_ext = IL.n;

            [EElist, EE0list] = GDT0(NP.pos,NP.a,NP.chiTensor,IL);
            
            Np = numel(NP.DIs);
            NP.DIs = NP.DIs.setEE( reshape(EElist,[3,Np]).' );
            NP.DIs = NP.DIs.setEE0( reshape(EE0list,[3,Np]).' );
            NP.DIs = NP.DIs.setE0( IL.E0 );
            NP.DIs = NP.DIs.setp( NP.eps0*NP.EE*transpose(NP.chiTensor * NP.a^3) );
            NP.Illumination = IL;

        end

        function obj = moveTo(obj,varargin)
            % moveTo([x0,y0,z0])
            % moveTo(x0,y0,z0)
            % moveTo('x',val)
            % moveTo('y',val)
            % moveTo('z',val)
            % moveTo('x',x0,'y',y0)
            % etc
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
                                    obj.DIs(id).pos(1) = obj.DIs(id).pos(1)+varargin{2*iv};
                                end
                            else
                                error('error in the method ''move'' of Dipole. Not a number.')
                            end
                        elseif strcmp(varargin{2*iv-1},'y')
                            if isnumeric(varargin{2*iv})
                                for id = 1:obj.N
                                    obj.DIs(id).pos(2) = obj.DIs(id).pos(2)+varargin{2*iv};
                                end
                            else
                                error('error in the method ''move'' of Dipole. Not a number.')
                            end
                        elseif strcmp(varargin{2*iv-1},'z')
                            if isnumeric(varargin{2*iv})
                                for id = 1:obj.N
                                    obj.DIs(id).pos(3) = obj.DIs(id).pos(3)+varargin{2*iv};
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

        function IM = imaging(obj,MI,opt)
            arguments
                obj Nanoparticle
                MI Microscope
                opt.Npx = 0

            end

            IM = obj.DIs.imaging(MI,"Npx",opt.Npx);
        
        end

        function figure(obj)
            [xs,ys,zs] = sphere;
            No = numel(obj);
            figure
            if No > 2
                fullwidth
            end
            for io = 1:No
                ax = subplot(1,No,io);
                ax.FontSize = 16;
                if ~isempty(obj(io).EE)
                    EEint = sqrt(sum(obj(io).EE.*conj(obj(io).EE),2));
                    %figure
                    hold on 
                    for is = 1:obj(io).N
                        col = (EEint(is)-min(EEint))/(max(EEint)-min(EEint));
                        x_coords = obj(io).a/2*xs+obj(io).pos(is,1);
                        y_coords = obj(io).a/2*ys+obj(io).pos(is,2);
                        z_coords = obj(io).a/2*zs+obj(io).pos(is,3);
                        surf(x_coords*1e9,y_coords*1e9,z_coords*1e9, 'FaceColor', [col 0 0], 'FaceAlpha',0.9,'EdgeAlpha', 0)
                    end
                    light
                    axis equal
                else  %if the Nanoparticle does not contain any mesh for the moment.
                    %figure
                    hold on 
                    for is = 1:obj(io).N
                        x_coords = obj(io).a/2*xs+obj(io).pos(is,1);
                        y_coords = obj(io).a/2*ys+obj(io).pos(is,2);
                        z_coords = obj(io).a/2*zs+obj(io).pos(is,3);
                        surf(x_coords*1e9,y_coords*1e9,z_coords*1e9, 'FaceColor', [0.7 0.3 0.2], 'FaceAlpha',0.9,'EdgeAlpha', 0)
                    end
                    light
                    axis equal
                end
                % plot the plane:
                ecart = 5*obj(io).a;
                [x, y] = meshgrid(-ecart+min(min(obj(io).pos(:,1))):10e-9:ecart+max(max(obj(io).pos(:,1))) , -ecart+min(min(obj(io).pos(:,2))):10e-9:ecart+max(max(obj(io).pos(:,2))));
                z = 0.*x + 0.*y;
                surf(x*1e9,y*1e9,z, 'FaceColor', 'w', 'EdgeColor', [0.5 0.5 0.5])
                view(14,28)
                camproj('perspective')
                title(obj(io).N+" cells")
                xlabel('nm')
                ylabel('nm')
                zlabel('nm')
            end
        end
                
        % set/get
        function val = get.pos(obj)
            val = zeros(obj.N,3);
            for ip = 1:obj.N
                val(ip,:) = obj.DIs(ip).pos;
            end
        end

        function val = get.pos_nm(obj)
            val = get.pos(obj)*1e9;
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
                
    end
    
    
end