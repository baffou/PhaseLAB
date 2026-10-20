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
            if val > 1 % wavelength certainly in [nm]
                val = val*1e-9;
            end
            obj.lambda = val;
        end

        function moveBy(obj,val)
            if val > 1 % wavelength certainly in [nm]
                val = val*1e-9;
            end
            obj.lambda = obj.lambda + val;
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