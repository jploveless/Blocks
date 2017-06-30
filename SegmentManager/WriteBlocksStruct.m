function WriteBlocksStruct(filename, Block)
% WriteBlocksStruct.m

% Open file stream
filestream                          = fopen(filename, 'w');

% Write header
fprintf(filestream, 'Name\n');
fprintf(filestream, 'interior_long interior_lat\n');
fprintf(filestream, 'Euler_long Euler_long_sig\n');
fprintf(filestream, 'Euler_lat  Euler_lat_sig\n');
fprintf(filestream, 'rotation_rate rotation_rate_sig\n');
fprintf(filestream, 'rotation_info apriori_toggle\n');
fprintf(filestream, 'other    other    other\n');
fprintf(filestream, 'other    other    other\n');

% Loop over blocks and write to file
for cnt = 1 : numel(Block.rotationRate)
   fprintf(filestream, '%s\n', Block.name(cnt, :));
   fprintf(filestream, '%3.3f   %3.3f\n', Block.interiorLon(cnt), Block.interiorLat(cnt));
   fprintf(filestream, '%3.3f   %3.3f\n', Block.eulerLon(cnt), Block.eulerLonSig(cnt));
   fprintf(filestream, '%3.3f   %3.3f\n', Block.eulerLat(cnt), Block.eulerLatSig(cnt));
   fprintf(filestream, '%3.3f   %3.3f\n', Block.rotationRate(cnt), Block.rotationRateSig(cnt));
   fprintf(filestream, '%3.3f   %d\n', Block.rotationInfo(cnt), Block.aprioriTog(cnt));
   fprintf(filestream, '%3.3f   %3.3f   %3.3f\n', Block.other1(cnt), Block.other2(cnt), Block.other3(cnt));
   fprintf(filestream, '%3.3f   %3.3f   %3.3f\n', Block.other4(cnt), Block.other5(cnt), Block.other6(cnt));
end
fclose(filestream);
