function block2tex(block, tex)
%
% BLOCK2TEX parses block parameters and writes them to a LaTeX table.
%
%   BLOCK2TEX(BLOCK, TEX) reads a BLOCK file and writes the names and 
%   Euler pole longitudes, latitudes, and rotation rates, with their
%   corresponding uncertainties, to the file TEX, which can be cut and
%   paste into a LaTeX document.
%

b = ReadBlock(block);
tf = fopen(tex, 'w');

% Set up the table environment
fprintf(tf, '%s\n%s\n%s\n%s\n', '\begin{table}[htdp]', '\begin{center}', '\begin{tabular}{lccc}');

fprintf(tf, 'Name & $\\phi_E$ & $\\lambda_E$ & $\\omega_E (^{\\circ}/Myr)$\\\\ \n \\hline\n');
for i = 1:numel(b.interiorLon)
   fprintf(tf, '%s & $%6.2f^{\\circ} \\pm %4.2f^{\\circ}$ & $%6.2f^{\\circ} \\pm %4.2f^{\\circ}$ & $%6.2f^{\\circ} \\pm %4.2f^{\\circ}$\\\\ \n', ...
                 b.name(i, :), b.eulerLon(i), b.eulerLonSig(i), b.eulerLat(i), b.eulerLatSig(i), b.rotationRate(i), b.rotationRateSig(i)); 
end
% Close the table environment
fprintf(tf, '%s\n%s\n%s\n%s\n%s\n%s\n', '\end{tabular}', '\end{center}', '\caption{Block parameters}', '\label{tab:blockparam}', '\end{table}');

fclose(tf);