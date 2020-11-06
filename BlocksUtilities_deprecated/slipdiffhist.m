function slipdiffhist(dirnames, comp, refidx)
% slipdiffhist  Makes a histogram of slip rate differences
%    slipdiffhist(DIRNAMES, COMP) makes a histogram showing the differences
%    in estimated slip rates contained in the Mod.segment files
%    within Blocks run directories DIRNAMES. DIRNAMES is a 
%    character array giving the full path of the results directories
%    to be compared. By default, the difference with respect to the
%    first directory in the list is used as the reference directory
%    to which other runs' slip rates are compared. COMP can be 1 or 2,
%    corresponding to the strike-slip or fault normal component, 
%    respectively.
%
%    slipdiffhist(DIRNAMES, COMP, REFIDX) allows specification of the row index
%    of the directory to be used as the reference as REFIDX.
%

% Check whether a reference index has been specified
if ~exist('refidx', 'var')
   refidx = 1;
end

ndirs = size(dirnames, 1);
otheridx = setdiff(1:ndirs, refidx);

% Load the reference segment structure
s(refidx) = ReadSegmentTri([dirnames(refidx, :) filesep 'Mod.segment']);
nsegs = size(s(refidx).name, 1);
[rate, ratediff] = deal(zeros(nsegs, 2*ndirs));
loc = zeros(nsegs, ndirs);
loc(:, refidx) = 1:nsegs;
rate(:, 2*refidx-1) = s(refidx).ssRate;
rate(:, 2*refidx-0) = s(refidx).dsRate - s(refidx).tsRate;

figure; hold on
cmap = jet(ndirs-1);

j = length(otheridx);
% Load in the other segment structures 
for i = fliplr(otheridx)
   s(i) = ReadSegmentTri([dirnames(i, :) filesep 'Mod.segment']);
   % Match segments to reference by name
   [~, loc(:, i)] = ismember(s(refidx).name, s(i).name, 'rows');
   % Rates and differences
   rate(:, 2*i-1) = s(i).ssRate(loc(:, i));
   rate(:, 2*i-0) = s(i).dsRate(loc(:, i)) - s(i).tsRate(loc(:, i));
   ratediff(:, 2*i-1) = rate(:, 2*i-1) - rate(:, 2*refidx-1);
   ratediff(:, 2*i-0) = rate(:, 2*i-0) - rate(:, 2*refidx-0);
   ho(i) = histogram(ratediff(:, 2*i-1), 'binwidth', 2, 'facecolor', cmap(j, :), 'facealpha', 0.3, 'normalization', 'probability');
   j = j-1;
end
xlabel('Slip rate difference (mm/yr)', 'fontsize', 12)
ylabel('Frequency', 'fontsize', 12)
axis tight