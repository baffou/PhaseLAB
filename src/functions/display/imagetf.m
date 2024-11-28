function imagetf(itf,funct)

if nargin==1
    funct='sqrtsqrt';
end

if isreal(itf(2)) % if the second pixel of the image is imaginy, then it is certainly a Fourier transform
    convFun=@(x) fftshift(fft2(x));
else
    if isreal(itf(2))
        convFun=@(x) fftshift(x);
    else
        convFun=@(x) x;
    end        
end

if strcmpi(funct,'log10') || strcmpi(funct,'log')
    func=@(x) log10(abs(convFun(x)));
elseif strcmpi(funct,'sqrt')
    func=@(x) sqrt(abs(convFun(x)));
elseif strcmpi(funct,'sqrtsqrt')
    func=@(x) sqrt(sqrt(abs(convFun(x))));
end

%ImPlot=sqrt(sqrt(abs(itf)));
%ImPlot=log10(abs(itf));
ImPlot=func(itf);
imagebw(ImPlot)
set(gca,'YDir','normal')
colormap(gca,parula)
%caxis([0 max(max(imgaussfilt(ImPlot,1)))])
