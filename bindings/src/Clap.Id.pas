{ FROM "id.h" }
unit Clap.Id;

{$MINENUMSIZE 4}
{$scopedEnums ON}

interface

type 
PClapId =   ^TClapId;
TClapId =   uint32;

const 
INVALID :   TClapId =   high(TClapId);

implementation

end.