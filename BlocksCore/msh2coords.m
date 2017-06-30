function [c,v] = msh2coords(file)
%
% MSH2COORDS extracts coordinate and vertex information from a Gmsh .msh file.
%
%   [C,V] = MSH2COORDS(FILE) extracts the coordinates and vertex ordering of 
%   triangular elements from the Gmsh .msh file named FILE.  The coordinates
%   are returned to the n x 3 array C, arranged with the x, y, and z locations
%   of coordinates in the three columns.  V is an m x 3 array containing the 
%   indices of the 3 vertices making up each of the m triangular elements.
%

% open file as character array
in             = opentxt(file);

% extract number of nodes and elements
nnode          = str2double(in(5,:));
ne             = str2double(in(8+nnode,:));

c              = str2num(in(6:5+nnode,:));
c              = c(:,2:end);

% find 1-D elements and ignore
d1             = 9+nnode; % start at line of first element listing
sp             = strfind(in(d1,:),' '); % find the locations of spaces in that line
while str2double(in(d1,sp(1)+1)) == 1; % while the first char. after the first space = 1... 
    d1         = d1+1; % skip that line: it's a one-dimensional element
    sp         = strfind(in(d1,:),' '); % make a new index of space locations
end
v              = str2num(in(d1:8+nnode+ne,:));
v              = v(:,end-2:end);
