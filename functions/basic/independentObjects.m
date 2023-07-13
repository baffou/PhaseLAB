function [objList2, nList] = independentObjects(objList)
% gathering all the different objects from a list [obj1, obj1, obj2, obj3,
% obj2] into [obj1, obj2, obj3]

No = numel(objList);
objList2 = objList(1);

n=1;
nList = zeros(No,1);
for io = 2:No
    if ~any(objList(io) == objList2) % the new Ref is not alreay in the list
        n = n+1;
        nList(io) = 1;
        objList2(n) = objList(io);
    end
end

objList2=objList2(1:n);
