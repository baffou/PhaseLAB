function imagetf(itf,funct)

if nargin==1
    funct='sqrtsqrt';
end

if strcmpi(funct,'log10') || strcmpi(funct,'log')
    func=@(x) log10(abs(x));
elseif strcmpi(funct,'sqrt')
    func=@(x) sqrt(abs(x));
elseif strcmpi(funct,'sqrtsqrt')
    func=@(x) sqrt(sqrt(abs(x)));
end

%ImPlot=sqrt(sqrt(abs(itf)));
%ImPlot=log10(abs(itf));
ImPlot=func(itf);
imagebw(ImPlot)
set(gca,'YDir','normal')
colormap(gca,'Gray')
%caxis([0 max(max(imgaussfilt(ImPlot,1)))])
