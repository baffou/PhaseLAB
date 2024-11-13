function obj2obj(obj_out,obj_in)
% makes obj_out = obj_in, but without giving a new handle to object obj_out, which
% already exists.

propList = getNonDependentClassProperties(class(obj_out));
if numel(obj_out) ~= numel(obj_in)
    error('The input and output image lists must have the same number of elements')
end
for io = 1:numel(obj_in)
    for propName = string(propList')
        obj_out(io).(propName) = obj_in(io).(propName);
    end
end
end

