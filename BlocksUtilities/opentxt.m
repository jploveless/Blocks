function in = opentxt(infile);
%
% IN = OPENTXT(INFILE) returns a character array IN by reading the text file
% INFILE.
%

fid1 = fopen(infile); frewind(fid1);

in = textscan(fid1, '%s', 'delimiter', '\n', 'whitespace', '');
in = in{1};
in = char(in);
szin = size(in);

fclose(fid1);