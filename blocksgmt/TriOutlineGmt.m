function TriOutlineGmt(c, v, ol, file)
%
%  TriOutlineGmt writes a GMT file suitable for plotting using 
%  >> psxy file -L
%
%  TriOutlineGmt(C, V, OL, FILE) uses the information in the coordinate
%  array C, the vertex array V, and an array designating the number of 
%  elements per mesh OL (same as P.nEl of the Patches structure) to write
%  a file containing the outlines of the triangular mesh.
%

 % Write outline file
% determine outline filename
if file(end-2:end) ~= '.ol'
   file = [file '.ol'];
end   
fid = fopen(file, 'w');
cnel = cumsum([0 ol]);
for i = 1:numel(ol)
   edge = OrderedEdges(c, v(cnel(i)+1:cnel(i+1), :));
   for j = 1:numel(edge)/2
      fprintf(fid, '%d %d\n', c(edge(1, j), 1), c(edge(1, j), 2));
   end
   if i ~= numel(ol)
      fprintf(fid, '>\n');
   end   
end
fclose(fid);
