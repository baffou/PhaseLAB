function fontSize(hndl,val)
if isa(hndl,'matlab.ui.Figure')
    set(findall(hndl, 'Type', 'axes'), 'FontSize', val);
elseif isa(hndl,'matlab.graphics.axis.Axes')
    set(hndl, 'FontSize', 16)
else
    error('not a proper input type')
end
