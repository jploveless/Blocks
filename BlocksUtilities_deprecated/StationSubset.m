function s2 = StationSubset(s1, idx);
%
% STATIONSUBSET returns a new structure containing a subset of a station structure.
%    SNEW = STATIONSUBSET(SOLD, I) returns the structure SNEW containing the station
%    data for the I stations in SOLD.
%

% Determine field names
n = fieldnames(s1);

for i = 1:numel(n)
   s2(1).(n{i}) = s1.(n{i})(idx, :);
end