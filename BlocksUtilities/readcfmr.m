function seg = readcfmr(file, outfile)
% READCFMR  Reads and parses a CFM-R file.
%   SEG = READCFMR(FILE) reads the CFM-R text FILE and parses
%   fault data to the segment structure SEG.
%
%   SEG = READCFMR(FILE, OUTFILE) also writes the file OUTFILE.segment.
%

fid = fopen(file, 'r');
c = textscan(fid, '%s %f %f %f %f %f %f %f %f %f %f %f %f %f %f\n');
fclose(fid);
[seg.name, seg.dip1, seg.dip2, seg.lDep1, seg.lDep2, seg.elev1, seg.elev2,...
 seg.xda, seg.xdb, seg.xta, seg.xtb, seg.xda, seg.seg.xdb, seg.yta, seg.ytb] = deal(c{:});
seg.name = char(seg.name);
[seg.lon1, seg.lat1] = gmtutm(seg.xta, seg.yta, 11, 1);
[seg.lon2, seg.lat2] = gmtutm(seg.xtb, seg.ytb, 11, 1);
seg.lDep = -0.5*(seg.lDep1 + seg.lDep2)/1000;
seg.dip = 0.5*(seg.dip1 + seg.dip2);
seg.bDep = zeros(size(seg.lDep));
if exist('outfile', 'var')
   WriteSegmentStruct(outfile, seg);
end

