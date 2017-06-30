function pnc2cpt(cvec, range, file)
%
% PNC2CPT writes a GMT .cpt file using a Matlab positive-negative colormap.  
% Helpful for setting explicit colors for given values.
%
%   CVEC2CPT(CVEC, RANGE, CPT) converts the n-by-3 colormap CVEC, defined
%   over the interval RANGE (a 2-element vector) to the file CPT.
%

vals = linspace(range(1), range(2), size(cvec, 1));
cvec = round(255*cvec);

fid = fopen(file, 'w');
fprintf(fid, '# GMT .cpt file written with CVEC2CPT.m.\n#COLOR_MODEL = RGB\n#\n');

for i = 1:size(cvec, 1)-1
   fprintf(fid, '%d %d %d %d %d %d %d %d\n', vals(i), cvec(i, 1), cvec(i, 2), cvec(i, 3), vals(i+1), cvec(i+1, 1), cvec(i+1, 2), cvec(i+1, 3));
end

fprintf(fid, 'B %d %d %d\n', cvec(1, 1), cvec(1, 2), cvec(1, 3));
fprintf(fid, 'F %d %d %d\n', cvec(end, 1), cvec(end, 2), cvec(end, 3));
[mv, neut] = min(abs(vals));
fprintf(fid, 'N %d %d %d\n', cvec(neut, 1), cvec(neut, 2), cvec(neut, 3));

fclose(fid);