{ FROM "timestamp.h" }
unit Clap.Timestamp;

{$MINENUMSIZE 4}
{$scopedEnums ON}

interface

// This type defines a timestamp: the number of seconds since UNIX EPOCH.
// See C's time_t time(time_t *).
type 
PClapTimestamp  =   ^TClapTimestamp;
TClapTimestamp  =   uint64;

// Value for unknown timestamp.
const 
UNKNOWN :   TClapTimestamp  =   0;

implementation

end.