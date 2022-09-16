function obj2 = flatten(obj,method,nmax)
% methods:
%   'Zernike'
%   or
%   'Waves', 'Wave', 'Sine', 'sine'

if nargout
    obj2=copy(obj);
else
    obj2=obj;
end

if nargin==1 % if obj = flatten(3), then consider flatten('Zernike',3)
    nmax=method;
    method='Waves';
end



if nargin==1
    nmax = 1;
end
if ~(round(nmax)==nmax)
    error('The input must be an integer (array).')
end
if length(nmax)>=2
    error('The order must be a scalar.')
end



if strcmp(method,'Zernike')
    % Removes Zernike moments up to n = nmax

    No = numel(obj);
    for io = 1:No
        temp=obj(io).OPD;
        for n = 1:nmax
            for m = mod(n,2):2:n
                temp = ZernikeRemoval(temp,n,m); % use a temp image to avoid writing several times on the HDD in remote mode.
            end
        end
        obj2(io).OPD=temp;
    end
elseif strcmpi(method,'Waves') || strcmpi(method,'Wave') || strcmpi(method,'Sines') || strcmpi(method,'Sine')
    No = numel(obj);
    for io = 1:No
        temp=obj(io).OPD;
        for n = 1:nmax
            temp = SineRemoval(temp,n); % use a temp image to avoid writing several times on the HDD in remote mode.
        end
        obj2(io).OPD=temp;
    end
end
