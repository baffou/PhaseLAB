function [string, ext] = removeExtension(string0)
arguments
    string0 {mustBeText(string0)}
end

pos=find(char(string0)=='.');

if isempty(pos)
    string = string0;
else
    if ischar(string0)
        string = string0(1:pos(end)-1);
        ext = string0(pos(end)+1:end);
    else
        string0 = char(string0);
        string = convertCharsToStrings(string0(1:pos(end)-1));
        ext = convertCharsToStrings(string0(pos(end)+1:end));
    end
    
end