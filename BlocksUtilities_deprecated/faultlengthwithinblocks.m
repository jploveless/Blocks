function [L, Ln] = faultlengthwithinblocks(direc, fault, exclud, varargin)
% FAULTLENGTHWITHINBLOCKS calculates the total length of a fault map within 
% a given block geometry.
%
%   FAULTLENGTHWITHINBLOCKS(DIREC, FAULT, EXCLUD) uses the Block.coords file in
%   DIREC as well as the faultmap in file FAULT (assumed to be a NaN-separated
%   x, y file) to determine the total length of faults within the block geometry, 
%   excluding those that lie within 10 km of a block boundary.  Blocks whose names
%   are within the cell EXCLUD are not considered.
% 
%   FAULTLENGTHWITHINBLOCKS(DIREC, FAULT, EXCLUD, BUFFER) uses BUFFER km as the 
%   wiggle room in defining faults that may be represented by the block geometry.
%
%   FAULTLENGTHWITHINBLOCKS(..., OUT) writes a colored blocks file to OUT.
%
%   L = FAULTLENGTHWITHINBLOCKS(...) returns the total length of faults to vector L.
%

% Parse optional input arguments
if nargin == 4
   if ischar(varargin{1}) | iscell(varargin{1})
      outname = varargin{1};
   else
      buff = varargin{1};
   end
elseif nargin == 5
   outname = varargin{1};
   buff = varargin{2};
end

% Assign default buffer
if ~exist('buff', 'var')
   buff = 10;
end

% Load necessary files
bc = ReadBlockCoords(direc);
Block = ReadBlock([direc filesep 'Mod.block']);
[~, includ] = setdiff(Block.name, exclud);
fm = load(fault);

% Calculate fault lengths
fl = distance(fm(1:end-1, 2), fm(1:end-1, 1), fm(2:end, 2), fm(2:end, 1), almanac('earth','ellipsoid','kilometers'));

% Some indexing to map coordinates to lengths
cn = isnan(fm(:, 1));
ln = isnan(fl);
fl(ln) = 0; % Set NaN lengths to zero

L = zeros(length(Block.interiorLon), 1);
Ln = L;

% Find all fault nodes within each block
for i = includ
   % Make a buffer of ~10 km within the block boundaries
   [latb, lonb] = bufferm(bc{i}([1:end, 1], 2), bc{i}([1:end, 1], 1), buff/111, 'in');
   % Find fault nodes within that buffered block
   infault = find(inpolygon(fm(:, 1), fm(:, 2), lonb, latb));
   % Sum associated fault lengths - straight up link between coordinate and length indices
   L(i) = sum(fl(infault));
   if nargout == 2
      % Normalize by block area
      ba(i) = areaint(bc{i}(:, 2), bc{i}(:, 1), almanac('earth','ellipsoid','kilometers'));
      Ln(i) = L(i)./sqrt(ba(i))*100;
   end   
end
   
if exist('outname', 'var')
   if iscell(outname)
      ColorBlocksGmt(Block, L, outname{1}, includ, bc);
      ColorBlocksGmt(Block, Ln, outname{2}, includ, bc);
   else
      ColorBlocksGmt(Block, L, outname, includ, bc);
   end   
end

keyboard
