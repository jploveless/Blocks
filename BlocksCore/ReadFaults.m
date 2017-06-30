function F = ReadFaults(faultfile)
% F = ReadFaults(faultfile) extracts fault coordinates from faultfile.

% Read the faults from Coulomb compilation
datastream           = char(textread(faultfile, '%s', 'delimiter', '\n'));

% Find the indices of all of the breaks
breakIdx             = strmatch('>', datastream);

% Loop over each index and store in a vector of structures
for i = 1:numel(breakIdx)-2
   data              = str2num(datastream(breakIdx(i)+1:breakIdx(i+1)-1,:));
   F(i).lon          = data(:,1) + 360;
   F(i).lat          = data(:,2);
end
   