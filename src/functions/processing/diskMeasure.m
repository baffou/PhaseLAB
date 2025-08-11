function [meanVal,values] = diskMeasure(img, Npx, opt)
    % averageDisk computes the mean value of an image inside a disk centered at a user-clicked point.
    %
    % Syntax:
    %   meanVal = averageDisk(img, radius)
    %
    % Inputs:
    %   - img : 2D image (matrix)
    %   - Npx : radius of the disk (in pixels)
    %   - coords : coordinates [x, y] (in pixels)
    %
    % Output:
    %   - meanVal : average value within the disk

    arguments
        img (:,:) double
        Npx (1,1) double = 10
        opt.display logical = true
        opt.coords = []
    end

    if isempty(opt.coords)
        % Display the image
        hfig = figure;
        imagegb(img);
    
        % Get the point clicked by the user
        [x, y] = ginput(1);
    else
        x = opt.coords(1);
        y = opt.coords(2);
    end

    x = round(x);
    y = round(y);

    % Create the disk mask
    [X, Y] = meshgrid(1:size(img,2), 1:size(img,1));
    mask = (X - x).^2 + (Y - y).^2 <= Npx^2;

    % Compute the mean within the disk
    values = img(mask);
    meanVal = mean(values(:));

    % Optional: show the disk
    if opt.display
        hold on;
        viscircles([x y], Npx, 'Color', 'r');
        plot(x, y, 'r+', 'MarkerSize', 10, 'LineWidth', 1.5);
        hold off;
    else
        if exist('hfig','var')
            close(hfig)
        end
    end

end
