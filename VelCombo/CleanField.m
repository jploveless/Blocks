function [keepIdx, deleteIdx] = CleanField(filename, sigCutoff, velCutoff, offsetVel, outlierRange, closeRange, sigMult, useTogs, nowritesta, nomakefig)
% Good defaults:
% sigCutoff                      = 2.0; % mm/yr
% velCutoff                      = 200.0; % mm/yr
% offsetVel                      = 5.0; % mm/yr
% outlierRange                   = 20; % km
% closeRange                     = 0.5; % km
% sigMult                        = 5
% useTogs                        = 0 % 0 to ignore already toggled-off stations, 1 to consider them

togf = fopen([filename(1:end-9) '.tog'], 'w');
fprintf(togf, 'Toggle file created using command: CleanField(\''%s\'', %d, %d, %d, %d, %d, %d, %d);\n', filename, sigCutoff, velCutoff, offsetVel, outlierRange, closeRange, sigMult, useTogs);

if ischar(filename)
   S                              = ReadStadataStruct(filename);
elseif isstruct(filename)
   if isfield(filename, 'eastVel')
      S = fieldname;
      nowritesta = 1;
   end
end

refIdx                         = 1:1:numel(S.lon);

% Find zero toggles
togIdx                         = find(S.tog == 0);
for i = 1:length(togIdx)
   fprintf(togf, '%s 0 Already toggled off\n', S.name(togIdx(i), :));
end
% 
tIdx = refIdx;
if useTogs == 0
   tIdx(togIdx) = [];     
end

% Find any NaN data
enan = find(isnan(S.lon));
nnan = find(isnan(S.lat));
evnan = find(isnan(S.eastVel));
nvnan = find(isnan(S.northVel));
esnan = find(isnan(S.eastSig));
nsnan = find(isnan(S.northSig));
nanIdx = unique([enan; nnan; evnan; nvnan; esnan; nsnan]);
for i = 1:length(nanIdx)
   fprintf(togf, '%s 0 NaN data\n', S.name(nanIdx(i), :));
end

% samenameIdx = [];
% % Find duplicate stations names (1st 4 characters only)
% for i = 1:length(S.eastVel)
%    sn = strmatch(S.name(i, 1:4), S.name(:, 1:4));
%    if ~isempty(setdiff(sn, i))
%       umag = mag([S.eastSig(sn(:)) S.northSig(sn(:))], 2);
%       [~, minu] = min(umag);
%       sn(minu) = [];
%       samenameIdx = [samenameIdx; sn(:)];
%    end
% end

% Find large uncertainties
eastSigIdx                     = find(S.eastSig>sigCutoff);
for i = 1:length(eastSigIdx)
   fprintf(togf, '%s 0 Large east uncertainty\n', S.name(eastSigIdx(i), :));
end
northSigIdx                    = find(S.northSig>sigCutoff);
for i = 1:length(northSigIdx)
   fprintf(togf, '%s 0 Large north uncertainty\n', S.name(northSigIdx(i), :));
end
% Update running list of toggles
togIdx = unique([togIdx(:); eastSigIdx(:); northSigIdx(:)]);

% Find very large velocities
eastLargeIdx                   = find(abs(S.eastVel)>velCutoff);
for i = 1:length(eastLargeIdx)
   fprintf(togf, '%s 0 Large east vel.\n', S.name(eastLargeIdx(i), :));
end
northLargeIdx                  = find(abs(S.northVel)>velCutoff);
for i = 1:length(northLargeIdx)
   fprintf(togf, '%s 0 Large north vel.\n', S.name(northLargeIdx(i), :));
end
togIdx = unique([togIdx(:); eastLargeIdx(:); northLargeIdx(:)]);

% Find _EDM and _VLB
edmIdx                         = strmatch('_EDM', S.name);
for i = 1:length(edmIdx)
   fprintf(togf, '%s 0 EDM site\n', S.name(edmIdx(i), :));
end
vlbIdx                         = strmatch('_VLB', S.name);
for i = 1:length(vlbIdx)
   fprintf(togf, '%s 0 VLB site\n', S.name(vlbIdx(i), :));
