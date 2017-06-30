function WriteAllVelsGmt(direc, outdir, scale, varargin)
%
%
%

% Do we need to add a filesep to the end of the directory name?
if direc(end) ~= filesep
   direc = [direc filesep];
end

% Get the real name of the file (in the case of a "../" or "./")
a = pwd;
cd(direc);
realdirec = pwd; 
cd(a);

% Get the .sta.data files
a = dir([direc '*.sta.data']);

% Determine whether a name or index of the scaling file was specified
if ischar(scale)
   scale = strmatch(scale, char(a.name));
end

% Determine the files that should not be scaled
if nargin > 3
   noscale = char(varargin{1}); % Files should not be scaled
else 
   noscale = [];
end

nsidx = zeros(size(noscale, 1), 1);
% Determine indices of non-scaled files
if ~isnumeric(noscale)
   for i = 1:size(noscale, 1)
      nsidx(i) = strmatch(strtrim(noscale(i, :)), char(a.name));
   end
end
   
% Define the orders in which the files will be processed
nsorder = [scale; nsidx];
sorder = [setdiff(1:numel(a)', nsorder)];

% Write the non-scaled files
for i = 1:numel(nsorder)
   indot = findstr('.', a(nsorder(i)).name);
   outname = sprintf('%s%s%g%s%s', outdir, filesep, str2num(realdirec(end-9:end)), lower(a(nsorder(i)).name(1:indot(1)-1)), '.xy');
   out = ColorVelVecGmt(a(nsorder(i)).name, outname);
   mxmg(i) = max(out(:, 3)); % Write the max. length and save for later scaling
end

% Write the scaled files
for i = 1:numel(sorder)
   indot = findstr('.', a(sorder(i)).name);
   outname = sprintf('%s%s%g%s%s', outdir, filesep, str2num(realdirec(end-9:end)), lower(a(sorder(i)).name(1:indot(1)-1)), '.xy');
   out = ColorVelVecGmt(a(sorder(i)).name, outname, mxmg(1)); % Scaling by the selected file's max. length 
end
