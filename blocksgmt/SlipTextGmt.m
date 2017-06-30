function SlipTextGmt(s, comp, filen, varargin)
%
%  Write slip rates and uncertainties to a file to be plotted in GMT using:
%  pstext
%
%  Inputs:
%  s: Segment structure, loaded using s = ReadSegmentTri('Mod.segment')
%  comp: Slip component to be written:
%        0 = strike and normal, 1 = strike, 2 = normal
%  file: base file name to be written
%
%  Optional 4th argument:
%  format: 3 digit string giving the font size, rotation, and font number/name, e.g.,
%          '4 90 0' for 4 pt. font, rotated 90 degrees, Helvetica
%  (Default formatting string is '8 0 0')
%

if nargin == 4
  formt = varargin{:};
else
  formt = '8 0 0'; % Default is 8 pt, non-rotated, Helvetica
end

% Calculate midpoints
[s.midLon s.midLat] = deal((s.lon1+s.lon2)/2, (s.lat1+s.lat2)/2);

fid = fopen(filen, 'w');

% Need to use a for loop, because we might have different numbers of characters for each fault
for i = 1:length(s.lon1)
   fprintf(fid, '> %f %f %s CM 12p 0.5i c\n', s.midLon(i), s.midLat(i), formt);
   if comp == 0 | comp == 1      
      fprintf(fid, '%.1f\\234%.1f\n', s.ssRate(i), s.ssRateSig(i));
   end
   if comp == 0 | comp == 2
      nslips = s.dsRate - s.tsRate;
      nsigs  = s.dsRateSig + s.tsRateSig;
      fprintf(fid, '(%.1f\\234%.1f)\n', nslips(i), nsigs(i));
   end
end   

fclose all;
