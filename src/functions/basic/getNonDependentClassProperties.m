function props = getNonDependentClassProperties(className)
% returns the list of non-dependent properties of a class.

if ~istext(className) % if an object is directly specified
    className = class(className); % get its class
end

mc = meta.class.fromName(className); % get the metadata of the class

props = {};
for i = 1:length(mc.PropertyList)
    prop = mc.PropertyList(i);
    if ~prop.Dependent && ~prop.Constant
        props{end+1} = prop.Name;
    end
end
props = props';