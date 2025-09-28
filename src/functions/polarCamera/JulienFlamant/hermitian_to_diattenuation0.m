function [h0, D, pd] = hermitian_to_diattenuation0(H)
    if norm(H - H') > 1e-10
        error('Input matrix is not Hermitian');
    end
    if any(eig(H) < -1e-12)
        error('Input matrix is not positive semidefinite');
    end
    h0 = real(trace(H)) / 2;
    Hd = (1 / h0) * (H - h0 * eye(2));
    d = zeros(1, 3);
    d(1) = real(Hd(1, 1) - Hd(2, 2));
    d(2) = real(Hd(1, 2) + Hd(2, 1));
    d(3) = imag(-Hd(1, 2) + Hd(2, 1));
    pd = d / norm(d);
    D = norm(d) / 2;
end