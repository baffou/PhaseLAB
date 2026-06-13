classdef PiezoStage < handle
    properties (SetAccess = private, GetAccess = public)
        hndl  %PI_GCS_Controller handle
        model % piezo stage model
        SN    % serial number
        type  %'X', 'XY' or 'XYZ'
        homePosition PiezoPosition
        isJoystickUsable logical
    end

    properties (SetAccess = private, GetAccess = public)%(Access = ?GUIPiezo)
        Ax %Piezo doesn't understand 'XYZ' axis format but rather '123' or 'ABC' depending on the model
        ranges %Min/Max range of the piezo, for the specified axes
        AccTunable logical
    end

    methods (Access = public)

        function obj = PiezoStage(name) % Constructor
            arguments
                name (1,:) char {mustBeMember(name,{'PILine-XY-135x80','Pifoc'})}
            end
            pz = jsonImport(strcat(name,'.json'));
            obj.model = pz.model;

            try
                obj.hndl = PI_GCS_Controller();
            catch e
                e.rethrow();
            end


            obj.connect();
        end

        %default destructorAx
        function delete(obj)
            if obj.isPiezoConnected()
                obj.disconnect();
            end
        end

        %Link the controller to an actual piezo
        function connect(obj,SN_piezo)
            if ~obj.isPiezoConnected

                obj.hndl = obj.hndl.ConnectUSB(SN_piezo);

                if ~obj.isPiezoConnected()
                    obj.SN = [];
                    error('Connection failed');
                else
                    obj.SN = SN_piezo;
                end


                obj.hndl = obj.hndl.InitializeController();

                obj.setAx()
                obj.setType()
                obj.setRanges()


                obj.isJoystickUsable = true;
                obj.SwitchMotors(true);

                if obj.isJoystickUsable && max(obj.type == 'X') && max(obj.type == 'Y')
                    %If joystick mode is on, both X and Y axis are velocity based controlled
                    obj.hndl.HIA(obj.Ax{obj.getAxIndice('X')},3,2,1);
                    %                 obj.GCS_Object.SPA(obj.Ax{obj.getAxIndice('X')},97,1);  %Invert the X joystick axis
                    obj.hndl.HIA(obj.Ax{obj.getAxIndice('Y')},3,2,2);
                end
                obj.setHomePosition();

                obj.AccTunable = true;
                try
                    obj.hndl.ACC(obj.Ax{1},obj.hndl.qACC(obj.Ax{1}));
                catch
                    obj.AccTunable = false;
                end

            else
                warning('Piezo already connected')
                obj.disconnect()
                obj.connect(SN_piezo)
            end
        end

        % Disconnect the piezo
        function disconnect(obj)
            if obj.isPiezoConnected()
                obj.SwitchMotors(false);
            end
            obj.hndl.CloseConnection();
            obj.SN = [];
            obj.type = [];
        end

        function setAx(obj)
            obj.Ax = obj.hndl.qSAI_ALL();

            if isa(obj.Ax,'char') %Mono ax piezo can be bugged (Ax = '1\n')
                obj.Ax = obj.Ax(obj.Ax ~= newline);
            end
        end

        function setType(obj)
            if length(obj.Ax) == 1
                obj.Ax = {obj.Ax};
                obj.type = 'Z'; %I want that my mono ax piezo manage the Z ax
            else
                obj.type = [];

                for k=1:length(obj.Ax)
                    axesName = obj.hndl.qCST(obj.Ax{k});
                    currentAxe=axesName(length(axesName)-1);
                    if ~(strcmpi(currentAxe,'X') || strcmpi(currentAxe,'Y') || strcmpi(currentAxe,'Z'))
                        error('The format of the output of the qCST command is not formated as expected. Please read the comments in the PI_Piezo.m file');
                        %It is expected that the format is something like : 1=M-687.UN:1. If not, the object won't be able
                        %to convert the real axis (i.e. 'X') into the axis that the controller knows (i.e. '1').
                        %See "getAxIndice" method
                    end
                    obj.type = [obj.type currentAxe];
                end
            end
        end

        function setRanges(obj)
            for k = 1:length(obj.type)
                obj.ranges{k} = [obj.hndl.qTMN(obj.Ax{k}) obj.hndl.qTMX(obj.Ax{k})];
            end
        end

        %%Velocity & acceleration

        %Get the current velocity value for a given axe (X,Y,Z)
        function [vel] = getCurrentVelocity(obj,ax)
            vel = obj.hndl.qVEL(obj.Ax{obj.getAxIndice(ax)});
        end

        %Set the current velocity value for a given axe (X,Y,Z)
        function setVelocity(obj,axis,value)
            obj.hndl.VEL(obj.Ax(obj.getAxIndice(axis)),value);
        end

        %Get the current acceleration/desacceleration value for a given axe (X,Y,Z)
        function [acc] = getCurrentAcceleration(obj,ax)
            acc = obj.hndl.qACC(obj.Ax{obj.getAxIndice(ax)});
        end

        %Set the current acceleration value for a given axe (X,Y,Z)
        function setAcceleration(obj,ax,value)
            obj.hndl.ACC(obj.Ax{obj.getAxIndice(ax)},value);
            obj.hndl.DEC(obj.Ax{obj.getAxIndice(ax)},value);
        end

        %%Position

        %Get the axis range [min max] for a given axes
        function range = getCoordinateRange(obj,ax)
            range  = obj.ranges{obj.getAxIndice(ax)};
        end

        %Get the current coordinate for a given axe (X,Y,Z)
        function [coord] = getCurrentCoordinate(obj,ax)
            coord = obj.hndl.qPOS(obj.Ax{obj.getAxIndice(ax)});
        end

        %Get the current position as a PiezoPosition object
        function [pos] = getCurrentPosition(obj,name)
            arguments
                obj
                name char = 'Unnamed'
            end

            if obj.isPiezoConnected()
                tuples = cell(3,1); %Coordinate store in here, 3 max

                for k=1:length(obj.type)
                    tuples{k} = {obj.type(k),obj.getCurrentCoordinate(obj.type(k))};
                end

                pos = PiezoPosition(tuples{1},tuples{2},tuples{3},name);
            else
                error('Piezo not connected');
            end
        end

        %Move the piezo to the specified coordinate for a given axe (X, Y, Z)
        function moveRawCoordinate(obj,ax,value)
            if obj.isPiezoConnected()
                okVal = obj.checkPositionValidity(ax,value);
                obj.privateMoveCoordinate(ax,okVal);
            else
                error('Piezo not connected');
            end
        end

        %Move to a given position stored in a PiezoPosition object
        function movePosition(obj,pos)
            arguments
                obj
                pos PiezoPosition
            end

            if obj.isPiezoConnected()
                if ~isempty(pos.x)
                    okPos = obj.checkPositionValidity('X',pos.x);
                    obj.privateMoveCoordinate('X',okPos);
                end

                if ~isempty(pos.y)
                    okPos = obj.checkPositionValidity('Y',pos.y);
                    obj.privateMoveCoordinate('Y',okPos);
                end

                if ~isempty(pos.z)
                    okPos = obj.checkPositionValidity('Z',pos.z);
                    obj.privateMoveCoordinate('Z',okPos);
                end
            else
                error('Piezo not connected');
            end
        end

        %Move the piezo in the center of the platine
        function moveHome(obj)
            if obj.isPiezoConnected()
                obj.movePosition(obj.homePosition);
            else
                error('Piezo not connected');
            end
        end

        %%Utilities

        %Verify is the piezo is connected
        function bool = isPiezoConnected(obj)
            bool = logical(obj.hndl.IsConnected);
        end

        %Set the joystiuck mode on, if any connected
        function switchJoystickMode(obj,bool)
            if obj.isPiezoConnected()
                if obj.isJoystickUsable
                    if bool
                        obj.hndl.HIN('1',1);
                        obj.hndl.HIN('2',1);
                    else
                        obj.hndl.HIN('1',0);
                        obj.hndl.HIN('2',0);
                    end
                end
            else
                error('Piezo not connected');
            end
        end

        %True if the controller is controlled by a joystick
        function bool = isJoystickMode(obj)
            if obj.isPiezoConnected()
                if obj.isJoystickUsable 
                    bool = logical(max(obj.hndl.qHIN()));
                else
                    bool = false;
                end
            else
                error('Piezo not connected');
            end
        end

        %Burn time in a while loop until the piezo stoped moving
        function waitUntilPiezoStill(obj)
            if obj.isPiezoConnected()
                while obj.hndl.IsMoving
                    drawnow;
                end
            else
                error('Piezo not connected');
            end
        end

        %Stop smoothly the piezo if moving
        function stopPiezoMovement(obj)
            if obj.isPiezoConnected()
                for k=1:length(obj.Ax)
                    obj.hndl.HLT(obj.Ax{k})
                end
            else
                error('Piezo not connected');
            end
        end

        function setHomePosition(obj,HomePosition)
            arguments
                obj PI_Piezo
                HomePosition PiezoPosition = []
            end
            if obj.isPiezoConnected()
                if isempty([HomePosition.x, HomePosition.y, HomePosition.z])
                    HomePosition=obj.getCurrentPosition('Home');
                end
                obj.homePosition = HomePosition;
            else
                error('Piezo not connected');
            end
        end

        %Allow to rename the axes. If the piezo manage only one axe (by default named X), you can rename it Z.
        %For more information, see constructor and @getAxIndice
        function linkAxesManually(obj,newAxOrder)
            if obj.isPiezoConnected()
                if length(obj.type) == length(newAxOrder)
                    obj.type = newAxOrder;
                else
                    error("The length of newAxOrder should be the same as the number of axis that piezo controls." + ...
                        " It must be formatted as, for exemple, 'YXZ' (3 Ax), or 'ZY' (2 Ax), or 'Y' (1 Ax)");
                end
            else
                error('Piezo not connected');
            end
        end
    
        %List all the controller available
        function list = controllerAvailable(obj)
            list = obj.hndl.EnumerateUSB();
        end
    end

    methods %(Access = private)
        %Turns the motor ON/OFF
        function SwitchMotors(obj,bool)
            if bool
                for k=1:length(obj.type)
                    try
                        obj.hndl.HIN('1',0);
                        obj.hndl.HIN('2',0);
                        disp('Switch servo')
                    catch
                        obj.isJoystickUsable = false;
                    end
                        obj.hndl.SVO(obj.Ax{k},1);
                    try
                        obj.hndl.FRF(obj.Ax{k}); %MOOVE THE PIEZO TO THE REF POSITION AT STARTUP
                    catch
                    end
                end
            else
                for k=1:length(obj.type)
                    obj.hndl.SVO(obj.Ax{k},0);
                end
            end
        end

        %Switch from (XYZ) position to low level ones
        function ind=getAxIndice(obj,ax)
            indiceBool = (obj.type == ax);
            if max(max(indiceBool)) == 0
                error(['The axis ' ax ' is not controlled by the piezo. The controlled axes are : ' obj.type]);
            end
            ind = find(indiceBool);
        end

        %Move to a given coordinate
        function privateMoveCoordinate(obj,ax,target)
            obj.hndl.MOV(obj.Ax{obj.getAxIndice(ax)},target);
        end

        %Check if a pos is in range, return the valide range in okPos
        function okPos = checkPositionValidity(obj,ax,pos)
            okPos = pos;
            if pos > obj.ranges{obj.getAxIndice(ax)}(2)
                okPos = obj.ranges{obj.getAxIndice(ax)}(2) - eps;
            end
            if pos < obj.ranges{obj.getAxIndice(ax)}(1)
                okPos = obj.ranges{obj.getAxIndice(ax)}(1) + eps;
            end
        end
    end

    methods(Static)
        function setupSDK()
            addpath([getenv("ProgramFiles(x86)") '/Physik Instrumente (PI)\Software Suite\MATLAB_Driver']);
        end
    end
end