function [meanVal, ROIs] = ROImeans(hax,Nroi,opt)
% returns the mean values of Nroi drawn ROIs.
arguments
    hax = gca % image or Axes
    Nroi = 1  % number of regions to draw
    opt.ROIs (:,1) cell = cell.empty() % ROIs as cells containing masks
end

if isempty(opt.ROIs)
    
    if isnumeric(hax)
    % Display image
        img = hax;
        fig = figure;
        imagesc(img);
        axis image;
        colormap gray;
        colorbar;
        drawnow
        hax = gca;
    elseif isa(hax,'matlab.graphics.axis.Axes')
        img = findobj(hax, 'Type', 'image');
    else
        error("First input must be an image or an Axes handle.")
    end
    
    % Draw the ROIs
    polygons = repmat(images.roi.Polygon.empty,Nroi,1);
    for ii = 1:Nroi
        title("Draw ROI "+ii);
        polygons(ii) = drawpolygon(hax);
    end
    
    title('Modify the ROIs if needed, then close the figure');
    
    % Prevent immediate figure deletion when closing
    % uiwait is released instead
    fig.CloseRequestFcn = @(src,evt) uiresume(src);
    
    % Wait until the user closes the figure
    uiwait(fig);
    
    % Create masks from the final ROI positions
    ROIs = cell(Nroi,1);
    for ii = 1:Nroi
        ROIs{ii} = createMask(polygons(ii));
    end
    delete(fig);

else % opt.ROIs is not empty

    if isnumeric(hax)
        img = hax;
    elseif isa(hax,'matlab.graphics.axis.Axes')
        img = findobj(hax, 'Type', 'image');
    else
        error("First input must be an image or an Axes handle.")
    end

    
    
    
    
    if Nroi ~= numel(opt.ROIs)
        error("n input must equal the number of ROIs")
    end
    ROIs = opt.ROIs;
end

meanVal = zeros(Nroi,1);
for ii = 1:Nroi
    meanVal(ii) = mean(img(ROIs{ii}), 'omitnan');
end
