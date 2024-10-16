%% display of all the colormaps of PhaseLAB


fileName = which('displayColorMaps');
A = strfind(fileName,"/");
fprintf('%s\n',fileName(1:A(end)-1));

filePath = fileName(1:A(end)-1);

B = dir(filePath);

fileNames = {B.name};

Nf = numel(fileNames);

% selection of the proper files
nFiles = logical.empty(Nf, 0);
for ii = 1:Nf
    if isletter(fileNames{ii}(1)) % remove the . and .. files
        if strcmp(fileNames{ii}(end-1:end),'.m') % remove the .asv and .colormap files
            if ~strcmp(fileNames{ii},'displayColorMaps.m') % remove this file
                nFiles(ii) = true;
                disp(fileNames{ii})
            end
        end
    end
end

fileNames2 = fileNames(nFiles);
Nf2 = numel(fileNames2);

X = meshgrid(1:120,1:10);
figure
set(gcf,"MenuBar","none")
set(gcf,"ToolBar","none")
set(gcf,"Name","Specific PhaseLAB color maps")
set(gcf,"NumberTitle","off")
for ii = 1:Nf2
    func = str2func(fileNames2{ii}(1:end-2))
    ax = subplot(Nf2,1,ii);
    imagesc(X)
    set(ax, 'DataAspectRatio',[1 1 1])
    set(ax.XAxis, 'Visible','off')
    set(ax.YAxis, 'Visible','off')
    title(fileNames2{ii}(1:end-2))
    colormap(gca,func())

end
    







