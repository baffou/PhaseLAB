classdef RelayLens
    properties
        model 
        zoom (1,1) {mustBeNumeric}
        chromatic  logical = false
        mask     = 0 % presence of a mask in the Fourier space, within the relay lens to crop order 0
    end

    properties(SetAccess = private)
        zoomRange (1,:) {mustBeNumeric} = []  % set only with commercial cameras
    end

    methods

        function obj = RelayLens(var1)
            if nargin==1
                if istext(var1) % RelayLens('EO1.11')
                    obj = jsonImport(strcat(var1,'.json'));
                elseif isnumeric(var1)
                    obj.model = 'custom';
                    obj.zoom = abs(var1);
                else
                    error('Must be a RelayLens name or a zoom number')
                end
            end

            function obj = jsonImport(jsonFile)
                fileName = jsonFile; % filename in JSON extension
                fid = fopen(fileName); % Opening the file
                raw = fread(fid,inf); % Reading the contents
                str = char(raw'); % Transformation
                fclose(fid); % Closing the file
                data = jsondecode(str); %
                eval(['obj=' data.class '();'])
    
                objProps = properties(obj);
                Np = numel(objProps);
    
                for ip = 1:Np
                    eval(['obj.' objProps{ip} '=data.' objProps{ip} ';'])
                end
            end  
        end

        function obj = set.zoom(obj,val)
            if ~isempty(obj.zoomRange)
                if val <= max(obj.zoomRange) && val >= min(obj.zoomRange)
                    obj.zoom = val;
                else
                    error('value outside of the permitted zoom range.')
                end
            else
                obj.zoom = abs(val);
            end
        end

        function obj = set.mask(obj,val)
            if val==1 || val==true
                obj.mask=1;
            elseif val==0 || val==false
                obj.mask=0;
            end
        end
    end

end
