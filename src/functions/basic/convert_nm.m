function val = convert_nm(val0)
% function that converts nm into m
if val0>1e-3 % value indicated in nm
    val = val0*1e-9;
    %warning('You supposedely indicated a value in nm. Converted in m.')
else  % value indicated in m
    val = val0;
end
