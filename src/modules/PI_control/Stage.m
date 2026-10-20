classdef (Abstract) Stage < handle
% Abstract class: template of any translation stage that can be actuated
% using Matlab

    properties (Abstract, SetAccess = private, GetAccess = public)
        hndl % Controller or DAQ card handle
        SerialNumber %The serial number of the main controller
        axes (1,:) char {mustBeMember(axes,{'','X','XY','XYZ','Z'})} % Axes being controlled
        isJoystickUsable logical
    end

    properties(Abstract, Dependent)
        X
        Y
        Z
    end


    methods(Abstract)
             
        connect(obj,val,axes)
        disconnect(obj)

        getVelocity(obj)
        setVelocity(obj,val)
        moveTo(obj,pos,opt)
        moveBy(obj,pos,opt)

        bool = isJoystickON(obj)
        waitUntilStageStill(obj)
        stopStageMotion(obj)

    end


    methods(Static)


        serialNumbers = serialNumbersAvailable()

    end

end