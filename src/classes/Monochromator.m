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

    end
end