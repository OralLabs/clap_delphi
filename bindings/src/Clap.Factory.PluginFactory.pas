{ FROM "factory/plugin-factory.h" }
unit Clap.Factory.PluginFactory;

{$MINENUMSIZE 4}
{$scopedEnums ON}

interface

uses
    Clap.Plugin, Clap.Host;

const
PLUGIN_FACTORY_ID   :   PAnsiChar   =   'clap.plugin-factory';

// Every method must be thread-safe.
// It is very important to be able to scan the plugin as quickly as possible.
//
// The host may use clap_plugin_invalidation_factory to detect filesystem changes
// which may change the factory's content.
type
PClapPluginFactory  =   ^TClapPluginFactory;
TClapPluginFactory  =   packed record
    // Get the number of plugins available.
    // [thread-safe]
    procGetPluginCount      :   function(const factory: PClapPluginFactory): uint32; cdecl;

    // Retrieves a plugin descriptor by its index.
    // Returns null in case of error.
    // The descriptor must not be freed.
    // [thread-safe]
    procGetPluginDescriptor :   function(const factory: PClapPluginFactory; const &index: uint32): PClapPluginDescriptor; cdecl;

    // Create a clap_plugin by its plugin_id.
    // The returned pointer must be freed by calling plugin->destroy(plugin);
    // The plugin is not allowed to use the host callbacks in the create method.
    // Returns null in case of error.
    // [thread-safe]
    procCreatePlugin        :   function(const factory: PClapPluginFactory; const host: PClapHost; const pluginId: PAnsiChar):
        PClapPlugin; cdecl;
end;

implementation

end.