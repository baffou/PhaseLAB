function H = diattenuation_to_hermitian0(h0, D, pd)
    pauli = get_pauli_matrices0();
    D_op = pd(1) * pauli{1} + pd(2) * pauli{2} + pd(3) * pauli{3};
    H = h0 * (eye(2) + D * D_op);
end
