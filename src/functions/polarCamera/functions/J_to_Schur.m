function [U,V] = J_to_Schur(J)
arguments
    J JonesMatrix
end

Nim = numel(J);

Ny = J(1).Nx;
Nx = J(1).Ny;

U = cell(Nim,1);
V = cell(Nim,1);
for ith = 1:Nim

    U{ith} = zeros(2,2,Ny,Nx);
    V{ith} = zeros(2,2,Ny,Nx);
    Jmat = J(ith).mat;
    for ix = 1:Nx
        for iy = 1:Ny
            [U{ith}(:,:,iy,ix),V{ith}(:,:,iy,ix)] = schur(squeeze(Jmat(:,:,iy,ix)));
        end
    end

end
U = JonesMatrix(U);
V = JonesMatrix(V);

