function TrimCombinedSta(rootname);
%
% TRIMCOMBINEDSTA deletes repeated stations in a combined .sta.data file.
%
%   TRIMCOMBINEDSTA(ROOTNAME) deletes repeated stations from ROOTNAME.sta.data 
%   and writes the unique values to ROOTNAME_trim.sta.data, while also updating
%   ROOTNAME.mat as produced by ALIGNALLFIELDS.m.
%

% define file names
infile = [rootname '.sta.data'];
matfile = [rootname '.mat'];

% trim .sta.data file
s                                      = ReadStation(infile);
[s.lon, i]                             = unique(s.lon); 
j                                      = setdiff(1:length(s.lat), i);
s.lat                                  = s.lat(i);
s.eastVel                              = s.eastVel(i);
s.northVel                             = s.northVel(i);
s.eastSig                              = s.eastSig(i);
s.northSig                             = s.northSig(i);
s.tog                                  = s.tog(i);
s.name                                 = s.name(i, :);
s.other1                               = s.other1(i);
outfile                                = sprintf('%s_trim.sta.data', rootname);
WriteStation(outfile, s.lon, s.lat, s.eastVel, s.northVel, s.eastSig, s.northSig, s.corr, s.other1, s.tog, s.name);


% trim .mat file
if exist(matfile, 'file')
   load(matfile);
   n                                      = histc(j, sumnStations);
   n(end-1)                               = n(end-1) + n(end);
   n                                      = cumsum(n(1:end-1));
   sumnStations(2:end)                    = sumnStations(2:end) - n';
   outmat                                 = sprintf('%s_trim.mat', rootname);
   save(outmat, 'sumnStations', 'names', '-mat');
end