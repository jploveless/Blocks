function Segment = AlphaSortSegment(Segment)
%%  Sorts a Segment struct into alphabetical order by fault name

%%  Sort the segments into alphabetical order
[~, sortAlphaIndex]                                        = sort(cellstr(Segment.name));
Segment = structsubset(Segment, sortAlphaIndex);

%Segment.name                                                         = char(segmentName);
%
%Segment.lon1                                                         = Segment.lon1(sortAlphaIndex);
%Segment.lat1                                                         = Segment.lat1(sortAlphaIndex);
%Segment.lon2                                                         = Segment.lon2(sortAlphaIndex);
%Segment.lat2                                                         = Segment.lat2(sortAlphaIndex);
%
%Segment.lDep                                                         = Segment.lDep(sortAlphaIndex);
%Segment.lDepSig                                                      = Segment.lDepSig(sortAlphaIndex);
%Segment.lDepTog                                                      = Segment.lDepTog(sortAlphaIndex);
%
%Segment.bDep                                                         = Segment.bDep(sortAlphaIndex);
%Segment.bDepSig                                                      = Segment.bDepSig(sortAlphaIndex);
%Segment.bDepTog                                                      = Segment.bDepTog(sortAlphaIndex);
%
%Segment.dip                                                          = Segment.dip(sortAlphaIndex);
%Segment.dipSig                                                       = Segment.dipSig(sortAlphaIndex);
%Segment.dipTog                                                       = Segment.dipTog(sortAlphaIndex);
%
%Segment.ssRate                                                       = Segment.ssRate(sortAlphaIndex);
%Segment.ssRateSig                                                    = Segment.ssRateSig(sortAlphaIndex);
%Segment.ssRateTog                                                    = Segment.ssRateTog(sortAlphaIndex);
%
%Segment.dsRate                                                       = Segment.dsRate(sortAlphaIndex);
%Segment.dsRateSig                                                    = Segment.dsRateSig(sortAlphaIndex);
%Segment.dsRateTog                                                    = Segment.dsRateTog(sortAlphaIndex);
%
%Segment.tsRate                                                       = Segment.tsRate(sortAlphaIndex);
%Segment.tsRateSig                                                    = Segment.tsRateSig(sortAlphaIndex);
%Segment.tsRateTog                                                    = Segment.tsRateTog(sortAlphaIndex);
%
%Segment.res                                                          = Segment.res(sortAlphaIndex);
%Segment.resOver                                                      = Segment.resOver(sortAlphaIndex);
%Segment.resOther                                                     = Segment.resOther(sortAlphaIndex);
%
%Segment.other1                                                       = Segment.other1(sortAlphaIndex);
%Segment.other2                                                       = Segment.other2(sortAlphaIndex);
%Segment.other3                                                       = Segment.other3(sortAlphaIndex);
%Segment.other4                                                       = Segment.other4(sortAlphaIndex);
%Segment.other5                                                       = Segment.other5(sortAlphaIndex);
%Segment.other6                                                       = Segment.other6(sortAlphaIndex);
%Segment.other7                                                       = Segment.other7(sortAlphaIndex);
%Segment.other8                                                       = Segment.other8(sortAlphaIndex);
%Segment.other9                                                       = Segment.other9(sortAlphaIndex);
%Segment.other10                                                      = Segment.other10(sortAlphaIndex);
%Segment.other11                                                      = Segment.other11(sortAlphaIndex);
%Segment.other12                                                      = Segment.other12(sortAlphaIndex);
%
%Segment.patchName                                                    = Segment.patchName(sortAlphaIndex, :);
%Segment.patchFlag01                                                  = Segment.patchFlag01(sortAlphaIndex);
%Segment.patchFlag02                                                  = Segment.patchFlag02(sortAlphaIndex);