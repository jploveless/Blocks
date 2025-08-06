function stats = runsuitequery(faultnames, statsnames)
% runsuitequery  Queries fault results across a range of Blocks models
%    stats = runsuitequery(faultnames, statsnames) returns a set of 
%    summary statistics from a suite of Blocks runs. One or more faults
%    should be specified in the character array faultnames, and one or 
%    more statistic types should be specified in the character array
%    