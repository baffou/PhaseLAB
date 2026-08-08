function [T, J_lin,eigenvect, Dhat, beta_hat, h0_hat, phi0_hat] = Schur_to_T(U,V)
arguments
    U JonesMatrix
    V JonesMatrix
end

Nim = numel(U);

T.to = cell(Nim,1);
T.te = cell(Nim,1);
T.psi = cell(Nim,1);
Dhat = cell(Nim,1);
beta_hat = cell(Nim,1);
h0_hat = cell(Nim,1);
phi0_hat = cell(Nim,1); % difference in factor 2 because of the way we defined phi0 in birefringence_to_unitary

for im = 1:Nim
    
%    V{im}(1, 2,:,:) = 0; % set off-diagonal to zero to enforce homogeneity
    V(im).xy = 0; % set off-diagonal to zero to enforce homogeneity
    J_homo = pagemtimes( U(im).mat , pagemtimes(V(im).mat , pagectranspose(U(im).mat)));
    % project to linear only
    J_lin = 0.5*(J_homo + pagetranspose(J_homo)); % symmetry enforces linearity (component on sigma_3 vanishes)
    % compute parameters via eigendecomposition
    [eigenvect, t_vals] = pageeig(J_lin);
    %t_vals = diag(t_vals);

    % Ensure eigenvalues on each page are ordered by decreasing absolute value
    sz = size(t_vals);               % e.g. [2 2 nrows ncols]
    npages = prod(sz(3:end));
    tvals2 = reshape(t_vals, 2, 2, npages);
    eigvec2 = reshape(eigenvect, 2, 2, npages);

    for p = 1:npages
        a = tvals2(1,1,p);
        b = tvals2(2,2,p);
        if abs(a) < abs(b)
            % swap eigenvalues (diagonal entries)
            tvals2(:,:,p) = tvals2([2 1],[2 1],p);
            % swap corresponding eigenvectors (columns)
            eigvec2(:,:,p) = eigvec2(:,[2 1],p);
        end
    end

    % reshape back to original page sizes
    t_vals = reshape(tvals2, sz);
    eigenvect = reshape(eigvec2, size(eigenvect));

    % determine psi from eigenvectors
    T.psi{im} = squeeze( angle(eigenvect(1, 1,:,:) + 1j*eigenvect(2, 1,:,:)));
    % get D, beta
    t1 = squeeze( t_vals(1,1,:,:));
    t2 = squeeze( t_vals(2,2,:,:));
    Dhat{im} = (abs(t1) - abs(t2)) ./ (abs(t1) + abs(t2)) ;
    beta_hat{im} = angle(t1) - angle(t2);
    h0_hat{im} = (abs(t1) + abs(t2))/2;
    phi0_hat{im} = (angle(t1) + angle(t2))/2;

    T.to{im} = t1; % largest absolute value
    T.te{im} = t2;

    % print results
    % fprintf('t_e = %f\n', t_vals(1));
    % fprintf('t_o = %f\n', t_vals(2));
    % fprintf('psi = %f\n', psi);
    % fprintf('Dhat = %f\n', Dhat);
    % fprintf('beta_hat = %f\n', beta_hat);
    % fprintf('h0_hat = %f\n', h0_hat);
    % fprintf('phi0_hat = %f\n', phi0_hat); % difference in factor 2 because of the way we defined phi0 in birefringence_to_unitary
end