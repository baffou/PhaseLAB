function c = myColors(ch)
arguments
    ch {mustBeMember(ch,{'r','g','b','o','y','v','p'})}
end
    switch ch
        case 'r' % red
            c = [0.8 0.2  0.12];
        case 'g'   % green
            c = [0.6 0.9 0.12];
        case 'b'   % blue
            c = [0 0.45 0.70];
        case 'y'   % yellow
            c = [0.9 0.7 0.12];
        case {'v','p'}   % violet / purple
            c = [ 0.7 0.12 0.9];
        case 'o'   % orange
            c = [0.9 0.6  0.12];
        otherwise
            error('Unknown color code.')
    end
end
