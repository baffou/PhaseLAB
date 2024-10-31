function [obj2, mask] = flatten(obj,method,opt)
% flatten the backgound of the OPD image of the ImageQLSI or ImageEM object
% If a threshold is specified and well adjusted, remove the background
% without taking into account the object. Useful for eukaryotic cells.

arguments
    obj ImageMethods
    method (1,:) char {mustBeMember(method,{'Waves','Sine','Zernike','Chebyshev','Hermite','Legendre','Gaussian'})} = 'Gaussian'
    opt.nmax (1,:) {mustBeInteger(opt.nmax)} = 2 % n or [nx, ny]
    opt.threshold double = 0 % if not zero, segment the cells and create a mask
    opt.mask = []  % specifies a selection mask, instead of computing one when threshold is not zero
    opt.kind  (1,1) {mustBeInteger(opt.kind)} = 1 % for Chebychev
    opt.display logical = true
    opt.nGauss = 100
    opt.cut = 0.5
    opt.invert = false
    opt.params = []
end

if opt.threshold == 0
    opt.display = false;
end
% method:
%   'Zernike'
%   or
%   'Waves', 'Wave', 'Sine', 'sine'     (by default)
%   or
%   'Chebyshev

if nargout
    obj2=copy(obj);
else
    obj2=obj;
end


if strcmp(method,'Zernike') && opt.threshold ~= 0
    warning('No threshold algorithm can be applied with Zernike flattening. The threshold value is ignored.')
end

No = numel(obj);

for io = 1:No
    printLoop(io,No)    
    
    if ~isempty(opt.mask)
        mask = opt.mask;
    elseif (opt.threshold~=0 || ~isempty(opt.params)) && ~strcmp(method,'Zernike') % then create a mask

        if isempty(opt.params)
            nGauss = opt.nGauss;
            cut = opt.cut;
            invert = opt.invert;
        else
            opt.threshold = convert_nm(opt.params.gradThresh)*1e9;
            nGauss = opt.params.smoothing;
            cut = opt.params.cut;
            invert = opt.params.invert;
        end
        
        mask = computeSegmentationMasks(obj(io).DWx, obj(io).DWy,...
                                     opt.threshold, nGauss, cut, invert);
    else
        mask = ones(size(obj(io).OPD));
    end

    obj2(io).OPD = flatten0(obj(io).OPD,method,"kind", opt.kind,...
        "mask",mask,"nGauss",opt.nGauss,"nmax",opt.nmax, "display", opt.display);


    % cancel the gradients DWx and DWy, in case they exist,
    %  because they are not true anymore
    obj2(io).cancelGradients();



end

end