function [mmag, clus, alldis] = couprelease(p, coup, area, incr, wcscale, filebase)
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
%   Wells and Coppersmith scaling coefficients as the 4-element vector
%   COEFF, with stucture COEFF = [A B Auncertainty Buncertainty].
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

% Allocate space for total area
tarea = NaN(sum(p.nEl), length(incr));
alldis = tarea;

% For each coupling fraction,
for i = 1:length(incr)
   % Find the elements that are coupled at least as much as this increment (with a small correction)
   coupinc = coup >= incr(i)-2*(id/10);
   % Determine how many clusters comprise this increment
   [clus, dis] = meshclusters(p, coupinc);
   if exist('filebase', 'var')
      file = sprintf('%sp%g.xy', filebase, 10*incr(i));
      writegmtclusters(p, area, clus, file, wcscale)
   end
   % Loop through clusters to define individual events
   for j = 1:length(clus)
      % Multiply binary array by element area and sum to give total area
      tarea(j, i) = sum(area(clus{j}));
      alldis(1:numel(dis), i) = dis(:);
   end
end
% Trim unused rows
tarea(sum(isnan(tarea), 2) == length(incr), :) = [];
alldis(sum(isnan(alldis), 2) == length(incr), :) = [];
numeq = sum(~isnan(tarea), 1);

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
      [a, b, aunc, bunc] = deal(wcscale(1), wcscale(2), wcscale(3), wcscale(4));
   elseif ischar(wcscale)
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
minmag = 6.0;
smalleq = mmag < minmag;
% Set distances referring to the small earthquakes equal to zero
[r, c] = find(smalleq);
Alldis = NaN*alldis;

if ~isempty(Alldis)
	for i = 1:length(incr)
		% Find the row numbers corresponding to small earthquakes at this increment
		sminc = find(c == i);
		% Reshape distance array from column vector to a matrix
		tempdis = reshape(alldis(1:numeq(i).^2, i), numeq(i), numeq(i));
		% Wipe out the small earthquake rows and columns
		tempdis(sminc, :) = [];
		tempdis(:, sminc) = [];
		% Reshape back to column vector
		tempdis = tempdis(:); tempdis = sort(tempdis(tempdis > 0));
		% Reduce to nearly unique values
		dtempdis = diff([sort(tempdis); 1e20]);
		tempdis = tempdis(dtempdis > 1e-4);
		Alldis(1:length(tempdis), i) = tempdis;
	end
else
   Alldis = NaN(0, length(incr));
end
Alldis(sum(isnan(Alldis), 2) == length(incr), :) = [];
   
% And set the magnitudes equal to NaN
mmag(smalleq) = NaN;
[mmag, si] = sort(mmag, 1, 'ascend');
merr = aunc + bunc*log10(tarea);
si = repmat(size(mmag, 1)*(0:size(mmag, 2)-1), size(mmag, 1), 1) + si;
merr = merr(si);



% Make a plot
% Make a coupling vs. magnitude plot
figure('Position', [0 0 600 300]);
hold on;

for i = 1:2:numel(incr) % Draw some pretty fill to differentiate coupling values
    xfill = [-0.05 0.05 0.05 -0.05] + incr(i);
    yfill = [0 0 10 10];
    fh = fill(xfill, yfill, 'y');
    set(fh, 'edgeColor', 'none', 'FaceColor', 0.75*[1 1 1]);
end

Xvec = [];
Yvec = [];
Xerr = [];
Yerr = [];
Colo = [];
% Cycle through the increments and draw events with uncertainties
for i = 1:numel(incr)
   nrup = sum(~isnan(mmag(:, i)));
   space = 0.1./(nrup+1);
   xvec = 0:space:0.1; xvec = xvec(2:end-1) - 0.05 + incr(i);
   [yvec, si] = sort(mmag(1:nrup, i), 1, 'descend');
   xerr = repmat(xvec, 2, 1);
   yerr = [mmag(1:nrup, i)' + merr(1:nrup, i)'; mmag(1:nrup, i)' - merr(1:nrup, i)'];
   yerr = yerr(:, si);
   Xvec = [Xvec; xvec'];
   Yvec = [Yvec; yvec];
   Xerr = [Xerr, xerr];
   Yerr = [Yerr, yerr];
   Colo = [Colo; incr(i)*ones(size(xvec'))];
end
lin = line(Xerr, Yerr, 'color', 'k', 'linewidth', 2);
sca = scatter(Xvec, Yvec, 75, Colo, 'filled', 'markeredgecolor', 'k', 'linewidth', 2);
caxis([0 1]); colormap(flipud(hot));
axis([0.05 1.05 max([minmag 6]) 9.5]);
set(gca, 'xtick', 0.1:0.1:1, 'ytick', 6:0.5:9.5);
set(gca, 'xticklabel', num2str((0.1:0.1:1)', '%.1f'))
set(gca, 'yticklabel', num2str((6:0.5:9.5)', '%.1f'))
prepfigprint
xlabel('Coupling fraction', 'fontsize', 12)
ylabel('M_W', 'fontsize', 12)
set(lin, 'linewidth', 2);
set(sca, 'linewidth', 2);

% Make a coupling vs. distance plot
figure('Position', [0 0 600 300]);
hold on;

for i = 1:2:numel(incr) % Draw some pretty fill to differentiate coupling values
    xfill = [-0.05 0.05 0.05 -0.05] + incr(i);
    yfill = [0 0 1000 1000];
    fh = fill(xfill, yfill, 'y');
    set(fh, 'edgeColor', 'none', 'FaceColor', 0.75*[1 1 1]);
end

Xvec = [];
Yvec = [];
Colo = [];
% Cycle through the increments and draw events with uncertainties
for i = 1:numel(incr)
   nrup = sum(~isnan(Alldis(:, i)));
   if nrup > 0
		space = 0.1./(nrup+1);
		xvec = 0:space:0.1; xvec = xvec(2:end-1) - 0.05 + incr(i);
		[yvec, si] = sort(Alldis(1:nrup, i), 1, 'descend');
      Xvec = [Xvec; xvec'];
      Yvec = [Yvec; yvec];
		Colo = [Colo; incr(i)*ones(size(xvec'))];
   end
end
sca = scatter(Xvec, Yvec, 75, Colo, 'filled', 'markeredgecolor', 'k', 'linewidth', 2);
caxis([0 1]); colormap(flipud(hot));
% axis([0.05 1.05 max([minmag 6]) 9.5]);
set(gca, 'xtick', 0.1:0.1:1, 'ytick', 6:0.5:9.5);
set(gca, 'xticklabel', num2str((0.1:0.1:1)', '%.1f'))
% set(gca, 'yticklabel', num2str((6:0.5:9.5)', '%.1f'))
prepfigprint
xlabel('Coupling fraction', 'fontsize', 12)
ylabel('Separation distance (km)', 'fontsize', 12)
set(sca, 'linewidth', 2);

