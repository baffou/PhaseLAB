function [te, to, eigenvect, psi, Dhat, beta_hat, h0_hat, phi0_hat] = jones_linear_decomposition0(J)
    % project to homogeneous
    [T, Z] = schur(J);
    T(1, 2) = 0; % set off-diagonal to zero to enforce homogeneity
    J_homo = Z * T * Z';
    % project to linear only
    J_lin = 0.5*(J_homo + conj(J_homo')); % symmetry enforces linearity (component on sigma_3 vanishes)
    % compute parameters via eigendecomposition
    [eigenvect, t_vals] = eig(J_lin);
    t_vals = diag(t_vals);

    
    to_te = diag(t_vals);
    % Sort eigenvalues by absolute value
    [~, idx] = sort(abs(to_te), 'descend');
    to_val = to_te(idx(1)); % Largest absolute value
    te_val = to_te(idx(2)); % Smaller absolute value
    
    % Assign to to(s, i, j) and te(s, i, j)
    to = to_val;
    te = te_val;

    
    
    
    
    
    
    
    
    
    
    
    
    
    % determine psi from eigenvectors
    psi = angle(eigenvect(1, 1) + 1j*eigenvect(2, 1));
    % get D, beta
    Dhat = (abs(t_vals(1)) - abs(t_vals(2))) / (abs(t_vals(1)) + abs(t_vals(2)));
    beta_hat = angle(t_vals(1)) - angle(t_vals(2));
    h0_hat = (abs(t_vals(1)) + abs(t_vals(2)))/2;
    phi0_hat = (angle(t_vals(1)) + angle(t_vals(2)))/2;
    % print results


    % fprintf('t_e = %f\n', to);
    % fprintf('t_o = %f\n', te);
    % fprintf('psi = %f\n', psi);
    % fprintf('Dhat = %f\n', Dhat);
    % fprintf('beta_hat = %f\n', beta_hat);
    % fprintf('h0_hat = %f\n', h0_hat);
    % fprintf('phi0_hat = %f\n', phi0_hat); % difference in factor 2 because of the way we defined phi0 in birefringence_to_unitary
end