function [U,V] = J_to_Schurr(J)

Nth = numel(J);

Ny = size(J{1},3);
Nx = size(J{1},4);

U = cell(Nth,1);
V = cell(Nth,1);
for ith = 1:Nth

    U{ith} = zeros(2,2,Ny,Nx);
    V{ith} = zeros(2,2,Ny,Nx);
    
    for ix = 1:Nx
        for iy = 1:Ny
            [U{ith}(:,:,iy,ix),V{ith}(:,:,iy,ix)] = schur(squeeze(J{ith}(:,:,iy,ix)));
        end
    end

end
