function AlignAllFields6Param(direc, target, method, varargin)
%
% ALIGNALLFIELDS automates the alignment of an arbitrary number of velocity fields.
%
%  ALIGNALLFIELDS(DIR, TARGET, METHOD) finds all .sta.data files within the directory
%  DIR and rotates them to the reference frame of field TARGET using the specified
%  connectivity METHOD.  
%
%  TARGET can either be a number identifying which of the .sta.data files in DIR should
%  be used as the common reference frame, or it can be the actual file name.  
%
%  METHOD = 1 determines the connectivity path between all fields and the target field
%  by using the number of collocated stations in the fields, while METHOD = 2 determines
%  the connectivity path using the mean residuals of the vectors of each field rotated 
%  into the reference frame of all other fields.
% 
%  All velocity fields will be rotated into the reference frame of TARGET, and for each
%  file, a new file, named (file)_in_(target)_RF.sta.data will be created and placed into
%  a new directory within DIREC.  Additionally, a concatenated file will be created, 
%  containing all velocities in the common reference frame, with the velocities at the
%  collocated stations averaged.  This files is named All_in_(target)_RF.sta.data and is
%  also placed in the new run directory.
%
%  ALIGNALLFIELDS(DIR, METHOD, TARGET, PARAM) allows specification of the type of 
%  alignment that should be performed.  PARAM should be 3 or 6 specifying a 
%  3 (rotation only) or 6 (rotation plus translation) parameter estimation.  The 
%  default is 3.
%
%  ALIGNALLFIELDS(DIR, METHOD, TARGET, PARAM, FUZZ) accepts an optional argument FUZZ 
%  that specifies how close two stations have to be to be considered collocated.  FUZZ
%  should be given in degrees.  The default value is 0.005.
%
%  ALIGNALLFIELDS(DIR, METHOD, TARGET, FUZZ, MINSTA) also accepts an argument that
%  specifies the minimum number of stations required to be aligned.  The default
%  value is 10.  
%

% parse optional inputs
if nargin >= 4
   nparam = varargin{1};
else
   nparam = 3;
end

if nargin >= 5
   fuzz = varargin{2};
else
   fuzz = 0.005;
end

if nargin == 6
   minsta = varargin{3};
else
   minsta = 10;
end

% add trailing slash to directory name, if necessary
if direc(end) ~= '/';
   direc = [direc '/'];
end

% create output file directory
runName                             = GetRunName(direc);
mkdir([direc runName])


% find all .sta or .sta.data files in specified directory
dirdata                             = dir([direc '*.sta.data']);
nfiles                              = numel(dirdata);
nOverlap                            = zeros(nfiles);
nOverlapi                           = zeros(nfiles);
meanRes                             = zeros(nfiles);
nStations                           = zeros(nfiles, 1);
sumnStations                        = zeros(nfiles+1, 1);
G                                   = cell(nfiles,1);
omegaEst                            = cell(nfiles);
comInd                              = cell(nfiles);
comIndUnique                        = cell(nfiles);

