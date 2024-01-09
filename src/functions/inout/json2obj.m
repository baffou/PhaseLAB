function obj = json2obj(jsonFile)
    % read a json file and and create an object from it, from a specific class

    fileName = jsonFile; % filename in JSON extension
    fid = fopen(fileName); % Opening the file
    raw = fread(fid,inf); % Reading the contents
    str = char(raw'); % Transformation
    fclose(fid); % Closing the file
    data = jsondecode(str); %

    func = str2func(data.class); % necessarily 'RelayLens' in this context
    obj = func();

    objProps = properties(obj);
    Np = numel(objProps);

    for ip = 1:Np
        try
            obj.(objProps{ip}) = data.(objProps{ip}); % fails in the case of B&W cameras for the crosstalks properties
        end
    end
end  
