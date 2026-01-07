function infoVel = velocityOutputInfo(searchDir, staFile) 

%%%%% INPUT %%%%%
% searchDir: the directory containing output folders to pull results from
% staFile: text file containing the names of stations to include in
  % comparison

%%%%% OUTPUT %%%%%
% infoVel structure containing information on horizontal surface velocity
  % misfits of model to input velocities; rows correspond to model number
    % infoVel.nSta: number of stations
    % infoVel.resE: mean (abs) east vel residual
    % infoVel.resN: mean (abs) north vel residual
    % infoVel.avgMag: mean magnitude of residuals
    % infoVel.sumMag: summed magnitude of residuals
    % infoVel.names: list of station names

   
%%%%% VELOCITYOUTPUTINFO %%%%%
% load station names
infoVel.names = readlines(staFile);

% define folder path(s)
staResFiles = dir([searchDir,'/000*/Res.sta']);

% get station residual information
infoVel.nSta = nan(size(staResFiles,1),1);
infoVel.resE = nan(size(staResFiles,1),1);
infoVel.resN = nan(size(staResFiles,1),1);
infoVel.avgMag = nan(size(staResFiles,1),1);
infoVel.sumMag = nan(size(staResFiles,1),1);

for j = 1:size(staResFiles,1)
    % grab station residuals from output
    stations = ReadStation([staResFiles(j).folder,'/',staResFiles(j).name]);
    infoVel.name = string(stations.name);
    idx = find(contains(infoVel.names,stations.name));
    infoVel.nSta(j) = size(idx,1);
    infoVel.resE(j) = mean(abs(stations.eastVel(idx)));
    infoVel.resN(j) = mean(abs(stations.northVel(idx)));
    infoVel.avgMag(j) = mean(sqrt(stations.eastVel(idx).^2+stations.northVel(idx).^2));
    infoVel.sumMag(j) = sum(sqrt(stations.eastVel(idx).^2+stations.northVel(idx).^2));
end





