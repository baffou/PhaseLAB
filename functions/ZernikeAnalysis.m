function [Zlist,r0,x0,y0]=ZernikeAnalysis(Im)

hh=figure;
imageph(Im)

%center of the image
[x0,y0]=ginput(1);

%border of the circular area
[xr,yr]=ginput(1);

close(hh)

r0=sqrt((xr-x0)^2+(yr-y0)^2);

% Analyse des composantes de Zernike

Zlist=zeros(5,5);
for ii=1:5
    for jj=1:ii
        n=ii;
        m=mod(n,2)+2*(jj-1);
        Zlist(ii,jj) = ZernikeMoment2(Im,n,m,r0,x0,y0);
    end
end

end

