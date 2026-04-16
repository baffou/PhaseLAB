classdef Monochromator  <  handle  &  Illumination

    properties
        hndl    % Monochromator handle
    end


    methods

        function obj = Monochromator(val)
            % Monochromator(IL)
            % Monochromator(lambda)
            arguments
                val
            end
            if isa(val,'Illumination')
                IL = val;
            elseif isnumeric(val)
                IL = Illumination(val); 
            end
            obj@Illumination(IL.lambda, IL.Medium, IL.I, IL.polar);
        end

        function moveTo(obj,val)
            obj.lambda = val;
        end

        function moveBy(obj,val)
            if val > 1 % wavelength certainly in [nm]
                val = val*1e-9;
            end
            obj.lambda = obj.lambda + val;
        end

        function onLambdaSet(obj)
            %obj.hndl.MoveTo(obj.lambda)
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
        function setupSDK()

        end
    end
end