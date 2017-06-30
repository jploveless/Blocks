fileStream = fopen('c:\data1\Socal\SocalDisplacement2\Common\history.faults', 'r');
data            = fgetl(fileStream);
xCoord          = [];
yCoord          = [];
while (isstr(data));
   %%  Try a conversion to numeric
   vals         = str2num(data);
   
   if (isempty(vals))
      plot(zero22pi(xCoord), yCoord, '-k', 'LineWidth', 0.5, 'Color', 0.6 * [1 1 1], 'Tag', 'lineAll');
      xCoord    = [];
      yCoord    = [];
   else
      xCoord    = [xCoord ; vals(1)];
      yCoord    = [yCoord ; vals(2)];
   end
   
   %%  Get the next line
   data = fgetl(fileStream);
end
fclose(fileStream);