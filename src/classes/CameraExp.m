classdef (Abstract) CameraExp < handle
% Abstract class: template of any experimental camera that need to be
% controlled in live
    
    properties(Abstract, SetAccess = private)
        hndl
        CData double
    end

    properties(Abstract, Dependent, SetAccess = private)
        expTime %exposure time in seconds
        imagesize
        width
        height
        top
        left
        stride
        transformImage
        cycleMode
        triggerMode
    end

    methods(Abstract)
        rc = switchCamera(obj,val)
        setExpTime(obj)
        setMode(obj,cycleMode, triggerMode,opt)
        startAcquisition(obj,him)
        stopAcquisition(obj)
        setImageDimensions(obj,str)
        setupSDK()
    end

end

