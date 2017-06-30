function [eastLabel westLabel] = TriBlockLabel(patchFileNames, SegmentEastLabel, SegmentWestLabel)
%
% TriBlockLabel.m uses the segment-patch IDs in FileNames, as well as the segment block
% labels output from BlockLabel.m to assign block labels to the patches.
%

% Find unique blocks
[up, upInd] 				= unique(patchFileNames);
[eastLabel westLabel] 	= deal(SegmentEastLabel(upInd), SegmentWestLabel(upInd));