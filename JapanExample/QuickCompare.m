function QuickCompare(dir1, dir2)
% Quick comparison of Blocks output files for testing purposes.

% Compare segment files
Seg1 = ReadSegmentStruct(strcat(dir1, '/Mod.segment'));
Seg2 = ReadSegmentStruct(strcat(dir2, '/Mod.segment'));

% load block files:
Blk1 = ReadBlocksStruct(strcat(dir1, '/Mod.block'));
Blk2 = ReadBlocksStruct(strcat(dir2, '/Mod.block'));

issuccess = true
% Are there the same number of segments
if numel(Seg1.lon1) == numel(Seg2.lon1)
    fprintf(1, 'Number segments match.  Have a nice day.\n');
 else
   issuccess = false;
    fprintf(1, 'Number segments do not match.\n')
    fprintf(1, '%s has %d segments.\n', dir1, numel(Seg1.lon1));
    fprintf(1, '%s has %d segments.\n', dir2, numel(Seg2.lon1));
end


for i = 1:numel(Seg1.lon1)
    if Seg1.ssRate(i) ~= Seg2.ssRate(i)
       fprintf(1, '%s has different ssRate.\n', deblank(Seg1.name(i,:)));
       fprintf(1, '%s ssRate %6.3f.\n', dir1, Seg1.ssRate(i));
       fprintf(1, '%s ssRate %6.3f.\n', dir2, Seg2.ssRate(i));
    end

    if Seg1.dsRate(i) ~= Seg2.dsRate(i)
       fprintf(1, '%s has different dsRate.\n', deblank(Seg1.name(i,:)));
       fprintf(1, '%s dsRate %6.3f.\n', dir1, Seg1.dsRate(i));
       fprintf(1, '%s dsRate %6.3f.\n', dir2, Seg2.dsRate(i));
    end

    if Seg1.tsRate(i) ~= Seg2.tsRate(i)
       fprintf(1, '%s has different ssRate.\n', deblank(Seg1.name(i,:)));
       fprintf(1, '%s tsRate %6.3f.\n', dir1, Seg1.tsRate(i));
       fprintf(1, '%s tsRate %6.3f.\n', dir2, Seg2.tsRate(i));   
    end
end
fprintf('Done comparing segments.\n');

% compare Mod.block
for i = 1:numel(Blk1.eulerLon)
    if Blk1.eulerLon(i) ~= Blk2.eulerLon(i)
       fprintf(1, '%s has different eulerLon.\n', deblank(Blk1.name(i,:)));
       fprintf(1, '%s eulerLon %6.3f.\n', dir1, Blk1.eulerLon(i));
       fprintf(1, '%s eulerLon %6.3f.\n', dir2, Blk2.eulerLon(i));
    end
    
    if Blk1.eulerLat(i) ~= Blk2.eulerLat(i)
       fprintf(1, '%s has different eulerLat.\n', deblank(Blk1.name(i,:)));
       fprintf(1, '%s eulerLat %6.3f.\n', dir1, Blk1.eulerLat(i));
       fprintf(1, '%s eulerLat %6.3f.\n', dir2, Blk2.eulerLat(i));
    end

    if Blk1.rotationRate(i) ~= Blk2.rotationRate(i)
       fprintf(1, '%s has different rotationRate.\n', deblank(Blk1.name(i,:)));
       fprintf(1, '%s rotationRate %6.3f.\n', dir1, Blk1.rotationRate(i));
       fprintf(1, '%s rotationRate %6.3f.\n', dir2, Blk2.rotationRate(i));
    end
end
fprintf('Done comparing blocks.\n');
    
% compare patch files:
%[c1, v1, s1] = PatchData(strcat(dir1, '/Mod.patch'));
%[c2, v2, s2] = PatchData(strcat(dir2,'Mod.patch'));
%meshview(c1, v1, s1(:, 1)); % Plot strike slip
%meshview(c1, v1, s1(:, 2)); % Plot dip slip
%fprintf('Done comparing patches.\n');
if ~issuccess
   exit(1);
end
