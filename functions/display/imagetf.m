function imagetf(itf,funct)

if nargin==1
    funct='sqrt';
end

if isreal(itf)
    convFun=@(x) fftshift(fft2(x));
else
    convFun=@(x) x;
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
