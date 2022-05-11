function im=flatten(im0,n)

if nargin==1
    n=1;
end


[Ny,Nx]=size(im0);

[X,Y]=meshgrid(1:Nx,1:Ny);
X=X-mean(X(:));
Y=Y-mean(Y(:));
norm=sqrt(sum(X(:).*X(:)));
X=X/norm;
Y=Y/norm;
valx=sum(X(:).*im0(:));
valy=sum(Y(:).*im0(:));

im=im0-valx*X-valy*Y;


if n==2
    R=sqrt(X.^2+Y.^2);
    R=R-mean(R(:));
    norm=sqrt(sum(R(:).*R(:)));
    R=R/norm;
    val=sum(R(:).*im0(:));

    im=im0-val*R;    
end

