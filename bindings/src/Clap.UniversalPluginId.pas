{ FROM "universal-plugin-id.h" }
unit Clap.UniversalPluginId;

{$MINENUMSIZE 4}
{$scopedEnums ON}

interface

// Pair of plugin ABI and plugin identifier.
//
// If you want to represent other formats please send us an update to the comment with the
// name of the abi and the representation of the id.
type 
PClapUniversalPluginId  =   ^TClapUniversalPluginId;
TClapUniversalPluginId  =   packed record
    // The plugin ABI name, in lowercase and null-terminated.
    // eg: "clap", "vst3", "vst2", "au", ...
    abi :   PAnsiChar;

    // The plugin ID, null-terminated and formatted as follows:
    //
    // CLAP: use the plugin id
    //   eg: "com.u-he.diva"
    //
    // AU: format the string like "type:subt:manu"
    //   eg: "aumu:SgXT:VmbA"
    //
    // VST2: print the id as a signed 32-bits integer
    //   eg: "-4382976"
    //
    // VST3: print the id as a standard UUID
    //   eg: "123e4567-e89b-12d3-a456-426614174000"
    id  :   PAnsiChar;
end;

implementation

end.