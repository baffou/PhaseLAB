classdef CrossGrating  <  handle & matlab.mixin.Copyable
    % class that define a cross-grating used in CGM

    properties (SetAccess = private)
        name    char = 'undefined' % name
        Gamma   (1,1) % Period
        depth   (1,1) double % Etching depth. Only used and usefull for CGMinSilico simulations
        RI      (1,1) double % Refractive index of the material
        lambda0 (1,1) double % Wavelength the grating is made for
    end

    properties
        angle = acos(3/5)   % rotation angle of the grating
    end
        
    methods

        function CG = CrossGrating(name,opt)
            % CrossGrating()
            % CrossGrating('F2')
            % CrossGrating(Gamma=39e-6,depth=554e-9)
            % CrossGrating(Gamma=39e-6,lambda0=600e-9)
            arguments
                name (1,:) char = 'undefined' % name
                opt.Gamma (1,1) double = 0
                opt.depth (1,1) double = 0
                opt.lambda0 (1,1) double = 0
                opt.RI (1,1) double = 1.46 % Quartz by default
            end

            if ~strcmpi(name,'undefined') % ('P2')
                CG = jsonImport(strcat(name,'.json'));
            else
                CG.Gamma = opt.Gamma;
                CG.RI = opt.RI;
                if opt.depth~=0 && opt.lambda0~=0
                    error('You cannot specify at the same time lambda0 and depth')
                end
                if opt.depth==0 && opt.lambda0==0
                    warning('You should specify at least lambda or depth or lambda0')
                end
                if opt.depth~=0
                    CG.set_depth(opt.depth);
                elseif  opt.lambda0~=0
                    CG.set_lambda0(opt.lambda0);
                end
            end

            function obj = jsonImport(jsonFile)
                obj = json2obj(jsonFile);
            end
        end

        function set.depth(obj,val)
            obj.depth = convert_nm(val);
        end

        function set.lambda0(obj,val)
            obj.lambda0 = convert_nm(val);
        end

        function set.Gamma(obj,val)
            obj.Gamma = convert_um(val);
        end

        function set_lambda0(obj,val)
            obj.lambda0 = val;
            obj.depth = obj.lambda0/((obj.RI-1)*2);
        end

        function set_depth(obj,val)
            obj.depth = val;
            obj.lambda0 = obj.depth*(obj.RI-1)*2;
        end

    end
end