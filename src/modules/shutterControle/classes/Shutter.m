classdef Shutter < handle

    properties (SetAccess = private)
        portLine
        daqObj
        channel
        isOpen = false
    end

    methods

        function obj = Shutter(portLine)
            % Constructor
            %
            % Example:
            %   shutter = Shutter('port0/line0');

            obj.portLine = portLine;

            % Create DAQ object
            obj.daqObj = daq('ni');

            % Add digital output
            obj.channel = addoutput(obj.daqObj, 'Dev1', portLine, 'Digital');

            % Initialize shutter in closed state
            write(obj.daqObj, 0);

            obj.isOpen = false;
        end


        function open(obj)
            % Open shutter

            write(obj.daqObj, 1);
            obj.isOpen = true;
        end


        function close(obj)
            % Close shutter

            write(obj.daqObj, 0);
            obj.isOpen = false;
        end

    end

end
