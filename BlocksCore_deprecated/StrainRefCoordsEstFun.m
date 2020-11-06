function resid = StrainRefCoordsEstFun(stateVec)
global GLOBAL;

lon0 = stateVec(1:end/2);
lat0 = stateVec(end/2+1:end);
penaltyValue = 1e10;

% Check to see if reference coordinates lie outside of block boundaries
% If they do add a big number to the goodness of fit metric as a penalty
badLocation = 0;
for i = 1:numel(GLOBAL.Block.interiorLon)
   if ~inpolygon(lon0(i), lat0(i), GLOBAL.Block.orderLon{i}, GLOBAL.Block.orderLat{i})
      badLocation = 1;
   end
end

if badLocation == 1
   resid = penaltyValue;
else
   % Calcuate the strain rate partial derivatives for the current reference coordinate location
   [Partials.strain, strainBlockIdx,...
    Model.lonStrain, Model.latStrain]         = GetStrainReferencePartials(GLOBAL.Block, GLOBAL.Station, GLOBAL.Segment, lon0, lat0);
   
   % Rebuild R with the new strain partials based on the current guess for the reference coordinates
   strainIdx = size(GLOBAL.R, 2) - size(GLOBAL.strainPadding, 2); % determine width of the R matrix not including strains
   GLOBAL.R(:, strainIdx + 1:end) = [Partials.strain; GLOBAL.strainPadding];
    
   % Estimate the goodness of fit to all data
   mest = GLOBAL.R\GLOBAL.d;
   
   % Calculate residual magntude to minimize
   model = GLOBAL.R*mest;
   
   resid = sum(abs(GLOBAL.d(1:2*numel(GLOBAL.Station.lon)) - model(1:2*numel(GLOBAL.Station.lon))));
end

