function [strain, Index, Model]            = GetStrainPartials(Block, Station, Segment, Command, Index);
% GetStrainPartials   Wrapper function for calculating strain partial derivatives.


[strain, Index.strainBlock]                = deal(zeros(3*numel(Station.lon), 0), []);
[Model.lonStrain, Model.latStrain]         = deal(zeros(size(Block.interiorLon)));

if sum(Block.rotationInfo) > 0 % If any blocks have strain turned on
   switch Command.strainMethod
      case 1 % use the block centroid
         [strain, Index.strainBlock,...
          Model.lonStrain, Model.latStrain]   = GetStrainCentroidPartials(Block, Station, Segment);
      case 2 % solve for the reference coordinates
         [strain, Index.strainBlock]          = GetStrain56Partials(Block, Station, Segment);
      case 3 % solve for the reference latitude only
         [strain, Index.strainBlock]          = GetStrain34Partials(Block, Station, Segment);
      case 4 % use the simulated annealing approach to solve for reference coordinates inside the block boundaries
         [strain, Index.strainBlock]          = GetStrainSearchPartials(Block, Station, Segment);
   end      
end