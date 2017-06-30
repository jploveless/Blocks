function CheckScecDates(filename)

S = ReadStadataStruct(filename);
data = char(textread('timelist.gps.txt', '%s', 'delimiter', '\n'));
N = numel(S.lon);
date

rangeLanders         = 60;
lonLanders           = 243.53;
latLanders           = 34.22;
timeLanders          = 1992;

rangeNorthridge      = 60;
lonNorthridge        = 241.47;
latNorthridge        = 34.20;
timeNorthridge       = 1994;

rangeHector          = 60;
lonHector            = 243.75;
latHector            = 34.55;
timeHector           = 1999;

% Calculate Landers case
for i = 1:N
   matchIdx = strmatch(S.name(i,:), data);
   if ~isempty(matchIdx)
      dates = str2num(data(matchIdx, 9:17));
      rng                   = distance(latLanders, lonLanders, S.lat(i), S.lon(i), [6371 0]);
      if (min(dates) <= timeLanders+3) && (rng <= rangeLanders)
         fprintf(1, '%s 0 Landers filter\n', S.name(i, :));
      end
   end
end

% Calculate Northridge case
for i = 1:N
   matchIdx = strmatch(S.name(i,:), data);
   if ~isempty(matchIdx)
      dates = str2num(data(matchIdx, 9:17));
      rng                   = distance(latNorthridge, lonNorthridge, S.lat(i), S.lon(i), [6371 0]);
      if (min(dates) <= timeNorthridge) && (rng <= rangeNorthridge)
         fprintf(1, '%s 0 Northridge filter\n', S.name(i, :));
      end
   end
end

% Calculate Hector Mine case
for i = 1:N
   matchIdx = strmatch(S.name(i,:), data);
   if ~isempty(matchIdx)
      dates = str2num(data(matchIdx, 9:17));
      rng                   = distance(latHector, lonHector, S.lat(i), S.lon(i), [6371 0]);
      if (min(dates) <= timeHector) && (rng <= rangeHector)
         fprintf(1, '%s 0 Hector filter\n', S.name(i, :));
      end
   end
end
