function knockoutseghist2gmt(fn, filename)
% KNOCKOUTSEGHIST2GMT(FN, FILENAME) plots a GMT histogram of a fault segment's 
% knockout slip rate distribution.  FN is the figure number in which the plot
% appears and FILENAME is the full path to where the file should be created.
% The script "knockoutseghist.bash" should appear within the target directory.
%

[p, f, e] = fileparts(filename);

figure(fn)
c = get(gca, 'children');
histx = get(c, 'xdata');
histy = get(c, 'ydata');
histog = zeros(9, size(histx, 2));
histog(1, :) = [get(c, 'facevertexcdata')]';
histog(2:2:end, :) = histx;
histog(3:2:end, :) = histy;

fid = fopen('hist', 'w');
fprintf(fid, '> -Z%d\n%d %d\n%d %d\n%d %d\n%d %d\n', histog);
fclose(fid);

ca = caxis;
system(sprintf('makecpt -Cseis -I -Z -T0/%d/1 > hist.cpt', ca(end)));

xl = get(gca, 'xlim');
yl = get(gca, 'ylim');
xd = get(gca, 'xtick'); xd = xd(2) - xd(1);
yd = get(gca, 'ytick'); yd = yd(2) - yd(1);

system(sprintf('bash %s%sknockoutseghist.bash %s %d %d %d %d %d %d', p, filesep, filename, xl(1), xl(2), yl(1), yl(2), xd, yd));