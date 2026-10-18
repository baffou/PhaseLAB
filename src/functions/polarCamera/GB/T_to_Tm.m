function [Tm] = T_to_Tm(T, masks)

Nth = numel(T.to);

Tm.to = zeros(Nth,1);
Tm.te = zeros(Nth,1);
Tm.phi = zeros(Nth,1);

for ith = 1:Nth
    Tm.to(ith) = mean(T.to{ith}(masks{ith}));
    Tm.te(ith) = mean(T.te{ith}(masks{ith}));
    Tm.phi(ith) = meanDirection(T.phi{ith}(masks{ith}));
end

if isfield(T,'phib')
    Tm.phib = zeros(Nth,1);
    Tm.phid = zeros(Nth,1);
    for ith = 1:Nth
        Tm.phib(ith) = meanDirection(T.phib{ith}(masks{ith}));
        Tm.phid(ith) = meanDirection(T.phid{ith}(masks{ith}));
    end    
end



