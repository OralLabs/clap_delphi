{ FROM "factory/draft/plugin-state-converter.h" }
unit Clap.Factory.PluginStateConverter;

{$MINENUMSIZE 4}
{$scopedEnums ON}

interface

uses
    Clap.Id, Clap.UniversalPluginId, Clap.Stream, Clap.Version;

type
PClapPluginStateConverterDescriptor =   ^TClapPluginStateConverterDescriptor;
TClapPluginStateConverterDescriptor =   packed record
    clapVersion :   TClapVersion;

    srcPluginId :   TClapUniversalPluginId;
    dstPluginId :   TClapUniversalPluginId;

    id          :   PAnsiChar;  // eg: "com.u-he.diva-converter", mandatory
    name        :   PAnsiChar;  // eg: "Diva Converter", mandatory
    vendor      :   PAnsiChar;  // eg: "u-he"
    version     :   PAnsiChar;  // eg: 1.1.5
    description :   PAnsiChar;  // eg: "Official state converter for u-he Diva."
end;

// This interface provides a mechanism for the host to convert a plugin state and its automation
// points to a new plugin.
//
// This is useful to convert from one plugin ABI to another one.
// This is also useful to offer an upgrade path: from EQ version 1 to EQ version 2.
// This can also be used to convert the state of a plugin that isn't maintained anymore into
// another plugin that would be similar.
PClapPluginStateConverter   =   ^TClapPluginStateConverter;
TClapPluginStateConverter   =   packed record
    desc                        :   PClapPluginStateConverterDescriptor;

    converterData               :   Pointer;    //TODO

    // Destroy the converter.
    procDestroy                 :   procedure(const converter: PClapPluginStateConverter); cdecl;

    // Converts the input state to a state usable by the destination plugin.
    //
    // error_buffer is a place holder of error_buffer_size bytes for storing a null-terminated
    // error message in case of failure, which can be displayed to the user.
    //
    // Returns true on success.
    // [thread-safe]
    procConvertState            :   function(const converter: PClapPluginStateConverter; const src: PClapInputStream; 
        const dst: PClapOutputStream; const errorBuffer: PAnsiChar; const errorBufferSize: NativeUInt): boolean; cdecl;

    // Converts a normalized value.
    // Returns true on success.
    // [thread-safe]
    procConvertNormalizedValue  :   function(const converter: PClapPluginStateConverter; const srcParamId: TClapId;
        const srcNormalizedValue: double; const dstParamId: PClapId; const dstNormalizedValue: PDouble): boolean; cdecl;

    // Converts a plain value.
    // Returns true on success.
    // [thread-safe]
    procConvertPlainValue       :   function(const converter: PClapPluginStateConverter; const srcParamId: TClapId;
        const srcPlainValue: double; const dstParamId: PClapId; const dstPlainValue: PDouble): boolean; cdecl;
end;

// Factory identifier
const
PLUGIN_STATE_CONVERTER_FACTORY_ID   :   PAnsiChar   =   'clap.plugin-state-converter-factory/1';

type
// List all the plugin state converters available in the current DSO.
PClapPluginStateConverterFactory    =   ^TClapPluginStateConverterFactory;
TClapPluginStateconverterFactory    =   packed record
    // Get the number of converters.
    // [thread-safe]
    procCount           :   function(const factory: PClapPluginStateconverterFactory):  uint32;

    // Retrieves a plugin state converter descriptor by its index.
    // Returns null in case of error.
    // The descriptor must not be freed.
    // [thread-safe]
    procGetDescriptor   :   function(const factory: PClapPluginStateConverterFactory; const &index: uint32): PClapPluginStateConverterDescriptor; cdecl;

   // Create a plugin state converter by its converter_id.
   // The returned pointer must be freed by calling converter->destroy(converter);
   // Returns null in case of error.
   // [thread-safe]
   procCreate           :   function(const factory: PClapPluginStateConverterFactory; const converterId: PAnsiChar): PClapPluginStateConverter; cdecl;
end;

implementation

end.