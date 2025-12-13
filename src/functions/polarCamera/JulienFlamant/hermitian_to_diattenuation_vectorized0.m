function [h0, D, pd] = hermitian_to_diattenuation_vectorized0(H)
    h0 = 0.5 * (real(H(1,1, :, :)) + real(H(2,2, :, :)));
    Hd = H;
    Hd(1,1, :, :) = 1 ./ h0 .* (Hd(1,1, :, :) - h0);
    Hd(2,2, :, :) = 1 ./ h0 .* (Hd(2,2, :, :) - h0);
    Hd(1,2, :, :) = 1 ./ h0 .* Hd(1,2, :, :);
    Hd(2,1, :, :) = 1 ./ h0 .* Hd(2,1, :, :);
    d = zeros([size(H,3), size(H,4), 3]);
    d(:,:,1) = real(Hd(1,1, :, :) - Hd(2,2, :, :));
    d(:,:,2) = real(Hd(1,2, :, :) + Hd(2,1, :, :));
    d(:,:,3) = imag(-Hd(1,2, :, :) + Hd(2,1, :, :));
    norm_d = sqrt(sum(d.^2, 3));
    pd = d ./ norm_d;
    D = norm_d / 2;
    h0 = squeeze(h0);
end