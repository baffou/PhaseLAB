function [imgx, imgy, mat] = Jones0(img0x, img0y, varargin)

% readjust the varargin, in case it comes from the varargin of the Jones
% method:
if numel(varargin) == 1
    if iscell(varargin{1}) % cell containing the varargin of the Jones Method
        varargin = varargin{1};
    end
end

Nvar = numel(varargin);

if Nvar > 1  % Jones0(im1, im2, 'P', 45, 'QWP', 30', 'J', {J, 45} ...)
    %angles in degrees

    % Quarter waveplate
    QWP = [1 0; 0 1i];
    % Half waveplate
    HWP = [1 0; 0 -1];
    % Polarizer
    P   = [1 0; 0 0];
    % Rotation matrix
    R = @(theta) [cosd(theta) -sind(theta);sind(theta) cosd(theta)];


    mat = eye(2,2);
    if isnumeric(varargin{1}) % [a b; c d]
        if all(size(varargin{1})==[2 2])
            mat = varargin{1};
        end
    else
        for ii = 1:2:Nvar
            if mod(Nvar,2)
                error('Must have an even number of inputs')
            end
            if ~ischar(varargin{ii})
                error('this input must be text: ''P'', ''QWP'', ''HWP'', or ''J''')
            end
            switch varargin{ii}
                case 'P'
                    mat = R(varargin{ii+1})*P*R(-varargin{ii+1})*mat;
                case 'QWP'
                    mat = R(varargin{ii+1})*QWP*R(-varargin{ii+1})*mat;
                case 'HWP'
                    mat = R(varargin{ii+1})*HWP*R(-varargin{ii+1})*mat;
                case 'J'
                    mat = R(varargin{ii+1}{2})*varargin{ii+1}{1}*R(-varargin{ii+1}{2})*mat;
            end
        end
    end

elseif Nvar == 1 % Jones0(im1, im2, matrix)
    mat = varargin{1};
else
    error('not enough input arguments')
end

imgx = img0x*mat(1,1)+img0y*mat(1,2);
imgy = img0x*mat(2,1)+img0y*mat(2,2);

