classdef Shutter < handle

    properties %(SetAccess = private)
        portLine
        deviceID
        daqObj
        channel
        isOpen = false
    end

    methods

        function obj = Shutter(portLine,deviceID)
            arguments
                portLine  % text or number
                deviceID = []    % text or number
            end
            % Constructor
            %
            % SH = Shutter("Dev4","port0/line0")
            % SH = Shutter(4,[0,0])


            if nargout == 0
                error('you mush define an output')
            end

            if isempty(deviceID)
                d = daqlist;
                obj.deviceID = d.DeviceID;
            elseif isnumeric(deviceID)
                if round(deviceID) ~= deviceID % if not an integer
                    error('Device must be integer')
                end
                obj.deviceID = "Dev"+deviceID;
            elseif ~istext(deviceID)
                error('Device must be a number, or text')
            else
                obj.deviceID = deviceID;
            end

            if isnumeric(portLine)
                if numel(portLine)~=2
                    error('If numeric, PortLine must be a 2-vector')
                end
                obj.portLine = "port"+ portLine(1) + "/line" + portLine(2);
            elseif ~istext(portLine)
                error('PortLine must be a 2-vector, or text')
            else
                obj.portLine = portLine;
            end



            % Create DAQ object
            obj.daqObj = daq('ni');

            % Add digital output
            obj.channel = addoutput(obj.daqObj,obj.deviceID, obj.portLine, 'Digital');

            fprintf('Shutter connected successfully to %s on device %s.\n', portLine, deviceID);


            % Initialize shutter in closed state
            obj.close()
        end


        function open(obj)
            % Open shutter
            try
                write(obj.daqObj, 1);
            catch
                error('Hardware is reserved. To unreserve the hardware, try >> daqreset')
            end
            obj.isOpen = true;

        end


        function close(obj)
            % Close shutter
            try
                write(obj.daqObj, 0);
            catch
                error('Hardware is reserved. To unreserve the hardware, try >> daqreset')
            end
            obj.isOpen = false;

        end

        function delete(obj)
            % clear SH call the detructor and release the port without
            % having to call daqreset
            obj.daqObj = [];
            
        end

    end

end
