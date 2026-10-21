function val = lambda2nm(val)
% function that converts wavelengths from meters to nanometers
arguments
    val
end
if val<1
    val = val*1e9;
end