end
%pboIdx                         = strmatch('_PBO', S.name(:,5:8));


% Find colocated stations and if there is more than toggle off the high
% uncertainties (Exact positions only)
colocateIdx                    = [];
for i = 1:numel(S.lon)
   lonMatch                    = find(S.lon == S.lon(i));
   latMatch                    = find(S.lat == S.lat(i));
   locMatch                    = intersect(lonMatch, latMatch);
   locMatch                    = intersect(locMatch, tIdx);
   if numel(locMatch)>1
      eastSig                  = S.eastSig(locMatch);
      northSig                 = S.northSig(locMatch);
      sigMag                   = eastSig.^2 + northSig.^2;
      [minval minidx]          = min(sigMag);
      clbadIdx                 = setdiff(locMatch, locMatch(minidx));
      colocateIdx              = [colocateIdx ; clbadIdx];
   end
end
colocateIdx                    = unique(colocateIdx);
for i = 1:length(colocateIdx)
   fprintf(togf, '%s 0 Collocated station\n', S.name(colocateIdx(i), :));
end
togIdx = unique([togIdx(:); colocateIdx(:)]);

% Find very close stations and if there is more than toggle off the higher
% uncertainty
rangeIdx                       = [];
for i = 1:numel(S.lon)
   % Find stations within NNN km
   [RNG, AZ]                   = distance(S.lat(i), S.lon(i), S.lat, S.lon, [6371 0]);
   nearIdx                     = [i; find(RNG <= closeRange & RNG > 0)];
   nearIdx                     = intersect(nearIdx, tIdx);
   if numel(nearIdx) >= 2
      eastSig                  = S.eastSig(nearIdx);
      northSig                 = S.northSig(nearIdx);
      sigMag                   = eastSig.^2 + northSig.^2;
      [minval minidx]          = min(sigMag);
      clbadIdx                 = nearIdx(setdiff(nearIdx > i, nearIdx(minidx)));      
      rangeIdx                 = [rangeIdx ;clbadIdx];
   end
end
rangeIdx                       = unique(rangeIdx);
for i = 1:length(rangeIdx)
   fprintf(togf, '%s 0 Nearby station\n', S.name(rangeIdx(i), :));
end
togIdx = unique([togIdx(:); rangeIdx(:)]);

% Look at stations with NNN km.  Find the average of these and see if there
% any outliers
outlierIdx                     = [];
for i = 1:numel(S.lon)
   % Find stations within NNN km
   [RNG, AZ]                   = distance(S.lat(i), S.lon(i), S.lat(:), S.lon(:), [6371 0]);
   nearIdx                     = find(RNG <= outlierRange);
   nearIdx                     = intersect(nearIdx, tIdx);
   nearIdx                     = setdiff(nearIdx, togIdx); % Remove from consideration any of the stations that have been flagged for toggling off in the previous analyses
   if numel(nearIdx) > 2 % say we need 3 stations to bother
      meanEast                 = median(S.eastVel(nearIdx));
      meanNorth                = median(S.northVel(nearIdx));
      meanSigE                 = mean(S.eastSig(nearIdx));
      meanSigN                 = mean(S.northSig(nearIdx));
      if sigMult ~= 0
         outliers              = union(nearIdx(abs(S.eastVel(nearIdx) - meanEast) > sigMult*meanSigE), nearIdx(abs(S.northVel(nearIdx) - meanNorth) > sigMult*meanSigN));
      else
         outliers              = union(nearIdx(abs(S.eastVel(nearIdx) - meanEast) > offsetVel), nearIdx(abs(S.northVel(nearIdx) - meanNorth) > offsetVel));
      end 
      outlierIdx               = [outlierIdx; outliers(:)];
%      eastHighIdx              = find(S.eastVel(nearIdx) > meanEast+offsetVel);
%      eastLowIdx               = find(S.eastVel(nearIdx) < meanEast-offsetVel);
%      northHighIdx             = find(S.northVel(nearIdx) > meanNorth+offsetVel);
%      northLowIdx              = find(S.northVel(nearIdx) < meanNorth-offsetVel);   
%      outlierIdx               = [outlierIdx ; nearIdx([eastHighIdx(:) ; eastLowIdx(:) ; northHighIdx(:) ; northLowIdx(:)])];
   end
