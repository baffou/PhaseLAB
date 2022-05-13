function fileName = generateDatedFileName(prefix,extension)

if nargin==0
    extension = [];
    prefix = [];
elseif nargin==1
    prefix = [prefix '_'];
    extension = '.txt';
elseif ~strcmp(extension(1),'.')
    extension = ['.' extension];
end

time   = clock;
year   = num2str(time(1));
month  = num2str(time(2));
day    = num2str(time(3));
hour   = num2str(time(4));
minute = num2str(time(5));
second = num2str(time(6));
second = second(1:find(second=='.')-1);

if length(month) ==1,month=['0' month]; end
if length(day)   ==1,day=['0' month];   end
if length(hour)  ==1,hour=['0' hour];  end
if length(minute)==1,minute=['0' minute];end
if length(second)==1,second=['0' second];end

%fileName=[prefix '_' year(3:4) month day '_' hour 'h' minute extension];
fileName = [prefix year(3:4) month day '_' hour 'h' minute 'min' second 's' extension];

end
