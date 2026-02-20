function Tm = Schur_to_Tm(Um, Vm)

for ith = 1:numel(Um)
    Tm.to(ith) = Vm{ith}(1,1);
    Tm.te(ith) = Vm{ith}(2,2);

    v = [Um{ith}(1,1);Um{ith}(2,1)];
    V = v*v';
    p = zeros(3,1);
    p(1) = V(1, 1) + V(2,2);
    p(2) = real( V(1,2) + V(2,1));
    p(3) = imag(-V(1,2) + V(2,1));
    
    Tm.phi(ith) = -angle(p(1)+1i*p(2));
end
