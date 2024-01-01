function daystring = todayFolder()
if exist('today')==2
    ymd = datevec(today);
else
    ymd = datevec('01/01/2020');
end

ystr = num2str(ymd(1));

if ymd(2)<10
    mstr = ['0' num2str(ymd(2))];
else
    mstr = num2str(ymd(2));
end


if ymd(3)<10
    dstr = ['0' num2str(ymd(3))];
else
    dstr = num2str(ymd(3));
end

daystring = [ystr(3:4) mstr dstr];

















