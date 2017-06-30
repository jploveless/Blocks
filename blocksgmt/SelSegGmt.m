function a = SelSegGmt(outfile)
%
% SELSEGGMT outputs the coordinates of currently selected segments
% to a GMT readable file.
%
%    SELSEGGMT(FILE) writes the coordinates to FILE for plotting using
%    PSXY -M.
%
%    SEL = SELSEGGMT(...) returns the indices of the selected segments 
%    to SEL.
%

a = intersect(findobj(gcf, '-regexp', 'tag', '^Segment'), findobj(gcf, 'color', 'r'));
x = get(a, 'xdata');
y = get(a, 'ydata');
if iscell(x)
   x = cell2mat(x);
   y = cell2mat(y);
end   

if exist('outfile', 'var')
   fid = fopen(outfile, 'w');
   fprintf(fid, '%g %g %g %g\n>\n', [x(:, 1)'; y(:, 1)'; x(:, 2)'; y(:, 2)']);
   fclose(fid);
end

if nargout > 0
   a = char(get(a, 'tag'));
   a = str2num(a(:, 9:end));
end