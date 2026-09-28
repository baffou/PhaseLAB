classdef (Abstract) CameraLive < handle
% Abstract class: template of any experimental camera that need to be
% controlled in live
    
    properties(Abstract, SetAccess = private)
        hndl
        %CData double
        imageDimensionsList
    end

    properties(SetAccess = {?LIVE})
        status (1,:) char {mustBeMember(status,{'Live','Stop','Snap','TimeLapse','Ref','Burst','External'})} = 'Stop'
    end

    properties(Abstract, Dependent, SetAccess = private)
        expTime   % exposure time in seconds
        imagesize % image size in bytes
        width     % crop dimension, must be < Nx
        height    % crop dimension, must be < Ny
        top
        left
        stride
    end
    
    methods(Abstract)
        rc = turn(obj,val)
        setMode(obj,cycleMode, triggerMode,opt)
        startAcquisition(obj)
        stopAcquisition(obj)
        acquire_continuous(obj)
        acquire_fixed(obj,Nim)
        setCameraROI(obj,str)
        setExpTime(obj) % sets the exposure time in [ms]
        getROI(obj)
        setupSDK()
    end

end

