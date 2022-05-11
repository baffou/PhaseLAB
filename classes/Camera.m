classdef Camera  <  handle
    properties
        pxSize (1,1) {mustBeNumeric} = 6.5e-6
        Nx (1,1) {mustBeInteger,mustBePositive} = 600
        Ny (1,1) {mustBeInteger,mustBePositive} = 600
        fullWellCapacity (1,1) {mustBeInteger} = 25000
        model char 
    end
    
    methods
        
        function cam=Camera(var1,NX,NY)
            % (6.5e-6,2560,2160)  pxSize in µm
            % (6.5   ,2560,2160)  pxSize in m
            % ('Zyla')
            if nargin==3 % ex: (6.5e-6,2560,2160)
                cam.Nx=NX;
                cam.Ny=NY;
                cam.pxSize=var1*(var1<1) + var1*(var1>=1)*1e-6;
            elseif nargin==2 % ex: (6.5e-6,2048)
                cam.Nx=NX;
                cam.Ny=NX;
                cam.pxSize=var1*(var1<1) + var1*(var1>=1)*1e-6;
            elseif nargin==1 % ex: ('Zyla')
                if istext(var1)
                    cam=jsonImport(strcat(var1,'.json'));
                else
                    error('If only one input, must be a camera name')
                end
            end     
            
            function obj=jsonImport(jsonFile)
                fileName = jsonFile; % filename in JSON extension
                fid = fopen(fileName); % Opening the file
                raw = fread(fid,inf); % Reading the contents
                str = char(raw'); % Transformation
                fclose(fid); % Closing the file
                data = jsondecode(str); %
                eval(['obj=' data.class '();'])

                objProps=properties(obj);
                Np=numel(objProps);

                for ip=1:Np
                    eval(['obj.' objProps{ip} '=data.' objProps{ip} ';'])
                end
            end        
        end
        
        function set.pxSize(cam,val)
            if isnumeric(val)
                if val>0
                    if val>1
                        cam.pxSize=val*1e-6;
                    elseif val<50e-6 && val>1e-6
                        cam.pxSize=val;
                    else
                        warning('this length does not look like a pixel size')
                    end
                else
                    error('A pixel size must be a positive number')
                end
            else
                error('A pixel size must be a number')
            end
        end
        
        function set.fullWellCapacity(cam,val)
            if isempty(cam.model)
                cam.fullWellCapacity=val;
            else
                error(['The full well capacity of a ' cam.model ' camera cannot be modified from its value of ' num2str(cam.fullWellCapacity) '.'])
            end
        end
        
        function obj=crop(obj,Nx0,Ny0)
            if nargin==2
                obj.Nx=Nx0;
                obj.Nx=Nx0;
            elseif nargin==3
                obj.Nx=Nx0;
                obj.Nx=Ny0;
            else
                error('Wrong number of inputs')
            end
            
        end

    end
    
    
    
end