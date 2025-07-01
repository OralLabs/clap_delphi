unit OOClap;

interface

type
  TOOClapPlugin

  TOOClapPlugin = class
  function

  function getEntry: Pointer;
  end;

implementation

var entry: TOOClapPlugin;

exports
  entry name 'clap_entry';

end.
