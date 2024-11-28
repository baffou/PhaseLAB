function fullwidth(hfig)
arguments
    hfig = gcf
end

Pos = get(0, 'Screensize');
hfig.Position(1) = Pos(1);
hfig.Position(3) = Pos(3);
