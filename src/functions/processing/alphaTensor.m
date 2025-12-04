function [ax, ay, theta, exL, eyL, exR, eyR] = alphaTensor(alphaR,alphaL,opt)
% computes the polarizability tensor from 4-polar measurements over two
% circular polarizations
% alphaR = 
% [ alpha_R_0 alpha_R_45 alpha_R_90 alpha_R_135
%   alpha_L_0 alpha_L_45 alpha_L_90 alpha_L_135 ]
%
% or
%
% alphaR = 
% [ alpha_R_0 alpha_R_45 alpha_R_90 alpha_R_135
% alphaL = 
%   alpha_L_0 alpha_L_45 alpha_L_90 alpha_L_135 ]
%
% or
%
% [ alpha_R_0 alpha_R_90
%   alpha_L_0 alpha_L_90 ]
%
% or
%
% alphaR = 
% [ alpha_R_0 alpha_R_90
% alphaL = 
%   alpha_L_0 alpha_L_90 ]


arguments
    alphaR (:,:) double
    alphaL (:,:) double = []
    opt.ordering = false
end

if isempty(alphaL)
    if size(alphaR,1)~=2
        error('The size of the input should be (2,4), the two rows corresponding to the two polarizations')
    end
    alphaL = alphaR(2,:);
    alphaR = alphaR(1,:);
end

if size(alphaL,2) == 4
    alphaL = alphaL([1, 3]);
    alphaR = alphaR([1, 3]);
elseif size(alphaL,2) ~= 2
    error('the alpha values must have 2 or 4 components')
end

SR = alphaR(1)+alphaR(2);
DR = alphaR(1)-alphaR(2);
DL = alphaL(1)-alphaL(2);
SL = alphaL(1)+alphaL(2);

% SL-DR = -1i*2*sin(2*theta)*(sx - sy)
% SL+DR =     2*cos(2*theta)*(sx - sy)

%thetaNP = 0.25*angle( DR./SL);

theta = 0.5*atan(imag((DR-DL)./(DL+DR)));

ax  = 0.5*(SL + DL*exp(2*1i*theta));
ay  = 0.5*(SL - DL*exp(2*1i*theta));

if opt.ordering
    %abs(ax)>abs(ay)
end