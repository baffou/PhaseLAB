function val = convert_um(val0)
if val0>1 % value indicated in µm
    val = val0*1e-6;
    warning('You supposedely indicated a value in µm. Converted in m.')
else  % value indicated in m
    val = val0;
end
