function spec=imSpectrum(image,opt)
% either computes the spectrum of an image, or display it, or both
% spec=imSpectrum(A);
% imSpectrum(A,'YScale','normal')
% imSpectrum(A,'YScale','log')
% imSpectrum(A,'XScale','log','YScale','log')

arguments
    image
    opt.XScale {mustBeMember(opt.XScale,{'normal','log'})} ='normal'
    opt.YScale {mustBeMember(opt.YScale,{'normal','log'})} ='normal'
end

Fimage=ifftshift(fft2(image-mean(image(:))));
spec0 = radialAverage0(abs(Fimage).^2,size(Fimage)/2+[1 1]);

if nargout
    spec=spec0;
end
 
if ~strcmpi(opt.YScale,'normal')
    set(gca,'YScale', 'log')
end

if ~strcmpi(opt.XScale,'normal')
    set(gca,'YScale', 'log')
end







