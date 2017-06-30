function Station = ReadStation(varargin)
% ReadStationStruct.m
%
% This function reads in and returns the station information in fileName.
%
% Arguments:
%   fileName     :  file name (required)
%   showText     :  1 to print info (optional) default is 0 (no print)
%
% Returned variables:
%   Station       :  a struct with everything

% Process varargin
filestream = 1;
if (nargin == 0)
   fprintf(filestream, 'No arguments found!  Exiting.  Please supply a file name.\n');
   return;
end

fileName = varargin{1};
showText = 0;
if (nargin > 1)
   showText                                                          = varargin{2};
   fprintf(filestream, '\n--> Reading %s file\n', fileName);
end

% Read in everything quickly(?) and throw it into the struct Station
%[Station.lon,     Station.lat,      Station.eastVel, Station.northVel, ...
% Station.eastSig, Station.northSig, Station.corr, ...
% Station.other1,  Station.tog,      Station.name] = textread(fileName, '%f%f%f%f%f%f%f%d%d%s');

% This is much faster:
fid = fopen(fileName,'rt');
% Check for a header line
c1 = fread(fid, 1, 'uint8=>char'); % Read first character
if ~isempty(str2num(c1)) % Try to change to digit; if it's not empty, there's data on the first line
   hlines = 0;
else
   hlines = 1;
end
frewind(fid);
c = textscan(fid, '%f%f%f%f%f%f%f%d%d%s', 'headerlines', hlines);
fclose(fid);
fn = {'lon','lat','eastVel','northVel','eastSig','northSig','corr','other1','tog','name'};
Station = cell2struct(c,fn,2);

% Convert station coordinates to 3 decimal places. This is consistent with how results are written
if verLessThan('matlab', '8.4')
   Station.lon  = str2num(num2str(Station.lon, '%3.3f'));
   Station.lat  = str2num(num2str(Station.lat, '%3.3f'));
else
   Station.lon  = round(Station.lon,3); %
   Station.lat  = round(Station.lat,3); %
end
Station.name = char(Station.name);
Station.tog  = logical(Station.tog);

% Add fields to Station to deal that are not included in a .sta.data file
sz = size(Station.eastVel);
Station.upVel    = zeros(sz);
Station.upSig    = ones (sz);
Station.eastAdj  = zeros(sz);
Station.northAdj = zeros(sz);
Station.upAdj    = zeros(sz);

% Take a look at how many stations we have
nStations        = numel(Station.lon);
nInvertStations  = numel(Station.tog == 1);

if (showText)
   fprintf(filestream, 'Total number of sites : %d\n', nStations);
   fprintf(filestream, 'Number of sites included in inversion : %d\n', nInvertStations);
   includeIdx = find(Station.tog >= 1);
   if ~isempty(includeIdx)
      fprintf(filestream, 'Names of sites  included in inversion :\n');
      for nInclude = 1 : numel(includeIdx)
         fprintf(filestream, '%s\n', Station.name(nInclude, :));
      end
   else
      fprintf(filestream, 'No sites toggled on.\n');
   end
   fprintf(filestream, '<-- Done reading %s file\n\n', fileName);
end
