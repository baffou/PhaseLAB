%% PhaseLAB package
% Class that defines the microscope setup and layered medium)
%
% Microscope(OB)
%  OB: Objective object
%  ->To be used for numerical simulations
%
% Microscope(OB,f_TL)
%  f_TL: focal length of the tube length
%  -> to be used when importing experimental images.
%  Can also be used for numerical simulations.
%
% Microscope(OB,f_TL,camera,software)
%  -> camera ID and software only required when importing and
%  processing interferograms
%
% OB can be an object vector.

% author: Guillaume Baffou
% affiliation: CNRS, Institut Fresnel
% date: Aug 24, 2020

classdef Microscope  <  handle & matlab.mixin.Copyable
    
    properties
        Objective Objective % Objective object
        CGcam  %CGcamera % CGcamera object
        f_TL      (1,1) {mustBeNumeric, mustBePositive} = 180 % Actual focal length of the tube lens used in the microscope not necessarily the one advised by the constructor.
        software  char % software used with the microscope. Should be within the private property list obj.softwareList
    end
    
    properties (Dependent)
        M (1,1) {mustBeNumeric}        % Microscope magnification, take into accound Mobj, f_TL, relaylensZoom 
        pxSize      % pixel size at the focal plane (usually in the 60 nm range)
        dxSize      % pixel size at the image plane, ie dexel size of the camera if zoom=1 (usually in the 6 µm range)
    end
    
    properties(Access=public)
        zo (1,1) {mustBeNumeric} = 0              % Position in z of the imaged plane. Only useful for numerical simulation, not for processing exp data.
        T0                  % Microscope temperature
    end

    properties (Access = private, Constant)
        softwareList = {'Sid4Bio','PHAST','CG','PhaseLIVE','other'}
        f_Nikon      = 200;  % focal length of the TL recommended by Nikon
        f_Thorlabs   = 200;  % focal length of the TL recommended by Thorlabs
        f_Leica      = 200;  % focal length of the TL recommended by Leica
        f_Olympus    = 180;  % focal length of the TL recommended by Olympus
        f_Zeiss      = 165;  % focal length of the TL recommended by Zeiss
    end
     
    properties(Access=private)
        f_brand        % tubelens recommended by the manufacturer. Used to compute the actual mgnification, which can be different from the one specified by the manufacturer if another tube lens focal length is used.        
    end
    
    
    methods

        function m=Microscope(OB,f_TL,CGcam,software)
            m.Objective=Objective();
            m.CGcam=CGcamera();
            if nargin~=0

                if nargin>=5
                    error(['input numbers must be either 1, 2 or 4. Here it is ' num2str(nargin)])
                end
                
                if ~isa(OB,'Objective')
                    error('First input must be an Objective object')
                end
                
                if nargin==4
                    m.CGcam=CGcam;
                    m.software=software;
                end
                
                if nargin==3
                    m.CGcam=CGcam;
                    m.software='other';
                end
                
                m.Objective=OB;
                if nargin~=1
                    m.f_TL=f_TL;
                end                        
            end %nargin~=0
            eval(['m.f_brand=m(1).f_' m.Objective.objBrand ';'])

        end      
           
        function set.zo(obj,z)
            if abs(z)>0.1
                warning('Are you sure z0 is in nanometer?')
            end
            obj.zo=z;
        end

        function set.software(m,str)
            if isa(str,'char')
                if ismember(str,m.softwareList)
                    m.software=str;
                else
                    fprintf(['Error: ' '''' str ''': Unkown software name.\n'])
                    fprintf('Here is the list of software names:\n\n')

                    for ii=1:numel(m.softwareList)
                        disp(['''' m.softwareList{ii} ''''])
                    end
                    error(' ')
                end
            else
                error('the property software must be a string')
            end                    
        end

        function set.CGcam(m,str)
            if isa(str,'char')
                Lia= ismember(str,m.camList);
                if max(Lia)
                    m.CGcam=CGcamera(str);
                else
                    fprintf(['Error: ' '''' str ''': Unkown camera name.\n'])
                    fprintf('Here is the list of camera names:\n\n')

                    for ii=1:numel(m.camList)
                        disp(['''' m.camList{ii} ''''])
                    end
                    fprintf('\n')

                    error(' ')
                end
            elseif isa(str,'CGcamera')
                m.CGcam=str;
            else
                error('the property software must be a string')
            end                    
            
        end
        
        function val=pxSizePhasics(obj)
            % returns the pixel size of the phase image in [m]. When using a Phasics (binning) software.
            p=obj.CGcam.Camera.dxSize;
            val=abs(p*obj.CGcam.zeta/(obj.CGcam.zoom*obj.M));
        end
        
        function val=pxSizeItf(obj)
            % returns the pixel size of the interferogram image in the object plane [m].
            pxSizeCamera=obj.CGcam.Camera.dxSize;
            val=abs(pxSizeCamera/(obj.M));
        end
        
        function val=camList(obj)
            % returns the list of available cameras
            cameraList=dir([obj.MIpath '/../CGcameras/*.txt']);
            Nc=numel(cameraList);
            val=cell(Nc,1);
            for ic=1:Nc
                val{ic}=cameraList(ic).name(1:end-4);
            end
        end    
        
        function set.Objective(obj,val)
            if isa(val,'Objective')
                obj.Objective=val;
            end
        end
        
        function set.f_TL(obj,val)
            if val<10 % focal length specified in [m]
                obj.f_TL=val*1000;
            else
                obj.f_TL=val;
            end
        end

        function val=Mobj(m)      % Magnification of the objective, specified by the manufacturer.
            val=m.Objective.Mobj;
        end

        function val=NA(m)      % Magnification of the objective, specified by the manufacturer.
            val=m.Objective.NA;
        end

        function val=get.dxSize(obj)
            % pixel size at the image plane
            obj.CGcam.Camera.dxSize
            obj.CGcam.RL.zoom
            if ~isempty(obj.CGcam.RL)
                val=obj.CGcam.Camera.dxSize/obj.CGcam.RL.zoom;
            else
                val=obj.CGcam.Camera.dxSize;
            end
        end

        function val=get.pxSize(obj)
            % pixel size at the focal plane
            val=abs( obj.dxSize()/obj.M );
        end

        function val=objBrand(m)      % Magnification of the objective, specified by the manufacturer.
            val=m.Objective.objBrand;
        end

        function val=get.M(m)
            %val=-m.Mobj*m.CGcam.zoom*m.f_TL/m.f_brand;
            val=-m.Mobj*m.f_TL/m.f_brand; % I remove the zoom from this expression to match the camera-shrink description
        end

        function sigma=sigmaTheo(MI)
            Z=abs(MI.CGcam.zoom);
            Lambda=MI.CGcam.CG.Gamma;
            d=MI.CGcam.distance();
            w=MI.CGcam.Camera.fullWellCapacity;
            Nim=1;
            Npx=MI.CGcam.Camera.Nx;
            p=MI.CGcam.Camera.dxSize;
            sigma=p*Lambda/(Z*d) * sqrt(2/(Nim*w)) * sqrt(log10(Npx*Npx))/(8*sqrt(2));
        end
        
    end


    methods(Static,Hidden)

        function val=MIpath()
            val=fileparts(which('Microscope.m'));
        end

    end

end