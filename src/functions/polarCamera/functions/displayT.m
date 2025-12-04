function displayT(Tlist)

Nt = numel(Tlist);

figure
for it = 1:Nt
    % opical conductivity
    %Tlist(it).to = 1./Tlist(it).to-1;
    %Tlist(it).te = 1./Tlist(it).te-1;
    subplot(2,Nt,it)
    hold on
    plot(Tlist(it).to,'s','Color',myColors('o'),'LineWidth',2)
    plot(Tlist(it).te,'s','Color',myColors('b'),'LineWidth',2)
    plot(0,0,'k+')
    set(gca,'DataAspectRatio',[1 1 1])
    legend({'to','te'},"Location","northwest")
    xline(0, 'k--', 'HandleVisibility', 'off');
    yline(0, 'k--', 'HandleVisibility', 'off');
    box on
    xlabel('Re(t_j)','FontSize',16)
    ylabel('Im(t_j)','FontSize',16)

    subplot(2,Nt,it+Nt)
    hold on
    plot(0:20:180,180/pi*unwrap(4*Tlist(it).phi)/4,'s-','Color',myColors('p'),'LineWidth',2)

    if isfield(Tlist(it),'phib')
        plot(0:20:180,180/pi*unwrap(4*Tlist(it).phib)/4,'s-')
        plot(0:20:180,180/pi*unwrap(4*Tlist(it).phid)/4,'s-')
    end
    plot(0:20:180,0:20:180,'k--')
    grid on
    box on
    set(gca,'DataAspectRatio',[1 1 1])
    if isfield(Tlist(it),'phib')
        legend({'phi','phib','phid','sample angle'})
    else
        legend({'phi','sample angle'})
    end
    set(gcf,'Position',[560   428   560*Nt   800])
    set(gcf,'Color',[1 1 1])
    xlabel('Sample angle [°]','FontSize',16)
    ylabel('phi [°]','FontSize',16)


end



