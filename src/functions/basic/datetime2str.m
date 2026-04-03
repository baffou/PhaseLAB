function str = datetime2str(dt)
try
str = char(dt,'yyMMdd_HH'':''mm'':''ss''.''SSS');
catch
    pause(1)
end