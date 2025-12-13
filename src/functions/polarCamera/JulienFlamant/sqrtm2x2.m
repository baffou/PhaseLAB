function sqrtH = sqrtm2x2(H)
    tau = H(1,1, :, :) + H(2,2, :, :);
    delta = H(1,1, :, :).*H(2,2, :, :) - H(1,2, :, :).*H(2,1, :, :);
    s = sqrt(delta);
    alpha = s ./ sqrt(tau + 2 * s);
    beta = 1 ./ sqrt(tau + 2 * s);
    sqrtH = zeros(size(H));
    sqrtH(1,1, :, :) = alpha + beta .* H(1,1, :, :);
    sqrtH(2,2, :, :) = alpha + beta .* H(2,2, :, :);
    sqrtH(1,2, :, :) = beta .* H(1,2, :, :);
    sqrtH(2,1, :, :) = beta .* H(2,1, :, :);
end
