function h5entry(h5fileName,entryName,data)

if ~isreal(data)
    if numel(data) == 1
        data0 = [real(data), imag(data)];
        data = data0;
    end
end

h5create(h5fileName,entryName,size(data))
h5write (h5fileName,entryName,data)

end