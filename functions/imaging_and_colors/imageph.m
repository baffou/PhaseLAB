function ai=imageph(A,Amin,Amax,opt)
arguments
    A
    Amin = 0
    Amax = 0
    opt.reverseColor = false
end
if nargout
    ai=imagesc(A);
else
    imagesc(A);
end
set(gca,'dataAspectRatio',[1 1 1])
colorbar
set(gca,'YDir','normal')

if opt.reverseColor
    colormap(gca,flipud(phase1024));
else
    colormap(gca,phase1024);
end

if Amax~=0 && Amin==0
    caxis([min(A(:)) Amax])
elseif Amax~=0 && Amin~=0
    caxis([Amin Amax])
end

