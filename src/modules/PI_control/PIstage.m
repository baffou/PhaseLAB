%PIstage class
%
%Desc:  This class is used to interface matlab with a Physik Instrumente controller, which controls piezos.
%       It must be initizialized with a serial number. The static method @controllerAvailable gives the
%       controller available.
%       A Joystick can be used to control the piezo thank to the method @switchJoystickMode(true)
%
%
%Notes: /!\ When isJoystickMode is true, the piezo can't be controlled programmatically /!\
%       Acceleration and deceleration are both set to the same value. (ACC = DEC)
%
%Dependency : PI_DevelopmentSuite (Matlab third party toolbox)
%
%Baptiste MARTHY & Guillaume Baffou - 2021 & 2026

classdef PIstage < handle
    properties (SetAccess = private, GetAccess = public)
        Controller %PI_GCS_Controller %Low level Piezo object
        SerialNumber %The serial number of the main controller
        axes (1,:) char {mustBeMember(axes,{'','X','XY','XYZ','Z'})} = '' % Axes being controlled
        idAxes cell %Piezo doesn't understand 'XYZ' axis format but rather '123' or 'ABC' depending on the model

        axesRanges cell %Min/Max range of the piezo, for the specified axes
        HomePosition (1,:) double = double.empty(1,0)
        isJoystickUsable logical
        AccTunable logical
    end

    properties(Dependent)
        X
        Y
        Z
    end

    methods (Access = public)

        function obj = PIstage(serialNumber)
            arguments
                serialNumber
            end
            % Constructor
            try
                obj.Controller = PI_GCS_Controller();
            catch
                addpath([getenv("ProgramFiles(x86)") '/Physik Instrumente (PI)\Software Suite\MATLAB_Driver']);
                obj.Controller = PI_GCS_Controller();
            end
            obj.SerialNumber = serialNumber;
        end


        function delete(obj)
            if obj.isPiezoConnected()
                obj.disconnect();
            end
        end

        function rc = connect(obj)
            %Link the controller to an actual piezo
            arguments
                obj
            end
            
            obj.Controller = obj.Controller.ConnectUSB(obj.SerialNumber);

            if ~obj.isPiezoConnected()
                obj.SerialNumber = [];
                rc = -1;
                warning("No PI controller found")
                return
            end

            obj.Controller = obj.Controller.InitializeController();

            obj.initializeAxes()

            for k=1:length(obj.axes)
                obj.axesRanges{k} = [obj.Controller.qTMN(obj.idAxes{k}) obj.Controller.qTMX(obj.idAxes{k})];
            end

            obj.isJoystickUsable = true;
            obj.turnMotors('on');

            if obj.isJoystickUsable && max(obj.axes == 'X') && max(obj.axes == 'Y')
                %If joystick mode is on, both X and Y axis are velocity based controlled
                obj.Controller.HIA(obj.idAxes{obj.axNum('X')},3,2,1);
                %                 obj.GCS_Object.SPA(obj.Ax{obj.getAxIndice('X')},97,1);  %Invert the X joystick axis
                obj.Controller.HIA(obj.idAxes{obj.axNum('Y')},3,2,2);
            end
            obj.setHomePosition();

            obj.AccTunable = true;
            try
                obj.Controller.ACC(obj.idAxes{1},obj.Controller.qACC(obj.idAxes{1}));
            catch
                obj.AccTunable = false;
            end

            rc = 0;

        end

        function disconnect(obj)
            %Disconnect the piezo
            if obj.isPiezoConnected()
                obj.turnMotors('off');
            end
            obj.Controller.CloseConnection();
            obj.SerialNumber = [];
            obj.axes = [];
        end

        function initializeAxes(obj)
            % Determine the number and the name of the axes ('X', 'Y', ...)
            % and numAxes (1, 2, 3, ...)

            obj.idAxes = obj.Controller.qSAI_ALL();

            if isa(obj.idAxes,'char') %Mono ax piezo can be bugged (Ax = '1\n')
                obj.idAxes = {obj.idAxes(obj.idAxes ~= newline)};
            end
            
            for k = 1:length(obj.idAxes)
                axisName = obj.Controller.qCST(obj.idAxes{k});
                currentAxis = axisName(length(axisName)-1);
                if ~(strcmpi(currentAxis,'X') || strcmpi(currentAxis,'Y') || strcmpi(currentAxis,'Z'))
                    error('The format of the output of the qCST command is not formated as expected. Please read the comments in the PIstage.m file');
                    %It is expected that the format is something like : 1=M-687.UN:1. If not, the object won't be able
                    %to convert the real axis (i.e. 'X') into the axis that the controller knows (i.e. '1').
                    %See "axNum" method
                end
                obj.axes = [obj.axes currentAxis];
            end

        end
    
        %%Velocity & acceleration

        function [vel] = getVelocity(obj,ax)
            %Get the current velocity value for a given axe (X,Y,Z)

            vel = obj.Controller.qVEL(obj.idAxes{obj.axNum(ax)});
        
        end

        function setVelocity(obj,ax,val)
            %Set the current velocity value for a given axe (X,Y,Z)

            obj.Controller.VEL(obj.idAxes(obj.axNum(ax)),val);
        
        end

        function [acc] = getAcceleration(obj,ax)
            %Get the current acceleration/desacceleration value for a given axe (X,Y,Z)

            acc = obj.Controller.qACC(obj.idAxes{obj.axNum(ax)});
            
        end

        function setAcceleration(obj,ax,val)
            %Set the current acceleration value for a given axe (X,Y,Z)

            try
                obj.Controller.ACC(obj.idAxes{obj.axNum(ax)},val);
                obj.Controller.DEC(obj.idAxes{obj.axNum(ax)},val);
            catch
                warning('Acceleration not setable');
            end

        end

        %%Position

        function range = getCoordinateRange(obj,ax)
            %Get the axis range [min max] for a given axes
           range  = obj.axesRanges{obj.axNum(ax)};
        end

        function [coord] = getCoordinate(obj,ax)
            %Get the current coordinate for a given axe (X,Y,Z)
            coord = obj.Controller.qPOS(obj.idAxes{obj.axNum(ax)});
        end

        function pos = getPosition(obj,ax)
            %Get the current position as a PiezoPosition object
            arguments
                obj
                ax = []
            end

            if isempty(ax) % If no axis specified
                ax = obj.axes; % return all the coordinates : [x, y]
            end

            pos = zeros(length(ax),1); %Coordinate store in here, 3 max

            for k = 1:length(ax)
                pos(k) = obj.Controller.qPOS(obj.idAxes{obj.axNum(ax(k))});
            end

        end

        function moveTo(obj,pos,opt)
            arguments
                obj
                pos (1,:) double = double.empty(1,0)
                opt.X
                opt.Y
                opt.Z
            end
            if isempty(fieldnames(opt)) % moveTo([-1.2, 2.3, 0.3])
                Np = numel(pos);
                for ii = 1:Np
                    obj.moveSingleAxisTo(obj.idAxes{ii},pos(ii));
                end
            else                        % moveTo('X', 0.2, 'Y', -7.3)
                fieldNames = fieldnames(opt);
                Np = numel(fieldNames);
                for ii = 1:Np
                    obj.moveSingleAxisTo(fieldNames{ii},opt.(fieldNames{ii}));
                end
            end
            

        end

        function moveBy(obj,pos,opt)
            arguments
                obj
                pos (1,:) double = double.empty(1,0)
                opt.X
                opt.Y
                opt.Z
            end
            if isempty(fieldnames(opt)) % moveBy([-1.2, 2.3, 0.3])
                Np = numel(pos);
                for ii = 1:Np
                    val0 = obj.(obj.axes(ii)); % obj.X, currentPosition
                    obj.moveSingleAxisTo(obj.idAxes{ii},val0+pos(ii));
                end
            else                        % moveTo('X', 0.2, 'Y', -7.3)
                fieldNames = fieldnames(opt);
                Np = numel(fieldNames);
                for ii = 1:Np
                    val0 = obj.(obj.axes(ii));
                    obj.moveSingleAxisTo(fieldNames{ii},val0+opt.(fieldNames{ii}));
                end
            end

        end
        
        function moveHome(obj)
            %Move the piezo in the center of the platine
            if ~isempty(obj.HomePosition)
                obj.moveTo(obj.HomePosition);
            else
                warning("No home position defined. The stage did not move.")
            end
        end

        %%Utilities

        function bool = isPiezoConnected(obj)
            %Verify is the piezo is connected
            bool = logical(obj.Controller.IsConnected);
        end

        function turnJoystick(obj,val)
            %Set the joystiuck mode on, if any connected

            if obj.isJoystickUsable
                switch val
                    case {'on','On',"on","On",1}
                        obj.Controller.HIN('1',1);
                        obj.Controller.HIN('2',1);
                    case {'off','Off',"off","Off",0}
                        obj.Controller.HIN('1',0);
                        obj.Controller.HIN('2',0);
                end
            end

        end

        function bool = isJoystickON(obj)
        %True if the controller is controlled by a joystick
            if obj.isJoystickUsable 
                bool = logical(max(obj.Controller.qHIN()));
            else
                bool = false;
            end
        end

        function waitUntilPiezoStill(obj)
            %Burn time in a while loop until the piezo stoped moving
            while obj.Controller.IsMoving
                drawnow;
            end
        end

        function stopPiezoMotion(obj)
            %Stop smoothly the piezo if moving

            for k = 1:length(obj.idAxes)
                obj.Controller.HLT(obj.idAxes{k})
            end

        end

        function setHomePosition(obj,HomePosition)
            arguments
                obj
                HomePosition (1,:) double = empty(1,0)
            end

            if isempty(HomePosition)
                HomePosition = obj.getPosition();
            end
            obj.HomePosition = HomePosition;

        end

        function renameAxes(obj,newAxesOrder)
            %Allow to rename the axes. If the piezo manages only one axis (by default named X), you can rename it Z.
            %For more information, see constructor and @getAxIndice
            arguments
                obj
                newAxesOrder (1,:) char
            end

                if length(obj.axes) == length(newAxesOrder)
                    obj.axes = newAxesOrder;
                else
                    error("The length of newAxOrder should be the same as the number of axis that piezo controls." + ...
                          " It must be formatted as, for exemple, 'YXZ' (3 Ax), or 'ZY' (2 Ax), or 'Y' (1 Ax)");
                end

        end
    
        function list = controllersAvailable(obj)
            %List all the available controllers
            list = obj.Controller.EnumerateUSB();
        end
    end

    methods
        function turnMotors(obj,val)
            %Turns the motor ON/OFF
            switch val
                case {'on','On',"on","On"}
                    for k=1:length(obj.axes)
                        try
                            obj.Controller.HIN('1',0);
                            obj.Controller.HIN('2',0);
                            disp('Switch servo')
                        catch
                            obj.isJoystickUsable = false;
                        end
                            obj.Controller.SVO(obj.idAxes{k},1);
                        try
                            obj.Controller.FRF(obj.idAxes{k}); %MOOVE THE PIEZO TO THE REF POSITION AT STARTUP
                        catch
                        end
                    end
                case {'off','Off',"off","Off"}
                    for k=1:length(obj.axes)
                        obj.Controller.SVO(obj.idAxes{k},0);
                    end
            end
        end

        function ind = axNum(obj,ax)
            %Switch from (XYZ) position to low level ones
            arguments
                obj
                ax {mustBeMember(ax,{'X','Y','Z'})}
            end

            indiceBool = (obj.axes == ax);
            if sum(indiceBool) == 0
                error(['The axis ' ax ' is not controlled by the piezo. The controlled axes are : ' obj.axes]);
            end
            ind = find(indiceBool);
        end

        function moveSingleAxisTo(obj,ax,val)
            %Move a single axis to a given coordinate
            val = obj.checkPositionValidity(ax,val);
            obj.Controller.MOV(obj.idAxes{obj.axNum(ax)},val);
            % obj.waitUntilPiezoStill() % useful ???
        end

        function okPos = checkPositionValidity(obj,ax,pos)
            %Check if a pos is in range, then return the valid okPos
            okPos = pos;
            if pos > obj.axesRanges{obj.axNum(ax)}(2)
                okPos = obj.axesRanges{obj.axNum(ax)}(2) - eps;
            end
            if pos < obj.axesRanges{obj.axNum(ax)}(1)
                okPos = obj.axesRanges{obj.axNum(ax)}(1) + eps;
            end
        end
    end

    methods
        function val = get.X(obj)
            val = obj.Controller.qPOS(obj.idAxes{obj.axNum('X')});
        end
        function val = get.Y(obj)
            val = obj.Controller.qPOS(obj.idAxes{obj.axNum('Y')});
        end
        function val = get.Z(obj)
            val = obj.Controller.qPOS(obj.idAxes{obj.axNum('Z')});
        end

    
        function set.X(obj, val)
            obj.moveSingleAxisTo(obj.idAxes{obj.axNum('X')},val);
        end
        function set.Y(obj, val)
            obj.moveSingleAxisTo(obj.idAxes{obj.axNum('Y')},val);
        end
        function set.Z(obj, val)
            obj.moveSingleAxisTo(obj.idAxes{obj.axNum('Z')},val);
        end
    
    
    end
end