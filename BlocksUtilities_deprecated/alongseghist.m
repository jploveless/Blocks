function [n, ins] = alongseghist(seg, d, dx, dy)
% ALONGSEGHIST  Determines the number of data within swaths along segments.
%    ALONGSEGHIST(SEG, D, DX, DY) first makes a swath polygon about SEG 
%    with distance D (using SWATHSEG) and then counts the data given by
%    coordinates DX, DY that lie within the boxes defined by each segment's
%    length and the swath width.
%
%    N = ALONGSEGHIST(...) returns the count to N, which is an nSeg-by-1 vector
%    that can be plotted using MYCLINE.
%
%    [N, IDX] = ALONGSEGHIST(...) also returns a cell IDX containing the indices
%    of the data points within each bin.
%

% First call SWATHSEG
[sx, sy, seg] = swathseg(seg, d);

nseg = length(seg.lon1);

% Determine the indices for each bin
idx = [1:nseg; 2:nseg+1; fliplr(nseg+2:2*nseg+1); fliplr(nseg+3:2*nseg+2)];

n = zeros(nseg, 1);
ins = cell(size(idx, 2), 1);
% Loop through and do the binning
for i = 1:size(idx, 2)
   in = inpolygon(dx, dy, sx(idx(:, i)), sy(idx(:, i)));
   ins{i} = find(in);
   n(i) = numel(ins{i});
end