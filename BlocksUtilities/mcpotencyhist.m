function [mu, sig, actual] = mcpotencyhist(sim, block, real, fit)
% MCPOTENCYHIST  Makes a histogram plot for Monte Carlo potency simulations.
%   MCPOTENCYHIST(SIM, BLOCK, REAL) makes a plot showing a histogram of simulated
%   block potency values, contained in the nBlock-by-nTrial array SIM for block 
%   with row index BLOCK, and plots a vertical line showing the REAL value
%   evaluated from the whole residual velocity gradient.  REAL is the full vector
%   of full residual potency values.  
%
%   MCPOTENCYHIST(SIM, BLOCK, REAL, FIT) allows adjustment of the historgram.  The
%   entries of FIT should be [number of histogram bins, number of fit evaluations]
%   where the first entry gives the number of bins to be used in fitting the true
%   histogram to the data (the default is 25), and the second should be the number 
%   of evenly spaced data points used in the PDF fitting calculation (default is 100).
%
%   [MU, SIG, ACTUAL] = MCPOTENCYHIST(...) outputs the mean MU and standard deviation 
%   STD of the histogram fit, as well as the potency value, ACTUAL, for use with 
%   MCPOTENCYHIST2GMT.

% Check existence of fitting parameters
if ~exist('fit', 'var')
   fit = [25, 100];
end

% Calculate histogram
[n, x] = hist(sim(block, :), fit(1));

% Calculate Gaussian fit
[mu, sig] = normfit(sim(block, :))
xfit = linspace(min(sim(block, :))-std(sim(block, :)), max(sim(block, :))+std(sim(block, :)), fit(2));
yfit = normpdf(xfit, mu, sig);

% Plot the figure
figure
%bar(x, n, 1, 'edgecolor', 'none', 'facecolor', 0.75*[1 1 1]) 
stairs(x, n)
%plot(x, n, 'color', 0.75*[1 1 1], 'linewidth', 5);
hold on
yfit = size(sim, 2)*(x(2)-x(1))*yfit;
yfit(yfit < 0) = 0;
plot(xfit, yfit, 'color', 'k', 'linewidth', 5);
linemax = max([max(yfit) max(n)])
actual = real(block);
line([actual; actual], [0; linemax], 'color', 'k', 'linestyle', '--', 'linewidth', 5);
fs = 12;
xlabel('Potency (\times10^9 m^3)', 'fontsize', fs); ylabel('N', 'fontsize', fs);
%legend('Trials', 'Best-fit Gaussian', 'Full residual')
set(gca, 'fontsize', fs)%, 'xtick', [], 'ytick', []);
axis tight;
set(gca, 'xlim', get(gca, 'xlim').*[0.9 1.1]);