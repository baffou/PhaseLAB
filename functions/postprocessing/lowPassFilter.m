function im2 = lowPassFilter(im,n)
% filters an image by removing a Gaussian blurr
arguments
    im (:,:) double
    n double = 10
end

im2 = imgaussfilt(im,n);