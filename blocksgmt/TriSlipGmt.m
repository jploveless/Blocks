function TriSlipGmt(c, v, s, comp, file, cpt, ol, dim)
%
%  TriSlipGmt writes a GMT file suitable for plotting using 
%  >> psxy file -L
%
%  TriSlipGmt(C, V, S, COMP, FILE, CPT, OL) uses the information in the coordinate
%  array C, the vertex array V, and the slip array S to create a GMT file named
%  FILE that contains the triangular mesh geometry colored by slip component COMP.
%  CPT specifies the name, with full path if necessary, to a GMT colormap and an 
%  accompanying .cpt file will be written (or not if CPT = 0).  To write a file 
%  that will allow the outline of the patch(es) to be drawn by GMT, specify 
%  OL = [el(1) el(2)...el(n)], where el(i) is a number representing the number of 
%  triangles in a given patch (from the patch structure).
%

% extract slip components to be written
slip = s(:, comp);

% optional dimension
if ~exist('dim', 'var')
   dim = 2;
end

% write the geometry
fid = fopen(file, 'w');
if dim == 2
   for i = 1:size(v, 1)
      fprintf(fid, '> -Z%d\n%d %d\n%d %d\n%d %d\n', slip(i), c(v(i, 1), 1), c(v(i, 1), 2), c(v(i, 2), 1), c(v(i, 2), 2), c(v(i, 3), 1), c(v(i, 3), 2));
   end
elseif dim == 3
   for i = 1:size(v, 1)
      fprintf(fid, '> -Z%d\n%d %d %d\n%d %d %d\n%d %d %d\n', slip(i), c(v(i, 1), 1), c(v(i, 1), 2), c(v(i, 1), 3), c(v(i, 2), 1), c(v(i, 2), 2), c(v(i, 2), 3), c(v(i, 3), 1), c(v(i, 3), 2), c(v(i, 3), 3));
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
   cptcom = sprintf('makecpt -C%s -Z -D > %s', cpt, cptfile);
   system(cptcom);
end

% Write outline file, if requested
if sum(ol) ~= 0
	% determine outline filename
	olfile = [path filesep fname '.ol'];
	fid = fopen(olfile, 'w');
	cnel = cumsum([0; ol]);
   for i = 1:numel(ol)
      edge = OrderedEdges(c, v(cnel(i)+1:cnel(i+1), :));
      if dim == 2
         for j = 1:numel(edge)/2
            fprintf(fid, '%d %d\n', c(edge(1, j), 1), c(edge(1, j), 2));
         end
      elseif dim == 3
         for j = 1:numel(edge)/2
            fprintf(fid, '%d %d %d\n', c(edge(1, j), 1), c(edge(1, j), 2), c(edge(1, j), 3));
         end
      end         
      if i ~= numel(ol)
         fprintf(fid, '>\n');
      end   
   end
   fclose(fid);
end
