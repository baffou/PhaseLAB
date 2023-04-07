%% NPimaging package
% Class that defines the objective lens of a microscope
%
% Objective(Mobj,NA[,brand]).
%  Mobj: The magification, as it is written on the objective lens.
%        It can be different from the actual magnification of the
%        microscope if the microscope is endowed with a tube length.
%  NA:   Numerical aperture of the microscope
%  brand: Brand of the objective, only necessary when associated with
%         a microscope endowed with a tube lens.
            
% author:      Guillaume Baffou
% affiliation: CNRS, Institut Fresnel
% date:        Aug 1, 2020

classdef Objective  <  handle & matlab.mixin.Copyable
    
    properties(SetAccess = protected, GetAccess = public)
        Mobj (1,1) {mustBePositive} = 100     % Magnification of the objective, specified by the manufacturer.
        NA   (1,1) {mustBeNumeric, mustBePositive} = 1.3     % Numerical aperture of the microscope objective
        objBrand char ='Olympus'  % Brand of the objective (can be 'Nikon', 'Thorlabs', 'Leica', 'Olympus' or 'Zeiss', nothing else. Proper specification is MANDATORY to properly estimate the magnification).
    end
    properties%(NonCopyable)
        mask PCmask
    end
    
    
    
    
    methods
        
        function obj = Objective(Mobj,NA,brand)
            % . Objective() or Objective(Mobj,NA) or Objective(Mobj,NA,brand)
            if nargin~=0
                if nargin==2
                    obj.Mobj = abs(Mobj);
                    obj.NA = NA;
                elseif nargin==3
                    obj.Mobj = abs(Mobj);
                    obj.NA = NA;
                    obj.objBrand = brand;
                else
                    error('wrong number of inputs')
                end
            end
        end
        
        function set.Mobj(obj,val)
            if ~isnumeric(val)
                error('Magnification should be a number')
            elseif val<=0
                error('Objective magnification must be a positive number')
            elseif val/10~=round(val/10) || val>100
                warning('are you sure this is the magnification written on the objective?')
            end
            obj.Mobj = val;
        end
        
        function set.NA(obj,val)
            if ~isnumeric(val)
                error('NA should be a number')
            elseif val<=0
                error('NA must be a positive number')
            elseif val>1.5
                warning(['are you sure ' num2str(val) ' is the NA written on the objective? It looks too big.'])
            end
            obj.NA = val;
        end
        
        function set.objBrand(obj,val)
            if ~ischar(val)
                error('NA should be a character string')
            end
            
            if strcmpi(val,'Olympus')
                obj.objBrand = 'Olympus';
            elseif strcmp(val,'Nikon')
                obj.objBrand = 'Nikon';
            elseif strcmp(val,'Zeiss')
                obj.objBrand = 'Zeiss';
            elseif strcmp(val,'Leica')
                obj.objBrand = 'Leica';
            elseif strcmp(val,'Thorlabs')
                obj.objBrand = 'Thorlabs';
            else
                error(['This objective brand, ' val ', is not known by PhaseLAB.'])
            end
            
            
        end
    end
    

end