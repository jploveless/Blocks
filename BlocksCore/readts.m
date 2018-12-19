function [c, v] = readts(filename)
% readts  Reads coordinate and vertex information from .ts file
%   [C, V] = ReadTsCoords(FILENAME) reads the coordinate information
%   and vertex information from the GOCAD .ts file FILENAME. The 
%   3-dimensional coordinates are returned to C and the row indices
%   of C that define triangular elements are returned to V.
%
%   Based on Brendan Meade's ReadTsCoords.
%
textDump                                                         = textread(filename, '%s', 'delimiter', '\n', 'bufsize', 1e7);
[idxVrtx idxPvrtx idxTrgl]                                       = deal(strmatch('VRTX', textDump), strmatch('PVRTX', textDump), strmatch('TRGL', textDump));
idxVrtx                                                          = union(idxVrtx, idxPvrtx);

% Coordinate array
c = char(textDump(idxVrtx));
c = str2num(c(:, 5:end));
c = c(:, 2:end);

% Vertex array
v = char(textDump(idxTrgl));
v = str2num(v(:, 5:end));
