function out = applySymmetryD4(img, ops)
% applyMinimalTransform  Apply a sequence of H, V, R transforms in minimal form.
%   img  – input image
%   ops – cell array or char array, e.g. {'H','V','R','V'} or 'HVRV'
%   out – image after the single equivalent transform

% Represent a D₄ element as (f,k):
%   f = 0 → no flip; f = 1 → horizontal flip (H)
%   k = 0..3 → number of 90° CCW rotations

% To ensure that the sequence of transformations is reduced to the simplest equivalent, we can exploit the fact that the operations
%     H = horizontal mirror
%     V = vertical mirror
%     R = 90° rotation
% generate the dihedral group D₄ (the symmetries of the square). Any arbitrary sequence of these operations corresponds to a single element of D₄, which can be described as either:
%     a rotation by 0°, 90°, 180° or 270° (R⁰, R¹, R², R³),
%     or a horizontal mirror followed by a rotation of k×90°.
% The algorithm is therefore:
%     Scan the list of operations and compose at each step the current element of D₄.
%     At the end, apply to the image the single equivalent transformation.
arguments
    img (:,:) double
    ops (1,:) char
end

f = 0;
k = 0;

for i = 1:numel(ops)
    op = ops(i);
    switch op
        case 'H'    % horizontal mirror
            f2 = 1; k2 = 0;
        case 'V'    % vertical mirror = H then R^2
            f2 = 1; k2 = 2;
        case 'R'    % rotate 90° CCW
            f2 = 0; k2 = 1;
        otherwise
            error('Unknown operation: %s', op);
    end

    % Compose new = op ∘ current
    if f2 == 0
        % composing a pure rotation R^k2
        if f == 0
            k = mod(k + k2, 4);
        else
            k = mod(k - k2, 4);
        end
        % f stays the same
    else
        % composing flip H then R^k2
        if f == 0
            f = 1;
            k = mod(k2 + k, 4);
        else
            f = 0;
            k = mod(k - k2, 4);
        end
    end
end

% Finally apply the single transform
if f == 0
    out = rot90(img, k);
else
    tmp = flipud(img);       % horizontal mirror
    out = rot90(tmp, k);
end
end
