function [cnm, A, Phi] = ZernikeMoment(p,n,m,r0,x0,y0)

% -------------------------------------------------------------------------
% Copyright C 2014 Amir Tahmasbi
% Texas A&M University
% amir.tahmasbi@tamu.edu
% http://people.tamu.edu/~amir.tahmasbi/index.html
%
% License Agreement: To acknowledge the use of the code please cite the 
%                    following papers:
%
% [1] A. Tahmasbi, F. Saki, S. B. Shokouhi, 
%     Classification of Benign and Malignant Masses Based on Zernike Moments, 
%     Comput. Biol. Med., vol. 41, no. 8, pp. 726-735, 2011.
%
% [2] F. Saki, A. Tahmasbi, H. Soltanian-Zadeh, S. B. Shokouhi,
%     Fast opposite weight learning rules with application in breast cancer 
%     diagnosis, Comput. Biol. Med., vol. 43, no. 1, pp. 32-41, 2013.
%
% -------------------------------------------------------------------------
% Function to find the Zernike moments for an N x N binary ROI
%
% [Z, A, Phi] = Zernikmoment(p,n,m)
% where
%   p = input image N x N matrix (N should be an even number)
%   n = The order of Zernike moment (scalar)
%   m = The repetition number of Zernike moment (scalar)
% and
%   Z = Complex Zernike moment 
%   A = Amplitude of the moment
%   Phi = phase (angle) of the mement (in degrees)
%
% Example: 
%   1- calculate the Zernike moment (n,m) for an oval shape,
%   2- rotate the oval shape around its centeroid,
%   3- calculate the Zernike moment (n,m) again,
%   4- the amplitude of the moment (A) should be the same for both images
%   5- the phase (Phi) should be equal to the angle of rotation

% radFrac: equals 1 by default, but can equal, e.g., 0.95 is one wants the
% calculation to be performed over a circular area with a smaller radius.


N = min(size(p));

if nargin==3
    r0 = N/2-1;
    x0 = N/2;
    y0 = N/2;
elseif nargin==4
    x0 = N/2;
    y0 = N/2;
elseif nargin~=6
    error('not he proper number of inputs')
end

r0 = round(r0);

if mod(n,2)~=mod(m,2)
    error('wrong parity of m')
end


Xlist = round(x0-r0):(floor(x0+r0)+1);
Ylist = round(y0-r0):(floor(y0+r0)+1);

pCrop = p(Ylist,Xlist);


N = size(pCrop,1);

x = 1:N; y = x;
[X,Y] = meshgrid(x,y);
R = sqrt((2.*X-N-1).^2+(2.*Y-N-1).^2)/N;
Theta = atan2((N-1-2.*Y+2),(2.*X-N+1-2));
R = (R<=1).*R;
Rad = ZernikeRadialpoly(R,n,m);    % get the radial polynomial

Product = (R~=0).*pCrop(x,y).*Rad.*exp(-1i*m*Theta);
cnm = sum(Product(:));        % calculate the moments

epsm = 2-mod(m,2);
cnt = nnz(R)+1;             % count the number of pixels inside the unit circle, corresponds to the factor pi
cnm = 2*(n+1)*cnm/cnt/epsm;            % normalize the amplitude of moments
A = abs(cnm);                 % calculate the amplitude of the moment
Phi = angle(cnm)*180/pi;      % calculate the phase of the mement (in degrees)