end
outlierIdx                     = unique(outlierIdx);
for i = 1:length(outlierIdx)
   fprintf(togf, '%s 0 Local outlier\n', S.name(outlierIdx(i), :));
end
togIdx = unique([togIdx(:); outlierIdx(:)]);

% Calculate the keeper idx
%deleteIdx                      = unique([togIdx(:) ; samenameIdx(:) ; eastSigIdx(:) ; northSigIdx(:) ; eastLargeIdx(:) ; northLargeIdx(:) ; edmIdx(:) ; vlbIdx(:) ; colocateIdx(:) ; rangeIdx(:) ; outlierIdx(:)]);
deleteIdx                      = unique([togIdx(:) ; nanIdx(:) ; eastSigIdx(:) ; northSigIdx(:) ; eastLargeIdx(:) ; northLargeIdx(:) ; edmIdx(:) ; vlbIdx(:) ; colocateIdx(:) ; rangeIdx(:) ; outlierIdx(:)]);
keepIdx                        = setdiff(tIdx, deleteIdx);

if ~exist('nowritesta', 'var') || (exist('nowritesta', 'var') && nowritesta == 0)

% Write station file without toggled off stations
WriteStation([filename(1:end-9) '_Clean.sta.data'], S.lon(keepIdx), S.lat(keepIdx), S.eastVel(keepIdx), S.northVel(keepIdx), S.eastSig(keepIdx), S.northSig(keepIdx), S.corr(keepIdx), S.other1(keepIdx), S.tog(keepIdx), S.name(keepIdx, :));

% Write station file without toggled off stations and all uncertainties equal to unity
WriteStation([filename(1:end-9) '_Clean1Sig.sta.data'], S.lon(keepIdx), S.lat(keepIdx), S.eastVel(keepIdx), S.northVel(keepIdx), ones(size(keepIdx)), ones(size(keepIdx)), S.corr(keepIdx), S.other1(keepIdx), S.tog(keepIdx), S.name(keepIdx, :));

% Write station file with dirty stations toggled off and clean stations toggled on
newTog                         = ones(size(refIdx));
newTog(deleteIdx)              = 0;
WriteStation([filename(1:end-9) '_CleanAll.sta.data'], S.lon, S.lat, S.eastVel, S.northVel, S.eastSig, S.northSig, S.corr, S.other1, newTog, S.name);

% Write station file with dirty stations toggled off and clean stations toggled on and uncertainties equal to unity
% newTog                         = ones(size(refIdx));
% newTog(deleteIdx)              = 0;
WriteStation([filename(1:end-9) '_CleanAll1Sig.sta.data'], S.lon, S.lat, S.eastVel, S.northVel, ones(size(S.eastSig)), ones(size(S.northSig)), S.corr, S.other1, newTog, S.name);

end

% Make a plot showing the flagged stations
if ~exist('nomakefig', 'var') || (exist('nomakefig', 'var') && nomakefig == 0)
   figure
   sta = plot(S.lon(tIdx), S.lat(tIdx), '.k'); hold on;
   es = plot(S.lon(eastSigIdx), S.lat(eastSigIdx), '.r');
   ns = plot(S.lon(northSigIdx), S.lat(northSigIdx), '.m');
   el = plot(S.lon(eastLargeIdx), S.lat(eastLargeIdx), '.g');
   nl = plot(S.lon(northLargeIdx), S.lat(northLargeIdx), 'ob');
   co = plot(S.lon(colocateIdx), S.lat(colocateIdx), '.c');
   nr = plot(S.lon(rangeIdx), S.lat(rangeIdx), 'xb');
   ol = plot(S.lon(outlierIdx), S.lat(outlierIdx), 'or');
   legend([sta, es, ns, el, nl, co, nr, ol], {'Stations', 'E Sig.', 'N Sig.', 'E Lg.', 'N Lg.', 'Colo.', 'Near', 'Out'});
end