function infoSeg = faultInfo(searchDir, faultFile) 

%%%%% INPUT %%%%%
% searchDir: the directory containing output folders to pull results from
% faultFile: text file containing the names of segments to be queried -
  % this script looks for segments that contain the entirety of the name
  % specified in faultFile (i.e., all segments with additonal characters
  % after/before the segment name are included in the calculations)

%%%%% OUTPUT %%%%%
% infoSeg: structure containing information on segment slip rates,
  % attributes, and some geometric properties
  % fields except names are an m-by-n matrix where m = number of faults
  % listed in faultNames.txt and n = number of models
    % names: fault names 
    % ts: length weighted average tensile-slip rate (only calculated using
      % segments with dip=90°)
    % ds: length weighted average dip-slip rate (only calculated using
      % segments with dip~=90°)
    % ss: length weighted average strike-slip rate
    % length: summed length of all segments comprising the fault
    % lengthT: summed length of segments comprising the fault with dip=90°
    % lengthD: summed length of segments comprising the fault with dip~=90°
    % midLat: latitude of the median segment endpoint
    % midLon: longitude of the median segment endpoint
    % dip: mean of dip for all segments comprising the fault
    % lDep: mean of locking depth for all segments comprising the fault
    % nSeg: number of segments comprising the fault
    % rakeTog: mean of rake toggle for all segments comprising the fault
    % patchTog: mean of patch toggle for all segments comprising the fault
   
%%%%% FAULTINFO %%%%%
% load fault names
infoSeg.names = readlines(faultFile);

% define folder path(s)
segFiles = dir([searchDir,'/000*/Mod.segment']);

% initialize variables
infoSeg.ts = nan(size(infoSeg.names,1),size(segFiles,1));
infoSeg.ds = nan(size(infoSeg.names,1),size(segFiles,1));
infoSeg.ss = nan(size(infoSeg.names,1),size(segFiles,1));
infoSeg.length = nan(size(infoSeg.names,1),size(segFiles,1));
infoSeg.lengthT = nan(size(infoSeg.names,1),size(segFiles,1));
infoSeg.lengthD = nan(size(infoSeg.names,1),size(segFiles,1));
infoSeg.midLat = nan(size(infoSeg.names,1),size(segFiles,1));
infoSeg.midLon = nan(size(infoSeg.names,1),size(segFiles,1));
infoSeg.dip = nan(size(infoSeg.names,1),size(segFiles,1));
infoSeg.lDep = nan(size(infoSeg.names,1),size(segFiles,1));
infoSeg.nSeg = nan(size(infoSeg.names,1),size(segFiles,1));
infoSeg.rakeTog = nan(size(infoSeg.names,1),size(segFiles,1));
infoSeg.patchTog = nan(size(infoSeg.names,1),size(segFiles,1));

% get segment attributes
for j = 1:size(segFiles,1)
    % grab segment information from output
    seg = ReadSegmentTri([segFiles(j).folder,'/',segFiles(j).name]);
    seg.name = string(seg.name);
    for i = 1:size(infoSeg.names,1)
        idx = find(contains(seg.name,infoSeg.names(i)));
        if ~isempty(idx)
            % get segment length
            % calculate angular distance between endpoints
            angD = sind((seg.lat2(idx)-seg.lat1(idx))./2).^2 + ...
                cosd(seg.lat1(idx)) .* cosd(seg.lat2(idx)) .* ...
                sind((seg.lon2(idx)-seg.lon1(idx))./2).^2; 
            % calculate central angle for each segment
            cent = 2 .* atan2d(sqrt(angD),sqrt(1-angD));
            % calculate length in km for each segment
            leng = 6371 .* deg2rad(cent);
            % sum length for all fault segments
            infoSeg.length(i,j) = sum(leng);
            infoSeg.lengthT(i,j) = sum(leng(seg.dip(idx)==90));
            infoSeg.lengthD(i,j) = sum(leng(seg.dip(idx)~=90));
            % length weighted average slip rates     
            infoSeg.ss(i,j) = sum(seg.ssRate(idx).*(leng/sum(leng)));
            infoSeg.ds(i,j) = sum(seg.dsRate(idx(seg.dip(idx)~=90)).*...
                (leng(seg.dip(idx)~=90)/infoSeg.lengthD(i,j)));
            infoSeg.ts(i,j) = sum(seg.tsRate(idx(seg.dip(idx)==90)).*...
                (leng(seg.dip(idx)==90)/infoSeg.lengthT(i,j)));
            % mean locking depth
            infoSeg.lDep(i,j) = mean(seg.lDep(idx));
            % mean dip
            infoSeg.dip(i,j) = mean(seg.dip(idx));
            % mean of patch toggle values
            infoSeg.patchTog(i,j) = mean(seg.patchTog(idx));
            % mean of rake toggle values
            infoSeg.rakeTog(i,j) = mean(seg.rakeTog(idx));
            % number of segments
            infoSeg.nSeg(i,j) = length(idx);
            % midpoint lat/lon
            infoSeg.midLat(i,j) = seg.lat2(idx(round(length(leng)/2)));
            infoSeg.midLon(i,j) = seg.lon2(idx(round(length(leng)/2)));
        end
    end
end












