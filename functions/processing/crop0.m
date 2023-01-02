function [x1, x2, y1, y2] = crop0(obj,opt)
% arguments
%     obj    % Interfero or ImageMethods
%     opt.xy1 = []
%     opt.xy2 = []
%     opt.Center {mustBeMember(opt.Center,{'Auto','Manual','auto','manual'})} = 'Auto'
%     opt.Size = 'Manual'
%     opt.twoPoints logical = false
% end

if opt.twoPoints
    obj(1).figure
    [xx,yy]=ginput(2);
    x1=round(min(xx));
    x2=round(max(xx));
    y1=round(min(yy));
    y2=round(max(yy));
    x1=round(max([1;x1]));
    x2=round(min([obj(1).Nx;x2]));
    y1=round(max([1;y1]));
    y2=round(min([obj(1).Ny;y2]));
elseif ~isempty(opt.xy1) && ~isempty(opt.xy2)  % crop('xy1', [a,b], 'xy2', [a,b])
    if numel(opt.xy1)~=2
        error('First input must be a 2-vector (x,y)')
    end
    if numel(opt.xy2)~=2
        error('Second input must be a 2-vector (x,y)')
    end
    x1 = min([opt.xy1(1),opt.xy2(1)]);
    x2 = max([opt.xy1(1),opt.xy2(1)]);
    y1 = min([opt.xy1(2),opt.xy2(2)]);
    y2 = max([opt.xy1(2),opt.xy2(2)]);
else
    if strcmpi(opt.Center,'Manual') % crop('Center','Manual')
        h = obj(1).figure;
        [xc, yc] = ginput(1);
        close(h)
    else
        xc = obj(1).Nx/2;
        yc = obj(1).Ny/2;
    end
    if strcmpi(opt.Size,'Manual') % crop('Center','Manual')
        h = obj(1).figure;
        h.UserData{12}.getPoint = 0;
        rr = rectangle();
        set (h, 'WindowButtonMotionFcn', @(src,event)drawRect(h,rr,xc,yc))
        set (h, 'WindowButtonDownFcn', @(src,event)getPoint(h))
        while h.UserData{12}.getPoint==0
            pause(0.1)
        end
        Size = h.UserData{12}.side;
        if mod(Size,2)==1,Size=Size-1;end % makes sure Size is even
        close (h)
        x1 = floor(xc-Size/2+1);
        x2 = floor(xc-Size/2+Size);
        y1 = floor(yc-Size/2+1);
        y2 = floor(yc-Size/2+Size);
    elseif isnumeric(opt.Size)
        if length(opt.Size)==1
            if mod(opt.Size,2)==1 % makes sure Size is even
                opt.Size=opt.Size-1;
                warning('The size of the image has been decremented to make sure it is even')
            end
            x1 = floor(xc-opt.Size/2+1);
            x2 = floor(xc-opt.Size/2+opt.Size);
            y1 = floor(yc-opt.Size/2+1);
            y2 = floor(yc-opt.Size/2+opt.Size);
        elseif length(opt.Size)==2
            if mod(opt.Size(1),2)==1 % makes sure Size is even
                opt.Size(1)=opt.Size(1)-1;
                warning('The size of the image has been decremented to make sure it is even')
            end
            if mod(opt.Size(2),2)==1 % makes sure Size is even
                opt.Size(2)=opt.Size(2)-1;
                warning('The size of the image has been decremented to make sure it is even')
            end
            x1 = floor(xc-opt.Size(2)/2+1);
            x2 = floor(xc-opt.Size(2)/2+opt.Size(2));
            y1 = floor(yc-opt.Size(1)/2+1);
            y2 = floor(yc-opt.Size(1)/2+opt.Size(1));
        end
    end

    
end

if mod(x2-x1,2)==0
    x2=x2-1;
end
if mod(y2-y1,2)==0
    y2=y2-1;
end



    function drawRect(h,rr,xc,yc)
        C = get (h.UserData{7}(2), 'CurrentPoint');
        side = floor(max(abs([2*(C(1)-xc), 2*(C(3)-yc)])));
        set(rr,'Position',[xc-side/2 yc-side/2 side side])
        h.UserData{12}.side = side;
        disp(side)
    end

    function getPoint(h)
        h.UserData{12}.getPoint = 1;
    end


end