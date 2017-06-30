function ChangeCompiledRF(varargin)
%
% CHANGECOMPILEDRF allows for interactive changing of the reference frame
% for a combined velocity field, such as that produced by ALIGNALLFIELDS.m.  
%
%  CHANGECOMBINEDRF(INFILE, MATFILE) changes the reference frame of the combined
%  velocity field contained in INFILE and makes a new file and plot.  MATFILE
%  is the name of a .mat file containing at minimum the variables "sumnStations"
%  and "names" as determined and output by AlignAllFields.m.  
%
%  CHANGECOMBINEDRF(ROOTNAME) assumes that the .sta.data and the .mat file have 
%  the same path and root name.

% Parse inputs
if nargin == 1 % rootname specified
	infile 				= sprintf('%s.sta.data', varargin{1});
	matfile				= sprintf('%s.mat', varargin{1});
elseif nargin == 2;
	infile 				= varargin{1};
	matfile 				= varargin{2};
end

% Get the inputs
s 							= ReadStation(infile);
load(matfile)
nfiles 					= length(sumnStations) - 1;

% Plot all station locations on a world map and request selection of stable points
load coast
long(long<0)			= long(long<0) + 360;
figure
co 						= plot(long, lat, 'k'); 
axis equal; axis tight; hold on
plot(s.lon, s.lat, 'r.');
uiwait(msgbox('Draw a lasso around the points to be used as the stable reference frame.','Reference frame definition','modal'));
refresh;
pl 						= selectdata('selectionmode','lasso','ignore',co);
close

% Send the selected stable points to StableReferenceFrame.m
outfile 					= sprintf('%s_rot.sta.data', infile(1:end-9));
StableReferenceFrame(infile, pl, outfile);

% Load the resulting outfile
s	 						= ReadStation(outfile);

% Set up the map and plot
figure;
% Get geographic extents
mnla												= nfix(min(s.lat), 10);
mnlo												= nfix(min(s.lon), 10);
mxla												= nceil(max(s.lat), 10);
mxlo												= nceil(max(s.lon), 10);
m_proj('mercator', 'lat', [mnla mxla], 'lon', [mnlo mxlo]);
m_coast('patch', [.9 .9 .9], 'edgecolor', 'k'); hold on;
m_grid('tickdir', 'out', 'yaxislocation', 'right', 'xaxislocation','bottom','xlabeldir','end','ticklen',.02, 'linestyle', 'none');
% plot the stations that were used for the reference frame
m_plot(s.lon(pl), s.lat(pl), 'ok');
% make colormap
colb 												= jet(nfiles);
% plot the vectors in unique colors to identify parent field
for i = 1:nfiles;
	ht(i) = m_vec(400, s.lon(sumnStations(i)+1:sumnStations(i+1)), s.lat(sumnStations(i)+1:sumnStations(i+1)), s.eastVel(sumnStations(i)+1:sumnStations(i+1)), s.northVel(sumnStations(i)+1:sumnStations(i+1)), colb(i,:), 'headlength', 3, 'shaftwidth', 0.5);
end
legend(ht, names)
