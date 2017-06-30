function Model = ModelSarVels(Partials, Model, Index)
% ModelSarVels   Calculates SAR velocity components.
%   Model = ModelSarVels(Partials, Model) updates structure Model with 
%   fields giving SAR velocities due to various contributions.
%

Model.Sar                                        = (Partials.srotation-Partials.selastic * Partials.slip)*Model.omegaEstRot + Partials.sramp*Model.omegaEstSarRamp;
Model.SarDef                                     = (Partials.selastic * Partials.slip)*Model.omegaEstRot;
Model.SarRot                                     = Partials.srotation*Model.omegaEstRot;
Model.SarRamp                                    = Partials.sramp*Model.omegaEstSarRamp;
Model.SarShift                                   = Model.SarRot + Model.SarRamp;
Model.SarTri                                     = Partials.stri(:, Index.triColkeep)*Model.omegaEstTriSlip;
Model.Sar                                        = Model.Sar - Model.SarTri;
Model.SarStrain                                  = Partials.sstrain*Model.omegaEstStrain;
Model.Sar                                        = Model.Sar + Model.SarStrain;  
Model.SarMogi                                    = Partials.smogi*Model.omegaEstMogi;
Model.Sar                                        = Model.Sar + Model.SarMogi;       

