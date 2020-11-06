function Command = GoogleFormCommand(web, out, idx)
% GoogleFormCommand  Writes a .command file from Google Form response.
%    GoogleFormCommand(WEB, OUT) saves the parameters specified in the 
%    final line of WEB, an exported text document from the Google Form Command
%    File Manager to command file OUT.
%
%    GoogleFormCommand(WEB, OUT, IDX) writes the parameters in row IDX of the 
%    exported response spreadsheet.
%
%    C = GoogleFormCommand(WEB, OUT, IDX) returns a command structure based
%    on the parameters.
%

% Open file for reading
fid = fopen(web, 'r');
% Extract all parameters.  This is set up to have any number of columns.
params = textscan(fid, '%s', 'delimiter', '\t');
% Total number of cells extracted
cols = size(params{:}, 1);
% Re-read the file to determine the number of rows
frewind(fid);
rows = textscan(fid, '%s %*[^\n]');
rows = size(rows{:}, 1);
% Determine number of columns
cols = cols./rows;

% Remove timestamp parameters
params{1}(1:cols:end) = [];
cols = cols - 1;

% Extract selected row
if ~exist('idx', 'var')
   idx = rows;
end

sparams = params{1}((idx-1)*cols + (1:cols));

% Write selected parameters along with header lines
ofid = fopen(out, 'w');
for i = 1:cols
   fprintf(ofid, '%s %s\n', char(params{1}(i)), char(sparams{i}));
end
fclose all;