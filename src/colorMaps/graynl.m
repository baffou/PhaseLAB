function cmap = graynl(n, gamma)
%GRAYNL Colormap grayscale non linéaire
%   cmap = graynl(n, gamma)
%
%   n     : nombre de niveaux (default 256)
%   gamma : facteur non linéaire (<1 = éclaircit les sombres)
    arguments
        n = 1024
        gamma = 0.5;
    end

    % échelle linéaire
    x = linspace(0,1,n)';

    % transformation gamma
    x = x.^gamma;

    % colormap RGB
    cmap = [x x x];
end