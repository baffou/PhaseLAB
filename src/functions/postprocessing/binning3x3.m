function out=binning3x3(image0)

if ~isnumeric(image0)
    error('this function only works with numeric matrices')
end

if length(size(image0))~=2
    error('the matrix has to be 2-dimensional')
end

[Ny, Nx]=size(image0);
Nys=floor((Ny)/3);
Nxs=floor((Nx)/3);

if mod(Nxs,2)==1
    Nxs=Nxs-1;
end
if mod(Nys,2)==1
    Nys=Nys-1;
end

image=zeros(Nys,Nxs,9);

image(:,:,1)=image0(1:3:3*Nys,1:3:3*Nxs);
image(:,:,2)=image0(2:3:3*Nys,1:3:3*Nxs);
image(:,:,3)=image0(3:3:3*Nys,1:3:3*Nxs);
image(:,:,4)=image0(1:3:3*Nys,2:3:3*Nxs);
image(:,:,5)=image0(2:3:3*Nys,2:3:3*Nxs);
image(:,:,6)=image0(3:3:3*Nys,2:3:3*Nxs);
image(:,:,7)=image0(1:3:3*Nys,3:3:3*Nxs);
image(:,:,8)=image0(2:3:3*Nys,3:3:3*Nxs);
image(:,:,9)=image0(3:3:3*Nys,3:3:3*Nxs);

out=mean(image,3);






