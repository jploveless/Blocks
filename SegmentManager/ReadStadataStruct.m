function [Station] = ReadStadataStruct(varargin)
%%  ReadStadataStruct.m
%%
%%  This function reads in and returns the
%%  station information in fileName.
%%
%%  Arguments:
%%    fileName     :  file name (required)
%%    showText     :  1 to print info (optional)
%%                     default is 0 (no print)
%%
%%  Returned variables:
%%    Station       :  a struct with everything

%%  Process varargin
if (nargin == 0)
   disp('No arguments found!  Exiting.  Please supply a file name.');
   return;
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

%%  Read in everything quickly and throw it into the struct Station
[Station.lon, Station.lat, Station.eastVel, Station.northVel, ...
 Station.eastSig, Station.northSig, Station.corr, ...
 Station.other1, Station.tog, Station.name]                          = textread(fileName, '%f%f%f%f%f%f%f%d%d%s');
Station.name                                                         = char(Station.name);

%%  Add fields to Station to deal that are not included in a
%%  .sta.data file
Station.upVel                                                        = zeros(size(Station.eastVel));
Station.upSig                                                        = ones(size(Station.eastVel));
Station.eastAdj                                                      = zeros(size(Station.eastVel));
Station.northAdj                                                     = zeros(size(Station.eastVel));
Station.upAdj                                                        = zeros(size(Station.eastVel));

%%  Take a look at how many stations we have
nStations                                                            = length(Station.lon);
nInvertStations                                                      = length(Station.tog == 1);

if (showText)
   %%  Report on stations
   disp(sprintf('Total number of sites : %d', nStations));
   disp(sprintf('Number of sites included in inversion : %d', nInvertStations));
   includeIdx                                                        = find(Station.tog >= 1);
   if (length(includeIdx) > 0)
      disp('Names of sites  included in inversion :');
      for nInclude = 1 : length(includeIdx)
         disp(Station.name(nInclude, :))
      end
   else
      disp('No sites toggled on.');
   end

   %%  Acknowledge reaching the end of the function
   disp(sprintf('<-- Done reading %s file', fileName));
   disp(' ');
end
