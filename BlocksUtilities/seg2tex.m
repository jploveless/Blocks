function out = seg2tex(s, sel, file, varargin)
%
% SEG2TEX writes TeX code containing segment data.
%    SEG2TEX(SEG, SEL, FILE) writes the data contained in the segment structure SEG
%    for the selected element indices SEL (from SelSegGmt.m) to FILE.  
%
%    SEG2TEX(SEG, SEL, FILE, GEOM) accepts a vector specifying which, if any, geometric
%    parameters should be written to the file.  Include any of the following:
%    1 = length, 2 = locking depth, 3 = strike, 4 = dip, [] = write no geometry
%
%    SEG2TEX(SEG, SEL, FILE, SORT) sorts the segment end points before writing the file.
%    Specify SORT as 1 for N-S, 2 for S-N, 3 for E-W, 4 for W-E.
%


if nargin == 4
   if numel(varargin{1}) == 1
      sd = varargin{1};
      geom = [1:4];
   else
      sd = [];
      geom = varargin{1};
   end
elseif nargin == 5
   geom = varargin{1};
   sd = varargin{2};
end

% sort, if necessary: 1 = N-S, 2 = S-N, 3 = E-W, 4 = W-E   
if ~isempty(sd)
	switch sd
		case 1
			[o, i] = sort(s.lat1(sel), 'descend');
			sel = sel(i);
		case 2
			[o, i] = sort(s.lat1(sel), 'ascend');
			sel = sel(i);
		case 3
			[o, i] = sort(s.lon1(sel), 'descend');
			sel = sel(i);
		case 4
			[o, i] = sort(s.lon1(sel), 'ascend');
			sel = sel(i);
	end
end

% Make the temporary arrays
[leng, azi] = distance(s.lat1(sel), s.lon1(sel), s.lat2(sel), s.lon2(sel), [6371 0]);
out = [[1:numel(sel)]' s.ssRate(sel) s.ssRateSig(sel) s.dsRate(sel) s.dsRateSig(sel) s.tsRate(sel) s.tsRateSig(sel) leng s.lDep(sel) azi s.dip(sel)];

fid = fopen(file, 'w');
for i = 1:numel(sel)
   if s.dsRate(sel(i)) == 0
      fprintf(fid, ['%0.0f & $%0.1f\\pm%0.1f$ & & $%0.1f\\pm%0.1f$', repmat('& %0.0f', numel(geom), 1), '\\\\ \n'], i, out(i, [2:3, 6:7, 7+geom]));
   else   
      fprintf(fid, ['%0.0f & $%0.1f\\pm%0.1f$ & $%0.1f\\pm%0.1f$ &', repmat('& %0.0f', numel(geom), 1), '\\\\ \n'], i, out(i, [2:5, 7+geom]));
   end
end
fclose(fid);