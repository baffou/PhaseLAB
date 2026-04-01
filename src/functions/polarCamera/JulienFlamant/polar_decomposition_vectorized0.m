function [U, H] = polar_decomposition_vectorized0(J, mode)
arguments
    J JonesMatrix
    mode char {mustBeMember(mode,{'UH', 'HU'})} = 'UH'
end

% sz = size(J);
% if numel(sz) == 2
%     J0 = J;
%     J = zeros(size(J,1), size(J,2), 1, 1);
%     J(:,:,1,1) = J0;
% end
if strcmp(mode, 'UH')
    % Use pagemtimes for batch matrix multiplication
    JhJ = pagemtimes(conj(permute(J.mat, [2 1 3 4])), J.mat);
    H = sqrtm2x2(JhJ);
    detH = H(1,1, :, :).*H(2,2, :, :) - H(1,2, :, :).*H(2,1, :, :);
    %only implemented case where matrix H is not rank deficient
    pinvH = zeros(size(H));
    pinvH(1,1, :, :) = H(2,2, :, :) ./ detH;
    pinvH(1,2, :, :) = -H(1,2, :, :) ./ detH;
    pinvH(2,1, :, :) = -H(2,1, :, :) ./ detH;
    pinvH(2,2, :, :) = H(1,1, :, :) ./ detH;
    U = pagemtimes(J.mat, pinvH);
elseif strcmp(mode, 'HU')
    JJh = pagemtimes(J.mat, conj(permute(J.mat, [2 1 3 4])));
    H = sqrtm2x2(JJh);
    detH = H(1,1, :, :).*H(2,2, :, :) - H(1,2, :, :).*H(2,1, :, :);
    %only implemented case where matrix H is not rank deficient
    pinvH = zeros(size(H));
    pinvH(1,1, :, :) = H(2,2, :, :) ./ detH;
    pinvH(1,2, :, :) = -H(1,2, :, :) ./ detH;
    pinvH(2,1, :, :) = -H(2,1, :, :) ./ detH;
    pinvH(2,2, :, :) = H(1,1, :, :) ./ detH;
    U = pagemtimes(pinvH, J.mat);
else
    error('Mode must be ''UH'' or ''HU''');
end
end