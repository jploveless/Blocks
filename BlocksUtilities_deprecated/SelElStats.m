function [smax, smin, smean] = SelElStats(slip, sel)
%
% SELELSTATS gives statistics of slip for selected elements.
%   SELELSTATS(SLIP, SEL) uses the slip matrix SLIP (as loaded using
%   PATCHDATA) to calculate the minimum, maximum, and mean slip on 
%   the elements whose indices are defined in SEL.  SEL can be an 
%   n-by-1 vector or a cell array of one-dimensional vectors containing
%   the selected indices for multiple groups of elements.  
%
%   [SMAX, SMIN, SMEAN] = SELELSTATS(...) returns the statistics to the 
%   output arrays SMAX, SMIN, and SMEAN, which are either 3 element
%   arrays or m-by-3 vectors, where m is the number of cell array elements
%   in SEL.  The 3 columns of the outputs represent the statistics for the 
%   strike component, dip component, and magnitude of slip, respectively.
%

% Determine number of patch clusters on which to operate
if iscell(sel) % if SEL is a cell array...
   nsp = numel(sel); % ...multiple patch clusters are defined
else % if not...
   nsp = 1; % we just have one
   sel = {sel}; % convert to a cell for easy referencing
end

% Allocate space for arrays
smax = zeros(nsp, 3);
smin = smax;
smean = smax;

% Calculate the magnitude of slip just once
slipmag = mag(slip(:, 1:2), 2);

% Loop through patch clusters to calculate the statistics
for i = 1:nsp
   smax(i, :)  = [max(slip(sel{i}, 1)), max(slip(sel{i}, 2)), max(slipmag(sel{i}))];
   smin(i, :)  = [min(slip(sel{i}, 1)), min(slip(sel{i}, 2)), min(slipmag(sel{i}))];
   smean(i, :) = [mean(slip(sel{i}, 1)), mean(slip(sel{i}, 2)), mean(slipmag(sel{i}))];
end