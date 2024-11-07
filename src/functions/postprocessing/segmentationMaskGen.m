function [mask, paramsOut] = segmentationMaskGen(img, paramsIn)
arguments
    img = []
    paramsIn = []
end

if isempty(paramsIn)
    app = segmentationMaskGenApp(img);
else
    app = segmentationMaskGenApp(img,"threshold",paramsIn.threshold, ...
                                     "smoothing", paramsIn.smoothing, ...
                                     "cut",       paramsIn.cut, ...
                                     "invert",    paramsIn.invert);
end
waitfor(app,'Finished',true)

paramsOut.threshold = app.threshold;
paramsOut.smoothing  = app.smoothing;
paramsOut.cut        = app.cut;
paramsOut.invert     = app.invert;
paramsOut.type       = app.type;
mask = app.maskFinal;

delete(app)










