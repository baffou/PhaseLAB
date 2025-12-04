function [bir, diatt] = jones_decomposition_vectorized0(J, mode)
    if nargin < 2
        mode = 'HU';
    end
    [U, H] = polar_decomposition_vectorized0(J, mode);
    [bir.phi0, bir.beta, bir.pb  ] = unitary_to_birefringence_vectorized0(U);
    [diatt.h0, diatt.D,  diatt.pd] = hermitian_to_diattenuation_vectorized0(H);
end
