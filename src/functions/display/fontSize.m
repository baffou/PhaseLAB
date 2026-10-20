function fontSize(hndl,val)

% fontSize(hfig, 16)
if nargin == 1 % fontSize(16)
    val = hndl;
    hndl = gcf;
end
if isa(hndl,'matlab.ui.Figure')
    set(findall(hndl, 'Type', 'axes'), 'FontSize', val);
elseif isa(hndl,'matlab.graphics.axis.Axes')
    set(hndl, 'FontSize', 16)
else
    error('not a proper input type')
end
