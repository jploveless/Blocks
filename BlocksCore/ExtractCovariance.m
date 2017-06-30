function Model = ExtractCovariance(Model, Index)
% ExtractStateVector  Divides estimated model parameter covarainces into groups.
%   Model = ExtractCovariance(Model, Index) updates structure Model with 
%   fields covarianceRot, covarianceTriSlip, covarianceStrain, and covarianceSarRamp,
%   reflecting individual categories of estimated covariances, based on the
%   fields of structure Index.
%

Model.covarianceRot                              = Model.covariance(1:Index.szslip(2), 1:Index.szslip(2));
Model.covarianceTriSlip                          = Model.covariance(Index.szslip(2) + (1:Index.sztri(2)), Index.szslip(2) + (1:Index.sztri(2)));
Model.covarianceStrain                           = Model.covariance(Index.szslip(2) + Index.sztri(2) + (1:Index.szstrain(2)), Index.szslip(2) + Index.sztri(2) + (1:Index.szstrain(2)));
Model.covarianceMogi                             = Model.covariance(Index.szslip(2) + Index.sztri(2) + Index.szstrain(2) + (1:Index.szmogi(2)), Index.szslip(2) + Index.sztri(2) + Index.szstrain(2) + (1:Index.szmogi(2))); 
Model.covarianceSarRamp                          = Model.covariance(Index.szslip(2) + Index.sztri(2) + Index.szstrain(2) + Index.szmogi(2) + 1:end, Index.szslip(2) + Index.sztri(2) + Index.szstrain(2) + Index.szmogi(2) + 1:end);
