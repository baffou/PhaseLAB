function [phi0, beta, pb] = unitary_to_birefringence0(U)
    if norm(U * U' - eye(size(U))) > 1e-10
        error('Input matrix is not unitary');
    end
    phi0 = angle(det(U));
    Ub = U * exp(-1i * phi0 / 2);
    logU = -1i * logm(Ub);
    b = zeros(1, 3);
    b(1) = real(logU(1, 1) - logU(2, 2));
    b(2) = real(logU(1, 2) + logU(2, 1));
    b(3) = imag(-logU(1, 2) + logU(2, 1));
    pb = b / norm(b);
    beta = norm(b);
end
