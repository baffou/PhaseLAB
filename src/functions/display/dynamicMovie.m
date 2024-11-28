%% dynamicMovie.m
% Function that transforms a figure created by the dynamicFigure function into a movie.
%
%% Inputs
%
%   h           : handle of the figure previously created by the dynamicFigure function
%   videoName   : name of the video file to be created
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
% 

function dynamicMovie(h, videoName, opt)

arguments
    h
    videoName
    opt.rate = 1.5
    opt.period = []
end

if ~isempty(opt.period)
    opt.rate = 1/opt.period;
end

% create the video writer with 1 fps
writerObj = VideoWriter(videoName);
writerObj.FrameRate = opt.rate;
% open the video writer
open(writerObj);
% write the frames to the video
IM = h.UserData.imageList{1};
for u=1:numel(IM)
    % convert the image to a frame

    h.UserData.imageList

    frame=getframe(h);
    drawnow
    writeVideo(writerObj, frame);
    h.UserData.changeImage(h,+1)
    drawnow

end