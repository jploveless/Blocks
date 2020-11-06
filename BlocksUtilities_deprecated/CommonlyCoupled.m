function thr = CommonlyCoupled(p, direc, thresh)
% COMMONLYCOUPLED calculates the most coupled elements for a range of smoothing
% values.
%   COUP = COMMONLYCOUPLED(P, DIREC, THRESH) uses the triangular mesh structure P, 
%   a parent directory DIREC containing result directories produced using 
%   SMOOTHINGEVAL.m, and a threshold THRESH to determine the most coupled elements
%   (the top THRESH percent) for a range of smoothing values.
%

d = dir(direc);

for i = 1:numel(d)
   if d(i).isdir & isempty(strmatch(d(i).name(1), '.'))
      [c, v, slip] = PatchData([direc filesep d(i).name filesep 'Mod.patch']);
      comm = ls(strcat(direc, filesep, d(i).name, filesep, '*.command'));
      start = strfind(comm, 'smooth') + 6;
      endd = strfind(comm, '.command') - 1;
      locked = CoupledEls(p, slip, thresh);
      thr{i} = locked;
      cols = zeros(size(p.v));
      for j = 1:numel(locked)
         cols(locked{j}, 1) = 1;
      end   
      meshview(p.c, p.v, cols); title(sprintf('\beta = %s', comm(start:endd)));
   end 
end