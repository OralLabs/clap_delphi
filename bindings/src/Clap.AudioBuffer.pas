unit Clap.AudioBuffer;

{$MINENUMSIZE 4}
{$scopedEnums ON}

interface

// ATTENTION: CUSTOM, INTERNAL
// Pointer array types
type
PSingleArray    = ^PSingle;
PDoubleArray    = ^PDouble;

// Sample code for reading a stereo buffer:
//
// bool isLeftConstant = (buffer->constant_mask & (1 << 0)) != 0;
// bool isRightConstant = (buffer->constant_mask & (1 << 1)) != 0;
//
// for (int i = 0; i < N; ++i) {
//    float l = data32[0][isLeftConstant ? 0 : i];
//    float r = data32[1][isRightConstant ? 0 : i];
// }
//
// Note: checking the constant mask is optional, and this implies that
// the buffer must be filled with the constant value.
// Rationale: if a buffer reader doesn't check the constant mask, then it may
// process garbage samples and in result, garbage samples may be transmitted
// to the audio interface with all the bad consequences it can have.
//
// The constant mask is a hint.
type 
TClapAudioBuffer    =   packed record
   // Either data32 or data64 pointer will be set.
   data32       :   PSingleArray;
   data64       :   PDoubleArray;
   channelCount :   uint32;
   latency      :   uint32; // latency from/to the audio interface
   constantMask :   uint32;
end;

implementation

end.