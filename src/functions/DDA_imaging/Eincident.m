function EE0 = Eincident(IL,pos,opt)
arguments
    IL Illumination
    pos (:,3)
    opt.reshape logical = true
end

lambda = IL.lambda;
n = IL.n;
nS = IL.nS;
E0 = IL.E0;
direct = IL.direct;
kk = direct*2*pi/lambda;

%% incoming electric field
r12 = (n-nS)/(n+nS);
N = size(pos,1);

EE0 = zeros(3*N,1);
for ii = 1:N
    %EE0(3*ii-2:3*ii) = E0*exp(1i*n*kk*pos(ii,:)');
    EE0(3*ii-2:3*ii) = E0*exp(1i*n*kk*pos(ii,:)') + r12*E0*exp(-1i*n*kk*pos(ii,:)');
end

if opt.reshape
    EE0 = reshape(EE0,[3,N]);
end