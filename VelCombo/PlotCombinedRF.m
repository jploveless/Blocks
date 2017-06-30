function PlotCompiledRF(varargin)
%
% PLOTCOMPILEDRF plots combined velocity field, such as that produced by ALIGNALLFIELDS.m.  
%
%  PLOTCOMBINEDRF(INFILE, MATFILE) plots the combined velocity field contained in INFILE.
%  MATFILE is the name of a .mat file containing at minimum the variables "sumnStations"
%  and "names" as determined and output by AlignAllFields.m.  
%
%  PLOTCOMBINEDRF(ROOTNAME) assumes that the .sta.data and the .mat file have 
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

% make colormap
colb 												= jet(nfiles);
% plot the vectors in unique colors to identify parent field
for i = 1:nfiles;
	ht(i) = m_vec(400, s.lon(sumnStations(i)+1:sumnStations(i+1)), s.lat(sumnStations(i)+1:sumnStations(i+1)), s.eastVel(sumnStations(i)+1:sumnStations(i+1)), s.northVel(sumnStations(i)+1:sumnStations(i+1)), colb(i,:), 'headlength', 3, 'shaftwidth', 0.5);
end
legend(ht, names)
