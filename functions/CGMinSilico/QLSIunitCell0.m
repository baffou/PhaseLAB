function M=QLSIunitCell0(nCell,phase,period)
% generate the typical unit cell of the QLSI grating (0-pi checkerboard)
% without dark lines
U=zeros(6*nCell,6*nCell);
U(1:3*nCell,1:3*nCell)=1;
U(1+3*nCell:6*nCell,1+3*nCell:6*nCell)=1;
U(1+3*nCell:6*nCell,1:3*nCell)=exp(1i*phase);
U(1:3*nCell,1+3*nCell:6*nCell)=exp(1i*phase);

M=CGmatrix(U,period);

end

