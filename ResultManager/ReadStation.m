function [Station] = ReadStationStruct(varargin)
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
filestream                                                           = 1;
if (nargin == 0)
   fprintf(filestream, 'No arguments found!  Exiting.  Please supply a file name.\n');
   return;
end

fileName                                                             = varargin{1};
showText                                                             = 0;
if (nargin > 1)
   showText                                                          = varargin{2};
   fprintf(filestream, '\n--> Reading %s file\n', fileName);
end

% Read in everything quickly and throw it into the struct Station
[Station.lon, Station.lat, Station.eastVel, Station.northVel, ...
 Station.eastSig, Station.northSig, Station.corr, ...
 Station.other1, Station.tog, Station.name]                          = textread(fileName, '%f%f%f%f%f%f%f%d%d%s');
Station.name                                                         = char(Station.name);

% Add fields to Station to deal that are not included in a .sta.data file
Station.upVel                                                        = zeros(size(Station.eastVel));
Station.upSig                                                        = ones(size(Station.eastVel));
Station.eastAdj                                                      = zeros(size(Station.eastVel));
Station.northAdj                                                     = zeros(size(Station.eastVel));
Station.upAdj                                                        = zeros(size(Station.eastVel));

% Take a look at how many stations we have
nStations                                                            = numel(Station.lon);
nInvertStations                                                      = numel(Station.tog == 1);

if (showText)
   fprintf(filestream, 'Total number of sites : %d\n', nStations);
   fprintf(filestream, 'Number of sites included in inversion : %d\n', nInvertStations);
   includeIdx                                                        = find(Station.tog >= 1);
   if (length(includeIdx) > 0)
      fprintf(filestream, 'Names of sites  included in inversion :\n');
      for nInclude = 1 : numel(includeIdx)
         fprintf(filestream, '%s\n', Station.name(nInclude, :));
      end
   else
      fprintf(filestream, 'No sites toggled on.\n');
   end
   fprintf(filestream, '<-- Done reading %s file\n\n', fileName);
end
