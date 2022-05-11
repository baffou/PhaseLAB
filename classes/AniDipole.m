%% NPimaging package
% Class that defines a dipole moment, associated with a polarizability
% tensor

% author: Guillaume Baffou
% affiliation: CNRS, Institut Fresnel
% date: Apr 28, 2020

% Be carfule, in this version, when using an array of AniDipole, to simulate
% serveral AniDipole is a field of view, all the alpha must be equal. 

classdef AniDipole  < Dipole

    properties
        beta
    end
    
    properties(Dependent)
        alpha
    end
    
    properties(Access=private)
        alphaAngle=0
    end

    methods
    
        function obj=AniDipole(mat,radius,beta,z)
            obj@Dipole(mat,radius);
            obj.beta=beta;
            if nargin==4
                obj.z=z;
            end
        end
    
        function val = get.alpha(obj)
            RotMat=...
            [cosd(obj.alphaAngle) -sind(obj.alphaAngle) 0
             sind(obj.alphaAngle)  cosd(obj.alphaAngle) 0
             0                     0                    1];         
            val = abs(obj.alphaMie)*RotMat*[exp(1i*obj.beta/2),0,0;0,exp(-1i*obj.beta/2),0;0,0,1]*RotMat';
            
        end
        
        function obj = rotateTo(obj,theta)
            %rotate(theta)
            if ~isnumeric(theta)
                error('theta mush be a number')
            elseif length(theta)~=1
                error('theta should not be a vector, but a scalar')
            elseif theta*1000~=round(theta*1000)
                warning('are you sure the input of rotation() is in degres and not in radian?') 
            end
            obj.alphaAngle=theta;
        end
        
        function obj = rotateBy(obj,theta)
            %rotate(theta)
            if ~isnumeric(theta)
                error('theta mush be a number')
            elseif length(theta)~=1
                error('theta should not be a vector, but a scalar')
            elseif theta*1000~=round(theta*1000)
                warning('are you sure the input of rotation() is in degres and not in radian?') 
            end
            obj.alphaAngle=obj.alphaAngle+theta;
        end
        
        function [obj,mat]=Jones(obj,varargin)
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
            obj=Jones0(obj,mat);
            
        end
        
        function obj=Jones0(obj,mat)
            p1=obj.p(1)*mat(1,1)+obj.p(2)*mat(1,2);            
            p2=obj.p(1)*mat(2,1)+obj.p(2)*mat(2,2);            

            obj=obj.setp([p1 p2 obj.p(3)]);
        end
        
        
        
        
    end

        
        
    
end
    
    