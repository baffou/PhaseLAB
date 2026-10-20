% Baptiste Marthy & Guillaume Baffou

classdef DAQ_Piezo < handle
    properties (SetAccess = private)
        DAQ_handle daq.interfaces.DataAcquisition % Handle to the Matlab object that controls the DAQ
        DAQvoltageTarget (1,3) double % Target voltage applied to the DAQ
        rawVoltageRange % Range of voltage to avoid overflow issue. Must be inside [0,10]V.
    end

    properties (Constant, Hidden)
        conversionVoltToUm = 10;
    end

    properties (Dependent, SetAccess = private, GetAccess = public)
        dynamicVoltageRange (3,2) double % The output voltage range, in range of [-10 +10] V. The effective voltage                           
                                         % range leads to [0 10] V (= voltageRange + offSet)
        positionRange % Range of the piezo displacement, in µm
    end
    
    properties(Access = private)
        isPatternRunning = false
        PiezoVoltageOffset (1,3) double = [0 0 0]
    end    

    methods (Access = public)
        function obj = DAQ_Piezo()

            obj.setVoltageRange([0 10],[0 10],[0 10]);

            obj.DAQ_handle = obj.DAQ_init(); %Loading the DAQ libraries, return handle
            obj.applyDAQvoltage([0 0 0]);

            obj.updateOffset()

        end

        function delete(obj)
            obj.DAQ_handle.delete(); %close the connection
        end

        function moveBy(obj,val,opt)
            % moveBy([dx, dy])
            % moveBy("x", dx])
            % moveBy("y", dy])
            % moveBy("z", dy])
            % moveBy("x", dx, "y", dy, "z", dz])
            arguments
                obj DAQ_Piezo
                val (1,3) double = [0 0 0]
                opt.x (1,1) double = 0
                opt.y (1,1) double = 0
                opt.z (1,1) double = 0
            end

            if all(val == [0,0,0])
                val = [opt.x, opt.y, opt.z];
            end

            obj.stopAndFlush();
            currentPos = obj.readPos_um();
            corrTargetPos = obj.verifyPosValidity(currentPos + val);
            corrDisplacement = corrTargetPos - currentPos;
            outputVolt = obj.um2V(corrTargetPos);
            obj.applyDAQvoltage(outputVolt);
            obj.updateOffset()

            fprintf('Piezo moved by [%.1f %1.f %1.f]\n',corrDisplacement(1),corrDisplacement(2),corrDisplacement(3));
        end
        
        function moveTo(obj,val)
            arguments
                obj DAQ_Piezo
                val (1,3) double  = [0 0 0]
            end

            targetPos = obj.verifyPosValidity(val);
            outputStr = ['[' num2str(targetPos) ']'];

            %Move the piezo to reach the targeted position
            outputVolt = obj.um2V(targetPos); 
            obj.applyDAQvoltage(outputVolt);
            obj.updateOffset()

            fprintf('Piezo moved to %s !\n',outputStr);
        end



        function pos = readPos_um(obj)
            readPos = obj.readDAQvoltage();
            pos = round(readPos.*obj.conversionVoltToUm,3);
        end


        function applyZeroVolt(obj)
            applyDAQvoltage(obj,[0 0 0])
            obj.updateOffset()

            pause(0.1);
        end

        function moveAlongAPattern(obj,pattern,rate)
            arguments
                obj DAQ_Piezo
                pattern (:,2) {mustBeNumeric} % Piezo voltage list
                rate {mustBePositive,mustBeInteger}
            end

            obj.DAQ_handle.Rate = rate;
            
            obj.stopAndFlush();

            pattern = pattern - obj.PiezoVoltageOffset(1:2);

            vRange = obj.dynamicVoltageRange;
            
            if any(pattern < vRange(1:2,1)' | ...
                   pattern > vRange(1:2,2)', 'all')
            
                error('Pattern exceeds the allowed voltage range.');
            
            end

            obj.DAQ_handle.preload([pattern obj.DAQvoltageTarget(3)*ones(size(pattern,1),1)]);
            target0 = obj.DAQvoltageTarget;
            obj.isPatternRunning = true;
            obj.DAQ_handle.start();

            while obj.DAQ_handle.Running
                pause(0.1);
            end

            % Restore initial DAQ voltage without estimating offset
            obj.DAQ_handle.write(target0);
            obj.DAQvoltageTarget = target0;
            obj.updateOffset()

            obj.isPatternRunning = false;
        end
    
        function stopAndFlush(obj)

            if obj.DAQ_handle.Running
        
                obj.DAQ_handle.stop();
                obj.DAQ_handle.flush();
        
                % Restore a known output voltage
                obj.DAQ_handle.write(obj.DAQvoltageTarget);
        
            else
        
                obj.DAQ_handle.flush();
        
            end        
        end

        function setVoltageRange(obj,Vrange_ch1, Vrange_ch2, Vrange_ch3)
            if Vrange_ch1(1) > Vrange_ch1(2) || Vrange_ch2(1) > Vrange_ch2(2) || Vrange_ch3(1) > Vrange_ch3(2)
                error('Minimum of the range should be smaller than maximum value of the range')
            end

            if Vrange_ch1(1) < 0 || Vrange_ch2(1) < 0 || Vrange_ch3(1) < 0
                error('Minimum value should be greater or equal to 0');
            end
            
            if Vrange_ch1(2) > 10 || Vrange_ch2(2) > 10 || Vrange_ch3(2) > 10
                error('Maximum value should be smaller or equal to 10');
            end

            obj.rawVoltageRange = [Vrange_ch1;Vrange_ch2;Vrange_ch3];
        end

        function updateOffset(obj)
        
            if obj.DAQ_handle.Running || obj.isPatternRunning
                error('Cannot update offset during a pattern.');
            end
        
            % Wait for mechanical stabilization
            pause(0.1);
        
            % Estimate the voltage offset
            obj.PiezoVoltageOffset = ...
                obj.readDAQvoltage() - obj.DAQvoltageTarget;
        
        end        
    
        function pattern = GeneratePattern(obj, patternType, patternDuration, repetition)
            nPointsElem = ceil(patternDuration * obj.DAQ_handle.Rate);
            nPoints =  nPointsElem * repetition;
            pattern = zeros(nPoints,2);
            switch patternType
                case 'Random'
                    pattern(:,1) = repmat(randi(round(obj.rawVoltageRange(1,:)*100),[1 nPointsElem])/100,[1 repetition]);
                    pattern(:,2) = repmat(randi(round(obj.rawVoltageRange(2,:)*100),[1 nPointsElem])/100,[1 repetition]);
            end
        end

    end%M public

    methods %set/get
        function voltageRange = get.dynamicVoltageRange(obj)
            
            voltageRange = obj.rawVoltageRange - obj.PiezoVoltageOffset';
            voltageRange(:,1) = ceil(voltageRange(:,1)*100)/100;
            voltageRange(:,2) = floor(voltageRange(:,2)*100)/100;

            voltageRange(:,1) = max(voltageRange(:,1), -10);
            voltageRange(:,2) = min(voltageRange(:,2),  10);
        end
    
        function positionRange = get.positionRange(obj)
            positionRange = obj.rawVoltageRange * obj.conversionVoltToUm;
        end
    end%M set get

    methods (Access = private)
        function Volt = um2V(obj,pos)
            arguments
                obj DAQ_Piezo
                pos (1,:) double
            end


            offset = obj.PiezoVoltageOffset;

            % Physical position-to-command conversion
            Volt = pos ./ obj.conversionVoltToUm - offset;

        end

        function posCorr = verifyPosValidity(obj,pos)
            arguments
                obj DAQ_Piezo
                pos (1,:) double
            end
                posCorr = max(pos, obj.positionRange(:,1)');
                posCorr = min(posCorr, obj.positionRange(:,2)');
        end
    
        function applyDAQvoltage(obj,Consigne)
            arguments
                obj DAQ_Piezo 
                Consigne (1,3) double
            end
            obj.stopAndFlush();

            if all(Consigne == [0 0 0])
                obj.DAQ_handle.write([0 0 0]);
                obj.DAQvoltageTarget = [0 0 0];
            elseif all(Consigne >= obj.dynamicVoltageRange(:,1)') ...
                && all(Consigne <= obj.dynamicVoltageRange(:,2)')

                obj.DAQ_handle.write(Consigne);
                obj.DAQvoltageTarget = Consigne;
            else 
                error('DAQ voltage target is outside the allowed range.');
            end
        end
    
        function vals = readDAQvoltage(obj)
            % measures the voltages on the ai (input) channels of the DAQ card
            % that are the voltages returned by the piezo stage
            vals = obj.DAQ_handle.read('OutputFormat','Matrix');
        end


    end

    methods (Static)
        function dq = DAQ_init()
            DAQlist = daqlist; %Search devices

            if isempty(DAQlist)
                error('No DAQ found ...')
            end
            
            deviceName = DAQlist.DeviceID;

            if size(DAQlist,1) > 1    
                deviceName = deviceName(1);
                warning('Several DAQ detected ... %s has been selected', deviceName);
            end

            
            dq = daq('ni');

            dq.Rate = 5000;

            dq.addoutput(deviceName,"ao0","Voltage"); % Ch1 = x
            dq.addoutput(deviceName,"ao1","Voltage"); % Ch2 = y
            
            dq.addinput(deviceName,'ai0','Voltage'); % Ch1 = x
            dq.addinput(deviceName,'ai1','Voltage'); % Ch2 = y
            
            dq.addoutput(deviceName,"ao2","Voltage"); % Ch3 = z
            dq.addinput(deviceName,'ai2','Voltage'); % Ch3 = z

            fprintf('The DAQ %s is connected and ready\n',DAQlist{1,"Model"})
        end
    end
end %Class

