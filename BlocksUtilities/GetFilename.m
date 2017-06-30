function filenameFull = GetFilename(hEditbox, fileType, filter, selectionFilter)
% GetFilename
%
%    filenameFull = GetFilename(hEditbox, fileType, filter)
%
% This function gets a user-specified filename
%
% Inputs:
%   hEditbox : Handle of the GUI editbox that holds the filename
%   fileType : String containing the file type (e.g.: 'Segments')
%   filter   : String containing the file filter (e.g., '*.segment; *.segment.xml')
%   selectionFilter: String used for the selection of the default filename (default: filter) (e.g.: '*.segment*')
%
% Outputs:
%   filenameFull : full filename path of the user-selected file

    filename = get(hEditbox, 'string');
    if exist(filename, 'file')
        filenameFull = which(filename);  %=fullfile(pwd, filename);
        if isempty(filenameFull)
            filenameFull = filename;
        end
    else
        dirname = fileparts(filename);
        if isempty(dirname)
            try
                dirname = getpref('Blocks',[fileType 'Dir']);
            catch
                dirname = pwd;
            end
        end
        initialName = dirname;
        if nargin < 4
            d = dir([dirname '\' filter]);
        else
            d = dir([dirname '\' selectionFilter]);
        end
        if ~isempty(d)
            initialName = fullfile(dirname, d(1).name);
        end
        [filename, pathname] = uigetfile({filter, fileType}, ['Load ' lower(fileType) ' file'], initialName);
        if filename == 0
            set(hEditbox, 'string', '');
            filenameFull = '';
            return;
        else
            filenameFull = fullfile(pathname, filename);
            set(hEditbox, 'string', filenameFull);  % filename);
            setpref('Blocks',[fileType 'Dir'],pathname);
        end
    end
end
