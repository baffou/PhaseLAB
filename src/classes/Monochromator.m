classdef Monochromator  <  handle  &  Illumination

    properties
        hndl    % Monochromator handle
        lambdaWidth = 20;
    end


    methods

        function obj = Monochromator(val)
            % Monochromator(IL)
            % Monochromator(lambda)
            arguments
                val = 600e-9
            end
            if isa(val,'Illumination')
                IL = val;
            elseif isnumeric(val)
                IL = Illumination(val); 
            end
            obj@Illumination(IL.lambda, IL.Medium, IL.I, IL.polar);

            obj.connect()

        
        end

        function connect(obj)
            obj.hndl= obj.setupSDK();

            % Connexion
            connected = logical(obj.hndl.connect());
            
            % Vérification
            disp(connected)
        end


        function moveTo(obj,val)
            if val < 1 % wavelength certainly in [m]
                val = val*1e9;
            end
            obj.lambda = val;
            w = obj.lambdaWidth;
            obj.hndl.set_filter(obj.lambda*1e9 - w/2, obj.lambda*1e9 + w/2);
        end

        function moveBy(obj,val)
            if val > 1 % wavelength certainly in [nm]
                val = val*1e-9;
            end
            obj.lambda = obj.lambda + val;
        end

        function val = adjustLambda(obj,val)
            arguments
                obj
                val (1,1) double
            end

            if val < 1
                val = val*1e9;
            end
            if val < 510 || val >1200
                warning('lambda value out of range. no change made')
                val = lambda2m(obj.lambda);
                return
            end

            if val - obj.lambdaWidth/2 < 500
                warning('lambda value out of range')
                val = obj.lambdaWidth/2 + 500;
            end
        
        end

        function set.lambdaWidth(obj, val)
            arguments
                obj
                val {mustBeGreaterThanOrEqual(val,20),mustBeLessThanOrEqual(val,100)}
            end
            if obj.lambda*1e9 - val/2 < 500
                val = obj.lambda*1e9 - 500;
                warning('lambdaWidth value out of range')
            end
            obj.lambdaWidth = val;
            obj.hndl.set_filter(obj.lambda*1e9 - val/2, obj.lambda*1e9 + val/2);
        end


        function rc = turn(obj, state)
            arguments
                obj
                state {mustBeMember(state,{'on','off'})}
            end

            switch state
                case 'on'
                    pause(1)
                    rc = obj.start();
                case 'off'
                    pause(1)
                    rc = obj.stop();
            end
        end

        function rc = start(obj)
            rc = 0;
        end

        function rc = stop(obj)
            rc = 0;
        end

    end

    methods(Static)
        function SDK = setupSDK()
            % Configuration Python (à faire une seule fois)
            pyenv(ExecutionMode="OutOfProcess");
            
            % Dossier contenant les fichiers Python
            folder0 = fullfile(fileparts(mfilename('fullpath')));
            folder = [folder0 '..\modules\live\SDK\Leukos-Laser-Bebop-Control'];
            
            insert(py.sys.path, int32(0), folder);
            
            % Importer le module
            SDK = py.importlib.import_module('BebopMatlab');
            
        end
    end
end