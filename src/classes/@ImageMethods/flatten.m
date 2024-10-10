function [obj2, mask] = flatten(obj,method,opt)


arguments
    obj ImageMethods
    method (1,:) char {mustBeMember(method,{'Waves','Sine','Zernike','Chebyshev','Hermite','Legendre','Gaussian'})} = 'Gaussian'
    opt.nmax (1,1) {mustBeInteger(opt.nmax)} = 2
    opt.threshold double = 0 % if not zero, segment the cells and create a mask
    opt.mask = []  % specifies a mask, instead of computing one when threshold is not zero
    opt.kind  (1,1) {mustBeInteger(opt.kind)} = 1 % for Chebychev
    opt.display logical = false
    opt.nGauss = 100
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


if strcmp(method,'Zernike') && opt.threshold ~= 0
    warning('No threshold algorithm can be applied with Zernike flattening. The threshold value is ignored.')
end

No = numel(obj);

for io = 1:No

    if ~isempty(opt.mask)
        mask = opt.mask;
    elseif opt.threshold~=0 && ~strcmp(method,'Zernike') % then create a mask

        mask0 = abs(obj(io).DWx) > opt.threshold*1e-9;
        IMxm = obj(io).DWx.*mask0;

        mask0 = abs(obj(io).DWy) > opt.threshold*1e-9;
        IMym = obj(io).DWy.*mask0;


        N = 3;
        Tikh = 1e-5;

        x = (1:size(IMxm,2))';
        y = (1:size(IMym,1))';
        opt.Smatrix = g2sTikhonovRTalpha(x,y,N);
        W = g2sTikhonovRT(IMxm,IMym,opt.Smatrix,Tikh);

        %avgBG = mean(mean(W(~mask0)));
        %W = W-avgBG;
        %mask = W<opt.threshold*10*1e-9;

        %mask = ~mask0;
        mask = conv2(mask0,ones(10),"same")<1;

        dynamicFigure('ph',obj(io).OPD,'ph',W,'bw',double(mask0),'bw',double(mask),'nm',[2,2],'titles',{'original W','thresholded W','mask0','mask'})
        fullscreen

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
    elseif strcmp(method,'Waves') || strcmp(method,'Sine')
        temp=obj(io).OPD;
        for n = 1:opt.nmax
            temp = SineRemoval(temp,n,mask);
        end
        obj2(io).OPD=temp;
    elseif  strcmp(method,'Gaussian')
        obj2(io).OPD=obj2(io).OPD-imgaussfilt(obj(io).OPD,opt.nGauss);
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


    if opt.threshold~=0 && ~strcmp(method,'Zernike')
        if opt.display
            subplot(2,2,4)
            imageph(temp)
            title('final image')
            colormap(Pradeep)
            %climSym
            subplot(2,2,3)
            imageph(obj(io).OPD)
            title('initial image')
            colormap(Pradeep)
            %climSym
            subplot(2,2,2)
            imageph(temp.*mask+(1-mask).*max(temp(:)))
            title('considered area')
            fullscreen
            drawnow
        end
    end
    % cancel the gradients DWx and DWy, in case they exist,
    %  because they are not true anymore
    obj2(io).cancelGradients();

end

end