% TODO: permettre l'utilisationde 1, 2, ou 3 canaux


classdef DAQstage < Stage
    properties (SetAccess = private)
        hndl % Handle to the Matlab object that controls the DAQ
        SerialNumber 
        axes % Axes being controlled
        DAQvoltageTarget (1,:) double % Target voltage applied to the DAQ
        rawVoltageRange % Range of voltage to avoid overflow issue. Must be inside [0,10]V.
        isJoystickUsable logical = false
    end

    properties (Constant, Hidden)
        conversionVoltToUm = 10;
    end

    properties (Dependent)
        X % measured position in um
        Y % measured position in um
        Z % measured position in um
        dynamicVoltageRange (:,2) double % The output voltage range, in range of [-10 +10] V. The effective voltage                           
                                         % range leads to [0 10] V (= voltageRange + offSet)
        positionRange % Range of the stage displacement, in µm
    end
    
    properties(Access = private)
        isPatternRunning = false
        StageVoltageOffset (1,:) double = [0 0 0]
    end    

    methods (Access = public)
        function obj = DAQstage(model,axes)
            % piezo = DAQstage();
            % piezo = DAQstage('auto');
            % ST = DAQstage('USB-6343 (BNC)');
            arguments
                model = []
                axes = 'XY'
            end
            
            obj.connect(model,axes); %Loading the DAQ libraries, return handle
            

        end

        function rc = connect(obj,model,axes)
            arguments
                obj
                model
                axes {mustBeMember(axes,{'X','XY','XYZ'})}
            end

            if strcmp(model,'auto')

                dq = daqlist("ni");
                deviceName = string(dq.DeviceID(1));
                fprintf('The DAQ %s is connected and ready\n',dq.Model{1})
                rc = 0;
            elseif istext(model) % DAQ name. ex: "USB-6343 (BNC)"
                models = DAQstage.serialNumbersAvailable();
                dq = daqlist("ni");    
                idx = find(string(dq.Model) == model);
            
                if isempty(idx)
                    warning('DAQ model not found.');
                    rc = -1;
                    return
                end
            
                % Retrieve the device identifier
                deviceName = string(dq.DeviceID(idx(1)));
    
                fprintf('The DAQ %s is connected and ready\n',models{1})
                rc = 0;
            else
                return
            end

            d = daq('ni');
            obj.SerialNumber = model;
            obj.hndl = d;
            obj.axes = axes;

            d.Rate = 5000;

            obj.setVoltageRange([0 10]);

            if contains(axes,'X')
                d.addoutput(deviceName,"ao0","Voltage"); % Ch1 = x
                d.addinput(deviceName,'ai0','Voltage');  % Ch1 = x
            end            
            
            if contains(axes,'Y')
                d.addoutput(deviceName,"ao1","Voltage"); % Ch2 = y
                d.addinput(deviceName,'ai1','Voltage');  % Ch2 = y
            end

            if contains(axes,'Z')
                d.addoutput(deviceName,"ao2","Voltage"); % Ch3 = z
                d.addinput(deviceName,'ai2','Voltage');  % Ch3 = z
            end
            try
                obj.applyDAQvoltage(zeros(1,length(obj.axes)))
                obj.updateOffset()
            catch
                warning('The DAQ is maybe already piloted by something else. Try >> daqreset')
                rc = -1;
            end
        end

        function disconnect(obj)
            obj.hndl
            obj.SerialNumber = [];
            obj.axes = [];
            obj.delete()
        end

        function delete(obj)
            obj.hndl.delete(); %close the connection
        end

        function moveBy(obj,val,opt)
            % moveBy([dx, dy])
            % moveBy("x", dx])
            % moveBy("y", dy])
            % moveBy("z", dy])
            % moveBy("x", dx, "y", dy, "z", dz])
            arguments
                obj DAQstage
                val (1,:) double {mustBeFinite} = [0 0 0]
                opt.X (1,1) double {mustBeFinite} = 0
                opt.Y (1,1) double {mustBeFinite} = 0
                opt.Z (1,1) double {mustBeFinite} = 0
            end
        
            if all(val == 0)
                val = [opt.X, opt.Y, opt.Z];
                Naxes = length(obj.axes);
                val = val(1:Naxes);
            end
        
            % Read the current position
            obj.stopStageMotion();
            currentPos = obj.readPos_um();
        
            % Calculate the target position
            targetPos = obj.verifyPosValidity(currentPos + val);
            displacement = targetPos - currentPos;
        
            % Apply the initial position command
            outputVolt = obj.um2V(targetPos);
            obj.applyDAQvoltage(outputVolt);
        
            % Iterative correction using position feedback
            tolerance = 0.05; % um
            maxIterations = 10;
            gain = 0.5;
        
            for k = 1:maxIterations
        
                % Allow the stage to settle
                pause(0.1);
        
                % Measure the actual position
                measuredPos = obj.readPos_um();
        
                % Calculate the position error
                errorPos = targetPos - measuredPos;
        
                if all(abs(errorPos) < tolerance)
                    break
                end
        
                % Correct the DAQ command
                outputVolt = obj.DAQvoltageTarget + ...
                             gain * errorPos / obj.conversionVoltToUm;
        
                obj.applyDAQvoltage(outputVolt);
        
            end
        
            disp('Stage moved by:')
            disp(displacement)
        
        end
        
        function moveTo(obj,val)
            arguments
                obj DAQstage
                val (1,:) double {mustBeFinite}
            end
        
            targetPos = obj.verifyPosValidity(val);
        
            % Apply the initial position command
            outputVolt = obj.um2V(targetPos);
            obj.applyDAQvoltage(outputVolt);
        
            % Iterative correction using position feedback
            tolerance = 0.05; % um
            maxIterations = 10;
            gain = 0.5;

            for k = 1:maxIterations
        
                % Allow the stage to settle
                pause(0.1);
        
                % Measure the actual position
                measuredPos = obj.readPos_um();
        
                % Calculate the position error
                errorPos = targetPos - measuredPos;
        
                if all(abs(errorPos) < tolerance)
                    break
                end
        
                % Correct the DAQ command
                outputVolt = obj.DAQvoltageTarget + ...
                             gain * errorPos / obj.conversionVoltToUm;
        
                obj.applyDAQvoltage(outputVolt);
        
            end

            switch length(obj.axes)==1
                case 1
                    fprintf('Stage target: [%.2f] um\n',targetPos);
                case 2
                    fprintf('Stage target: [%.2f %.2f] um\n',targetPos);
                case 3
                    fprintf('Stage target: [%.2f %.2f %.2f] um\n',targetPos);
            end
        end

        function pos = readPos_um(obj)
            readPos = obj.readDAQvoltage();
            pos = round(readPos.*obj.conversionVoltToUm,3);
        end

        function applyZeroVolt(obj)
            applyDAQvoltage(obj,zeros(1,length(obj.axes)))
            obj.updateOffset()

            pause(0.1);
        end

        function moveAlongAPattern(obj,pattern,rate)
            arguments
                obj DAQstage
                pattern (:,2) {mustBeNumeric} % Stage voltage list
                rate {mustBePositive,mustBeInteger}
            end

            obj.hndl.Rate = rate;
            
            obj.stopStageMotion();

            pattern = pattern - obj.StageVoltageOffset(1:2);

            vRange = obj.dynamicVoltageRange;
            
            if any(pattern < vRange(1:2,1)' | ...
                   pattern > vRange(1:2,2)', 'all')
            
                error('Pattern exceeds the allowed voltage range.');
            
            end

            obj.hndl.preload([pattern obj.DAQvoltageTarget(3)*ones(size(pattern,1),1)]);
            target0 = obj.DAQvoltageTarget;
            obj.isPatternRunning = true;
            obj.hndl.start();

            obj.waitUntilStageStill()

            % Restore initial DAQ voltage without estimating offset
            obj.hndl.write(target0);
            obj.DAQvoltageTarget = target0;
            obj.updateOffset()

            obj.isPatternRunning = false;
        end

        function waitUntilStageStill(obj)
            while obj.hndl.Running
                pause(0.1);
            end
        end

        function bool = isJoystickON(obj)
            bool = false;
        end

        function stopStageMotion(obj)

            if obj.hndl.Running
        
                obj.hndl.stop();
                obj.hndl.flush();
        
                % Restore a known output voltage
                obj.hndl.write(obj.DAQvoltageTarget);
        
            else
        
                obj.hndl.flush();
        
            end        
        end

        function setVoltageRange(obj,Vrange)
            if Vrange(1) > Vrange(2)
                error('Minimum of the range should be smaller than maximum value of the range')
            end

            if Vrange(1) < 0
                error('Minimum value should be greater or equal to 0');
            end
            
            if Vrange(2) > 10
                error('Maximum value should be smaller or equal to 10');
            end

            obj.rawVoltageRange = repmat(Vrange,length(obj.axes),1);
        end

        function updateOffset(obj)
        
            if obj.hndl.Running || obj.isPatternRunning
                error('Cannot update offset during a pattern.');
            end
        
            % Wait for mechanical stabilization
            pause(0.1);
        
            % Estimate the voltage offset
            obj.StageVoltageOffset = ...
                obj.readDAQvoltage() - obj.DAQvoltageTarget;
        
        end        
    
        function pattern = GeneratePattern(obj, patternType, patternDuration, repetition)
            nPointsElem = ceil(patternDuration * obj.hndl.Rate);
            nPoints =  nPointsElem * repetition;
            pattern = zeros(nPoints,2);
            switch patternType
                case 'Random'
                    pattern(:,1) = repmat(randi(round(obj.rawVoltageRange(1,:)*100),[1 nPointsElem])/100,[1 repetition]);
                    pattern(:,2) = repmat(randi(round(obj.rawVoltageRange(2,:)*100),[1 nPointsElem])/100,[1 repetition]);
            end
        end

        function setVelocity(obj,val)

        end

        function val = getVelocity(obj)
            val = 0;
        end
        
    end%M public

    methods %set/get
        function voltageRange = get.dynamicVoltageRange(obj)
            
            voltageRange = obj.rawVoltageRange - obj.StageVoltageOffset';
            voltageRange(:,1) = ceil(voltageRange(:,1)*100)/100;
            voltageRange(:,2) = floor(voltageRange(:,2)*100)/100;

            voltageRange(:,1) = max(voltageRange(:,1), -10);
            voltageRange(:,2) = min(voltageRange(:,2),  10);
        end
    
        function positionRange = get.positionRange(obj)
            positionRange = obj.rawVoltageRange * obj.conversionVoltToUm;
        end

        function val = get.X(obj)
            readPos = obj.readDAQvoltage();
            val = readPos(1)*obj.conversionVoltToUm;
        end
        function val = get.Y(obj)
            readPos = obj.readDAQvoltage();
            val = readPos(2)*obj.conversionVoltToUm;
        end
        function val = get.Z(obj)
            readPos = obj.readDAQvoltage();
            val = readPos(3)*obj.conversionVoltToUm;
        end
    end%M set get

    methods (Access = private)
        function Volt = um2V(obj,pos)
            arguments
                obj DAQstage
                pos (1,:) double
            end


            offset = obj.StageVoltageOffset;

            % Physical position-to-command conversion
            Volt = pos ./ obj.conversionVoltToUm - offset;

        end

        function posCorr = verifyPosValidity(obj,pos)
            arguments
                obj DAQstage
                pos (1,:) double
            end
                posCorr = max(pos, obj.positionRange(:,1)');
                posCorr = min(posCorr, obj.positionRange(:,2)');
        end
    
        function applyDAQvoltage(obj,Consigne)
            arguments
                obj DAQstage 
                Consigne (1,:) double
            end
            obj.stopStageMotion();
            Consigne = round(Consigne,2);
            if all(Consigne == 0)
                obj.hndl.write(zeros(1,length(obj.axes)));
                obj.DAQvoltageTarget = zeros(1,length(obj.axes));
            elseif all(Consigne >= obj.dynamicVoltageRange(:,1)') ...
                && all(Consigne <= obj.dynamicVoltageRange(:,2)')

                obj.hndl.write(Consigne);
                obj.DAQvoltageTarget = Consigne;
            else 
                disp(Consigne)
                disp(" is not included in:")
                obj.dynamicVoltageRange
                error('DAQ voltage target is outside the allowed range.');
            end
        end
    
        function vals = readDAQvoltage(obj)
            % measures the voltages on the ai (input) channels of the DAQ card
            % that are the voltages returned by the stage
            vals = obj.hndl.read('OutputFormat','Matrix');
        end

        function [Vout, Vin] = testCalibration(obj)
        
            % Test several DAQ output voltages
            Vout = (1:0.5:8)';
        
            Vin = zeros(numel(Vout),3);
        
            for k = 1:numel(Vout)
        
                % Apply identical voltages to all three axes
                obj.applyDAQvoltage([Vout(k) Vout(k) Vout(k)]);
        
                pause(0.1);
        
                % Measure feedback voltages
                Vin(k,:) = obj.readDAQvoltage();
        
            end
        
            % Fit the input-output relation for each axis
            for i = 1:3
                p = polyfit(Vout, Vin(:,i), 1);
        
                fprintf('Axis %d: gain = %.5f, bias = %.5f V\n', ...
                    i, p(1), p(2));
            end
        
            figure
            plot(Vout, Vin, 'o-')
            hold on
            plot(Vout, Vout, 'k--')
            xlabel('DAQ output voltage (V)')
            ylabel('Position feedback voltage (V)')
            legend('X','Y','Z','Ideal')
            grid on
        
        end
    end

    methods(Static)


        function deviceID = controllersAvailable()
            daqreset
            DAQlist = daqlist;
            if ~isempty(DAQlist)
                
                deviceID = cellstr(DAQlist.DeviceID);
            else
                deviceID = cell.empty();
            end
        end
        
        
        function models = serialNumbersAvailable()

            daqreset
            DAQlist = daqlist;
            if ~isempty(DAQlist)
                
                models = cellstr(DAQlist.Model);
            else
                models = cell.empty();
            end
           

        end

    end
end %Class

