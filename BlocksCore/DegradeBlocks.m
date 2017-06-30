function [sn, bn] = DegradeBlocks(s, b, idx)

% Determine segments that should be retained
east = ismember(s.eastLabel, idx);
west = ismember(s.westLabel, idx);
keep = sum([east, west], 2) > 0


