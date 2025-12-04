function U = birefringence_to_unitary0(phi0, beta, pb)
    pauli = get_pauli_matrices0();
    B = pb(1) * pauli{1} + pb(2) * pauli{2} + pb(3) * pauli{3};
    U = exp(1i * phi0 / 2) * (cos(beta / 2) * eye(2) + 1i * sin(beta / 2) * B);
end
