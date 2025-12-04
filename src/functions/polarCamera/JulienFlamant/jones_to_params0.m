function [bir, diatt] = jones_to_params0(J, mode)
    if nargin < 2
        mode = 'HU';
    end
    [U, H] = polar_decomposition0(J, mode);
    [phi0, beta, pb] = unitary_to_birefringence0(U);
    [h0, D, pd] = hermitian_to_diattenuation0(H);
    bir.phi0=phi0;
    bir.beta = beta;
    bir.pb = pb;
    diatt.h0 = h0;
    diatt.D = D;
    diatt.pd = pd;
end
