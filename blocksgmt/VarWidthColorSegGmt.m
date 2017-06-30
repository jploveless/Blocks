function out = VarWidthColorSegGmt(seg, comp, outfile, maxwidth)
% 

if ~isstruct(seg)
   seg = ReadSegmentTri(seg);
end

% Extract selected component
if comp == 1
   comp = seg.ssRate;
elseif comp == 2
   comp = seg.dsRate - seg.tsRate;
elseif comp == 3
   comp = mag([seg.ssRate seg.dsRate seg.tsRate], 2);
end

% Define segment width
width = maxwidth*abs(comp)/max(abs(comp));
width = max([2*ones(size(width)) width], [], 2);

% Write multi-segment output file
out = [width comp seg.lon1 seg.lat1 seg.lon2 seg.lat2];

% Sort so that thinner lines are always on top of thicker
out = sortrows(out, -1);

fid = fopen(outfile, 'w');
fprintf(fid, '> -W%fp -Z%f\n%f %f\n%f %f\n', out');
fclose(fid);