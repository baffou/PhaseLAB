function val = lambda2m(val)
% function that converts wavelengths from nanometers to meters
arguments
    val
end
if val>1
    val = val*1e-9;
end
