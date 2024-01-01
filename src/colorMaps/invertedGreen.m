function map = invertedGreen(n,opt)
arguments
    n double {mustBeInteger,mustBePositive} = 1024
    opt.limV double {mustBeInRange(opt.limV,0,1)} = 0.45;
end
    limV = round(opt.limV*n);
    
    map = (zeros(n,3));
    
    map(1:limV, 1) = linspace(n,0,limV)';
    map(1:limV, 2) = linspace(n,limV,limV)';
    map(limV+1:end, 2) = linspace(limV,0,n-limV)';
    map(1:limV, 3) = linspace(n,0,limV)';
    map = map/n;
end