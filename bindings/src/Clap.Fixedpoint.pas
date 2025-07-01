{ FROM "fixedpoint.h" }
unit Clap.FixedPoint;

{$MINENUMSIZE 4}
{$scopedEnums ON}

interface

/// We use fixed point representation of beat time and seconds time
/// Usage:
///   double x = ...; // in beats
///   clap_beattime y = round(CLAP_BEATTIME_FACTOR * x);

type
PClapBeatTime   =   ^TClapBeatTime;
TClapBeatTime   =   int64;
PClapSecTime    =   ^TClapSecTime;
TClapSecTime    =   int64;

// This will never change
const
BEATTIME_FACTOR   :   TClapBeatTime =   1 shl 31;
SECTIME_FACTOR    :   TClapSecTime  =   1 shl 31;

implementation

end.
