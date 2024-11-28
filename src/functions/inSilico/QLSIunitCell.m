function M=QLSIunitCell(nCell,phase,period)
% generate the typical unit cell of the QLSI grating (0-pi checkerboard)
U=zeros(6*nCell,6*nCell);
U(nCell+1:3*nCell,nCell+1:3*nCell)=1;
U(1+4*nCell:6*nCell,1+4*nCell:6*nCell)=1;
U(1+4*nCell:6*nCell,nCell+1:3*nCell)=exp(1i*phase);
U(nCell+1:3*nCell,1+4*nCell:6*nCell)=exp(1i*phase);

M=CGmatrix(U,period);

end

