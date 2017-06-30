function ColorBlocksGmt(Block, c, outfile, subset, varargin)
% ColorBlocksGmt(b, c, outfile) writes the ordered block coordinates contained
% in structure b to a GMT file, plottable using psxy -M -L, colored by the values
% in vector c, to the file "outfile".
%
% ColorBlocksGmt(b, c, outfile, subset) allows a subset of blocks to specified.
%
% ColorBlocksGmt(b, c, outfile, subset, bc) uses ordered block coordinates from
% cell bc rather than b.orderLon and b.orderLat (in case BlockLabel hasn't been run).
%

% write the geometry
fid = fopen(outfile, 'w');

% define subset of whole set
if ~exist('subset', 'var')
   subset = 1:size(Block.interiorLon, 1);
end

% check where ordered coordinates are stored
if nargin == 5
   bc = varargin{1};
end

% Write ordered block coordinates
for i = subset
   if exist('bc', 'var')
      out = [bc{i}(:, 1)'; bc{i}(:, 2)'];
   else
      out = [Block.orderLon{i}'; Block.orderLat{i}'];
   end
   fprintf(fid, '> -Z%d\n', c(i));
   fprintf(fid, '%d %d\n', out);
end

fclose(fid);

[p, n, e] = fileparts(outfile);
textfile = [p filesep n '.labels'];
fid = fopen(textfile, 'w');
for i = subset
   fprintf(fid, '%g %g 10 0 0 CM %.1f\n', Block.interiorLon(i), Block.interiorLat(i), c(i));
   %fprintf(fid, '%g %g 10 0 0 CM %.1e\n', Block.interiorLon(i), Block.interiorLat(i), c(i));
end
fclose(fid);
   