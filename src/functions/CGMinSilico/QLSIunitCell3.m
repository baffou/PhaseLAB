function M=QLSIunitCell3(nCell,period)
%% generate the ideal sine intensity profile grating

U = zeros(6*nCell,6*nCell);
[X, Y] = meshgrid(1:6*nCell,1:6*nCell);
U = sin(2*pi*X/(6*nCell)).^2.*sin(2*pi*Y/(6*nCell)).^2;

M = CGmatrix(U,period);

end

