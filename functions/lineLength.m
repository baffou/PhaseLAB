function len=lineLength(polyline)

if ~isa(polyline,'images.roi.Polyline')
    error('The input must be a line object')
end

x=polyline.Position(:,1);
y=polyline.Position(:,2);

Np=length(x);

len=0;
for ii=1:Np-1
    len=len+sqrt((x(ii)-x(ii+1))^2+(y(ii)-y(ii+1))^2);
end








