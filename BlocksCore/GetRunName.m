function runName = GetRunName(varargin)
% This function returns a string with the name of the new run directory

if nargin ~= 0;
	direc = varargin{1};
else
	direc = pwd;
end

dirContents      = dir(direc);
nFiles           = numel(dirContents);
dirNames         = [];
for iFile = 1:nFiles
   if dirContents(iFile).isdir==1
      dirNames   = strvcat(dirNames, dirContents(iFile).name);
   end
end

nDir             = size(dirNames, 1);
dirVals          = [];
for iDir = 1:nDir
   localName     = deblank(dirNames(iDir,:));
   if (numel(localName)==10) && ~isempty(str2num(localName))
      dirVals    = [dirVals str2num(localName)];
   end
end

if isempty(dirVals)
   runName       = '0000000001';
else
   runName       = sprintf('%010.0f', max(dirVals)+1);
end

runName = [runName filesep];