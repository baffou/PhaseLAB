function hfig0 = displayJonesMatrix(J,opt)
% J : 2*2 or 2*2*Ny*Nx matrix or JonesMatrix object
arguments
    J % double or cell array or JonesMatrix
    opt.func {mustBeMember(opt.func,{'abs','real','imag','angle'})} = 'abs' % Functions to be applied to the Jij
    opt.clim = []
end

if isnumeric(J)
    J = JonesMatrix(J);
elseif iscell(J)
    J0 = JonesMatrix(No);
    for io = 1:No
        J0(io) = JonesMatrix(J{io});
    end
    J = J0;
    clear J0
elseif ~isa(J,'JonesMatrix')
    error('Wrong input type. Should be cell, numeric or JonesMatrix.')
end

switch opt.func
    case 'abs'
        titleList = {"|Jxx|","|Jxy|","|Jyx|","|Jyy|"};
    case 'real'
        titleList = {"Re(Jxx)","Re(Jxy)","Re(Jyx)","Re(Jyy)"};
    case 'imag'
        titleList = {"Im(Jxx)","Im(Jxy)","Im(Jyx)","Im(Jyy)"};
    case 'angle'
        titleList = {"Arg(Jxx)","Arg(Jxy)","Arg(Jyx)","Arg(Jyy)"};
end

if iscell(opt.clim)
    if numel(opt.clim) == 2
        opt.clim = [opt.clim(1) opt.clim(2) opt.clim(2) opt.clim(1)];
    end
end

hfig = dynamicFigure("gb",{J.xx},"gb",{J.xy},"gb",{J.yx},"gb",{J.yy}, ...
                     'nm',[2 2], ...
                     'range', opt.clim, ...
                     'titles',titleList, ...
                     'func',opt.func);

if nargout
    hfig0 = hfig;
end