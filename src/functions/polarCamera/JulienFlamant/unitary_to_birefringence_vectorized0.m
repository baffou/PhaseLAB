function [phi0, beta, pb] = unitary_to_birefringence_vectorized0(U)
    detU = U(1,1, :, :).*U(2,2, :, :) - U(1,2, :, :).*U(2,1, :, :);
    phi0 = angle(detU);
    Ub = U .* exp(-1i * phi0 / 2);
    cosbeta2 = 0.5 * (real(Ub(1,1, :, :)) + real(Ub(2,2, :, :)));
    beta = squeeze(2 * acos(cosbeta2));
    Ubc = Ub * (-1i);
    b = zeros([size(U,3), size(U,4), 3]);
    b(:,:,1) = real(Ubc(1,1, :, :) - Ubc(2,2, :, :));
    b(:,:,2) = real(Ubc(1,2, :, :) + Ubc(2,1, :, :));
    b(:,:,3) = imag(-Ubc(1,2, :, :) + Ubc(2,1, :, :));
    norm_b = sqrt(sum(b.^2, 3));
    pb = b ./ norm_b;
    phi0 = squeeze(phi0);
end
