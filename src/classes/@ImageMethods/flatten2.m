function [obj2, mask] = flatten2(obj,method,opt)
% second version, tested on bacteria

arguments
    obj (1,:) ImageMethods
    method (1,:) char {mustBeMember(method,{'Waves','Zernike','Chebyshev','Hermite','Legendre'})} = 'Waves'
    opt.nmax (1,1) {mustBeInteger(opt.nmax)} = 2
    opt.threshold double = double.empty() % if not empty, segment the cells and create a mask
    opt.kind  (1,1) {mustBeInteger(opt.kind)} = 1
    opt.display logical = false
end

% method:
%   'Zernike'
%   or
%   'Waves', 'Wave', 'Sine', 'sine'     (by default)
%   or
%   'Chebyshev

if nargout
    obj2=copy(obj);
else
    obj2=obj;
end


if strcmp(method,'Zernike') && ~isempty(opt.threshold)
    warning('No threshold algorithm can be applied with Zernike flattening. The threshold value is ignored.')
end

No = numel(obj);
for io = 1:No

    if ~isempty(opt.threshold) && ~strcmp(method,'Zernike') % then create a mask
        imstd=stdfilt(obj(io).OPD,true(11));
        if opt.display
            figure,subplot(2,2,1)
        end

        maxA=max(imstd(:));
        minA=min(imstd(:));
        ampl=maxA-minA;
        
        mask=imstd<(minA+ampl/4);
        
        mask=imgaussfilt(double(mask),opt.threshold)>0.99;
        imagesc(mask)
        drawnow

    else
        mask = ones(obj(io).Ny, obj(io).Nx)==1;
    end

    if strcmpi(method,'Chebyshev') && opt.kind == 2
        method='Chebyshev2';
    end


    if strcmp(method,'Zernike')
        temp=obj(io).OPD;
        for n = 1:opt.nmax
            for m = mod(n,2):2:n
                temp = ZernikeRemoval(temp,n,m); % use a temp image to avoid writing several times on the HDD in remote mode.
            end
        end
        obj2(io).OPD=temp;
    elseif strcmp(method,'Waves')
        temp=obj(io).OPD;
        for n = 1:opt.nmax
            temp = SineRemoval(temp,n,mask);
        end
        obj2(io).OPD=temp;
    else  

        temp=obj(io).OPD;

        for n = 0:opt.nmax
            for m = 0:opt.nmax
                if n+m <= opt.nmax
                    temp = polynomialRemoval(temp,method,n,m,'mask',mask);
                end
            end
        end
        obj2(io).OPD=temp;
    end
    
    
    if ~isempty(opt.threshold) && ~strcmp(method,'Zernike')
        if opt.display
            subplot(2,2,2)
            imageph(temp)
            title('final image')
            subplot(2,2,3)
            imageph(temp.*(1-mask)+mask.*max(temp(:)))
            title('masked area')
            subplot(2,2,4)
            imageph(temp.*mask+(1-mask).*max(temp(:)))
            title('considered area')
            fullscreen
        end
    end
    
    
    
end

end

