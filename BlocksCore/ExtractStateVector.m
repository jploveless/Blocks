function Model = ExtractStateVector(Model, Index)
% ExtractStateVector  Divides estimated model parameters into groups.
%   Model = ExtractStateVector(Model, Index) updates structure Model with 
%   fields omegaEstRot, omegaEstTriSlip, omegaEstStrain, and omegaEstSarRamp,
%   reflecting individual categories of estimated parameters, based on the
%   fields of structure Index.
%

Model.omegaEstRot                                = Model.omegaEst(1:Index.szslip(2)); % rotation parameters
Model.omegaEstTriSlip                            = Model.omegaEst(Index.szslip(2) + (1:Index.sztri(2))); % triangular slips
Model.omegaEstStrain                             = Model.omegaEst(Index.szslip(2) + Index.sztri(2) + (1:Index.szstrain(2))); % strain parameters
Model.omegaEstMogi                               = Model.omegaEst(Index.szslip(2) + Index.sztri(2) + Index.szstrain(2) + (1:Index.szmogi(2))); % Mogi source volume changes
Model.omegaEstSarRamp                            = Model.omegaEst(Index.szslip(2) + Index.sztri(2) + Index.szstrain(2) + Index.szmogi(2) + 1:end); % SAR ramp parameters
