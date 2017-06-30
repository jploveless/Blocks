function mcpotencyhist2gmt(fn, stats, filename)
% MCPOTENCYHIST2GMT(FN, STATS, FILENAME) plots a GMT histogram of the Monte 
% Carlo potency rate simulation.  FN is the figure number, STATS is a 3-element
% vector containing [MU, SIG, ACTUAL] as output from MCPOTENCYHIST, and FILENAME
% is the root filename of the .ps file to be produced.  Provide the full path, 
% and make sure that the GMT script "mcpotencyhist.bash" is within the desired
% output directory.
%

[p, f, e] = fileparts(filename);

figure(fn)
c = get(gca, 'children');
actual = [get(c(1), 'xdata')' get(c(1), 'ydata')'];
fithis = [get(c(2), 'xdata')' get(c(2), 'ydata')'];
histx = get(c(3), 'xdata');
histy = get(c(3), 'ydata');
histog = zeros(2*length(histx) + 2, 2);
histog(1:2:end, 1) = [histx(:); histx(end) + (histx(2)-histx(1))];
histog(2:2:end, 1) = [histx(:); histx(end) + (histx(2)-histx(1))];
histog(1:2:end, 2) = [0; histy(:)];
histog(2:2:end, 2) = [histy(:); 0];

save('actual', 'actual', '-ascii');
save('hist', 'histog', '-ascii');
save('fit', 'fithis', '-ascii');

xl = get(gca, 'xlim');
yl = get(gca, 'ylim');
xd = get(gca, 'xtick');
xd = xd(2) - xd(1);

fid = fopen('labels', 'w');
fprintf(fid, '> %d %d 10 0 0 RB 10p 0.8i r\n@~m@~ = %.1e\n@~s@~ = %.1e\nA = %.1e\n', xl(1), yl(1), stats(1), stats(2), stats(3));
fclose(fid);

system(sprintf('bash %s%smcpotencyhist.bash %s %d %d %d %d %d', p, filesep, filename, xl(1), xl(2), yl(1), yl(2), xd));