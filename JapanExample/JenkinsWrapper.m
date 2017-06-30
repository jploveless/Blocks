try
   cd('/Users/Shared/Jenkins/Blocks/JapanExample');
   Blocks('japan_new481_shannon.command');
catch e
   disp(getReport(e,'extended'));
   exit(1);
end
exit;
