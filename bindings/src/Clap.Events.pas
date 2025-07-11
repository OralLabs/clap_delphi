{ FROM "events.h" }
unit Clap.Events;

{$MINENUMSIZE 4}
{$scopedEnums ON}

interface

uses
    Clap.Fixedpoint, Clap.Id;

// event header
// All clap events start with an event header to determine the overall
// size of the event and its type and space (a namespacing for types).
// clap_event objects are contiguous regions of memory which can be copied
// with a memcpy of `size` bytes starting at the top of the header. As
// such, be very careful when designing clap events with internal pointers
// and other non-value-types to consider the lifetime of those members.
type 
PClapEventHeader    =   ^TClapEventHeader;
TClapEventHeader    =   packed record
    size    :   uint32; // event size including this header, eg: sizeof (clap_event_note)
    time    :   uint32; // sample offset within the buffer for this event
    spaceId :   uint16; // event space, see clap_host_event_registry
    &type   :   uint16; // event type
    flags   :   uint32; // see clap_event_flags
end;

// The clap core event space
const 
CORE_EVENT_SPACE_ID :   uint16  =   0;

type
TClapEventFlags = (
    // Indicate a live user event, for example a user turning a physical knob
    // or playing a physical key.
    IS_LIVE = 1 shl 0,

    // Indicate that the event should not be recorded.
    // For example this is useful when a parameter changes because of a MIDI CC,
    // because if the host records both the MIDI CC automation and the parameter
    // automation there will be a conflict.
    DONT_RECORD = 1 shl 1
);

// Some of the following events overlap, a note on can be expressed with:
// - CLAP_EVENT_NOTE_ON
// - CLAP_EVENT_MIDI
// - CLAP_EVENT_MIDI2
//
// The preferred way of sending a note event is to use CLAP_EVENT_NOTE_*.
//
// The same event must not be sent twice: it is forbidden to send a the same note on
// encoded with both CLAP_EVENT_NOTE_ON and CLAP_EVENT_MIDI.
//
// The plugins are encouraged to be able to handle note events encoded as raw midi or midi2,
// or implement clap_plugin_event_filter and reject raw midi and midi2 events.
TClapEventKind = (
   // NOTE_ON and NOTE_OFF represent a key pressed and key released event, respectively.
   // A NOTE_ON with a velocity of 0 is valid and should not be interpreted as a NOTE_OFF.
   //
   // NOTE_CHOKE is meant to choke the voice(s), like in a drum machine when a closed hihat
   // chokes an open hihat. This event can be sent by the host to the plugin. Here are two use
   // cases:
   // - a plugin is inside a drum pad in Bitwig Studio's drum machine, and this pad is choked by
   //   another one
   // - the user double-clicks the DAW's stop button in the transport which then stops the sound on
   //   every track
   //
   // NOTE_END is sent by the plugin to the host. The port, channel, key and note_id are those given
   // by the host in the NOTE_ON event. In other words, this event is matched against the
   // plugin's note input port.
   // NOTE_END is useful to help the host to match the plugin's voice life time.
   //
   // When using polyphonic modulations, the host has to allocate and release voices for its
   // polyphonic modulator. Yet only the plugin effectively knows when the host should terminate
   // a voice. NOTE_END solves that issue in a non-intrusive and cooperative way.
   //
   // CLAP assumes that the host will allocate a unique voice on NOTE_ON event for a given port,
   // channel and key. This voice will run until the plugin will instruct the host to terminate
   // it by sending a NOTE_END event.
   //
   // Consider the following sequence:
   // - process()
   //    Host->Plugin NoteOn(port:0, channel:0, key:16, time:t0)
   //    Host->Plugin NoteOn(port:0, channel:0, key:64, time:t0)
   //    Host->Plugin NoteOff(port:0, channel:0, key:16, t1)
   //    Host->Plugin NoteOff(port:0, channel:0, key:64, t1)
   //    # on t2, both notes did terminate
   //    Host->Plugin NoteOn(port:0, channel:0, key:64, t3)
   //    # Here the plugin finished processing all the frames and will tell the host
   //    # to terminate the voice on key 16 but not 64, because a note has been started at t3
   //    Plugin->Host NoteEnd(port:0, channel:0, key:16, time:ignored)
   //
   // These four events use clap_event_note.
   NOTE_ON = 0,
   NOTE_OFF = 1,
   NOTE_CHOKE = 2,
   NOTE_END = 3,

   // Represents a note expression.
   // Uses clap_event_note_expression.
   NOTE_EXPRESSION = 4,

   // PARAM_VALUE sets the parameter's value; uses clap_event_param_value.
   // PARAM_MOD sets the parameter's modulation amount; uses clap_event_param_mod.
   //
   // The value heard is: param_value + param_mod.
   //
   // In case of a concurrent global value/modulation versus a polyphonic one,
   // the voice should only use the polyphonic one and the polyphonic modulation
   // amount will already include the monophonic signal.
   PARAM_VALUE = 5,
   PARAM_MOD = 6,

   // Indicates that the user started or finished adjusting a knob.
   // This is not mandatory to wrap parameter changes with gesture events, but this improves
   // the user experience a lot when recording automation or overriding automation playback.
   // Uses clap_event_param_gesture.
   PARAM_GESTURE_BEGIN = 7,
   PARAM_GESTURE_END = 8,

   TRANSPORT = 9,   // update the transport info; clap_event_transport
   MIDI = 10,       // raw midi event; clap_event_midi
   MIDI_SYSEX = 11, // raw midi sysex event; clap_event_midi_sysex
   MIDI2 = 12       // raw midi 2 event; clap_event_midi2
);

