function figuredx_callback(hfig,nFrame,IM,k,UIk)


if nargin==5
    set(UIk,'string',num2str(k));
end

if nFrame==1

    if isa(IM,'ImageQLSI')
        title({IM.TfileName,IM.OPDfileName}, 'Interpreter', 'none')
    elseif isa(IM,'ImageEM')
        title({'Norm. intensity + phase','mixed representation'})
    end

    c = opendx(IM.T,IM.Ph);
    cb.Ph = c;
    cb.Ph.Label.String = 'Phase (rad)';
    cb.T = colorbar('westoutside');
    cb.T.Label.String = 'Normalized intensity';
    colormap(cb.T,gray(1024))
    minT = min(IM(1).T(:));
    maxT = max(IM(1).T(:));
    if minT>1 && maxT<1
        cb.T.Ticks = [minT,1,maxT];
    else
        cb.T.Ticks = [minT,maxT];
    end
    cb.T.Limits = [min(IM.T(:)) max(IM.T(:))];


elseif nFrame==2
    
    ha(1) = subplot(1,2,1);
    cb.T = opendx(IM.T,gray(1024));
    minT = min(IM(1).T(:));
    maxT = max(IM(1).T(:));
    if minT>1 && maxT<1
        cb.T.Ticks = [minT,1,maxT];
    else
        cb.T.Ticks = [minT,maxT];
    end
        
    cb.T.Label.String = 'Normalized intensity';
    if isa(IM,'ImageQLSI')
        title(IM.TfileName, 'Interpreter', 'none')
    else
        title('Transmission image')
    end
    ha(2) = subplot(1,2,2);
    cb.Ph = opendx(IM.Ph,phase1024,15); % opendx2(iamge,colorScale,camLightAngle)
    %cb.Ph = opendx(IM.Ph,hsv(1024),15);
    cb.Ph.Label.String = 'Phase (rad)';
    cb.OPD = colorbar('westoutside');
    cb.OPD.TickLabels = round(100*cb.Ph.Ticks*IM(1).lambda/(2*pi)*1e9)/100;
    cb.OPD.Label.String = 'OPD (nm)';
    camlight(90,180,'infinite')
    linkaxes(ha, 'xy');      
    if isa(IM,'ImageQLSI')
        title(IM.OPDfileName, 'Interpreter', 'none')
    else
        title('OPD image')
    end
    
end

hfig.UserData = cb;



