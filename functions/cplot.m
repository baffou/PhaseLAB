function hfigout=cplot(Z,varargin)
% Z: complex number or array of complex numbers


if nargin==1
    annot='numbering';% annot: 'nonumbering' or any other string. If any other string no numbering.
    hfig=figure;
    hold on
    zeroline='line';
else
    nannot=0;
    nzero=0;
    nfig=0;
    for iar=1:nargin-1
        if ischar(varargin{iar})
            if strcmp(varargin{iar},'numbering') || strcmp(varargin{iar},'nonumbering')
                annot=varargin{iar};
                nannot=1;
            elseif strcmp(varargin{iar},'line') || strcmp(varargin{iar},'noline')
                zeroline=varargin{iar};
                nzero=1;
            end
        elseif isa(varargin{iar},'matlab.ui.Figure')
            hfig=varargin{iar};
            figure(hfig)
            hold on
            nfig=1;
        end
    end
    
    if nannot==0
        annot='numbering';
    end
    if nzero==0
        zeroline='line';
    end
    if nfig==0
        hfig=figure;
        hold on
    end
end

    
Nz=length(Z);

if strcmp(annot,'numbering') % display numbers
    for iz=1:Nz
        plot(real(Z(iz)),imag(Z(iz)),'o','LineWidth',2);
        plot(real(Z),imag(Z),'--','LineWidth',0.5);
    end
else
    plot(real(Z),imag(Z),'LineWidth',1);
end




axis equal

xlabel('real part')
ylabel('imaginary part')

if Nz==1
    set(gca,'XLim',[min([real(Z);0])-0.2*abs(min([real(Z);0])) max([real(Z);0])+0.2*abs(max([real(Z);0]))]);
    set(gca,'YLim',[min([imag(Z);0])-0.2*abs(min([imag(Z);0])) max([imag(Z);0])+0.2*abs(max([imag(Z);0]))]);
else
    set(gca,'XLim',[min([real(Z)])-0.2*abs(min([real(Z)])) max([real(Z)])+0.2*abs(max([real(Z)]))]);
    set(gca,'YLim',[min([imag(Z)])-0.2*abs(min([imag(Z)])) max([imag(Z)])+0.2*abs(max([imag(Z)]))]);
end    

limx=get(gca,'XLim');
limy=get(gca,'YLim');
if strcmp(zeroline,'line')
    line([-max(abs([limx limy])) max(abs([limx limy]))],[0 0],'LineStyle','--')
    line([0 0],[-max(abs([limx limy])) max(abs([limx limy]))],'LineStyle','--')
end


if strcmp(annot,'numbering') % display numbers
    offsetX=(limx(2)-limx(1))/80;
    offsetY=(limy(2)-limy(1))/80;

    str=cell(Nz,1);
    for iz=1:Nz
        str{iz}= num2str(iz);
    end
    text(real(Z)+offsetX,imag(Z)+offsetY,str,'FontWeight','bold','FontSize',14)
end


if nargout % do not display ans if no output is asked by the user.
    hfigout=hfig;
end





end





