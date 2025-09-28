function [image, params] = crop0(image0,opt)
arguments
    image0 (:,:) double
    opt.xy1 = []
    opt.xy2 = []
    opt.Center = 'Auto' % 'Auto', 'Manual' or [x, y]
    opt.Size = 'Manual' % 'Auto', 'Manual', d or [dx, dy]
    opt.twoPoints logical = false
    opt.params double = double.empty()
    opt.shape char {mustBeMember(opt.shape,{'square','rectangle','Square','Rectangle'})}= 'square'
    opt.hfig matlab.ui.Figure = matlab.ui.Figure.empty() % figure object to be considered in case the image is already open
    opt.displayT logical = false
    opt.colormap = parula
    opt.even = true % image dimensions are even
end

if isempty(opt.params)

    [x1, x2, y1, y2] = boxSelection(image0,'xy1',opt.xy1, ...
        'xy2',opt.xy2, ...
        'Center',opt.Center, ...
        'Size',opt.Size, ...
        'twoPoints',opt.twoPoints, ...
        'params',opt.params, ...
        'shape',opt.shape, ...
        'displayT',opt.displayT, ...
        'colormap',opt.colormap, ...
        'even',opt.even, ...
        'hfig', opt.hfig);
    params=[x1, x2, y1, y2];
else
    x1 = opt.params(1);
    x2 = opt.params(2);
    y1 = opt.params(3);
    y2 = opt.params(4);
    params=opt.params;
end

image = image0(y1:y2,x1:x2);


end

