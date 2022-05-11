function [profile, w, cx, cy] = radialAverage0(IMG, center, Rmax)
    % computes the radial average of the image IMG around the cx,cy point
    % w is the vector of radii starting from zero
    [Ny,Nx] = size(IMG);
    
    
    if nargin==1
        hh=figure();
        imagesc(IMG);
        set(gca,'dataAspectRatio',[1 1 1])
        hc=drawcircle();
        cx=hc.Center(1);
        cy=hc.Center(2);
        w=1:floor(0.9*sqrt(Nx*Nx+Ny*Ny)/2);
        
        while isvalid(hh)
            pause(0.1)
        end
    elseif nargin==2
        cx=center(1);
        cy=center(2);
        w=1:floor(0.9*sqrt(Nx*Nx+Ny*Ny)/2);
    elseif nargin==3
        cx=center(1);
        cy=center(2);
        
        w=0:Rmax;
    end
    
    
    [X, Y] = meshgrid( (1:Nx)-cx, (1:Ny)-cy);

    R = sqrt(X.^2 + Y.^2);
    Nw=length(w);
    profile = zeros(Nw,1);
    for ii = 1:Nw % radius of the circle
        mask = (w(ii)-1<R & R<w(ii)+1); % smooth 1 px around the radius  
        %values = (1-abs(R(mask)-i)) .* double(IMG(mask)); % smooth based on distance to ring, doesn't work!
        values = IMG(mask); % without smooth
        profile(ii) = mean( values(:) );
    end
    profile(1)=IMG(round(cy),round(cx));
end



