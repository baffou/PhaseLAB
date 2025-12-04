%% dynamicMovie.m
% Function that transforms a figure created by the dynamicFigure function into a movie.
%
%% Inputs
%
%   h           : handle of the figure previously created by the dynamicFigure function
%   videoName   : name of the video file to be created, mp4 or avi
%
% For instance:
% % Generation of the dynamic figure
% 
% h = dynamicFigure("gb",IM,"gb",{IM.DWx},"gb",{IM.DWx},...
% 
%     "titles",{"OPD","grad_x OPD","grad_y OPD"});
% 
% creates a movie from the set of images contained in IM.
% 
% By default, the frame rate is 1.5 Hz, it can be changed by modifying either the frame rate or the time between two successive images, using a Name-value pattern:
% 
% dynamicMovie(h,'movieOPD.avi', 'rate', 25)
% 
% % or
% 
% dynamicMovie(h,'movieOPD.avi', 'period', 0.02)
% dynamicMovie(h,'movieOPD.mp4', 'period', 1)
% 

function dynamicMovie(h, videoName, opt)

arguments
    h
    videoName
    opt.rate = 1.5
    opt.period = []
    opt.labels = []
end

if ~isempty(opt.period)
    opt.rate = 1/opt.period;
end

% create the video writer with 1 fps
[~, ~, ext] = fileparts(videoName);
if strcmpi(ext,'mp4') || strcmpi(ext,'.mp4')
    writerObj = VideoWriter(videoName,'MPEG-4');
else 
    writerObj = VideoWriter(videoName);
end
writerObj.FrameRate = opt.rate;
% open the video writer
open(writerObj);
% write the frames to the video
IM = h.UserData.imageList{1};
for u=1:numel(IM)
    % convert the image to a frame
    frame=getframe(h);
    drawnow
    writeVideo(writerObj, frame);
    h.UserData.changeImage(h,+1)
    if ~isempty(opt.labels)
        hsg = sgtitle(opt.labels{u});
    end
    drawnow

end

if ~isempty(opt.labels)
    delete(hsg);
end

