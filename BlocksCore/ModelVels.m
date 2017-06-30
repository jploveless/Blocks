function Model = ModelVels(G, m, fn, Model, ufn, sgn)
% ModelVels   Generic function for calculating a particular set of model velocities.
%   Model = ModelVels(G, M, FN) uses the matrix G and state vector M to calculate 
%   model velocities in the N, E, U directions.  FN specifies the field name suffix,
%   such that velocity components will be saved to fields eastFN, northFN, and upFN 
%   (i.e., specify FN = 'Vel' to write fields eastVel, northVel, and upVel).
%
%   Model = ModelVels(G, M, FN, Model, UFN) will update the fields of the existing
%   structure Model by adding the newly calculated values to the update field name
%   UFN.  For example, to add the velocities due to internal block strain to the 
%   overall model predicted velocities, call:
%   
%   Model = ModelVels(Partials.strain, omegaEstStrain, 'StrainVel', Model, 'Vel');
%
%   Model = ModelVels(G, M, FN, Model, UFN, AS) instead specified whether the 
%   velocities UFN should be updated by adding (AS = 1) or subtracting (AS = -1)
%   the new velocities FN.

% Set up new field names
evn = ['east', fn];
nvn = ['north', fn];
uvn = ['up', fn];

% Do the multiplication and extract values
v = G*m;
ev = v(1:3:end);
nv = v(2:3:end);
uv = v(3:3:end);

% Zero vector
zv = zeros(size(G, 1)/3, 1);

% Assign to structure
if ~exist('Model', 'var')
   Model = struct(evn, zv+ev, nvn, zv+nv, uvn, zv+uv);
else
   Model.(evn) = ev;
   Model.(nvn) = nv;
   Model.(uvn) = uv;
end

if exist('Model', 'var') && exist('ufn', 'var')
   if ~exist('sgn', 'var')
      sgn = 1;
   end
   
   % Set up existing field names
   evn = ['east', ufn];
   nvn = ['north', ufn];
   uvn = ['up', ufn];
   
   % Do the addition
   Model.(evn) = Model.(evn) + zv+sign(sgn).*ev;
   Model.(nvn) = Model.(nvn) + zv+sign(sgn).*nv;
   Model.(uvn) = Model.(uvn) + zv+sign(sgn).*uv;
end