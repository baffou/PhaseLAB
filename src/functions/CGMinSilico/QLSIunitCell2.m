function M=QLSIunitCell2(nCell,phase,period)
% generate the typical unit cell of the QLSI grating (0-pi checkerboard)
% without dark lines and with 4 phase values

%%%%%%%%%%%%%%%%%
%       %       %
% 3pi/2 %   pi  %
%       %       %
%%%%%%%%%%%%%%%%%
%       %       %
%   0   %  pi/2 %
%       %       %
%%%%%%%%%%%%%%%%%

U=zeros(6*nCell,6*nCell);
U(1:3*nCell        ,1:3*nCell        ) = 0;
U(1+3*nCell:6*nCell,1:3*nCell        ) = exp(1i*phase/2);
U(1+3*nCell:6*nCell,1+3*nCell:6*nCell) = exp(1i*phase);
U(1:3*nCell        ,1+3*nCell:6*nCell) = exp(1i*3*phase/2);

M=CGmatrix(U,period);

end

