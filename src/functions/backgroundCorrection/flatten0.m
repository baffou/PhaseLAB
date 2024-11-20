function imgf = flatten0(img,method,opt)

arguments
    img (:,:) double
    method (1,:) char {mustBeMember(method,{'Waves','Sine','Zernike','Chebyshev','Hermite','Legendre','Gaussian'})} = 'Gaussian'
    opt.nmax (1,:) double {mustBeInteger(opt.nmax)} = 2
    opt.mask = []  % specifies a mask, instead of computing one when threshold is not zero
    opt.kind  (1,1) {mustBeInteger(opt.kind)} = 1 % for Chebychev
    opt.nGauss = 100
    opt.display = true
end


[Ny, Nx] = size(img);

if isempty(opt.mask)
    mask = ones(Ny,Nx) == 1;
else
    mask = opt.mask;
end

if all(mask(:) == 0)
    imgf = img;
    disp('only-zero-values mask. Wrong flatten parameters')
    return
end

if numel(opt.nmax) == 1
    condition_nmax = @(n,m) n+m <= opt.nmax;
    opt.nmax = [opt.nmax,opt.nmax];
elseif numel(opt.nmax) == 2
    condition_nmax = @(n,m) true;
end

if strcmpi(method,'Chebyshev') && opt.kind == 2
    method='Chebyshev2';
end

switch method
    case 'Zernike'
    imgf=img;
    for n = 1:opt.nmax(1)
        for m = mod(n,2):2:n
            imgf = ZernikeRemoval(imgf,n,m); % use a temp image to avoid writing several times on the HDD in remote mode.
        end
    end

    case {'Waves','Sine'}
        imgf=img;
        for n = 1:opt.nmax(1)
            imgf = SineRemoval(imgf,n,opt.mask(1));
        end

    case 'Gaussian'
        imgf=img-imgaussfilt(img,opt.nGauss);

    case {'Chebyshev','Hermite','Legendre'}

        imgf=img;

        for n = 0:opt.nmax(1)
            for m = 0:opt.nmax(2)
                if condition_nmax(n,m)
                    fprintf('(%d,%d) ',n,m)
                    imgf = polynomialRemoval(imgf,method,n,m,'mask',mask);
                end
            end
        end
        fprintf('\n')

    otherwise
        error('not a proper method name')

end

imgf = imgf - mean(img(mask));


if ~isempty(opt.mask) && opt.display
    if opt.display
        figure
        subplot(1,3,1)
        imageph(img)
        title('initial image')
        set(gca,'Colormap',Sepia)
        subplot(1,3,2)
        imageph(imgf)
        title('final image')
        set(gca,'Colormap',Sepia)
        subplot(1,3,3)
        imageph(mask)
        title('considered area')
        set(gca,'Colormap',gray)
        fullwidth
        drawnow
    end
end


end