for i = 1:nfiles
   % Count number of stations in current file
   file1                            = [direc dirdata(i).name];
   S1                               = ReadStation(file1);
   nStations(i)                     = numel(S1.lon);
   sumnStations(i+1)                = sumnStations(i) + nStations(i);
   names{i}                         = sprintf('%s', dirdata(i).name(1:end-9));
   % convert target field specification to index, if necessary
   if ischar(target) == 1
      if numel(findstr(names{i},target)) > 0;
         target = i;
      end
   end
   ids{i}                           = sprintf('%s (%d)', names{i}, nStations(i));
   combined                         = i;
   temp_old                         = names{i};
   
   % Calculate the matrix of partials for each velocity field
   G{i}                                = zeros(3*nStations(i), 6);
   for k = 1:nStations(i)
      rowIdx                        = (k-1)*3+1;
      colIdx                        = 1;
      [x y z]                       = sph2cart(deg2rad(S1.lon(k)), deg2rad(S1.lat(k)), 6371e6);
      R                             = GetCrossPartials([x y z]);
      [vn_wx ve_wx vu_wx]           = CartVecToSphVec(R(1,1), R(2,1), R(3,1), S1.lon(k), S1.lat(k));
      [vn_wy ve_wy vu_wy]           = CartVecToSphVec(R(1,2), R(2,2), R(3,2), S1.lon(k), S1.lat(k));
      [vn_wz ve_wz vu_wz]           = CartVecToSphVec(R(1,3), R(2,3), R(3,3), S1.lon(k), S1.lat(k));
      R                             = [ve_wx ve_wy ve_wz ; vn_wx vn_wy vn_wz ; vu_wx vu_wy vu_wz];
      G{i}(rowIdx:rowIdx+2,colIdx:colIdx+5) = [R eye(3)];
   end
   G{i}(3:3:end, :)                 = [];
   G{i}(:, 6)                       = [];
   
   % Loop over possible combinations
   for j = i+1:nfiles
      file2                         = [direc dirdata(j).name];
      names{j}                      = sprintf('%s', dirdata(j).name(1:end-9));
      S1                            = ReadStation(file1);
      S2                            = ReadStation(file2);
      sumnStations(j+1)             = sumnStations(j) + numel(S2.lon);

      % Find collocated station 
      lon1                          = [];
      lat1                          = [];
      
      f = 1;
      comInd1                       = [];
      comInd2                       = [];
      comIndU                       = [];
      for ii = 1:numel(S1.lon)
         for jj = 1:numel(S2.lon)
            dlon                    = S1.lon(ii)-S2.lon(jj);
            dlat                    = S1.lat(ii)-S2.lat(jj);
            if (abs(dlon) < fuzz) && (abs(dlat) < fuzz)
               lon1                 = [lon1 S1.lon(ii)];
               lat1                 = [lat1 S1.lat(ii)];
               comInd1(f)           = ii + sumnStations(i);
               comInd2(f)           = jj + sumnStations(j);
               f                    = f + 1;
            end
         end
      end
      nComSta                       = numel(lon1);
      nOverlap(i, j)                = nComSta;
      nOverlap(j, i)                = nComSta;
      comInd{i, j}                  = comInd1;
      comInd{j, i}                  = comInd2;
      
      % Align all velocity fields if possible and if required for final alignment:
      if nComSta >= minsta
         %disp(sprintf('Aligning %s and %s...', file1, file2));
         if nparam == 6
            [wmean,nComSta,...
             G{j},omegaEst{i, j}]   = AlignVelFieldsQuiet6Param(file1, file2, fuzz);
         else
            [wmean,nComSta,...
             G{j},omegaEst{i, j}]   = AlignVelFieldsQuiet(file1, file2, fuzz);
         end
         omegaEst{j, i}             = omegaEst{i, j};
         meanRes(i, j)              = wmean;
         meanRes(j, i)              = wmean;
      else
         comInd{i, j}               = [];
         comInd{j, i}               = [];
      end
   end
end

% Show overlap (old BJM code)
for i = 1:nfiles
   names{i}                         = sprintf('%s', dirdata(i).name(1:end-9));
   ids{i}                           = sprintf('%s (%d)', names{i}, nStations(i));
end
bg                                  = biograph(triu(nOverlap), ids);
set(bg, 'ShowArrows', 'off');
set(bg, 'ShowWeights', 'on');
h                                   = view(bg);
set(h.Nodes, 'Color', 0.85.*[1 1 1]);
set(h.Nodes, 'FontSize', 18);
set(h.Nodes, 'Shape', 'box');
set(h.Edges, 'LineColor', [0 0 0]);
set(h.Edges, 'LineWidth', 1);
set(h, 'EdgeFontSize', 18)

% Show overlap (old BJM code)
for i = 1:nfiles
   names{i}                         = sprintf('%s', dirdata(i).name(1:end-9));
   ids{i}                           = sprintf('%s (%d)', names{i}, nStations(i));
end
bg                                  = biograph(triu(meanRes), ids);
set(bg, 'ShowArrows', 'off');
set(bg, 'ShowWeights', 'on');
h                                   = view(bg);
set(h.Nodes, 'Color', 0.85.*[1 1 1]);
set(h.Nodes, 'FontSize', 18);
set(h.Nodes, 'Shape', 'box');
set(h.Edges, 'LineColor', [0 0 0]);
set(h.Edges, 'LineWidth', 1);
set(h, 'EdgeFontSize', 18)


% determine shortest path connecting all fields to the target field
if method == 1; % method is specified as using the number of common stations
   nOverlapi(find(nOverlap>0))      = 1./nOverlap(find(nOverlap>0));
   [dist, paths, pred]              = graphshortestpath(sparse(nOverlapi), target);   
else            % method is specifed as using the mean residuals between the aligned fields
   [dist, paths, pred]              = graphshortestpath(sparse(meanRes), target);
end

% define array with indices of all fields needing rotation, i.e. all except the target
toRotate                            = setdiff(1:nfiles,target);

% carry out all rotations

