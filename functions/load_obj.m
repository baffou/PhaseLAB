function obj=load_obj(fileName)
    matObj  = matfile(fileName);
    details = whos(matObj);
    [~, index] = max([details.bytes]);
    maxName = details(index).name;
    obj=matObj.(maxName);
end
