function fullscreen(hfig)
arguments
    hfig = gcf
end
    
set(hfig, 'Position', get(0, 'Screensize'));
drawnow