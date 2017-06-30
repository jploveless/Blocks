function ToggleControl(staFileName, togFileName)

% Load staFile
S                           = ReadStadataStruct(staFileName);

% Load .tog file
fid = fopen(togFileName);
c = textscan(fid, '%s %f %s %s %s %s %s %s %s %s\n', 'headerlines', 1);
fclose(fid);

% Find toggle locations, need to use a for loop in case some stations are duplicates
for i = 1:length(c{1})
   loc = strmatch(strtrim(c{1}(i)), S.name);
   if ~isempty(loc)
      S.tog(loc) = c{2}(i);
   end
end

% Write new .sta.data file
WriteStation([staFileName(1:end-9) '_Tog.sta.data'], S.lon, S.lat, S.eastVel, S.northVel, S.eastSig, S.northSig, S.corr, S.other1, S.tog, S.name);
