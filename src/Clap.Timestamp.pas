{ FROM "timestamp.h" }
unit Clap.Timestamp;

interface

type
    // This type defines a timestamp: the number of seconds since UNIX EPOCH.
    // See C's time_t time(time_t *).
    TClapTimestamp  =   uint64;

const
    // Value for unknown timestamp.
    UNKNOWN :   TClapTimestamp  =   0;

implementation

end.