function svdtrunccrawler(direc)
% SVDTRUNCCRAWLER  Crawls results directories to extract data.
%   SVDTRUNCCRAWLER(DIREC) reads the Mod.segment, ModelStruct.mat, and 
%   Res.sta.data files from each results directory within DIREC 
%

% Read number of results directories
resd = dir([direc filesep '000*']);
ndir = numel(resd);

s = ReadSegmentTri([direc filesep newdir 'Mod.segment']);
nseg = length(s.lon1);

% Set up the slip rate master structure...
[s.ssRate, s.dsRate, s.tsRate, s.ssRateSig, s.dsRateSig, s.tsRateSig] = deal(NaN(nseg, ndir));
% ...and the master rotation vector...
rv = zeros(ndir);
% ...and the residual field
res = ReadStation([direc filesep newdir 'Res.sta.data']);
nsta = length(res.lon);
[res.eastVel, res.northVel] = deal(NaN(nsta, ndir));

% Crawl directories
for i = 1:ndir
   % Read segments
   seg = ReadSegmentTri([direc filesep resd(i).name filesep 'Mod.segment']);
   s.ssRate(:, i) = seg.ssRate;
   s.dsRate(:, i) = seg.dsRate;
   s.tsRate(:, i) = seg.tsRate;
   s.ssRateSig(:, i) = seg.ssRateSig;
   s.dsRateSig(:, i) = seg.dsRateSig;
   s.tsRateSig(:, i) = seg.tsRateSig;
   % Read model vectors
   load([direc filesep resd(i).name filesep 'ModelStruct.mat']);
   rv(1:3:end, i) = Model.omegaX; 
   rv(2:3:end, i) = Model.omegaY; 
   rv(3:3:end, i) = Model.omegaZ; 
   % Read residual field
   re = ReadStation([direc filesep resd(i).name filesep 'Res.sta.data']);
   res.eastVel(:, i) = re.eastVel;
   res.northVel(:, i) = re.northVel;
end

save([direc filesep 'allslips.mat'], 's')
save([direc filesep 'allrots.mat'], 'rv');
save([direc filesep 'allres.mat'], 'res');