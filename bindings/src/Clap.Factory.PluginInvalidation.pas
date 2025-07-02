{ FROM "factory/draft/plugin-invalidation.h" }
unit Clap.Factory.PluginInvalidation;

{$MINENUMSIZE 4}
{$scopedEnums ON}

interface

// Use it to retrieve const clap_plugin_invalidation_factory_t* from
// clap_plugin_entry.get_factory()
const
    INVALIDATION_FACTORY_ID :   PAnsiChar   =   'clap.plugin-invalidation-factory/1';

type
PClapPluginInvalidationSource   =   ^TClapPluginInvalidationSource;
TClapPluginInvalidationSource   =   packed record
    // Directory containing the file(s) to scan, must be absolute
    directory       :   PAnsiChar;

    // globing pattern, in the form *.dll
    filenameGlob    :   PAnsiChar;

    // should the directory be scanned recursively?
    recursiveScan   :   boolean;
end;

// Used to figure out when a plugin needs to be scanned again.
// Imagine a situation with a single entry point: my-plugin.clap which then scans itself
// a set of "sub-plugins". New plugin may be available even if my-plugin.clap file doesn't change.
// This interfaces solves this issue and gives a way to the host to monitor additional files.
PClapPluginInvalidationFactory  =   ^TClapPluginInvalidationFactory;
TClapPluginInvalidationFactory  =   packed record
    // Get the number of invalidation source.
    procCount   :   function(const factory: PClapPluginInvalidationFactory): uint32; cdecl;

    // Get the invalidation source by its index.
    // [thread-safe]
    procGet     :   function(const factory: PClapPluginInvalidationFactory; const &index: uint32): PClapPluginInvalidationSource; cdecl;

    // In case the host detected a invalidation event, it can call refresh() to let the
    // plugin_entry update the set of plugins available.
    // If the function returned false, then the plugin needs to be reloaded.
    procRefresh :   function(const factory: PClapPluginInvalidationFactory): boolean; cdecl;
end;

implementation

end.