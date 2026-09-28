%% Example of live setup operation using coding

%% build the setup

folder = pwd;


OB = Objective(100,1.3);
CGcam = CGcamera("sc8-830");

MI = Microscope(OB,200,CGcam,'PhaseLAB');

ME = Medium(topMed,'glass');

IL = Monochromator(lambda,ME);

CGcam.turnOn()
PI = PIstage();
PI.connect()

%% operate the setup

CGcam.setExpTime(100)
lambdaList = 480:20:820;

for lambda = lambdaList
    IL.setLambda(lambda)
    Itf = CGcam.acquireImage();
    Itf.save(folder,'nickname',"ITF")
end

PI.moveBy("X_um", 100)

for lambda = lambdaList
    IL.setLambda(lambda)
    Itf = CGcam.acquireImage();
    Itf.save(folder,'nickname',"REF")
end





