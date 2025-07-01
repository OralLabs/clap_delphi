{ FROM "host.h" }
unit Clap.Host;

{$MINENUMSIZE 4}
{$scopedEnums ON}

interface

uses
Clap.Version;

type
PClapHost   =   ^TClapHost;
TClapHost   =   packed record

    clapVersion :   TClapVersion;   // initialized to CLAP_VERSION

    hostData    :   Pointer;    //TODO

    // name and version are mandatory.
    name        :   PAnsiChar;  // eg: "Bitwig Studio"
    vendor      :   PAnsiChar;  // eg: "Bitwig GmbH"
    url         :   PAnsiChar;  // eg: "https://bitwig.com"
    version     :   PAnsiChar; // eg: "4.3", see plugin.h for advice on how to format the version

    // Query an extension.
    // The returned pointer is owned by the host.
    // It is forbidden to call it before plugin->init().
    // You can call it within plugin->init() call, and after.
    // [thread-safe]
    procGetExtension    :   function(const host: PClapHost; const extensionId: PAnsiChar): Pointer; cdecl;  //TODO

    // Request the host to deactivate and then reactivate the plugin.
    // The operation may be delayed by the host.
    // [thread-safe]
    procRequestRestart  :   procedure(const host: PClapHost); cdecl;

    // Request the host to activate and start processing the plugin.
    // This is useful if you have external IO and need to wake up the plugin from "sleep".
    // [thread-safe]
    procRequestProcess  :   procedure(const host: PClapHost); cdecl;

    // Request the host to schedule a call to plugin->on_main_thread(plugin) on the main thread.
    // This callback should be called as soon as practicable, usually in the host application's next
    // available main thread time slice. Typically callbacks occur within 33ms / 30hz.
    // Despite this guidance, plugins should not make assumptions about the exactness of timing for
    // a main thread callback, but hosts should endeavour to be prompt. For example, in high load
    // situations the environment may starve the gui/main thread in favor of audio processing,
    // leading to substantially longer latencies for the callback than the indicative times given
    // here.
    // [thread-safe]
    procRequestCallback :   procedure(const host: PClapHost); cdecl;
end;

implementation

end.