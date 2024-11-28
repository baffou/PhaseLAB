function bool = istext(val)

if ischar(val) || isstring(val)
    bool = true;
else
    bool = false;
end