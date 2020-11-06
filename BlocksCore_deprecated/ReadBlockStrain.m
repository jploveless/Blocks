function [Block] = ReadBlock(baseFileName)
% ReadBlock.m
%
% Read in block information from *.block file.

filestream              = 1;
infile                  = fopen(baseFileName, 'r');
snames                  = [];
seg_data                = [];
numsegments             = [];

% Read past header
trash                   = fgetl(infile);
trash                   = fgetl(infile);
trash                   = fgetl(infile);
trash                   = fgetl(infile);
trash                   = fgetl(infile);
trash                   = fgetl(infile);
trash                   = fgetl(infile);
trash                   = fgetl(infile);

%  Read in block data (one block at a time)
while 1
   line                 = fgetl(infile);
   if ~isstr(line), break, end
   sname                = deblank(sscanf(line,'%s',inf));

   if ~isempty(snames)
      snames            = str2mat(snames, sname);
   else
      snames            = sname;
   end

   theline              = sscanf(fgetl(infile), '%f', inf);
   theline              = [theline; sscanf(fgetl(infile), '%f', inf)];
   theline              = [theline; sscanf(fgetl(infile), '%f', inf)];
   theline              = [theline; sscanf(fgetl(infile), '%f', inf)];
   theline              = [theline; sscanf(fgetl(infile), '%f', inf)];
   theline              = [theline; sscanf(fgetl(infile), '%f', inf)];
   theline              = [theline; sscanf(fgetl(infile), '%f', inf)];
   seg_data             = [seg_data; theline'];
end
fclose(infile);

% Assign each column to a meaningfully named vector
Block.interiorLon       = seg_data(:, 1);
Block.interiorLat       = seg_data(:, 2);
Block.eulerLon          = seg_data(:, 3);
Block.eulerLonSig       = seg_data(:, 4);
Block.eulerLat          = seg_data(:, 5);
Block.eulerLatSig       = seg_data(:, 6);
Block.rotationRate      = seg_data(:, 7);
Block.rotationRateSig   = seg_data(:, 8);
Block.rotationInfo      = seg_data(:, 9);
Block.aprioriTog        = seg_data(:, 10);
Block.eLonLon           = seg_data(:, 11);
Block.eLonLat           = seg_data(:, 12);
Block.eLatLat           = seg_data(:, 13);
Block.eLonLonSig        = seg_data(:, 14);
Block.eLonLatSig        = seg_data(:, 15);
Block.eLatLatSig        = seg_data(:, 16);
Block.name              = snames;


% Report on which blocks have constraints
% ss_idx                  = find(block_apriori_tog >= 1);
% if (numel(ss_idx) > 0)
%    fprintf(filestream, 'Block motion contraints :\n')
%    for ncnt = 1 : length(ss_idx)
%       fprintf(filestream, '%s %3.1f +/- %3.1f rad/yr at %3.3f +/- %2.3f deg longitude %3.3f +/- %2.3f deg latitude\n', ...
%                    snames(ss_idx(ncnt), :), ...
%                    Block.rotationRate(ss_idx(ncnt)), ...
%                    Block.rotationRateSig(ss_idx(ncnt)), ...
%                    Block.eulerLon(ss_idx(ncnt)), Block.eulerLonSig(ss_idx(ncnt)), ...
%                    Block.eulerLat(ss_idx(ncnt)), Block.eulerLatSig(ss_idx(ncnt)));
%    end
% end