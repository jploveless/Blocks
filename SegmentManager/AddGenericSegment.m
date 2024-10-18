function Segment = AddGenericSegment(Segment, newSegmentName, lon1, lat1, lon2, lat2)
%%  AddGenericSegment

Segment.name          = strvcat(Segment.name, newSegmentName);
Segment.lon1          = [Segment.lon1 ; lon1];
Segment.lat1          = [Segment.lat1 ; lat1];
Segment.lon2          = [Segment.lon2 ; lon2];
Segment.lat2          = [Segment.lat2 ; lat2];

Segment.midLon        = [Segment.midLon; 0.5*(lon1 + lon2)];
Segment.midLat        = [Segment.midLat; 0.5*(lat1 + lat2)];

ba                    = ones(size(lon1)); % Blank array for propagating through all properties

Segment.lDep          = [Segment.lDep ; 15*ba];
Segment.lDepSig       = [Segment.lDepSig ; 5*ba];
Segment.lDepTog       = [Segment.lDepTog ; 0*ba];

Segment.dip           = [Segment.dip ; 90*ba];
Segment.dipSig        = [Segment.dipSig ; 1*ba];
Segment.dipTog        = [Segment.dipTog ; 0*ba];

Segment.ssRate        = [Segment.ssRate ; 0*ba];
Segment.ssRateSig     = [Segment.ssRateSig ; 1*ba];
Segment.ssRateTog     = [Segment.ssRateTog ; 0*ba];

Segment.dsRate        = [Segment.dsRate ; 0*ba];
Segment.dsRateSig     = [Segment.dsRateSig ; 1*ba];
Segment.dsRateTog     = [Segment.dsRateTog ; 0*ba];

Segment.tsRate        = [Segment.tsRate ; 0*ba];
Segment.tsRateSig     = [Segment.tsRateSig ; 1*ba];
Segment.tsRateTog     = [Segment.tsRateTog ; 0*ba];

Segment.bDep          = [Segment.bDep ; 15*ba];
Segment.bDepSig       = [Segment.bDepSig ; 5*ba];
Segment.bDepTog       = [Segment.bDepTog ; 0*ba];

Segment.res           = [Segment.res ; 100*ba];
Segment.resOver       = [Segment.resOver ; 0*ba];
Segment.resOther      = [Segment.resOther ; 0*ba];

Segment.patchFile     = [Segment.patchFile ; 0*ba];
Segment.patchTog      = [Segment.patchTog ; 0*ba];
Segment.other3        = [Segment.other3  ; 0*ba];

Segment.patchSlipFile = [Segment.patchSlipFile ; 0*ba];
Segment.patchSlipTog  = [Segment.patchSlipTog  ; 0*ba];
Segment.other6        = [Segment.other6 ; 0*ba];

Segment.rake          = [Segment.rake ; 0*ba];
Segment.rakeSig       = [Segment.rakeSig ; 0*ba];  
Segment.rakeTog       = [Segment.rakeTog   ; 0*ba];

Segment.other7        = [Segment.other7 ; 0*ba];
Segment.other8        = [Segment.other8 ; 0*ba];
Segment.other9        = [Segment.other9 ; 0*ba];


