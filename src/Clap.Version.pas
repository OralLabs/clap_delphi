{ FROM "version.h" }
unit Clap.Version;

interface

type
    TClapVersion    =   packed record
        // This is the major ABI and API design
        // Version 0.X.Y correspond to the development stage, API and ABI are not stable
        // Version 1.X.Y correspond to the release stage, API and ABI are stable
        major       :   uint32;
        minor       :   uint32;
        revision    :   uint32;
    end:

const
    MAJOR       :   uint32  =   1;
    MINOR       :   uint32  =   2;
    REVISION    :   uint32  =   6;

    VERSION :   TClapVersion    = (
        MAJOR,
        MINOR,
        REVISION
    );

// TODO functions
//function clapVersionLowerThan(const maj, min, rev: uint32): boolean;
//function clapVersionEqual(const maj, min, rev: uint32): boolean; 
//function clapVersionGreaterEqual(const maj, min, rev: uint32): boolean; 

function isCompatible(const version: TClapVersion): boolean; inline;

implementation

function isCompatible(const version: TClapVersion): boolean; inline;
begin
    // versions 0.x.y were used during development stage and aren't compatible
    result  :=  (version.major >= 1);
end;

end.