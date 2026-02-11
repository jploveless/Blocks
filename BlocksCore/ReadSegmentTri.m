function [Segment] = ReadSegmentTri(varargin)
% ReadSegmentStruct.m
%
% This function reads in and returns the segment information in fileName.
%
% Arguments:
%   fileName     :  file name (required)
%   showText     :  1 to print info (optional) default is 0 (no print)
%
% Returned variables:
%   Segment      :  a struct with everything

% Declare variables
nHeaderLines = 13;
nFieldLines  = 13;
filestream   = 1;

% Process varargin
if (nargin == 0)
   fprintf(filestream, 'No arguments found!  Exiting.  Please supply a file name.');
   return;
end

fileName = varargin{1};
showText = 0;
if (nargin > 1)
   showText = varargin{2};
   disp(' ');
   fprintf(filestream, '--> Reading %s\n', fileName);
end

% Read in the whole segment file as a cell
contentsSegmentFile = textread(fileName, '%s', 'delimiter', '\n', 'whitespace', '');

% Get rid of the descriptive header
contentsSegmentFile(1 : nHeaderLines) = [];

% Assign the remaining data to structs
Segment.name = char(deal(contentsSegmentFile(1 : nFieldLines : end)));

endPointCoordinates = str2num_fast(contentsSegmentFile(2 : nFieldLines :end), 4);
[Segment.lon1, Segment.lat1, Segment.lon2, Segment.lat2] = deal(endPointCoordinates(:, 1), endPointCoordinates(:, 2), endPointCoordinates(:, 3), endPointCoordinates(:, 4));

infoLockingDepth                                         = str2num_fast(contentsSegmentFile(3 : nFieldLines :end), 3);
[Segment.lDep, Segment.lDepSig, Segment.lDepTog]         = deal(infoLockingDepth(:, 1), infoLockingDepth(:, 2), infoLockingDepth(:, 3));

infoDip                                                  = str2num_fast(contentsSegmentFile(4 : nFieldLines :end), 3);
[Segment.dip, Segment.dipSig, Segment.dipTog]            = deal(infoDip(:, 1), infoDip(:, 2), infoDip(:, 3));

infoStrikeSlip                                           = str2num_fast(contentsSegmentFile(5 : nFieldLines :end), 3);
[Segment.ssRate, Segment.ssRateSig, Segment.ssRateTog]   = deal(infoStrikeSlip(:, 1), infoStrikeSlip(:, 2), infoStrikeSlip(:, 3));

infoDipSlip                                              = str2num_fast(contentsSegmentFile(6 : nFieldLines :end), 3);
[Segment.dsRate, Segment.dsRateSig, Segment.dsRateTog]   = deal(infoDipSlip(:, 1), infoDipSlip(:, 2), infoDipSlip(:, 3));

infoTensileSlip                                          = str2num_fast(contentsSegmentFile(7 : nFieldLines :end), 3);
[Segment.tsRate, Segment.tsRateSig, Segment.tsRateTog]   = deal(infoTensileSlip(:, 1), infoTensileSlip(:, 2), infoTensileSlip(:, 3));

infoBurialDepth                                          = str2num_fast(contentsSegmentFile(8 : nFieldLines :end), 3);
[Segment.bDep, Segment.bDepSig, Segment.bDepTog]         = deal(infoBurialDepth(:, 1), infoBurialDepth(:, 2), infoBurialDepth(:, 3));

infoResolution                                           = str2num_fast(contentsSegmentFile(9 : nFieldLines :end), 3);
[Segment.res, Segment.resOver, Segment.resOther]         = deal(infoResolution(:, 1), infoResolution(:, 2), infoResolution(:, 3));

% Segment.patchFile contains a number from 0:N indicating which, if any, triangulated patch file the segment is a part of.
% These files should be listed in the commandFile.
% Segment.patchTog indicates whether the patch geometry should be ignored (.patchTog = 0) or used (.patchTog = 1).
infoOther                                                = str2num_fast(contentsSegmentFile(10 : nFieldLines :end), 3);
[Segment.patchFile, Segment.patchTog, Segment.other3]    = deal(infoOther(:, 1), infoOther(:, 2), infoOther(:, 3));

% Segment.patchSlipFile contains a number from 0:N indicating which, if any, triangulated patch slip distribution file the
% segment is a part of.
% Segment.patchSlipTog indicates whether the patch slip distribution should be ignored (.patchSlipTog = 0) or used as an a priori constraint (.patchSlipTog = 1)
infoOther                                                     = str2num_fast(contentsSegmentFile(11 : nFieldLines :end), 3);
[Segment.patchSlipFile, Segment.patchSlipTog, Segment.other6] = deal(infoOther(:, 1), infoOther(:, 2), infoOther(:, 3));

infoOther                                                = str2num_fast(contentsSegmentFile(12 : nFieldLines :end), 3);
[Segment.rake, Segment.rakeSig, Segment.rakeTog]         = deal(infoOther(:, 1), infoOther(:, 2), infoOther(:, 3));

infoOther                                                = str2num_fast(contentsSegmentFile(13 : nFieldLines :end), 3);
[Segment.other7, Segment.other8, Segment.other9]      = deal(infoOther(:, 1), infoOther(:, 2), infoOther(:, 3));

% Take a look at how many stations we have
nSegments = numel(Segment.lon1);

% A little more information
if (showText)
   fprintf(filestream, 'Total number of segments : %d\n', nSegments);
   fprintf(filestream, '<-- Done reading %s\n\n', fileName);
end