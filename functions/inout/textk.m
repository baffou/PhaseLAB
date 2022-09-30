function numk = textk(k)
    if k<10
        numk = ['0' int2str(k)];
    else
        numk = [int2str(k)];
    end
end
