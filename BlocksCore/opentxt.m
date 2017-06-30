function in = opentxt(infile, hl);
%
% IN = OPENTXT(INFILE) returns a character array IN by reading the text file
% INFILE.
%

if ~exist('hl', 'var')
   hl = 0;
end

fid1        = fopen(infile); frewind(fid1);

in          = textscan(fid1, '%s', 'delimiter', '\n', 'whitespace', '', 'headerlines', hl);
in          = in{1};
in          = char(in);
szin        = size(in);

fclose(fid1);