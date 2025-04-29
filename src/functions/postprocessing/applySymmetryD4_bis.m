function out = applySymmetryD4_bis(img, ops)
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
            dk = 0;
            df = 1;
        case 'V'    % vertical mirror = H then R^2
            dk = 2;
            df = 1;
        case 'R'    % rotate 90° CCW
            dk = 1-2*f;
            df = 0;
        otherwise
            error('Unknown operation: %s', op);
    end

    k = mod(k + dk, 4); 
    f = mod(f + df, 2);

    %fprintf('f=%.1d\tk=%.1d\n',f,k)

end

% Finally apply the single transform
if f == 0
    out = rot90(img, k);
else
    tmp = rot90(img, k);
    out = flipud(tmp);       % horizontal mirror
end
end
