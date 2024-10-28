function [mask, paramsOut] = segmentationMaskGen(img, paramsIn)
arguments
    img = []
    paramsIn = []
end

if isempty(paramsIn)
    app = segmentationMaskGenApp(img);
else
    app = segmentationMaskGenApp(img,"gradThresh",paramsIn.gradThresh, ...
                                     "smoothing", paramsIn.smoothing, ...
                                     "cut",       paramsIn.cut, ...
                                     "invert",    paramsIn.invert);
end
waitfor(app,'Finished',true)

paramsOut.gradThresh = app.gradThresh;
paramsOut.smoothing  = app.smoothing;
paramsOut.cut        = app.cut;
paramsOut.invert     = app.invert;
mask = app.maskFinal;

delete(app)










