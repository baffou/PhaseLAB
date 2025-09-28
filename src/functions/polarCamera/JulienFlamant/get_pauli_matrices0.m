function pauli = get_pauli_matrices0()
    sigma_1 = [1, 0; 0, -1];
    sigma_2 = [0, 1; 1, 0];
    sigma_3 = [0, -1i; 1i, 0];
    pauli = {sigma_1, sigma_2, sigma_3};
end
