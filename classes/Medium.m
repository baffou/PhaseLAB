%% NPimaging package
% Class that defines the refractive indices of
% the surrounding medium and the susbtrate
%
% Medium(n[,nS]).
%  n and nS can be real numbers, or belong to {'air','water','glass','BK7'},
%  meaning {1,1.33,1.51,1.51}. If only n is specified, it means a uniform
%  medium of refractive index n.

% author: Guillaume Baffou
% affiliation: CNRS, Institut Fresnel
% date: Jul 31, 2019

classdef Medium
    
    properties(Access = public)
        n0       % refractive index or nature of the upper medium
        nS0      % refractive index or nature of the substrate
    end
    
    properties(Dependent)
        n       % refractive index of the upper medium
        nS      % refractive index of the substrate
        lambda
    end

    properties(Hidden)
        Illumination Illumination
    end
    
    methods
        
        function obj = Medium(n,nS)
            % . Medium(n) or Medium(n,nS)
            if nargin==2
                obj.n0 = n;
                obj.nS0 = nS;
            elseif nargin==1
                obj.n0 = n;
                obj.nS0 = n;
            end
        end
        
        function val = get.n(obj)
            if isnumeric(obj.n0)
                val = obj.n0;
            else
                if strcmpi(obj.n0,'glass') || strcmpi(obj.n0,'BK7')
                    val = 1.51;
                elseif strcmpi(obj.n0,'water')
                    val = 1.33;
                elseif strcmp(obj.n0,'air')
                    val = 1.;
                elseif ~isempty(obj.Illumination)
                    val = real(indexReadDDA(obj.Illumination.lambda,obj.n0));
                else
                    error('There is a problem with the definition of the material')
                end
            end
        end
        
        function val = get.nS(obj)
            if isnumeric(obj.nS0)
                val = obj.nS0;
            else
                if strcmpi(obj.nS0,'glass') || strcmpi(obj.nS0,'BK7')
                    val = 1.51;
                elseif strcmpi(obj.nS0,'water')
                    val = 1.33;
                elseif strcmp(obj.nS0,'air')
                    val = 1.;
                elseif ~isempty(obj.Illumination)
                    val = real(indexReadDDA(obj.Illumination.lambda,obj.n0));
                else
                    error('There is a problem with the definition of the material')
                end
            end
        end
       
        function display(obj)
            if ~isempty(obj)
                if min(obj.n~=obj.n0)
                    fprintf(['   top mat: ' obj.n0 '\n'])
                end
                if min(obj.nS~=obj.nS0)
                    fprintf(['   sub mat: ' obj.nS0 '\n'])
                end
                fprintf('   n\t  : %.4g\n',obj.n)
                fprintf('   nS\t  : %.4g\n',obj.nS)
                if ~isempty(obj.Illumination)
                    fprintf('   lambda : %.1f nm\n',obj.Illumination.lambda*1e9)
                end
            else
                disp('empty object')
            end
        end

        function val = get.lambda(obj)
            val=obj.Illumination.lambda;
        end


    end

end