function dynamicMovie(h, videoName, opt)
arguments
    h
    videoName
    opt.rate = 1.5
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