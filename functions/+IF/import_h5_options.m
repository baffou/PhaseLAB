function opts = import_h5_options(fileh5)

if ~exist(fileh5,'file')
    error('Data files do not exist!')
end

%infos=h5info(fileNameh5);
% display the h5 structure
%for ii=1:59
%    disp(info.Groups(1).Datasets(ii).Name)
%end

% import parameters
opts.xscale=h5read(fileh5,'/Image/x Image'); % x coordinates
opts.kx=h5read(fileh5,'/Image/kx Fourier');  % k coordinates
opts.nfft=h5read(fileh5,'/Option/nfft2d');   % image size in pixels
opts.k0=h5read(fileh5,'/Option/k0');         % wave vector
opts.lambda=h5read(fileh5,'/Option/lambda');         % wave vector
opts.Mobj=h5read(fileh5,'/Option/Mobj');         % wave vector
opts.NA=h5read(fileh5,'/Option/NA');         % wave vector
opts.dxSize=h5read(fileh5,'/Option/dxSize');         % wave vector
