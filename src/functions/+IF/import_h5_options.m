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
opts.nfft=h5read(fileh5,'/Option/Npx');   % image size in pixels
opts.lambda=h5read(fileh5,'/Option/lambda');         % wave vector
opts.P0=h5read(fileh5,'/Option/P0');         % wave vector
opts.P0=h5read(fileh5,'/Option/P0');         % wave vector
opts.w0=h5read(fileh5,'/Option/w0');         % wave vector
opts.ndipole=h5read(fileh5,'/Option/ndipole');         % wave vector
opts.pxSize=h5read(fileh5,'/Option/aretecube');         % wave vector
opts.epsmax=h5read(fileh5,'/Option/epsmax');         % wave vector
opts.epsmin=h5read(fileh5,'/Option/epsmin');         % wave vector
opts.n=h5read(fileh5,'/Option/n');         % wave vector
opts.nS=h5read(fileh5,'/Option/nS');         % wave vector
opts.Mobj=h5read(fileh5,'/Option/M');         % wave vector
opts.NA=h5read(fileh5,'/Option/NA');         % wave vector

opts.xscale=h5read(fileh5,'/Image/x Image'); % x coordinates
opts.kx=h5read(fileh5,'/Image/kx Fourier');  % k coordinates
