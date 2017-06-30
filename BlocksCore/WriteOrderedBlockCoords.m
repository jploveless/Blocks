function WriteOrderedBlockCoords(filename, s, b)
%
% Function writes the ordered block coordinates to a file.
%

bc = fopen(filename, 'w');

for i = 1:numel(b.interiorLon)
   fprintf(bc, '%g %g\n', [b.orderLon{i}'; b.orderLat{i}']);
   fprintf(bc, '>\n');
end

fclose(bc);