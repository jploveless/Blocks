function SegGmt(s, name, varargin)
% SEGGMT  Outputs a segment structure to GMT format.
%   SEGGMT(S, NAME) outputs segment structure S to file NAME, which can
%   be plotted using PSXY -M in GMT.

if ischar(s)
   s = ReadSegmentTri(s);
end

fid = fopen(name, 'w');
fprintf(fid, '%f %f\n%f %f\n>\n', [s.lon1'; s.lat1'; s.lon2'; s.lat2']);
fclose(fid);
