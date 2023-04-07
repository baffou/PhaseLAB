function [obj2, mask] = flatten(obj,method,opt)
arguments
    obj (1,:) ImageMethods
    method (1,:) char {mustBeMember(method,{'Waves','Zernike','Chebyshev','Hermite','Legendre'})} = 'Waves'
    opt.nmax (1,1) {mustBeInteger(opt.nmax)} = 2
    opt.threshold double = 0 % if not zero, segment the cells and create a mask
    opt.kind  (1,1) {mustBeInteger(opt.kind)} = 1 % for Chebychev
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


if strcmp(method,'Zernike') && opt.threshold ~= 0
    warning('No threshold algorithm can be applied with Zernike flattening. The threshold value is ignored.')
end

No = numel(obj);
for io = 1:No

    if opt.threshold~=0 && ~strcmp(method,'Zernike') % then create a mask
        im20=imgaussfilt(stdfilt(obj(io).D2Wnorm,true(9)),10);
        %        imP=imgaussfilt(stdfilt(obj(io).PDCM,true(9)),10);
        %        hi=histogram(2*imP);
        if opt.display
            figure,subplot(2,2,1)
        end
        hi=histogram(im20);
        posM=find(hi.Values==max(hi.Values));
        x=hi.BinEdges(posM);
        threshold=opt.threshold*x;
        xline(threshold,"LineWidth",2,"Color",[0.9, 0.3, 0.2])
        %        hold on
        %        histogram(2*im20,'facecolor',[0.3, 0.2, 0.9],'facealpha',.5,'edgecolor','none');
        %mask=obj(io).OPD~=max(max(obj(io).OPD));
        mask=im20<threshold;
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
    
    
    if opt.threshold~=0 && ~strcmp(method,'Zernike')
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

