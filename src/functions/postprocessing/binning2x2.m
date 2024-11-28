function out=binning2x2(image)

if ~isnumeric(image)
    error('this function only works with numeric matrices')
end

if length(size(image))~=2
    error('the matrix has to be 2-dimensional')
end

[Ny, Nx]=size(image);
if mod(Ny,2)==1% if odd
    Nys=(Ny-1)/2;
else
    Nys=Ny/2;
end

if mod(Nx,2)==1% if odd
    Nxs=(Nx-1)/2;
else
    Nxs=Nx/2;
end

% make sure the final image has an even size
if mod(Nxs,2)==1
    Nx=Nx-2;
    Nxs=Nxs-1;
end
if mod(Nys,2)==1
    Ny=Ny-2;
    Nys=Nys-1;
end

out=zeros(Nys,Nxs);

for ix=1:Nx/2
    for iy=1:Ny/2
        out(iy,ix)=(image(2*iy-1,2*ix-1)+...
                    image(2*iy,2*ix-1)+...
                    image(2*iy,2*ix)+...
                    image(2*iy-1,2*ix))/4;
    end
end







