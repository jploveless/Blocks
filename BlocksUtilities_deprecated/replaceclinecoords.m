function replaceclinecoords(color, coords)
% REPLACECLINECOORDS  Replaces smooth cline coordinates.
%   REPLACECLINECOORDS(COLOR, COORDS) replaces the coordinates of the
%   smooth cline in file COLOR with those in COORDS.
%

in1 = opentxt(color);
in2 = opentxt(coords);

replace = setdiff(1:size(in1, 1), [1:5:size(in1, 1)]);

in1(replace, :) = in2(replace, :);

outname = [color(1:end-3) '_new.xy'];
fid = fopen(outname, 'w');

for i = 1:size(in1, 1)
   fprintf(fid, '%s\n', in1(i, :));
end
fclose(fid);