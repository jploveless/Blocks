function staIdx = BlockStationIdx(s, seg, b, n)
%
% BlockStation returns the indices of all stations on a particular block
%
%   STAIDX = BLOCKSTATION(S, SEG, B, N) returns the indices STAIDX of the 
%   stations contained in structure S that lie within the bounds of block
%   N of the block structure B, defined by the segment structure SEG.  
%   N can either be the name or number of the block.
%

% read data
s = ReadStation(s);
seg = ReadSegmentTri(seg);
b = ReadBlock(b);

% label stations
seg = OrderEndpoints(seg);
[seg.midLon seg.midLat] = deal((seg.lon1+seg.lon2)/2, (seg.lat1+seg.lat2)/2);
%s = SelectStation(s);
[seg, b, s] = BlockLabel(seg, b, s);

% parse block ID and convert to number if necessary
if ischar(n)
   n = strmatch(n, b.name);
end

staIdx = find(s.blockLabel == n);

