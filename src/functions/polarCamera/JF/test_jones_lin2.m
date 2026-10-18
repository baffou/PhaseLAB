function [to, te] = test_jones_lin2(J)
% process data
to = zeros(numel(J), J(1).Ny, J(1).Nx);
te = zeros(numel(J), J(1).Ny, J(1).Nx);
for s=1:numel(J)
    Jall = J(s).mat;
    for i=1:J(s).Ny
        for j=1:J(s).Nx
            J0 = squeeze(Jall(:, :, i, j));
            [Z, T] = schur(J0);
            T(1, 2) = 0; % set off-diagonal to zero to enforce homogeneity
            J_homo = Z * T * Z';
            % project to linear only
            J_lin = 0.5*(J_homo + conj(J_homo)'); % symmetry enforces linearity (component on sigma_3 vanishes)
            [eigenvect, t_vals] = eig(J_lin);
     
            to_te = diag(t_vals);
            % Sort eigenvalues by absolute value
            [abs_to_te, idx] = sort(abs(to_te), 'descend');
            to_val = to_te(idx(1)); % Largest absolute value
            te_val = to_te(idx(2)); % Smaller absolute value
   
            % Assign to to(s, i, j) and te(s, i, j)
            to(s, i, j) = to_val;
            te(s, i, j) = te_val;

        end
    end
end
