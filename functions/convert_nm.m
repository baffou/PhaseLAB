function val=convert_nm(val0)
if val0>1 % value indicated in nm
    val=val0*1e-9;
    warning('You supposedely indicated a value in nm. Converted in m.')
else  % value indicated in m
    val=val0;
end
