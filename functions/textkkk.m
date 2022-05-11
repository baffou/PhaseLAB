function numk=textkkk(k)
    if k<10
        numk=['000' int2str(k)];
    elseif k<100
        numk=['00' int2str(k)];
    elseif k<1000
        numk=['0' int2str(k)];
    else
        numk=int2str(k);
    end
end