// Note on, off, end and choke events.
//
// Clap addresses notes and voices using the 4-value tuple
// (port, channel, key, note_id). Note on/off/end/choke
// events and parameter modulation messages are delivered with
// these values populated.
//
// Values in a note and voice address are either >= 0 if they
// are specified, or -1 to indicate a wildcard. A wildcard
// means a voice with any value in that part of the tuple
// matches the message.
//
// For instance, a (PCKN) of (0, 3, -1, -1) will match all voices
// on channel 3 of port 0. And a PCKN of (-1, 0, 60, -1) will match
// all channel 0 key 60 voices, independent of port or note id.
//
// Especially in the case of note-on note-off pairs, and in the
// absence of voice stacking or polyphonic modulation, a host may
// choose to issue a note id only at note on. So you may see a
// message stream like
//
// CLAP_EVENT_NOTE_ON  [0,0,60,184]
// CLAP_EVENT_NOTE_OFF [0,0,60,-1]
//
// and the host will expect the first voice to be released.
// Well constructed plugins will search for voices and notes using
// the entire tuple.
//
// In the case of note on events:
// - The port, channel and key must be specified with a value >= 0
// - A note-on event with a '-1' for port, channel or key is invalid and
//   can be rejected or ignored by a plugin or host.
// - A host which does not support note ids should set the note id to -1.
//
// In the case of note choke or end events:
// - the velocity is ignored.
// - key and channel are used to match active notes
// - note_id is optionally provided by the host
PClapEventNote  =   ^TClapEventNote;
TClapEventNote  =   packed record 
    header      :   TClapEventHeader;
    noteId      :   int32;  // host provided note id >= 0, or -1 if unspecified or wildcard
    portIndex   :   int16;  // port index from ext/note-ports; -1 for wildcard
    channel     :   int16;  // 0..15, same as MIDI1 Channel Number, -1 for wildcard
    key         :   int16;  // 0..127, same as MIDI1 Key Number (60==Middle C), -1 for wildcard
    velocity    :   double; // 0..1
end;

// Note Expressions are well named modifications of a voice targeted to
// voices using the same wildcard rules described above. Note Expressions are delivered
// as sample accurate events and should be applied at the sample when received.
//
// Note expressions are a statement of value, not cumulative. A PAN event of 0 followed by 1
// followed by 0.5 would pan hard left, hard right, and center. They are intended as
// an offset from the non-note-expression voice default. A voice which had a volume of
// -20db absent note expressions which received a +4db note expression would move the
// voice to -16db.
//
// A plugin which receives a note expression at the same sample as a NOTE_ON event
// should apply that expression to all generated samples. A plugin which receives
// a note expression after a NOTE_ON event should initiate the voice with default
// values and then apply the note expression when received. A plugin may make a choice
// to smooth note expression streams.
TClapNoteExpression = (
    // with 0 < x <= 4, plain = 20 * log(x)
    VOLUME      = 0,

    // pan, 0 left, 0.5 center, 1 right
    PAN         = 1,

    // Relative tuning in semitones, from -120 to +120. Semitones are in
    // equal temperament and are doubles; the resulting note would be
    // retuned by `100 * evt->value` cents.
    TUNING      = 2,

    // 0..1
    VIBRATO     = 3,
    EXPRESSION  = 4,
    BRIGHTNESS  = 5,
    PRESSURE    = 6
);

PClapEventNoteExpression    =   ^TClapEventNoteExpression;
TClapEventNoteExpression    =   packed record
    header          :   TClapEventHeader;

    expressionId    :   TClapNoteExpression;

    // target a specific note_id, port, key and channel, with
    // -1 meaning wildcard, per the wildcard discussion above
    noteId          :   int32;
    portIndex       :   int16;
    channel         :   int16;
    key             :   int16;

   value            :   double; // see expression for the range
end;

PClapEventParamValue    =   ^TClapEventParamValue;
TClapEventParamValue    =   packed record
    header      :   TClapEventHeader;

    // target parameter
    paramId     :   TClapId;    // @ref clap_param_info.id
    cookie      :   Pointer;    // @ref clap_param_info.cookie

    // target a specific note_id, port, key and channel, with
    // -1 meaning wildcard, per the wildcard discussion above
    noteId      :   int32;
    portIndex   :   int16;
    channel     :   int16;
    key         :   int16;

    value       :   double;
end;

