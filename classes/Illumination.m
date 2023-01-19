%% PhaseLAB package
% Class that defines the optical incoming field
%
% Illumination(lambda,ME,I,polar)
% each parameter is optional
%  lambda: wavelength
%  ME: Medium object
%  I: Illumination
%  polar: 2D or 3D vector that defines the polarization. Its norm does not  matter. It is automatically normlized.

% author: Guillaume Baffou
% affiliation: CNRS, Institut Fresnel
% date: Jul 31, 2019

classdef Illumination  <  handle & matlab.mixin.Copyable
    properties
        lambda  double {mustBeNumeric, mustBePositive}       % free-space illumination wavelength [m]
    end
    
    properties(Access = public)
        I        {mustBeNumeric, mustBePositive} = 1             % Intensity of illumination light (W/m^2)
        direct (1,3) double = [0 0 1]  % 3-component vector that defines the propagation direction of the light beam
                        % Be careful, this version of the program only
                        % works for normal incidence as r12 is only defined
                        % for normal incidence.
        polar (1,3) double = [1 0 0]   % 3-component vector, which directions defines the polarization. The norm of this vector does not matter.
        NA (1,1) double = 0 % Useful only for inSilico algo
    end
    properties(Dependent,Hidden)
        n               % refractive index of the particle surroundings
        nS              % refractive index of the substrate
        e0              % incident electic field
        E0              % incident electric field vector
        k0              % wavevector in vacuum
        tr              % transmission coefficient through the interface
    end
    
    properties(Hidden)
        Medium  Medium
        identity       % random number as a signature of the object. Mimic an handle object this way and enables the comparison between two objects.
    end
    
    properties(Hidden,Constant)
        eps0 = 8.8541878128e-12;     % vacuum permittivity
        c = 299792458;               % speed of light
    end
    
    
    methods
        
        function obj = Illumination(lambda,ME,I,polar)
            % (lambda[,Medium(n,nS),I,polar]). polar can be a 2- or 3-vector, not necessarily unitary.
            if nargin~=0
                obj.lambda = lambda;
                if nargin>=2
                    if ~isa(ME,'Medium')
                        error('The 2nd input must be a Medium object')
                    else
                        obj.Medium = ME;
                    end
                end
                if nargin>=3
                    if ~isnumeric(I)
                        error('The 2nd input (I) must be a number')
                    else
                        obj.I = I;
                    end
                end
                if nargin==4
                    obj.polar = polar;
                end
            end
            obj.identity = rand(1,1);
        end
        
        function set.lambda(obj,val)
            if val>1
                obj.lambda = val*1e-9;
                warning('lambda assumed to be [nm], converted into [m]')
            else
                obj.lambda = val;
            end
        end
        
        function set.polar(obj,val)
            if ~isnumeric(val)
                error('the input polarization must be a vector')
            elseif norm(val)==0
                error('zero polar vector, characterizing no light intensity')
            elseif length(val)==2
                obj.polar = [val(1)/norm(val),val(2)/norm(val),0];
            elseif length(val)==3
                obj.polar = val(:).'/norm(val);
            else
                error('the input polarization must be a 2- or 3-vector')
            end
        end

        function set.I(obj,val)
            if val>0
                obj.I = val;
            else
                error('I must be positive')
            end
        end
        
        function set.direct(obj,val)
            if ~isnumeric(val)
                error('the input direction must be a number')
            elseif norm(val)==0
                error('zero direct vector, characterizing no light intensity')
            elseif length(val)==3
                obj.direct = val(:).'/norm(val);
            else
                error('the input polarization must be a 2- or 3-vector')
            end
        end
        
        function val = get.k0(obj)
            val = 2*pi./obj.lambda;
        end
        
        function val = get.n(obj)
            if ~isempty(obj.Medium)
                val = obj.Medium.n;
            else
                val = [];
            end
        end
        
        function val = get.nS(obj)
            if ~isempty(obj.Medium)
                val = obj.Medium.nS;
            else
                val = [];
            end
        end
        
        function val = get.tr(obj)
            val = 2*obj.n/(obj.n+obj.nS);
        end
        
        function val = get.e0(obj)
            val = sqrt(2*obj.I/(obj.n*obj.c*obj.eps0));
        end
        
        function val = get.E0(obj)
            val = obj.e0*obj.polar;
        end

        
        function val=EE0(IL,pos) 
            %% incoming electric field
            kk = IL.direct*2*pi/IL.lambda;
            r12 = (IL.n-IL.nS)/(IL.n+IL.nS);
            val = IL.E0*exp(1i*IL.n*kk(:).'*pos(:))+r12*IL.E0*exp(-1i*IL.n*kk(:).'*pos(:));
        end

        function obj = rotate(obj,varargin)
            if ~nargin==mod(nargin,2)
                error('The number of arguments of the rotate function should be an odd number, in the for ''x'',45, ...')
            end
            for il = 1:(nargin-1)/2
                num = il*2-1;
                phi = varargin{num+1};
                if strcmpi(varargin{num},'Z')
                    RotMat = [cosd(phi) -sind(phi)  0
                              sind(phi)  cosd(phi)  0
                              0          0         1];
                elseif strcmpi(varargin{num},'X')
                    RotMat = [1     0          0
                              0  cosd(phi)  -sind(phi)
                              0  sind(phi)   cosd(phi)];
                elseif strcmpi(varargin{num},'Y')
                    RotMat = [cosd(phi)   0   sind(phi)
                              0           1       0
                             -sind(phi) 0    cosd(phi)];
                else
                    error('Rotation of Illumination should be around ''X'' or ''Y'' or ''Z''')
                end
                obj.direct = (RotMat*obj.direct(:))';
                obj.polar = (RotMat*obj.polar(:))';
            end

            
        end
        
        function ILs = Jones(IL,varargin)
            % Jones('P', 45, 'QWP',90, 'HWP',30, ...). Applies of series of polarieing plates.
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
            ILs = IL.Jones0(mat);
        end
        
        function ILs = Jones0(IL,mat)
            % Jones0(IL,mat). IL: Illumination object, mat: a Jones Matrix. Applies a Jones matrix to the incoming light IL./
            pol2 = [IL.polar(1);IL.polar(2)];
            ILs = IL;
            pol = mat*pol2;
            ILs.I = IL.I*(norm(pol)/norm(pol2))^2;
            ILs.polar = [pol(1) pol(2) 0];
        end
        
        
    end
end