function [Um, Vm] = meanSchurr(U,V,masks)

Nth = numel(masks);

Um = cell(Nth,1);
Vm = cell(Nth,1);

for ith = 1:Nth
    
    Um{ith} = mean( U{ith}(:,:,masks{ith}) ,3);
    Vm{ith} = mean( V{ith}(:,:,masks{ith}) ,3);

end