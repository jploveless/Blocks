function ConvertToCsv
% Convert all files with extension in file_type to .csv files
file_types = {'*.sta', '*.sta.data', '*.segment', '*.block'};
for i = 1:numel(file_types)
    ConvertAll(file_types{i});
end

function ConvertAll(file_type)
% Look in current directory for all files of current file_type
dir_data = dir(file_type);
for i = 1:numel(dir_data)
    if strcmp(file_type, '*.sta')
        S = ReadStation(dir_data(i).name);
    elseif strcmp(file_type, '*.sta.data')
        S = ReadStation(dir_data(i).name);        
    elseif strcmp(file_type, '*.segment')
        S = ReadSegmentStruct(dir_data(i).name);
    elseif strcmp(file_type, '*.block')
        S = ReadBlock(dir_data(i).name);
    end

    % Convert to csv
    fprintf(1, 'Converting %s to %s\n', ...
            dir_data(i).name, [dir_data(i).name, '.csv']);
    struct2csv(S, [dir_data(i).name, '.csv']);
end
