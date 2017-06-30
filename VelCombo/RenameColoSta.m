function [idx1, idx2] = RenameColoSta(file1, file2, varargin);
%
% RENAMECOLOSTA renames collocated stations in one field with the names from another.
%
%   RENAMECOLOSTA(FILE1, FILE2) renames the collocated stations in the .sta.data file
%   FILE2 with the names given for those stations in FILE1.  The new file written is
%   'FILE2_renamed.sta.data'.
%
%   RENAMECOLOSTA(FILE1, FILE2, FUZZ) finds stations that are collocated within FUZZ
%   degrees.  The default FUZZ value is 0.
%

% Parse inputs
if nargin == 3
   fuzz = varargin{1};
else
   fuzz = 0;
end

% Read both station files
s1 = ReadStation(file1);
s2 = ReadStation(file2);

% Check length of station name array and adjust if necessary
sn = [size(s1.name, 2) size(s2.name, 2)];
[m, mi] = min(sn);
if mi == 1
   s1.name = [s1.name, repmat(' ', numel(s1.lon), abs(diff(sn)))];
else
   s2.name = [s2.name, repmat(' ', numel(s2.lon), abs(diff(sn)))];
end

% Make meshgrid-style matrices of coordinates
lon1 = repmat(s1.lon, 1, numel(s2.lon));
lon2 = repmat(s2.lon', numel(s1.lon), 1);
lat1 = repmat(s1.lat, 1, numel(s2.lat));
lat2 = repmat(s2.lat', numel(s1.lat), 1);

% Determine collocation indices
dlon = abs(lon1 - lon2);
dlat = abs(lat1 - lat2);
dcor = sqrt(dlon.^2 + dlat.^2);
[idx1, idx2] = find(dcor <= fuzz);

% Assign new names to field 2 stations
s2.name(idx2, :) = s1.name(idx1, :);

% Write the new file
outname = [file2(1:end-9) '_renamed.sta.data'];
WriteStation(outname, s2.lon, s2.lat, s2.eastVel, s2.northVel, s2.eastSig, s2.northSig, s2.corr, s2.other1, s2.tog, s2.name);
