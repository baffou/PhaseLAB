function [OPDsimu, Tsimu,IMout] = process_CGM(IM, opt)
% OPDsimu: simulated OPD
% Tsimu: simulated normalize intensity image
% IMout: possibly modified IM, e.g. cropped or binned
arguments
    IM
    opt.CGdistance =IM(1).Microscope.CGcam.distance
    opt.shotNoise = false
    opt.definition = 'low'
    opt.auto = true
    opt.Nim = 1
    opt.NimRef = []
end

Nim = numel(IM); % in case disc illumination

IL = IM(1).Illumination.lambda;

Itf = Interfero(Nim);
for io = 1:Nim
    IM(io).Microscope.CGcam.setDistance(opt.CGdistance);
    Itf(io) = CGMinSilico(IM(io),shotNoise=opt.shotNoise,Nimages=opt.Nim,NimagesRef=opt.NimRef,NAill=0,cut=0);
end

Itf_CGM = Itf.mean();

IMis=QLSIprocess(Itf_CGM,IL,"definition",opt.definition,'auto',opt.auto);
%        IMis=QLSIprocess(Itf_CGM,Illumination(lambda),"definition","low");
IMis.level0("method","boundary")
OPDsimu=IMis.OPD;
Tsimu = IMis.T;
IMout = ImageQLSI(IM);
if strcmpi(opt.definition,'low')
    IMout.binning(IM.Microscope.CGcam.zeta);
end

