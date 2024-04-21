classdef Camera  <  handle & matlab.mixin.Copyable
    
    properties(SetAccess = {?ImageEM,?ImageQLSI,?JS}) % to enable modif of the dxSize due to binning or by json2obj
        dxSize (1,1) {mustBeNumeric} = 6.5e-6
        Nx (1,1) {mustBeInteger,mustBePositive} = 600
        Ny (1,1) {mustBeInteger,mustBePositive} = 600
        fullWellCapacity (1,1) {mustBeInteger} = 15000
        offset (1,1) double = 100
        model char
        colorChannels double {mustBeInteger, mustBeGreaterThan(colorChannels,0),...
                              mustBeLessThan(colorChannels,3)} = 1 % number of colors of the camera sensor
                                         % For the moment, working only for
                                         % = 2 and 3
        crosstalk12 = 0
        crosstalk21 = 0
    end
    
    methods
        
        function cam = Camera(var1,NX,NY)
            % (6.5e-6,2560,2160)  dxSize in µm
            % (6.5   ,2560,2160)  dxSize in m
            % ('Zyla')
            if nargin==3 % ex: (6.5e-6,2560,2160)
                cam.Nx = NX;
                cam.Ny = NY;
                cam.dxSize = var1*(var1<1) + var1*(var1>=1)*1e-6;
            elseif nargin==2 % ex: (6.5e-6,2048)
                cam.Nx = NX;
                cam.Ny = NX;
                cam.dxSize = var1*(var1<1) + var1*(var1>=1)*1e-6;
            elseif nargin==1 % ex: ('Zyla')
                if istext(var1)
                    cam = jsonImport(strcat(var1,'.json'));
                elseif isnumeric(var1)
                    cam.Nx = 2048;
                    cam.Ny = 2048;
                    cam.dxSize = var1*(var1<1) + var1*(var1>=1)*1e-6;
                else
                    error('If only one input, must be a camera name')
                end
            end     
            
            function obj = jsonImport(jsonFile)
                obj = JS.json2obj(jsonFile);
            end
        end

        function set.dxSize(cam,val)
            if isnumeric(val)
                if val>0
                    if val>1
                        cam.dxSize = val*1e-6;
                    elseif val<50e-6 && val>1e-6
                        cam.dxSize = val;
                    else
                        cam.dxSize = val;
                        warning('this length does not look like a dexel size')
                    end
                else
                    error('A dexel size must be a positive number')
                end
            else
                error('A dexel size must be a number')
            end
        end
        
        function set.fullWellCapacity(cam,val)
            if isempty(cam.model)
                cam.fullWellCapacity = val;
            else
                error(['The full well capacity of a ' cam.model ' camera cannot be modified from its value of ' num2str(cam.fullWellCapacity) '.'])
            end
        end
        
        function obj = crop(obj,Nx0,Ny0)
            if nargin==2
                obj.Nx = Nx0;
                obj.Nx = Nx0;
            elseif nargin==3
                obj.Nx = Nx0;
                obj.Nx = Ny0;
            else
                error('Wrong number of inputs')
            end
            
        end

    end
    
end