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
        eps             % complex permittivity of the nanosphere material
        n               % complex refractive index of the nanosphere material
        p               % electric dipolar moment
        EE0             % local electric field experienced by the dipole
    end
    properties(Access = public)
        x = 0           % x position of the dipole [m]
        y = 0           % y position of the dipole [m]
        z               % z position of the dipole [m]
        n_ext           % refractive index of the surroundings
    end

    properties(Dependent)
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

    properties(Access = private)
        eps0 = 8.8541878128e-12     % vacuum permittivity
        c = 299792458               % speed of light
        epsHidden
        alphaHidden
    end
    
    methods

        function obj = Dipole(mat,radius,z,opt)
            arguments
                mat = 'none'
                radius = 0
                z = 0
                opt.alpha
            end
            %Dipole(mat,radius,[z]). By default, z = radius.
            if nargin~=0
                if ~isnumeric(radius)
                    error('The 2nd input (radius) must be a real number')
                elseif radius<0
                    error('The 2nd input must be positive')
                end   

                obj.r = radius;

                if ischar(mat)
                    obj.mat = mat;
                elseif isnumeric(mat)
                    if abs(mat)>1e-6 % specify an epsilon value
                        disp('The code understands that you specify directly the permittivity value instead of the material')
                        obj.epsHidden = mat;
                        obj.mat = 'user defined';
                    else
                        disp('The code understands that you specify directly the polarisability value instead of the material')
                        obj.alphaHidden = mat;
                        obj.mat = 'user defined';
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
            obj = DDA(obj,IL);
        end

        function val = get.eps(obj)
            if strcmp(obj.mat,'user defined')
                val = obj.epsHidden;
            else
                val = epsReadDDA(obj.lambda,obj.mat);   % dielectric function of the nanoparticle 
            end
        end
        
        function val = get.n(obj)
            if strcmp(obj.mat,'user defined')
                val = sqrt(obj.epsHidden);
            else
                val = indexRead(obj.lambda,obj.mat);   % dielectric function of the nanoparticle 
            end
        end
        
        function val = get.alphaMie(obj)
            prop = MieTheory(obj);
            val = prop.alpha;
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

        function val = get.pos(obj)
            val = [obj.x,obj.y,obj.z];
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
            if ~isnumeric(p)
                error('p must be a number')
            elseif length(p)~=3
                error('p must be a 3-vector')
            end
            obj.p = p;   % dipole moment of the nanoparticle 
        end

        function obj = setEE0(obj,val)
            % Sets the dipole moment p
            if ~isnumeric(val)
                error('EE0 must be a number')
            elseif length(val)~=3
                error('EE0 must be a 3-vector')
            end
            obj.EE0 = val;   % dipole moment of the nanoparticle 
        end

        function obj = set(obj,str1,val1,str2,val2,str3,val3)
            if nargin==3
                eval(['obj.' str1 '=val1;'])
            elseif nargin==5
                eval(['obj.' str1 '=val1;'])
                eval(['obj.' str2 '=val2;'])
            elseif nargin==7
                eval(['obj.' str1 '=val1;'])
                eval(['obj.' str2 '=val2;'])
                eval(['obj.' str3 '=val3;'])
            end
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

        function prop = MieTheory(DIlist)
            
            N = numel(DIlist); % number of dipoles
            
            prop = repmat(NPprop(),N,1);
            
            for io = 1:N
                DI = DIlist(io);
                r0 = DI.r;
                n_DI = DI.n;
                m = n_DI/DI.n_ext;
                k = 2*pi*DI.n_ext/DI.lambda;
                x = k*r0;
                z = m*x;
                N = round(2+x+4*x.^(1/3));
            
                % computation
            
                j = (1:N);
            
                sqr = sqrt(pi*x/2);
                sqrm = sqrt(pi*z/2);
            
                phi = sqr.*besselj(j+0.5,x);
                xi = sqr.*(besselj(j+0.5,x)+1i*bessely(j+0.5,x));
                phim = sqrm.*besselj(j+0.5,z);
            
                phi1 = [sin(x), phi(1:N-1)];
            
                phi1m = [sin(z), phim(1:N-1)];
                y = sqr*bessely(j+0.5,x);
            
                y1 = [-cos(x), y(1:N-1)];
            
                phip = (phi1-j/x.*phi);
                phimp = (phi1m-j/z.*phim);
                xip = (phi1+1i*y1)-j/x.*(phi+1i*y);
            
                aj = (m*phim.*phip-phi.*phimp)./(m*phim.*xip-xi.*phimp);
                bj = (phim.*phip-m*phi.*phimp)./(phim.*xip-m*xi.*phimp);
            
                Csca = sum( (2*j+1).*(abs(aj).*abs(aj)+abs(bj).*abs(bj)) );
                Cext = sum( (2*j+1).*real(aj+bj) );    
            
                Cext = Cext*2*pi/(k*k);
                Csca = Csca*2*pi/(k*k);
                Cabs = Cext-Csca;
            
                alpha = 1i*6*pi*DI.n_ext*DI.n_ext*aj(1)/(k*k*k);
            
                prop(io) = NPprop(alpha,Cext,Csca,Cabs);
            
            end

        end
        
        function objs = plus(obj1,obj2)
            if ~isempty(obj1(1).Illumination) && ~isempty(obj2(1).Illumination)
                if obj1(1).Illumination.identity~=obj2(1).Illumination.identity
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
            color = ones(size(X,2), size(X,1), 3);
            surf(X*1e6,Y*1e6,Z*1e6,'FaceColor','w','EdgeColor','w');
            colormap(Pradeep)
            view(14,28)
            camproj('perspective')
            xlabel('µm');
            ylabel('µm');
            zlabel('µm');

% Ajout d'un titre 
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