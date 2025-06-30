{ FROM "plugin-features.h" }
unit Clap.PluginFeatures;

{$ScopedEnums ON}

// This file provides a set of standard plugin features meant to be used
// within clap_plugin_descriptor.features.
//
// For practical reasons we'll avoid spaces and use `-` instead to facilitate
// scripts that generate the feature array.
//
// Non-standard features should be formatted as follow: "$namespace:$feature"

interface

/////////////////////
// Plugin category //
/////////////////////

type
    // ATTENTION: CUSTOM, INTERNAL
    // Enum type for plugin main feature kinds
    TClapPluginMainFeature  =   (
        INSTRUMENT,
        AUDIO_EFFECT,
        NOTE_EFFECT,
        NOTE_DETECTOR,
        ANALYZER,
    );

const
    // corresponding String Array
    MAIN_FEATURES   :   array[low(TClapPluginMainFeature)..high(TClapPluginMainFeature)] of PAnsiChar   =   (
        'instrument',
        'audio-effect',
        'note-effect',
        'note-detector',
        'analyzer'
    );

/////////////////////////
// Plugin sub-category //
/////////////////////////

type
    // ATTENTION: CUSTOM, INTERNAL
    // Enum type for plugin sub feature kinds
    TClapPluginSubFeature   =   (
        // Instruments
        SYNTHESIZER,
        SAMPLER,
        DRUM,               // For single drum
        DRUM_MACHINE,
        // Effects  -   1
        FILTER,
        PHASER,
        EQUALIZER,
        DEESSER,
        PHASE_VOCODER,
        GRANULAR,
        FREQUENCY_SHIFTER,
        PITCH_SHIFTER,
        // Effects  -   2
        DISTORTION,
        TRANSIENT_SHAPER,
        COMPRESSOR,
        EXPANDER,
        GATE,
        LIMITER,
        // Effects  -   3
        FLANGER,
        CHORUS,
        DELAY,
        REVERB,
        // Effects  -   4
        TREMOLO,
        GLITCH,
        // Effects  -   5
        UTILITY,
        PITCH_CORRECTION,
        RESTORATION,        // repair the sound
        // Effects  -   other
        MULTI_EFFECTS,
        MIXING,
        MASTERING
    );

const
    // corresponding String Array
    SUB_FEATURES    :   array[low(TClapPluginSubFeature)..high(TClapPluginSubFeature)] of PAnsiChar   =   (
        // Instruments
        'synthesizer',
        'sampler',
        'drum',
        'drum-machine',
        // Effects  -   1
        'filter',
        'phaser',
        'equalizer',
        'de-esser',
        'phase-vocoder',
        'granular',
        'frequency-shifter',
        'pitch-shifter',
        // Effects  -   2
        'distortion',
        'transient-shaper',
        'compressor',
        'expander',
        'gate',
        'limiter',
        // Effects  -   3
        'flanger',
        'chorus',
        'delay',
        'reverb',
        // Effects  -   4
        'tremolo',
        'glitch',
        // Effects  -   5
        'utility',
        'pitch-correction',
        'restoration',
        // Effects  -   other
        'multi-effects',
        'mixing',
        'mastering'
    );


////////////////////////
// Audio Capabilities //
////////////////////////

type
    // ATTENTION: CUSTOM, INTERNAL
    // Enum type for plugin audio feature kinds
    TClapPluginAudioFeature  =   (
        MONO,
        STEREO,
        SURROUND,
        AMBISONIC
    );

const
    // corresponding String Array
    AUDIO_FEATURES  :   array[low(TClapPluginAudioFeature)..high(TClapPluginAudioFeature)] of PAnsiChar =   (
        'mono',
        'stereo',
        'surround',
        'ambisonic'
    );

implementation

end.