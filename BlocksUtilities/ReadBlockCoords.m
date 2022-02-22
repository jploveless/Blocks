function b = ReadBlockCoords(direc)
% READBLOCKCOORDS	 Reads a Block.coords file.
%   B = READBLOCKCOORDS(DIREC) reads the Block.coords file from the 
%   results folder DIREC and returns coordinates to the cell array
%   B.  Each cell of B contains a 2-column array giving the ordered
%   [lon. lat.] of the block coordinates.
%

% Read the file

% Check to see if a directory has been specified, or a file
[p, f, e] = fileparts(direc);
if isempty(f)
   data = textread([direc filesep 'Block.coords'],'','delimiter','>','emptyvalue', NaN);
else
   data = textread(direc, '','delimiter','>','emptyvalue', NaN);
end

% Find NaNs and split
sep = find(isnan(data(:, 1))); sep(end) = [];
beg = [1; sep+1];
fin = [sep-1; length(data)];

b = cell(length(beg), 1);
for i = 1:length(beg)
   b{i} = data(beg(i):fin(i), :);
   b{i} = b{i}(~isnan(b{i}(:, 1)), :);
end
