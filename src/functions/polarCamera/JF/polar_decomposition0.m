function [U, H] = polar_decomposition0(J, mode)
    if nargin < 2
        mode = 'UH';
    end
    if strcmp(mode, 'UH')
        H = sqrtm(J' * J);
        U = J / H;
    elseif strcmp(mode, 'HU')
        H = sqrtm(J * J');
        U = H \ J;
    else
        error('Mode must be "UH" or "HU"');
    end
end

