clear all
close all
clc


% Initialize a 5D array: [11 samples, 150, 150, 2, 2]
J_all = zeros(11, 150, 150, 2, 2);
%%
for sample = 1:11
    J1xx = readmatrix(sprintf("dataForJulien/J%dxx.txt", sample));
    J1xy = readmatrix(sprintf("dataForJulien/J%dxy.txt", sample));
    J1yx = readmatrix(sprintf("dataForJulien/J%dyx.txt", sample));
    J1yy = readmatrix(sprintf("dataForJulien/J%dyy.txt", sample));

    J_all(sample, :, :, 1, 1) = J1xx;
    J_all(sample, :, :, 1, 2) = J1xy;
    J_all(sample, :, :, 2, 1) = J1yx;
    J_all(sample, :, :, 2, 2) = J1yy;
end


% process data
to = zeros(11, 150, 150);
te = zeros(11, 150, 150);
for s=1:11
    for i=1:150
        for j=1:150
            tic
            Jj = squeeze(J_all(s, i, j, :, :));
    toc
            [Z, T] = schur(Jj);
            T(1, 2) = 0; % set off-diagonal to zero to enforce homogeneity
            J_homo = Z * T * Z';
    
            % project to linear only
            J_lin = 0.5*(J_homo + conj(J_homo)'); % symmetry enforces linearity (component on sigma_3 vanishes)
            [eigenvect, t_vals] = eig(J_lin);
            
            to_te = diag(t_vals);
            % Sort eigenvalues by absolute value
            [abs_to_te, idx] = sort(abs(to_te), 'descend');
            to_val = to_te(idx(1)); % Largest absolute value
            te_val = to_te(idx(2)); % Smaller absolute value
            
            % Assign to to(s, i, j) and te(s, i, j)
            to(s, i, j) = to_val;
            te(s, i, j) = te_val;

        end
    end
end


% Create a VideoWriter object
videoFile = 'output_movie.mp4'; % Output file name
v = VideoWriter(videoFile, 'MPEG-4');
v.FrameRate = 2; % Adjust frame rate as needed (e.g., 2 frames per second)
open(v);

% Create a figure outside the loop to avoid opening/closing figures
figure;

for s = 1:11
    % Plot abs(to)
    subplot(1, 2, 1);
    imagesc(abs(squeeze(to(s,:,:))));
    caxis([0.5 1.1]);
    colorbar;
    title(sprintf('abs(to), Sample %d', s));
    axis image
    % Plot abs(te)
    subplot(1, 2, 2);
    imagesc(abs(squeeze(te(s,:,:))));
    caxis([0.5 1.1]);
    colorbar;
    title(sprintf('abs(te), Sample %d', s));
    axis image
    % Capture the current figure as a frame
    frame = getframe(gcf);
    writeVideo(v, frame);

    % Optional: Pause briefly to visualize the loop (not needed for movie)
    pause(0.1);
end

% Close the video file
close(v);
fprintf('Movie saved as %s\n', videoFile);