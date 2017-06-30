function WritePatches(filename, c, v, trislipX, trislipY, trislipZ, trislipXSig, trislipYSig, trislipZSig, tristrikes, blockslips, blockslipd, blockslipt);		
%
% WritePatches writes a text file containing patch coordinates, vertex connections, and slip conditions
%

fid = fopen(filename, 'w');
nc = size(c, 1);
ne = size(v, 1);
fprintf(fid, '%d\n', nc); % write number of coordinates
for i = 1:nc;
	fprintf(fid, '%3.3f %3.3f %3.3f\n', c(i, 1), c(i, 2), c(i, 3)); % write coordinates
end
fprintf(fid, '%d\n', ne); % write number of elements
if size(v, 2) == 3
   for i = 1:ne;
	   fprintf(fid, '%d %d %d %3.3f %3.3f %3.3f %3.3f %3.3f %3.3f %3.3f %3.3f %3.3f %3.3f\n', v(i, 1), v(i, 2), v(i, 3), trislipX(i), trislipY(i), trislipZ(i), trislipXSig(i), trislipYSig(i), trislipZSig(i), rad2deg(tristrikes(i)), blockslips(i), blockslipd(i), blockslipt(i));
   end
elseif size(v, 2) == 4
   for i = 1:ne;
	   fprintf(fid, '%d %d %d %d %3.3f %3.3f %3.3f %3.3f %3.3f %3.3f %3.3f %3.3f %3.3f %3.3f\n', v(i, 1), v(i, 2), v(i, 3), v(i, 4), trislipX(i), trislipY(i), trislipZ(i), trislipXSig(i), trislipYSig(i), trislipZSig(i), rad2deg(tristrikes(i)), blockslips(i), blockslipd(i), blockslipt(i));
   end
end
fclose(fid);