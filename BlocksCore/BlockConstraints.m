function [blockCon, Index, Data, Sigma] = BlockConstraints(Block, Index, Data, Sigma, Command)

fprintf('   Applying a priori block motion constraints...')
blockCon                                         = GetBlockConstraintPartials(Block);
Index.blockCon                                   = find(Block.aprioriTog);
Data.nBlockCon                                   = 3*length(Index.blockCon);
Data.blockCon                                    = zeros(size(blockCon, 1), 1);
Sigma.blockCon                                   = zeros(size(blockCon, 1), 1);
if Data.nBlockCon > 0
   [apLons, apLats, apRates]                     = deal(Block.eulerLon(Index.blockCon), Block.eulerLat(Index.blockCon), Block.rotationRate(Index.blockCon).*1e6);
   [apbx, apby, apbz]                            = EulerToOmega(apLons, apLats, apRates);
   Data.blockCon(1:3:end)                        = apbx;
   Data.blockCon(2:3:end)                        = apby;
   Data.blockCon(3:3:end)                        = apbz;
   apbcov                                        = stack3([deg_to_rad(Block.eulerLatSig(Index.blockCon)), deg_to_rad(Block.eulerLonSig(Index.blockCon)), deg_to_rad(Block.rotationRateSig(Index.blockCon))]);
   [apbsx, apbsy, apbsz]                         = epoles_cov_to_omega_cov(apbx, apby, apbz, diag(apbcov));
   Sigma.blockCon(1:3:end)                       = apbsx;
   Sigma.blockCon(2:3:end)                       = apbsy;
   Sigma.blockCon(3:3:end)                       = apbsz;
end
Sigma.blockConWgt                                = Command.blockConWgt;
fprintf('done.\n')
