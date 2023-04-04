function obj2 = duplicate(obj)
% duplicates and object while duplicating all its noncopyable
% handle properties as well, which the copy method does not do.
if ~ isempty(obj) % can happen with the Einc property of the reference Interfero
    obj2 = copy(obj);
    propList = fieldnamesNonDependent(obj);
    Np = numel(propList);
    for ip = 1 : Np
        %disp(propList{ip})
        prop = obj2.(propList{ip});
        if isobject(prop)
            if isempty(prop)
                %propList{ip}
                obj2.(propList{ip}) = duplicate(obj.(propList{ip}));
            end
    
        end
    end
else
    obj2 = obj;
end