PClapEventParamMod  =   ^TClapEventParamMod;
TClapEventParamMod  =   packed record
    header      :   TClapEventHeader;

    // target parameter
    paramId     : TClapId;  // @ref clap_param_info.id
    cookie      : Pointer;  // @ref clap_param_info.cookie

    // target a specific note_id, port, key and channel, with
    // -1 meaning wildcard, per the wildcard discussion above
    noteId      :   int32;
    portIndex   :   int16;
    channel     :   int16;
    key         :   int16;

    amount      :   double; // modulation amount
end;

PClapEventParamGesture  =   ^TClapEventParamGesture;
TClapEventParamGesture  =   packed record
    header      :   TClapEventHeader;

    // target parameter
    paramId     :   TClapId;    // @ref clap_param_info.id
end;

TClapTransportFlags = (
    HAS_TEMPO               = 1 shl 0,
    HAS_BEATS_TIMELINE      = 1 shl 1,
    HAS_SECONDS_TIMELINE    = 1 shl 2,
    HAS_TIME_SIGNATURE      = 1 shl 3,
    IS_PLAYING              = 1 shl 4,
    IS_RECORDING            = 1 shl 5,
    IS_LOOP_ACTIVE          = 1 shl 6,
    IS_WITHIN_PRE_ROLL      = 1 shl 7
);

// clap_event_transport provides song position, tempo, and similar information
// from the host to the plugin. There are two ways a host communicates these values.
// In the `clap_process` structure sent to each processing block, the host may
// provide a transport structure which indicates the available information at the
// start of the block. If the host provides sample-accurate tempo or transport changes,
// it can also provide subsequent inter-block transport updates by delivering a new event.
PClapEventTransport =   ^TClapEventTransport;
TClapEventTransport =   packed record
    header          :   TClapEventHeader;

    flags           :   uint32;         // see clap_transport_flags

    songPosBeats    :   TClapBeatTime;  // position in beats
    songPosSecs     :   TClapSecTime;   // position in seconds

    tempo           :   double;         // in bpm
    tempoInc        :   double;         // tempo increment for each sample and until the next time info event

    loopStartBeats  :   TClapBeatTime;
    loopEndBeats    :   TClapBeatTime;
    loopStartSecs   :   TClapSecTime;
    loopEndSecs     :   TClapSecTime;

    barStart        :   TClapBeatTime;  // start pos of the current bar
    barNumber       :   int32;          // bar at song pos 0 has the number 0

    timeSigNum      :   uint16;         // time signature numerator
    timeSigDenom    :   UInt16;         // time signature denominator
end;

PClapEventMidi  =   ^TClapEventMidi;
TClapEventMidi  =   packed record
    header  :   TClapEventHeader;

    portIndex   :   uint16;
    data        :   array[0..2] of uint8;
end;

// clap_event_midi_sysex contains a pointer to a sysex contents buffer.
// The lifetime of this buffer is (from host->plugin) only the process
// call in which the event is delivered or (from plugin->host) only the
// duration of a try_push call.
//
// Since `clap_output_events.try_push` requires hosts to make a copy of
// an event, host implementers receiving sysex messages from plugins need
// to take care to both copy the event (so header, size, etc...) but
// also memcpy the contents of the sysex pointer to host-owned memory, and
// not just copy the data pointer.
//
// Similarly plugins retaining the sysex outside the lifetime of a single
// process call must copy the sysex buffer to plugin-owned memory.
//
// As a consequence, the data structure pointed to by the sysex buffer
// must be contiguous and copyable with `memcpy` of `size` bytes.
PClapEventMidiSysex =   ^TClapEventMidiSysex;
TClapEventMidiSysex =   packed record
    header      :   TClapEventHeader;

    portIndex   :   uint16;
    buffer      :   ^uint8; // midi buffer. See lifetime comment above.
    size        :   uint32;
end;

// While it is possible to use a series of midi2 event to send a sysex,
// prefer clap_event_midi_sysex if possible for efficiency.
PClapEventMidi2 =   ^TClapEventMidi2;
TClapEventMidi2 =   packed record
    header      :   TClapEventHeader;

    portIndex   :   uint16;
    data        :   array[0..3] of uint32;
end;

// Input event list. The host will deliver these sorted in sample order.
PClapInputEvents    =   ^TClapInputEvents;
TClapInputEvents    =   packed record
    ctx         :   Pointer; // reserved pointer for the list //TODO

    // returns the number of events in the list
    procSize    :   function(const list: PClapInputEvents): uint32; cdecl;

    // Don't free the returned event, it belongs to the list
    procGet     :   function(const list: PClapInputEvents; const &index: uint32): PClapEventHeader; cdecl;
end;

// Output event list. The plugin must insert events in sample sorted order when inserting events
PClapOutputEvents   =   ^TClapOutputEvents;
TClapOutputEvents   =   packed record
    ctx         :   Pointer; // reserved pointer for the list //TODO

    // Pushes a copy of the event
    // returns false if the event could not be pushed to the queue (out of memory?)
    procTryPush :   function(const list: PClapOutputEvents; const event: PClapEventHeader): boolean; cdecl;
end;


implementation

end.