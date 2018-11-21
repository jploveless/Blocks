function [R, d, W, Partials, Index] = AssembleMatricesTriCoup(Partials, Data, Sigma, Index)
% 
% % Trim arrays to eliminate vertical velocities and one triangular slip component
% Partials.rotation                                = Partials.rotation(Index.staRowkeep, :);
% Partials.elastic                                 = Partials.elastic(Index.staRowkeep, :);
% Partials.strain                                  = Partials.strain(Index.staRowkeep, :);
% Partials.tri                                     = Partials.tri(Index.staRowkeep, Index.triColkeep); 
% Partials.smooth                                  = Partials.smooth(Index.triColkeep, Index.triColkeep);
% Partials.triBlockCon                             = Partials.triBlockCon(Index.triConkeep, :);
% Partials.triSlipCon                              = Partials.triSlipCon(Index.triConkeep, Index.triColkeep);
% Data.smooth                                      = Data.smooth(Index.triColkeep);
% Sigma.smooth                                     = Sigma.smooth(Index.triColkeep);
% Data.triSlipCon                                  = Data.triSlipCon(Index.triConkeep);
% Sigma.triSlipCon                                 = Sigma.triSlipCon(Index.triConkeep);
% 
% Update index sizes
Index.szrot                                      = [length(Index.staRowkeep), size(Partials.rotation, 2)];
% Index.sztri                                      = [length(Index.staRowkeep), length(Index.triColkeep)];
Index.szstrain                                   = [length(Index.staRowkeep), size(Partials.strain, 2)];
Index.szmogi                                     = [length(Index.staRowkeep), size(Partials.mogi, 2)];
% 
% % Combine SAR partials, if necessary
% if Data.nSar > 0
%    Partials.elastic                              = [Partials.elastic ; Partials.selastic];
%    Partials.rotation                             = [Partials.rotation; Partials.srotation];
%    Partials.strain                               = [Partials.strain  ; Partials.sstrain];
%    Partials.tri                                  = [Partials.tri     ; Partials.stri];
% end     

% First determine submatrix sizes
if sum(abs(Data.upVel)) > 0
   rsta                                          = 3*Data.nSta; % velocity rows
else
   rsta                                          = 2*Data.nSta;
end
rsar                                             = Data.nSar;
rbcons                                           = Data.nBlockCon; % Block constraint rows
rscons                                           = Data.nSlipCon; % Slip constraint rows
% rtriw                                            = length(Index.triSmoothkeep); % Triangular smoothing rows
% rtric                                            = length(Index.triConkeep); % Triangular edge constraint rows

cblock                                           = Index.szrot(2); % Block/slip columns
% ctri                                             = length(Index.triColkeep); % Triangle columns
cstrain                                          = size(Partials.strain, 2); % Strain columns
cmogi                                            = Index.szmogi(2); % Mogi source columns
cramp                                            = Index.szramp(2); % SAR ramp columns

% Adjust rows, cols of triangle-related partials if full coupling is specified
 

% Determine indices
rnum                                             = [rsta rsar rbcons rscons];
cnum                                             = [cblock cstrain cmogi cramp];
ridx                                             = cumsum([0 rnum]);
cidx                                             = cumsum([0 cnum]);

for i = 1:length(rnum)
   for j = 1:length(cnum)
      rows{i, j}                                 = ridx(i) + (1:rnum(i));
      cols{i, j}                                 = cidx(j) + (1:cnum(j));
   end
end

% Allocate space for Jacobian
R                                                = zeros(ridx(end), cidx(end));
% Place partials
R(rows{1, 1}, cols{1, 1})                        = Partials.rotation(Index.staRowkeep, :)...
                                                 - Partials.elastic(Index.staRowkeep, :) * Partials.slip...
                                                 - Partials.tri(Index.staRowkeep, Index.triColkeep) * Partials.trislip(Index.triColkeep, :);
R(rows{1, 2}, cols{1, 2})                        = Partials.strain(Index.staRowkeep, :);
R(rows{1, 3}, cols{1, 3})                        = Partials.mogi(Index.staRowkeep, :);
R(rows{2, 1}, cols{2, 1})                        = Partials.srotation - Partials.selastic * Partials.slip;
R(rows{2, 2}, cols{2, 2})                        = Partials.sstrain;
R(rows{2, 3}, cols{2, 3})                        = Partials.smogi;
R(rows{2, 4}, cols{2, 4})                        = Partials.sramp;
R(rows{3, 1}, cols{3, 1})                        = Partials.blockCon;
R(rows{4, 1}, cols{4, 1})                        = Partials.slipCon;

% Allocate space for data and weight vectors
d                                                = zeros(ridx(end), 1);
w                                                = d;

% Place data and weights
if sum(abs(Data.upVel)) > 0
   d(rows{1, 1})                                 = stack3([Data.eastVel, Data.northVel, Data.upVel]);
   w(rows{1, 1})                                 = stack3(1./[Sigma.eastVel.^2, Sigma.northVel.^2, Sigma.upVel.^2]);
else
   d(rows{1, 1})                                 = stack2([Data.eastVel, Data.northVel]);
   w(rows{1, 1})                                 = stack2(1./[Sigma.eastVel.^2, Sigma.northVel.^2]);
end
d(rows{2, 1})                                    = Data.sar;
w(rows{2, 1})                                    = 1./Sigma.sar.^2;
d(rows{3, 1})                                    = Data.blockCon;
w(rows{3, 1})                                    = Sigma.blockConWgt./Sigma.blockCon.^2;
d(rows{4, 1})                                    = Data.slipCon;
w(rows{4, 1})                                    = Sigma.slipConWgt./Sigma.slipCon.^2;
W                                                = diag(w); % convert weights into a diagonal matrix