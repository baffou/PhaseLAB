%% Verify that the PI_Piezo Controller is detected
MyPiezo = PI_Piezo();
MyPiezo.controllerAvailable()
%% Connect the piezo
MyPiezo = PI_Piezo('0119003881');
% MyPiezo = PI_Piezo('0111167532');
%Or MyPiezo  = PI_Piezo();MyPiezo.connect('0119003881');
disp(['Controller connected! Axes available : ' MyPiezo.AxisBeingControlled])
%% Get information about the current state of the piezo : 
CurrentVelocity = [MyPiezo.getCurrentVelocity('X')  %Velocity
                   MyPiezo.getCurrentVelocity('Y')];

CurrentAcceleration = [MyPiezo.getCurrentAcceleration('X')
                       MyPiezo.getCurrentAcceleration('Y')];

CurrentCoordinate = [MyPiezo.getCurrentCoordinate('X')   %XY coordinate
                     MyPiezo.getCurrentCoordinate('Y')];

CurrentPosition = MyPiezo.getCurrentPosition('InitialPosition');
%% Set a velocity value
MyPiezo.setVelocity('X',20);
MyPiezo.setVelocity('Y',20);
%% Set an acceleration value
MyPiezo.setAcceleration('X',300);
MyPiezo.setAcceleration('Y',300);
%% Move the piezo - Raw Coordinate
MyPiezo.moveRawCoordinate('X', 1);
MyPiezo.moveRawCoordinate('Y', -5);
%% Move the piezo - Defined position
MyPiezo.movePosition(CurrentPosition);
%%
MyPiezo.moveRawCoordinate('X',50);
MyPiezo.moveRawCoordinate('Y',12);
MyPiezo.waitUntilPiezoStill();
MyPiezo.moveRawCoordinate('X',-50);
MyPiezo.moveRawCoordinate('Y',-12);
%% Move to a relative position
StepSize = 50;
MyPiezo.move_RawCoordinate('X',currentX-150);
currentX = MyPiezo.getCurrentCoordinate('X');
%% Switch on/off the joystick
MyPiezo.switchJoystickMode(1)
MyPiezo.isJoystickMode
%% Showcase - Move randomly and save the position
randomPosition = [];
rangeX = MyPiezo.getCoordinateRange('X');
rangeY = MyPiezo.getCoordinateRange('Y');
nPos = 4;

for k = 1:nPos
    xRand = randi(round(rangeX));
    yRand = randi(round(rangeY));

    MyPiezo.moveRawCoordinate('X', xRand);
    MyPiezo.moveRawCoordinate('Y', yRand);

    randomPosition = [randomPosition MyPiezo.getCurrentPosition(['Random Pos' num2str(k)])]; %#ok<AGROW> 
    pause(1);
end

MyPiezo.moveHome();
%% Showcase - move in spiral - XY Piezo only
spiralCenter = MyPiezo.getCurrentPosition('spiraleCenter');
spiralNumberCircle = 3;
maxR = [15,10];
ech = 100;
th = linspace(0,2*pi*spiralNumberCircle,ech);
Rx = linspace(0,maxR(1),ech);
Ry = linspace(0,maxR(2),ech);
X = spiralCenter.x + Rx .* cos(th);
Y = spiralCenter.y + Ry .* sin(th);
plot(X,Y)

tic
for k = 1:ech
    MyPiezo.moveRawCoordinate('X',X(k));
    MyPiezo.moveRawCoordinate('Y',Y(k));
    drawnow;
end
toc

MyPiezo.moveRawCoordinate('X',spiralCenter.x);
MyPiezo.moveRawCoordinate('Y',spiralCenter.y);
%% Free the controller 
MyPiezo.disconnect();