for rots = 1:nfiles-1; 
   i                                = toRotate(rots); % define the index
   omega                            = zeros(5, 1);
   RR                               = G{i};  
   for j = 1:numel(paths{i})-1;
      omega                         = omega + omegaEst{paths{i}(j), paths{i}(j+1)};
   end
   % Read velocity field
   s                                = ReadStation([direc dirdata(i).name]);
   
   % Assemble velocity vector
   d                                = zeros(size(RR,1), 1);
   d(1:2:end)                       = s.eastVel;
   d(2:2:end)                       = s.northVel;
   
   % Do composite transformation and extract new velocities
   dNew                             = d + RR*omega;
   evNew                            = dNew(1:2:end);
   nvNew                            = dNew(2:2:end);
   
   % Create new file name and write file
   outfile                          = sprintf('%s%s/%s_in_%s_RF.sta.data', direc, runName, dirdata(i).name(1:end-9), dirdata(target).name(1:end-9));
   WriteStation(outfile, s.lon, s.lat, evNew, nvNew, s.eastSig, s.northSig, s.corr, zeros(size(s.lon)), s.tog, s.name);
end

% load all stations, combine into a huge array, average collocated velocities, and plot
alls                                = dir([direc runName '/*in_*RF*.sta.data']);
% concatenate all stations into a common file
targName                            = [direc names{target} '.sta.data '];
bigName                             = [];
for i = 1:nfiles;
   if i ~= target
      j                             = find(toRotate == i);
      bigName                       = sprintf('%s%s%s/%s ', bigName, direc, runName, alls(j).name);
   else
      bigName                       = sprintf('%s%s', bigName, targName);
   end
end
system(sprintf('cat %s > %s%s/temp.sta.data', bigName, direc, runName));

% Read the file
s                                   = ReadStation(sprintf('%s%s/temp.sta.data',direc,runName));
system(sprintf('rm %s%s/temp.sta.data', direc, runName));

% Find the common stations
pairs                               = [];
for i = 1:nfiles;
   for j = i+1:nfiles;
      % array pairs is an n x 2 array, each column containing the index of 
      % a collocated station in each field
      pairs                         = [pairs; comInd{i, j}(:) comInd{j, i}(:)];
   end
end

% sort pairings rows
sp                                  = sortrows(pairs);
% find unique values and count how many recurrences
[up, r1]                            = unique(sp(:,1), 'first');
[up, r2]                            = unique(sp(:,1), 'last');
counts                              = r2-r1+2;
%repstaInd                       = []; % make array of the repeated station indices
% Average velocities amongst all collocated stations and propagate errors
for i = 1:length(up);
   s.eastVel([up(i); ...
              sp(r1(i):r2(i), 2)])  = sum(s.eastVel([up(i); sp(r1(i):r2(i), 2)]))/counts(i);
   s.northVel([up(i); ...
               sp(r1(i):r2(i), 2)]) = sum(s.northVel([up(i); sp(r1(i):r2(i), 2)]))/counts(i);
   s.eastSig([up(i); ...
              sp(r1(i):r2(i), 2)])  = sqrt(sum(s.eastSig([up(i); sp(r1(i):r2(i), 2)])))/counts(i);
   s.northSig([up(i); ...
               sp(r1(i):r2(i), 2)]) = sqrt(sum(s.northSig([up(i); sp(r1(i):r2(i), 2)])))/counts(i);
end

% Make a plot
% Get geographic extents
%mnla                                = nfix(min(s.lat), 5);
%mnlo                                = nfix(min(s.lon), 5);
%mxla                                = nceil(max(s.lat), 5);
%mxlo                                = nceil(max(s.lon), 5);
%
%% set up the map
%figure;
%m_proj('Miller Cylindrical', 'lat', [mnla mxla], 'lon', [mnlo mxlo]);
%m_coast('patch', [.9 .9 .9], 'edgecolor', 'k'); hold on;
%m_grid('tickdir', 'out', 'yaxislocation', 'right', 'xaxislocation','bottom','xlabeldir','end','ticklen',.02, 'linestyle', 'none');
%% make colormap
%colb                                = jet(nfiles);
%% plot the vectors in unique colors to identify parent field
%for i = 1:nfiles;
%   ht(i)                            = m_vec(400, s.lon(sumnStations(i)+1:sumnStations(i+1)), s.lat(sumnStations(i)+1:sumnStations(i+1)), s.eastVel(sumnStations(i)+1:sumnStations(i+1)), s.northVel(sumnStations(i)+1:sumnStations(i+1)), colb(i,:), 'headlength', 3, 'shaftwidth', 0.5);
%end
%legend(ht, names)

% Write final file
filename                            = sprintf('%s%s%sAll_in_%s_RF.sta.data', direc, runName, filesep, dirdata(target).name(1:end-9));
WriteStation(filename, s.lon, s.lat, s.eastVel, s.northVel, s.eastSig, s.northSig, s.corr, zeros(size(s.lon)), s.tog, s.name);

% Save a few variables to a .mat file
matname                       = sprintf('%s.mat', filename(1:end-9));
save(matname, 'names', 'sumnStations', 'paths', '-mat');

save(sprintf('%s_allvariables.mat', filename(1:end-9)));
