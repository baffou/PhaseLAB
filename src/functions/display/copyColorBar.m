function copyColorBar(cbin, cbout)


props = {
    'Limits'
    'Ticks'
    'TickLabels'
    'Label'
    'Colormap'
    'Direction'
    'Location'
    'FontSize'
    'FontName'
    'FontWeight'
    'Color'
    'LineWidth'
    };

for k = 1:numel(props)
    try
        cbout.(props{k}) = cbin.(props{k});
    end
end