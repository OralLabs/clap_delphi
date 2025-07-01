{ FROM "string-sizes.h" }
unit Clap.StringSizes;

{$MINENUMSIZE 4}
{$scopedEnums ON}

interface

// String capacity for names that can be displayed to the user.
const NAME_SIZE =   256;

// String capacity for describing a path, like a parameter in a module hierarchy or path within a
// set of nested track groups.
//
// This is not suited for describing a file path on the disk, as NTFS allows up to 32K long
// paths.
const PATH_SIZE =   1024;

implementation

end.