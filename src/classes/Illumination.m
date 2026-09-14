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
        S0
        S1
        S2
        S3
    end

    properties(Hidden)
        Medium  Medium
    end

    properties(Hidden,Constant)
        eps0 = 8.8541878128e-12;     % vacuum permittivity
        c = 299792458;               % speed of light
    end


    methods

        function obj = Illumination(lambda,ME,I,polar)
            arguments
                lambda = []
                ME Medium = Medium('water','glass');
                I  double = 1
                polar (1,:) = [1 0 0]
            end
            % (lambda[,Medium(n,nS),I,polar]). polar can be a 2- or 3-vector, not necessarily unitary.
            if nargin ~= 0
                Nv = numel(lambda);
                if Nv>1
                    obj = repmat(Illumination(), Nv, 1);
                    for iv = 1:Nv
                        obj(iv) = Illumination(lambda(iv), ME,I, polar);
                    end
                else
                    obj.lambda = lambda;
                    obj.Medium = ME;
                    obj.I = I;
                    if istext(polar)
                        if string(polar) == 'L' || string(polar) == "Left" || string(polar) == "left"
                            polar = [1 1i];
                        elseif  string(polar) == 'R' || string(polar) == "Right" || string(polar) == "right"
                            polar = [1 -1i];
                        end
                    end
                    if numel(polar) == 2
                        obj.polar = [polar(:).' 0];
                    elseif numel(polar) ==  3
                        obj.polar = polar(:).';
                    else
                        error('not a good expression for a polarization')
                    end
                end
            end
        end

        function set.lambda(obj,val)
            No = numel(obj);
            Nv = numel(val);

            if Nv == 1
                val = val*ones(No, 1);
                Nv = No;
            elseif Nv ~= No
                error('the number of wavelength must equal the number of Illumination objects')
            end

            for iv = 1:Nv
                if val(iv) > 1e5
                    error('wrong lambda value')
                elseif val(iv) > 0.1 % value indicated in [nm], then converts into [m]
                    obj(iv).lambda = val(iv)*1e-9;
                else % value properly indicated in [m]
                    obj(iv).lambda = val(iv);
                end
            end

            obj.onLambdaSet()
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

        function obj2 = rotate(obj,varargin)
            if isEven(nargin)
                error('The number of arguments of the rotate function should be an even number, in the for ''x'',45, ...')
            end

            if nargout
                obj2 = copy(obj);
            else
                obj2 = obj;
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
                obj2.direct = (RotMat*obj.direct(:)).';
                obj2.polar = (RotMat*obj.polar(:)).';
            end


        end

        function ILs = Jones(IL,varargin)
            % Jones('P', 45, 'QWP',90, 'HWP',30, 'J', {J, 45}, ...). Applies of series of polarieing plates.
            Nvar = numel(varargin);
            if mod(Nvar,2)
                error('Must have an even number of inputs')
            end
            if nargout
                ILs = copy(IL);
            else
                ILs = IL;
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
                    error('this input must be text: ''P'', ''QWP'', ''HWP'', or ''J''')
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
                    case 'J'
                        R(varargin{ii+1}{2})*varargin{ii+1}{1}*R(-varargin{ii+1}{2})*mat;
                end
            end
            ILs.Jones0(mat);
        end

        function ILs = Jones0(IL,mat)
            % Jones0(IL,mat). IL: Illumination object, mat: a Jones Matrix. Applies a Jones matrix to the incoming light IL./
            pol2 = [IL.polar(1);IL.polar(2)];
            if nargout
                ILs = copy(IL);
            else
                ILs = IL;
            end

            pol = mat*pol2;
            ILs.I = IL.I*(norm(pol)/norm(pol2))^2;
            ILs.polar = [pol(1) pol(2) 0];
        end

        function val = get.S0(obj)
            % 1st Stokes component
            val = abs(obj.polar(1)).^2 + abs(obj.polar(2)).^2;
        end

        function val = get.S1(obj)
            % 2nd Stokes component
            val = abs(obj.polar(1)).^2 - abs(obj.polar(2)).^2 ;
        end

        function val = get.S2(obj)
            % 3nd Stokes component
            val = 2*real(obj.polar(1).*obj.polar(2)');
        end

        function val = get.S3(obj)
            val = 2*imag(obj.polar(1)*obj.polar(2)');
        end

        function bool = isCircular(obj)
            if obj.S1 == 0 && obj.S2 == 0 && abs(obj.S3) == obj.S0
                bool = true;
            else
                bool = false;
            end
        end

        function onLambdaSet(obj)
            % To be overloaded in the daughter class monochromator
            % Does not any anything special here, but does action the
            % monochromator in the class Monochromator
        end
    end
end