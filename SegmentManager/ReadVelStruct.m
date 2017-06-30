function [Station] = ReadVelStruct(varargin)
%%  ReadVelStruct
%%
%%  This function reads in and returns the station information in fileName.
%%
%%  Arguments:
%%    fileName     :  file name (required)
%%    showText     :  1 to print info (optional) default is 0 (no print)
%%
%%  Returned variables:
%%    Station       :  a struct with everything

%%  Process varargin
if (nargin == 0)
   disp('No arguments found!  Exiting.  Please supply a file name.');
   break;
end

fileName                                                             = varargin{1};
showText                                                             = 0;
if (nargin > 1)
   showText                                                          = varargin{2};
end


if (showText)
   %%  Announce intentions
   disp(' ');
   disp(sprintf('--> Reading %s file', fileName));
end


%%  Get the number of header lines
[nHeaderLines, headerLines]                                          = GetVelHeaderLines(fileName);


%%  Read in everything quickly and throw it into the struct Station
[Station.Lon, Station.Lat, Station.EastVel, Station.NorthVel, ...
 Station.EastAdj, StationNorthAdj, ...
 Station.EastSig, Station.NorthSig, Station.Corr, ...
 Station.UpVel, Station.UpAdj, StationUpSig, Station.Name]           = textread(fileName, '%f%f%f%f%f%f%f%f%f%f%f%f%s', ...
                                                                                'headerlines', nHeaderLines);
Station.Name                                                         = char(Station.Name);

%%  Add fields to Station to deal that are not included in a
%%  .vel file
Station.Other1                                                       = zeros(size(Station.EastVel));
Station.Tog                                                          = ones(size(Station.EastVel));


%%  Add a comment field to Station with the name of the .sta.data
%%  file
Station.Comment                                                      = sprintf('Velocities from %s', fileName);


%%  Take a look at how many stations we have
nStations                                                            = length(Station.Lon);
nInvertStations                                                      = length(Station.Tog == 1);


if (showText)
   %%  Report on stations
   disp(sprintf('Total number of sites : %d', nStations));
   disp(sprintf('Number of sites included in inversion : %d', nInvertStations));
   includeIdx                                                        = find(Station.Tog >= 1);
   if (length(includeIdx) > 0)
      disp('Names of sites  included in inversion :');
      for nInclude = 1 : length(includeIdx)
         disp(Station.Name(nInclude, :))
      end
   else
      disp('No sites toggled on.');
   end

   %%  Acknowledge reaching the end of the function
   disp(sprintf('<-- Done reading %s file', fileName));
   disp(' ');
end
