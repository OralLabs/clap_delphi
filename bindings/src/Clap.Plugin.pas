{ FROM "plugin.h" }
unit Clap.Plugin;

{$MINENUMSIZE 4}
{$scopedEnums ON}

interface

uses
    Clap.Host, Clap.Process, Clap.PluginFeatures, Clap.Version;


type
PAnsiCharArray =  ^PAnsiChar;

PClapPluginDescriptor   =  ^TClapPluginDescriptor;
TClapPluginDescriptor   =  packed record
   clapVersion :  TClapVersion;  // initialized to CLAP_VERSION

   // Mandatory fields must be set and must not be blank.
   // Otherwise the fields can be null or blank, though it is safer to make them blank.
   //
   // Some indications regarding id and version
   // - id is an arbitrary string which should be unique to your plugin,
   //   we encourage you to use a reverse URI eg: "com.u-he.diva"
   // - version is an arbitrary string which describes a plugin,
   //   it is useful for the host to understand and be able to compare two different
   //   version strings, so here is a regex like expression which is likely to be
   //   understood by most hosts: MAJOR(.MINOR(.REVISION)?)?( (Alpha|Beta) XREV)?
   id          :  PAnsiChar;  // eg: "com.u-he.diva", mandatory
   name        :  PAnsiChar;  // eg: "u-he"
   vendor      :  PAnsiChar;  // eg: "Diva", mandatory
   url         :  PAnsiChar;  // eg: "https://u-he.com/products/diva/"
   manualUrl   :  PAnsiChar;  // eg: "https://dl.u-he.com/manuals/plugins/diva/Diva-user-guide.pdf" 
   supportUrl  :  PAnsiChar;  // eg: "https://u-he.com/support/" 
   version     :  PAnsiChar;  // eg: "1.4.4"
   description :  PAnsiChar;  // eg: "The spirit of analogue"

   // Arbitrary list of keywords.
   // They can be matched by the host indexer and used to classify the plugin.
   // The array of pointers must be null terminated.
   // For some standard features see plugin-features.h
   features    :  PAnsiCharArray;
end;

type
PClapPlugin =  ^TClapPlugin;
TClapPlugin =  packed record
   desc                 :  PClapPluginDescriptor;

   data                 :  Pointer; // reserved pointer for the plugin //TODO 

   // Must be called after creating the plugin.
   // If init returns false, the host must destroy the plugin instance.
   // If init returns true, then the plugin is initialized and in the deactivated state.
   // Unlike in `plugin-factory::create_plugin`, in init you have complete access to the host 
   // and host extensions, so clap related setup activities should be done here rather than in
   // create_plugin.
   // [main-thread]
   procInit             :  function(const plugin: PClapPlugin): boolean; cdecl;

   // Free the plugin and its resources.
   // It is required to deactivate the plugin prior to this call.
   // [main-thread & !active]
   procDestroy          :  procedure(const plugin: PClapPlugin); cdecl;

   // Activate and deactivate the plugin.
   // In this call the plugin may allocate memory and prepare everything needed for the process
   // call. The process's sample rate will be constant and process's frame count will included in
   // the [min, max] range, which is bounded by [1, INT32_MAX].
   // In this call the plugin may call host-provided methods marked [being-activated].
   // Once activated the latency and port configuration must remain constant, until deactivation.
   // Returns true on success.
   // [main-thread & !active]
   procActivate         :  function(const plugin: PClapPlugin; const sampleRate: double; const minFramesCount, maxFramesCount: uint32): boolean; cdecl;
   
   // [main-thread & active]
   procDeactivate       :  procedure(const plugin: PClapPlugin); cdecl;

   // Call start processing before processing.
   // Returns true on success.
   // [audio-thread & active & !processing]
   procStartProcessing  :  function(const plugin: PClapPlugin): boolean; cdecl;

   // Call stop processing before sending the plugin to sleep.
   // [audio-thread & active & processing]
   procStopProcessing   :  procedure(const plugin: PClapPlugin); cdecl;

   // - Clears all buffers, performs a full reset of the processing state (filters, oscillators,
   //   envelopes, lfo, ...) and kills all voices.
   // - The parameter's value remain unchanged.
   // - clap_process.steady_time may jump backward.
   //
   // [audio-thread & active]
   procReset            :  procedure(const plugin: PClapPlugin); cdecl;

   // process audio, events, ...
   // All the pointers coming from clap_process_t and its nested attributes,
   // are valid until process() returns.
   // [audio-thread & active & processing]
   procProcess          :  function(const plugin: PClapPlugin; const process: PClapProcess): TClapProcessStatus; cdecl;

   // Query an extension.
   // The returned pointer is owned by the plugin.
   // It is forbidden to call it before plugin->init().
   // You can call it within plugin->init() call, and after.
   // [thread-safe]
   procGetExtension     :  function(const plugin: PClapPlugin; const id: PAnsiChar): Pointer; cdecl; //TODO

   // Called by the host on the main thread in response to a previous call to:
   //   host->request_callback(host);
   // [main-thread]
   procOnMainThread     :  procedure(const plugin: PClapPlugin); cdecl;
end;

implementation

end.