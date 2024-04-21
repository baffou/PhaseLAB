%% meshing of the media

function ME=mesher(ME,MS,folder)

if nargin==2
    folder=pwd;
end

% zmesh(z1 , z2 , dz [, npx])
% z1: starting z
% z2: final z
% dz: starting increment
% npx: (optional) Number of pixels. By default: h/dz+1, i.e. uniform.

if strcmp(ME(1).mesh_param,'regular')
    ME(1) = ME(1).zmesh( 0 , -ME(1).h , -MS.pxSize );
elseif strcmp(ME(1).mesh_param,'progressive')
    if isempty(ME(1).mesh_Npx)
        ME(1) = ME(1).zmesh(0,-ME(1).h,-MS.pxSize, ME(1).h/(5*MS.pxSize)+1);
    else
        ME(1) = ME(1).zmesh(0,-ME(1).h,-MS.pxSize, ME(1).mesh_Npx);
    end
end

if strcmp(ME(2).mesh_param,'regular')
    ME(2) = ME(2).zmesh(0,       ME(2).h,          MS.pxSize);% ,  ME(2).h/(5*IM(length(IM)).pxSize)+1);
elseif strcmp(ME(2).mesh_param,'progressive')
    if isempty(ME(2).mesh_Npx)
        ME(2) = ME(2).zmesh(0,       ME(2).h,          MS.pxSize,  ME(2).h/(5*MS.pxSize)+1);
    else
        ME(2) = ME(2).zmesh(0,       ME(2).h,          MS.pxSize,  ME(2).mesh_Npx);
    end
end

if length(ME)==2
    zProfile = [ME(1).mesh.z(ME(1).mesh.npx:-1:2) ME(2).mesh.z];
end

if length(ME)==3
    if strcmp(ME(3).mesh_param,'regular')
        ME(3) = ME(3).zmesh(ME(2).h, ME(2).h+ME(3).h , ME(2).mesh.z(ME(2).mesh.npx-1)-ME(2).mesh.z(ME(2).mesh.npx-2));
    elseif strcmp(ME(3).mesh_param,'progressive')
        if isempty(ME(3).mesh_Npx)
            ME(3) = ME(3).zmesh(ME(2).h, ME(2).h+ME(3).h , ME(2).mesh.z(ME(2).mesh.npx-1)-ME(2).mesh.z(ME(2).mesh.npx-2), ME(3).h/(5*MS.pxSize)+1);
        else
            ME(3) = ME(3).zmesh(ME(2).h, ME(2).h+ME(3).h , ME(2).mesh.z(ME(2).mesh.npx-1)-ME(2).mesh.z(ME(2).mesh.npx-2), ME(3).mesh_Npx);       
        end
    end
zProfile = [ME(1).mesh.z(ME(1).mesh.npx:-1:2) ME(2).mesh.z ME(3).mesh.z(2:ME(3).mesh.npx)];
end

%plot of the profile
figure('Position',[50 50 700 500]);
plot(zProfile)
set(gca,'units','points','Position',[50 50 550 350])
title('z mesh profile')
hold on
line([0,length(zProfile)],[0,0],'Color','red','LineStyle','--')
line([length(ME(1).mesh.z),length(ME(1).mesh.z)],[-ME(1).h,ME(2).h],'Color','red','LineStyle','--')
if length(ME)==3
    line([length(ME(1).mesh.z),length(ME(1).mesh.z)],[-ME(1).h,ME(2).h+ME(3).h],'Color','red','LineStyle','--')
    line([length(ME(1).mesh.z)+length(ME(2).mesh.z),length(ME(1).mesh.z)+length(ME(2).mesh.z)],[-ME(1).h,ME(2).h+ME(3).h],'Color','red','LineStyle','--')
    line([0,length(zProfile)],[ME(2).h,ME(2).h],'Color','red','LineStyle','--')
end

Ntot=0;
for im=1:length(ME)
    uicontrol('Style','Text', 'position',[100+(im-1)*153 470 120 30],'string',['N' num2str(im) '=' int2str(length(ME(im).mesh.z)) ' px'],'FontSize',18,'FontWeight','bold');
    Ntot=Ntot+length(ME(im).mesh.z);
end

uicontrol('Style','Text', 'position',[100+153 430 120 30],'string',['Ntot=' int2str(Ntot) ' px'],'FontSize',16,'FontWeight','bold');

pause(2)

savepath=[folder '/_postprocess'];
if ~exist(savepath,'dir')
        mkdir(savepath)
else
    saveas(gcf,[savepath '/figure_meshing.png'])
end