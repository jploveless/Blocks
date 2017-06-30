function patchStruct = PatchEndAdjust(patchStruct, segStruct)
%
% PatchEndAdjust.m makes sure that the extrema of the patch files are collocated with
% the end points of the first and last segments that comprise them.  In other words, 
% because the patches must replace a series of segments as a block boundary, the
% intersections between adjacent patches and segments must be true intersections, 
% with identical coordinates.
%
%  Inputs:
%	patchStruct			: The structure containing patch coordinates and number of elements
%	segStruct			: The structure containing all segment information
%

% For each patch's segments, determine which end points are the extreme points.
%   This is accomplished by looking for segment end points that occur exactly
%   once, because all other end points within the patch will occur twice.

coordOrd													= [0; cumsum(patchStruct.nc(:))];

for i = 1:numel(patchStruct.nEl);
	patchSegs						 					= intersect(find(segStruct.patchFile == i), find(segStruct.patchTog > 0)); % determine which segments belong to the patch
	% Create coordinate arrays of the segment end points for this patch
	patchSegsLons										= [segStruct.lon1(patchSegs(:)); segStruct.lon2(patchSegs(:))];
	patchSegsLats										= [segStruct.lat1(patchSegs(:)); segStruct.lat2(patchSegs(:))];
	patchSegsCoords									= [patchSegsLons(:) patchSegsLats(:)];
	[uc, ucInd1]										= unique(patchSegsCoords, 'rows', 'first');
	[uc, ucInd2]										= unique(patchSegsCoords, 'rows', 'last');
	endCoords											= patchSegsCoords(ucInd1(find(ucInd2-ucInd1 == 0)), :);
	% find indices of points on patch closest to segment end points
	kFirst												= coordOrd(i) + dsearchn(patchStruct.c(coordOrd(i)+1:coordOrd(i+1), 1:2), endCoords);
	patchStruct.c(kFirst, 1:2)						= endCoords;
end
	