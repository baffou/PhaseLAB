function nonDepPropList = fieldnamesNonDependent(obj)
% functiont that returns only the non-dependent properties
% Suggested by Chat GPT
propList = properties(obj);
metaObj = metaclass(obj);
isDepProp = ismember(propList, {metaObj.PropertyList([metaObj.PropertyList.Dependent]).Name});
nonDepPropList = propList(~isDepProp);