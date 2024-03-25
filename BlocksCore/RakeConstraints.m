function [rakeCon, Index, Data, Sigma] = RakeConstraints(Segment, Block, Index, Data, Sigma, Command);

fprintf('\n  Applying a priori rake constraints...')
% Build a priori rake rate constraints
rakeCon                                          = GetSlipPartials(Segment, Block);
% grab ss ds ts rows
rakeToggle                                       = stack3([Segment.rakeTog(:) Segment.rakeTog(:) Segment.rakeTog(:)]);
Index.rakeCon                                    = find(rakeToggle); 
rake                                             = Segment.rake(find(Segment.rakeTog));
rakeCon                                          = rakeCon(Index.rakeCon,:);
% cut either dip slip or tensile slip (whichever is zero)
rakeCon = rakeCon(max(rakeCon,[],2)>0,:);

% force rake to be positive
rake = wrapTo360(rake);

% rotate counterclockwise (only do if rake constraints are applied)
if sum(rakeToggle)>0
    rakeCon                                      = rakeCon(1:2:end,:)*sind(rake) + rakeCon(2:2:end,:)*cosd(rake);
end
% change index to give segment # because we only constrain in one direction
Index.rakeCon                                    = find(Segment.rakeTog(:)); 
Data.nRakeCon                                    = length(Index.rakeCon);
Data.rakeCon                                     = zeros(length(Data.nRakeCon));
Data.rake                                        = rake; 
Sigma.rakeCon                                    = Segment.rakeSig(Index.rakeCon);

% assign the constraint weight in the command file or a generic value
if exist('Command.rakeConWgt')
    Sigma.rakeConWgt                                 = Command.rakeConWgt; 
else 
    Sigma.rakeConWgt                                 = 1e+10; 
end
fprintf('done.')