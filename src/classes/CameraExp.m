classdef (Abstract) CameraExp < handle
% Abstract class: template of any experimental camera that need to be
% controlled in live
    
    properties(Abstract, SetAccess = private)
        hndl
        %CData double
        imageDimensionsList
    end

    properties(Abstract, Dependent, SetAccess = private)
        expTime % exposure time in seconds
        imagesize
        width   % crop dimension, must be < Nx
        height  % crop dimension, must be < Ny
        top
        left
        stride
        transformImage
        cycleMode
        triggerMode
    end
    
    methods(Abstract)
        rc = turn(obj,val)
        setExpTime(obj)
        setMode(obj,cycleMode, triggerMode,opt)
        startAcquisition(obj,him)
        stopAcquisition(obj)
        setImageDimensions(obj,str)
        setupSDK()
        getROI()
    end

end

