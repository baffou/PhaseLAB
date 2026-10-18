function T = J_to_T(J)
% Spectral decomposition

Nth = numel(J);

T.te = cell(Nth,1);
T.to = cell(Nth,1);
T.phi = cell(Nth,1);
T.phid = cell(Nth,1);
T.phib = cell(Nth,1);

% vectorized algorithm of the retrieval of biref and diatt properties, from J

for ith = 1:Nth
    [bir, diatt] = jones_decomposition_vectorized0(J(ith).mat, 'HU');
    T.phid{ith} = angle(diatt.pd(:,:,1)+1i*diatt.pd(:,:,2))/2;
    T.phib{ith} = angle(bir.pb(:,:,1)+1i*bir.pb(:,:,2))/2;
    T.phi{ith} = angle(exp(1i*T.phib{ith}*4)+exp(1i*T.phid{ith}*4))/4;

    % sign correction in case where pd = -pd
    sgn = sign(dot(squeeze(bir.pb),squeeze(diatt.pd),3));
    
    % by convention, to and te are such that abs(to) > abs(te)
    T.to{ith} = diatt.h0.*exp(1i*bir.phi0).*(1+diatt.D).*exp(1i*sgn.*(bir.beta/2)); 
    T.te{ith} = diatt.h0.*exp(1i*bir.phi0).*(1-diatt.D).*exp(1i*sgn.*(-bir.beta/2));

end

if isscalar(T.te{1}) % scalar and not images
    T.te = cell2mat(T.te);
    T.to = cell2mat(T.to);
    T.phib = unwrap2(cell2mat(T.phib)*4)/4;
    T.phid = unwrap2(cell2mat(T.phid)*4)/4;
    T.phi = unwrap2(cell2mat(T.phi)*4)/4;
end


