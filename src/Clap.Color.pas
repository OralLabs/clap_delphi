{ FROM "color.h" }
unit Clap.Color;

interface

type
    TClapColor  =   packed record
        alpha   :   uint8;
        red     :   uint8;
        green   :   uint8;
        blue    :   uint8;
    end;

const
    TRANSPARENT :   TClapColor  =   (
        alpha   :   0,
        red     :   0,
        green   :   0,
        blue    :   0
    );

implementation

end.