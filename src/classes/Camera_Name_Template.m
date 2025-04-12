classdef Camera_Name_Template  <  Camera
    
    properties
        hndl
        expTime
    end


    methods

        function startCamera(obj)
        end

        function stopCamera(obj)
        end

        function setMode(obj,cycleMode, triggerMode)
        end

        function startAcquisition(obj)
        end

        function stopAcquisition(obj)
        end

        function setImageDimensions(obj,str)
        end

    end

    methods(Static)
        function setupSDK()
        end
    end




end