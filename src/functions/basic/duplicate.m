function obj2 = duplicate(obj)
% duplicates and object while duplicating all its noncopyable
% handle properties as well, which the copy method does not do.

if ~ isempty(obj) % isempty can happen with the Einc property of the reference Interfero. Avoids recurcivity

    obj2 = copy(obj);

    for io = 1:numel(obj)
        propList = fieldnamesNonDependent(obj(io));
        Np = numel(propList);
        for ip = 1 : Np
            %disp(propList{ip})
            prop = obj2(io).(propList{ip});
            if isobject(prop)
                %if isempty(prop)
                %propList{ip}
                obj2(io).(propList{ip}) = duplicate(obj(io).(propList{ip}));
                %end

            end
        end
    end

else
    obj2 = obj;
end

end