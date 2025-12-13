function hfig0 = displayJonesMatrix(J,opt)
arguments
    J double
    opt.Name = 'J matrix'
end

if numel(size(J)) == 2
    J0 = J;
    J = zeros(size(J,1), size(J,2), 1, 1);
    J(:,:,1,1) = J0;
end



hfig = figure;
subplot(2,4,1)
imagegb(abs(squeeze(J(1,1,:,:))))
title('|Jxx|')
subplot(2,4,2)
imagegb(abs(squeeze(J(1,2,:,:))))
title('|Jxy|')
subplot(2,4,3)
imagegb(abs(squeeze(J(2,1,:,:))))
title('|Jyx|')
subplot(2,4,4)
imagegb(abs(squeeze(J(2,2,:,:))))
title('|Jyy|')

tM = 2;
subplot(2,4,5)
imagehsv(mod(pi/2+angle(squeeze(J(1,1,:,:))),pi)-pi/2)
clim([-tM/4, tM/4])
title('arg(Jxx)')
subplot(2,4,6)
imagehsv(mod(pi/2+angle(squeeze(J(1,2,:,:))),pi)-pi/2)
clim([-tM, tM])
title('arg(Jxy)')
subplot(2,4,7)
imagehsv(mod(pi/2+angle(squeeze(J(2,1,:,:))),pi)-pi/2)
clim([-tM, tM])
title('arg(Jyx)')
subplot(2,4,8)
imagehsv(mod(pi/2+angle(squeeze(J(2,2,:,:))),pi)-pi/2)
clim([-tM/4, tM/4])
title('arg(Jyy)')
linkAxes

fullwidth

hfig.Name = opt.Name;
hfig.NumberTitle = "off";

if nargout
    hfig0 = hfig;
end