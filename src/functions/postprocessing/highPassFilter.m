function im2 = highPassFilter(im,n)
% filters an image by removing a Gaussian blurr
arguments
    im (:,:) double
    n double = 10
end

im2 = im-imgaussfilt(im,n);