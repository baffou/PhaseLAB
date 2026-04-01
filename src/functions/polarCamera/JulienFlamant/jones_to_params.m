function [bir, diatt] = jones_to_params(J, mode)
    if nargin < 2
        mode = 'HU';
    end
    [U, H] = polar_decomposition0(J, mode);
    [phi0, beta, pb] = unitary_to_birefringence0(U);
    [h0, D, pd] = hermitian_to_diattenuation0(H);
    bir{1}=phi0;
    bir{2} = beta;
    bir{3} = pb;
    diatt{1} = h0;
    diatt{2} = D;
    diatt{3} = pd;
end
