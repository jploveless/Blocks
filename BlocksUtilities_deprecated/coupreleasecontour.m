function [mmag, tarea] = couprelease(p, coup, area, incr, wcscale)
% couprelease   Earthquake magnitude releasing coupling fraction.
%   couprelease(P, COUP, AREA, INCR) calculates the earthquake magnitude
%   necessary to release coupling accumulated within the areas with
%   a specified range of coupling fractions. P is a patch structure
%   containing the network of triangular elements on which the 
%   coupling distribution has been estimated. COUP is an n-by-1 array
%   giving the actual coupling distribution, AREA is an n-by-1 array
%   giving the areas of the elements on which the coupling distribution
%   is estimated, and INCR is a vector giving the coupling fractions
%   for which the required earthquake magnitude should be calculated.
%   Magnitude is calculated using the Wells and Coppersmith (1994)
%   scaling relations between rupture area and moment magnitude.
%
%   couprepease(COUP, AREA, INCR, COEFF) permits specification of the
%   Wells and Coppersmith scaling coefficients as the 2-element vector
%   COEFF, with stucture COEFF = [A B].
%
%   MMAG = couprelease(...) returns the moment magnitudes to MMAG.
%
%   [MMAG, TAREA] = couprelease(...) also returns the total areas in 
%   square kilometers.
%
%   The idea is that, for a given value of INCR, all elements of that
%   coupling fraction or greater are found and their areas are summed,
%   and returned as TAREA. TAREA is also converted to moment magnitude
%   using the Wells and Coppersmith "All" relationship of Table 2A.
%
%

% Check increment difference
id = mean(diff(incr));

% Allocate space for total area: number of elements-by-# increments-by-# meshes
tarea = NaN(sum(p.nEl), length(incr), numel(p.nEl));
ncmax = 0;

% Mesh parts indices
last = cumsum(p.nEl);
first = ([1; 1+last(1:end-1)]);

% For each mesh,
for i = 1:length(p.nEl)
   % Make a grid onto which coupling will be interpolated
   xrange = minmax([p.lon1(first(i):last(i)); p.lon2(first(i):last(i)); p.lon3(first(i):last(i))]);
   yrange = minmax([p.lat1(first(i):last(i)); p.lat2(first(i):last(i)); p.lat3(first(i):last(i))]);
   [xg, yg] = meshgrid(xrange(1):km2deg(mean(sqrt(area(first(i):last(i))))):xrange(2), yrange(1):km2deg(mean(sqrt(area(first(i):last(i))))):yrange(2));
   % Interpolate coupling
   Coup = NaN*coup;
   Coup(first(i):last(i)) = coup(first(i):last(i));
   coupg = griddata(p.lonc, p.latc, Coup, xg, yg);
   % Contour 
   c = contour(xg, yg, coupg, incr);
   Incr = [incr incr(end)+eps];
   % For each coupling fraction,
   for j = 1:length(incr)
      % Identify individual closed contour indices
      begs = find(c(1, :) == Incr(j));
      ends = [begs find(c(1, :) == Incr(j+1), 1)]; ends = ends(2:end);
      % Special case for the highest value contour
      if length(ends) < length(begs)
         ends = [ends size(c, 2)+1];
      end
      % Find elements within each closed contour
      for k = 1:length(begs)
         ip = inpolygon(p.lonc, p.latc, c(1, begs(k)+1:ends(k)-1), c(2, begs(k)+1:ends(k)-1));
         tarea(k, j, i) = sum(ip.*area);
      end
      ncmax = max([k ncmax]);
   end
end

% Trim unused rows
tarea(ncmax+1:end, :, :) = [];

% Multiply total area by Wells and Coppersmith (1994) scaling parameters to give M_W

% Check to see if Wells and Coppersmith scaling parameters were specified as inputs
if ~exist('wcscale', 'var')
   % If not, set to be equal to the "all" coefficients
   a = 4.07;
   b = 0.98;
   aunc = 0.06;
   bunc = 0.03;
else
   % If so,
   
   % If it's numeric, then values are specified
   if isnumeric(wcscale)
      [a, b, aunc, bunc] = deal(wcscale);
   elseif ischar(wscale)
      switch lower(wcscale)
         case 'all'
            [a, b, aunc, bunc] = deal(4.07, 0.98, 0.06, 0.03);
         case 'n'
            [a, b, aunc, bunc] = deal(3.93, 1.02, 0.23, 0.10);
         case 'r'
            [a, b, aunc, bunc] = deal(4.33, 0.90, 0.12, 0.05);
         case 'ss'
            [a, b, aunc, bunc] = deal(3.98, 1.02, 0.07, 0.03);
      end
   end
end
% Convert area to moment magnitude
mmag = a + b*log10(tarea);
merr = aunc + bunc*log10(tarea);
keyboard

