function OrderedSegmentsGmt(direc, outfile)
% ORDEREDSEGMENTSGMT(DIREC, OUTFILE) writes the ordered segments contained in
%   DIREC/Block.coords to OUTFILE, which can be plotted using GMT's PSXY -M 
%   command.
% 

% load coordinates
b = ReadBlockCoords(direc);

% Write to file
fid = fopen(outfile, 'w');
for i = 1:size(b, 1)
   fprintf(fid, '>\n');
   fprintf(fid, '%d %d\n', b{i}');
end
fclose(fid);