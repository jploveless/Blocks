function [Segment] = ReadSegmentStruct(varargin)
%%  ReadSegmentStruct.m
%%
%%  This function reads in and returns the
%%  segment information in fileName.
%%
%%  Arguments:
%%    fileName     :  file name (required)
%%    showText     :  1 to print info (optional)
%%                     default is 0 (no print)
%%
%%  Returned variables:
%%    Segment       :  a struct with everything

%% Declare variables
nHeaderLines                                                         = 13;
nFieldLines                                                          = 13;

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
   disp(sprintf('--> Reading %s ', fileName));
end

%%  Read in the whole segment file as a cell
contentsSegmentFile                                                  = textread(fileName, '%s', 'delimiter', '\n', 'whitespace', '');

%%  Get rid of the descriptive header
contentsSegmentFile(1 : nHeaderLines)                                = [];

%%  Assign the remaining data to structs
Segment.name                                                         = char(deal(contentsSegmentFile(1 : nFieldLines : end)));

endPointCoordinates                                                  = str2num(char(contentsSegmentFile(2 : nFieldLines :end)));
[Segment.lon1, Segment.lat1, Segment.lon2, Segment.lat2]             = deal(endPointCoordinates(:, 1), endPointCoordinates(:, 2), ...
                                                                            endPointCoordinates(:, 3), endPointCoordinates(:, 4));

infoLockingDepth                                                     = str2num(char(contentsSegmentFile(3 : nFieldLines :end)));
[Segment.lDep, Segment.lDepSig, Segment.lDepTog]                     = deal(infoLockingDepth(:, 1), infoLockingDepth(:, 2), infoLockingDepth(:, 3));

infoDip                                                              = str2num(char(contentsSegmentFile(4 : nFieldLines :end)));
[Segment.dip, Segment.dipSig, Segment.dipTog]                        = deal(infoDip(:, 1), infoDip(:, 2), infoDip(:, 3));

infoStrikeSlip                                                       = str2num(char(contentsSegmentFile(5 : nFieldLines :end)));
[Segment.ssRate, Segment.ssRateSig, Segment.ssRateTog]               = deal(infoStrikeSlip(:, 1), infoStrikeSlip(:, 2), infoStrikeSlip(:, 3));

infoDipSlip                                                          = str2num(char(contentsSegmentFile(6 : nFieldLines :end)));
[Segment.dsRate, Segment.dsRateSig, Segment.dsRateTog]               = deal(infoDipSlip(:, 1), infoDipSlip(:, 2), infoDipSlip(:, 3));

infoTensileSlip                                                      = str2num(char(contentsSegmentFile(7 : nFieldLines :end)));
[Segment.tsRate, Segment.tsRateSig, Segment.tsRateTog]               = deal(infoTensileSlip(:, 1), infoTensileSlip(:, 2), infoTensileSlip(:, 3));

infoBurialDepth                                                      = str2num(char(contentsSegmentFile(8 : nFieldLines :end)));
[Segment.bDep, Segment.bDepSig, Segment.bDepTog]                     = deal(infoBurialDepth(:, 1), infoBurialDepth(:, 2), infoBurialDepth(:, 3));

infoResolution                                                       = str2num(char(contentsSegmentFile(9 : nFieldLines :end)));
[Segment.res, Segment.resOver, Segment.resOther]                     = deal(infoResolution(:, 1), infoResolution(:, 2), infoResolution(:, 3));

infoOther                                                            = str2num_fast(contentsSegmentFile(10 : nFieldLines :end), 3);
[Segment.patchFile, Segment.patchTog, Segment.other3]                = deal(infoOther(:, 1), infoOther(:, 2), infoOther(:, 3));

infoOther                                                            = str2num_fast(contentsSegmentFile(11 : nFieldLines :end), 3);
[Segment.patchSlipFile, Segment.patchSlipTog, Segment.other6]        = deal(infoOther(:, 1), infoOther(:, 2), infoOther(:, 3));

infoOther                                                            = str2num_fast(contentsSegmentFile(12 : nFieldLines :end), 3);
[Segment.rake, Segment.rakeSig, Segment.rakeTog]                     = deal(infoOther(:, 1), infoOther(:, 2), infoOther(:, 3));

infoOther                                                            = str2num_fast(contentsSegmentFile(13 : nFieldLines :end), 3);
[Segment.other7, Segment.other8, Segment.other9]                     = deal(infoOther(:, 1), infoOther(:, 2), infoOther(:, 3));

%%  Take a look at how many segments we have
nSegments                                                            = length(Segment.lon1);
Segment.patchName                                                    = repmat(' ', nSegments, 1);
Segment.patchFlag01                                                  = repmat(0, nSegments, 1);
Segment.patchFlag02                                                  = repmat(0, nSegments, 1);

%%  Sort the segment into alphabetical order
Segment                                                              = AlphaSortSegment(Segment);

%%  A little more information
if (showText)
   %%  Report on segments
   disp(sprintf('Total number of segments : %d', nSegments));

   %%  Acknowledge reaching the end of the function
   disp(sprintf('<-- Done reading %s', fileName));
   disp(' ');
end
