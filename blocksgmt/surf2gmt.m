function surf2gmt(h, file, cpt, ol, dim)
%
%  surf2gmt writes a surf handle to GMT file suitable for plotting using 
%  >> psxy file -L
%
%  SURF2GMT(H, FILE, CPT) uses the SURF handle H to write FILE, which
%  can be plotted using GMT's PSXY(Z) multisegment plotting command.  CPT
%  is an optional string defining a colormap to be output.
%

% Get data
x = get(h, 'xdata');
y = get(h, 'ydata');
z = get(h, 'zdata');
c = get(h, 'cdata');

% Should be one fewer cells than matrix size
fid = fopen(file, 'w');
for i = 1:size(x, 1)-1
   for j = 1:size(x, 2)-1
      fprintf(fid, '> -Z%d\n%d %d %d\n%d %d %d\n%d %d %d\n%d %d %d\n', c(i, j), x(i, j), y(i, j), z(i, j), x(i+1, j), y(i+1, j), z(i+1, j), x(i+1, j+1), y(i+1, j+1), z(i+1, j+1), x(i, j+1), y(i, j+1), z(i, j+1));
   end
end
fclose(fid);

% determine parts of filename
if length(cpt) + length(ol) > 0
   [path, fname, ext] = fileparts(file);
   if isempty(path)
      path = '.';
   end
end

% Write cpt file, if requested
if length(find(cpt)) > 0
   % determine cpt filename
   cptfile = [path filesep fname '.cpt'];
   cptcom = sprintf('makecpt -C%s -T%d/%d/1 -Z -D > %s', cpt, min(c(:)), abs(min(c(:))), cptfile);
   system(cptcom);
end

% Write outline file, if requested
%if sum(ol) ~= 0
%	% determine outline filename
%	olfile = [path filesep fname '.ol'];
%	fid = fopen(olfile, 'w');
%	cnel = cumsum([0 ol]);
%   for i = 1:numel(ol)
%      edge = OrderedEdges(c, v(cnel(i)+1:cnel(i+1), :));
%      if dim == 2
%         for j = 1:numel(edge)/2
%            fprintf(fid, '%d %d\n', c(edge(1, j), 1), c(edge(1, j), 2));
%         end
%      elseif dim == 3
%         for j = 1:numel(edge)/2
%            fprintf(fid, '%d %d %d\n', c(edge(1, j), 1), c(edge(1, j), 2), c(edge(1, j), 3));
%         end
%      end         
%      if i ~= numel(ol)
%         fprintf(fid, '>\n');
%      end   
%   end
%   fclose(fid);
%end
