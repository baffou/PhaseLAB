classdef (Abstract) CameraLive < handle
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
    end
    
    properties(SetAccess = {?LIVE})
        status (1,:) char {mustBeMember(status,{'live','stop','snap','timeLapse','ref','burst','external'})} = 'stop'
    end


    methods(Abstract)
        rc = turn(obj,val)
        setMode(obj,cycleMode, triggerMode,opt)
        startAcquisition(obj)
        stopAcquisition(obj)
        acquire_continuous(obj)
        acquire_fixed(obj,Nim)
        setImageDimensions(obj,str)
        setExpTime(obj)
        getROI(obj)
        setupSDK()
    end

end

