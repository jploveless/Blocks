function WriteBlocks(blockfilename, blockname, Ilon, Ilat, Elon, Elonsig, Elat, Elatsig, rrate, rrate_sig, ...
			      rrate_info, ap_tog, block_other1, block_other2, block_other3, block_other4, ...
			      block_other5, block_other6, varargin)

% Open file stream
filestream                          = fopen(blockfilename, 'w');

if nargin == 19
	hl = varargin{:};
	fprintf(filestream, '%s\n', hl{1});
	fprintf(filestream, '%s\n', hl{2});
	fprintf(filestream, '%s\n', hl{3});
	fprintf(filestream, '%s\n', hl{4});
	fprintf(filestream, '%s\n', hl{5});
	fprintf(filestream, '%s\n', hl{6});
	fprintf(filestream, '%s\n', hl{7});
	fprintf(filestream, '%s\n', hl{8});
else
	% Write standard header
	fprintf(filestream, 'Name\n');
	fprintf(filestream, 'interior_long interior_lat\n');
	fprintf(filestream, 'Euler_long Euler_long_sig\n');
	fprintf(filestream, 'Euler_lat  Euler_lat_sig\n');
	fprintf(filestream, 'rotation_rate rotation_rate_sig\n');
	fprintf(filestream, 'strain_calc apriori_toggle\n');
	fprintf(filestream, 'other    other    other\n');
	fprintf(filestream, 'other    other    other\n');
end

% Loop over blocks and write to file
for cnt = 1 : numel(rrate)
   fprintf(filestream, '%s\n', blockname(cnt, :));
   fprintf(filestream, '%3.3f   %3.3f\n', Ilon(cnt), Ilat(cnt));
   fprintf(filestream, '%3.3f   %3.3f\n', Elon(cnt), Elonsig(cnt));
   fprintf(filestream, '%3.3f   %3.3f\n', Elat(cnt), Elatsig(cnt));
   fprintf(filestream, '%3.3f   %3.3f\n', rrate(cnt), rrate_sig(cnt));
   fprintf(filestream, '%3.3f   %d\n', rrate_info(cnt), ap_tog(cnt));
   fprintf(filestream, '%3.3e   %3.3e   %3.3e\n', block_other1(cnt), block_other2(cnt), block_other3(cnt));
   fprintf(filestream, '%3.3e   %3.3e   %3.3e\n', block_other4(cnt), block_other5(cnt), block_other6(cnt));
end
fclose(filestream);
