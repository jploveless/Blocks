function WriteStation(output_file_name, varargin)
% WriteStation(outname, S.lon, S.lat, S.eastVel, S.northVel, S.eastSig, S.northSig, S.corr, S.other1, S.tog, S.name)
%
% This functions writes out station information in .sta.data format
%
% Arugments:
%    output_filename
%    all station data

if nargin == 2
   S = varargin{1};
   [station_lon, station_lat, station_east_vel, station_north_vel, station_east_sig, station_north_sig, station_corr, station_other, station_tog, station_name] = deal(S.lon, S.lat, S.eastVel, S.northVel, S.eastSig, S.northSig, S.corr, S.other1, S.tog, S.name);
else
   [station_lon, station_lat, station_east_vel, station_north_vel, station_east_sig, station_north_sig, station_corr, station_other, station_tog, station_name] = deal(varargin{:});   
end

% Open the file stream
output_file_stream                         = fopen(sprintf('%s', output_file_name), 'w');

% Loop to write out the data
for cnt = 1 : length(station_lon)
   fprintf(output_file_stream, '%3.5f\t%3.5f\t%3.3f\t%3.3f\t%3.3f\t%3.3f\t%3.3f\t%d\t%d\t%s\n', ...
           station_lon(cnt), station_lat(cnt), station_east_vel(cnt), station_north_vel(cnt), station_east_sig(cnt), ...
           station_north_sig(cnt), station_corr(cnt), station_other(cnt), station_tog(cnt), station_name(cnt, :));
end
fclose(output_file_stream);
