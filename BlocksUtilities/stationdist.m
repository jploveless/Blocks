function [s, varargout] = stationdist(sta, varargin)
% STATIONDIST  Calculates the distance between stations and, optionally, elements
%   S = STATIONDIST(STA) returns an n-by-n array S containing the distances between 
%   the n stations whose position are given in structure fields STA.lon, STA.lat.  
%
%   [S, SB] = STATIONDIST(STA, DS) also returns a logical array indicating the stations
%   that lie within DS km of a particular station, e.g., for column i, row entries 
%   containing ones correspond to indices of stations within DS km of station i.
%
%   [S, P] = STATIONDIST(STA, PAT) returns the n-by-n array S containing interstation
%   distances, as well as an m-by-n array containing distances between the n stations
%   and the centroids of the m elements whose positions are described by the structure
%   fields PAT.lonc, PAT.latc.
%
%   [S, P, SB, PB] = STATIONDIST(STA, PAT, DS, DP) returns the distance arrays as well
%   as binary arrays identifying both the nearby stations and elements, defined as those
%   lying within DS and DP km, respectively, of each station.
%

% Check inputs and allocate necessary arrays
s = NaN(numel(sta.lon));
if nargin == 2 % either a patch structure or threshold distance
   if isstruct(varargin{1})
      pat = varargin{1};
      p = NaN(numel(pat.lonc), numel(sta.lon));
   else
      ds = varargin{1};
   end
elseif nargin == 4
   pat = varargin{1};
   p = NaN(numel(pat.lonc), numel(sta.lon));
   ds = varargin{2};
   dp = varargin{3};
end

% Determine whether or not we're also doing patches, as we'll just set up two options for the loop
if exist('pat', 'var')
   for i = 1:numel(sta.lon)
      s(:, i) = distance(sta.lat(i), sta.lon(i), sta.lat, sta.lon, [6371, 0]);
      p(:, i) = distance(sta.lat(i), sta.lon(i), pat.latc, pat.lonc, [6371, 0]);
   end
else
   for i = 1:numel(sta.lon)
      s(:, i) = distance(sta.lat(i), sta.lon(i), sta.lat, sta.lon, [6371, 0]);
   end
end

% Do the binary calculation(s), if necessary
if exist('ds', 'var')
   sb = s < ds;
end

if exist('dp', 'var')
   pb = p < dp;
end

% Check output arguments
if nargout == 2
   if exist('pat', 'var')
      varargout(1) = {p};
   else
      varargout(1) = {sb};
   end
elseif nargout == 4
   varargout(1) = {p};
   varargout(2) = {sb};
   varargout(3) = {pb};
end
