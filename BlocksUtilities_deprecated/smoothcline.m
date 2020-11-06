function h = smoothcline(seg, wid, col, opts)
% SMOOTHCLINE  Plots a smooth colored "line" as a series of polygons
%    SMOOTHCLINE(SEG, WID, COL) uses the segment structure SEG to plot
%    colored polygons of width WID (km), colored by the magnitude of
%    vector COL.  For example, to plot the San Andreas Fault colored by 
%    slip rate, 10 km wide, call:
%   
%    >> smoothcline(saf, 10, saf.ssRate);
%
%    Add a 4th argument to call an alternate version of SWATHSEG: specify
%    OPTS = [D1 D2] to call SWATHSEG_HALF_OFFSET, or OPTS = D to call 
%    SWATHSEG_HALF (where D overrides WID).
%

% Sort the structure
sego = ordersegs(seg);

% Define the polygons
if ~exist('opts', 'var')
   [sx, sy, seg] = swathseg(seg, wid/2);
elseif numel(opts) == 1
   [sx, sy, seg] = swathseg_half(seg, opts);
elseif numel(opts) == 2
   [sx, sy, seg] = swathseg_half_offset(seg, opts);
end

% Define the individual polygons' indices
nseg = length(seg.lon1);
idx = [1:nseg; 2:nseg+1; fliplr(nseg+2:2*nseg+1); fliplr(nseg+3:2*nseg+2)];

% Make the plot
figure
h = patch('vertices', [sx(:) sy(:)], 'faces', idx', 'facevertexcdata', col(sego));
shading flat;