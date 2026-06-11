classdef Methods
    % general methods that apply to general objects
    methods(Static)
        function obj2 = duplicate(obj)
            % create a new object from an existing object, but makes sure
            % all the copied object properties are duplicated as well, and
            % not handled.
            if ~ isempty(obj) && isa(obj,'matlab.mixin.Copyable') % isempty can happen with the Einc property of the reference Interfero. Avoids recurcivity
                obj2 = copy(obj);
                for io = 1:numel(obj)
                    % propList = fieldnamesNonDependent(obj(io));
                    propList = getNonDependentClassProperties(class(obj(io)));
                    Np = numel(propList);
                    for ip = 1 : Np
                        %disp(propList{ip})
                        prop = obj2(io).(propList{ip});
                        if isobject(prop)
                            %if isempty(prop)
                            %propList{ip}
                            try
                                obj2(io).(propList{ip}) = Methods.duplicate(obj(io).(propList{ip}));
                            catch
                                obj2(io).(propList{ip}) = obj(io).(propList{ip});
                            end
                                %end
                        end
                    end
                end
            
            else
                obj2 = obj;
            end

        end

        function obj2obj(obj_out,obj_in)
            % makes obj_out = obj_in, but without overwriting the object obj_out (and then giving it a new handle), which
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


    end
end