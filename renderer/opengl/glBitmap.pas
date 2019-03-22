(***********************************************************
glBitmap by Steffen Xonna (2003-2007)
http://www.dev-center.de/
------------------------------------------------------------
This unit implement some textureobjects wich have inspired by

glBMP.pas Copyright by Jason Allen
http://delphigl.cfxweb.net/

and

textures.pas Coypright by Jan Horn
http://www.sulaco.co.za/

It is compatible with an standard Delphi TBitmap.
------------------------------------------------------------
The contents of this file are used with permission, subject to
the Mozilla Public License Version 1.1 (the "License"); you may
not use this file except in compliance with the License. You may
obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html
------------------------------------------------------------
Version 1.8.11
------------------------------------------------------------
History
24-10-2007
- ImageID flag of TGAs was ignored. (Thanks Zwoetzen)
15-11-2006
- Function SetBorderColor implemented (only used by opengl if wrap is set to GL_CLAMP_TO_BORDER)
- Function AddAlphaFromValue implemented to use an fixed Value as Alphachannel
- Function ReadOpenGLExtension is now only intern
29-06-2006
- pngimage now disabled by default like all other versions.
26-06-2006
- Setting up an anisotropic filter of 0 isnt allowed by nvidia (Thanks Ogridi)
22-06-2006
- Fixed some Problem with Delphi 5
- Now uses the newest version of pngimage. Makes saving pngs much easier.
22-03-2006
- Property IsCompressed and Size removed. Not really supported by Spec (Thanks Ogridi)
09-03-2006
- Internal Format ifDepth8 added
- function GrabScreen now supports all uncompressed formats
31-01-2006
- AddAlphaFromglBitmap implemented
29-12-2005
- LoadFromResource and LoadFromResourceId now needs an Instance and an ResourceType (for ID)
28-12-2005
- Width, Height and Depth internal changed to TglBitmapPixelPosition.
  property Width, Height, Depth are still existing and new property Dimension are avail
11-12-2005
- Added native OpenGL Support. Breaking the dglOpenGL "barrier".
19-10-2005
- Added function GrabScreen to class TglBitmap2D
18-10-2005
- Added support to Save images
- Added function Clone to Clone Instance
11-10-2005
- Functions now works with Cardinals for each channel. Up to 32 Bits per channel.
  Usefull for Future
- Several speed optimizations
09-10-2005
- Internal structure change. Loading of TGA, PNG and DDS improved.
  Data, format and size will now set directly with SetDataPtr.
- AddFunc now works with all Types of Images and Formats
- Some Funtions moved to Baseclass TglBitmap
06-10-2005
- Added Support to decompress DXT3 and DXT5 compressed Images.
- Added Mapping to convert data from one format into an other.
05-10-2005
- Added method ConvertTo in Class TglBitmap2D. Method allows to convert every
  supported Input format (supported by GetPixel) into any uncompresed Format
- Added Support to decompress DXT1 compressed Images.
- SwapColors replaced by ConvertTo
04-10-2005
- Added Support for compressed DDSs
- Added new internal formats (DXT1, DXT3, DXT5)
29-09-2005
- Parameter Components renamed to InternalFormat
23-09-2005
- Some AllocMem replaced with GetMem (little speed change)
- better exception handling. Better protection from memory leaks.
22-09-2005
- Added support for Direct Draw Surfaces (*.DDS) (uncompressed images only)
- Added new internal formats (RGB8, RGBA8, RGBA4, RGB5A1, RGB10A2, R5G6B5)
07-09-2005
- Added support for Grayscale textures
- Added internal formats (Alpha, Luminance, LuminanceAlpha, BGR8, BGRA8)
10-07-2005
- Added support for GL_VERSION_2_0
- Added support for GL_EXT_texture_filter_anisotropic
04-07-2005
- Function FillWithColor fills the Image with one Color
- Function LoadNormalMap added
30-06-2005
- ToNormalMap allows to Create an NormalMap from the Alphachannel
- ToNormalMap now supports Sobel (nmSobel) function.
29-06-2005
- support for RLE Compressed RGB TGAs added
28-06-2005
- Class TglBitmapNormalMap added to support Normalmap generation
- Added function ToNormalMap in class TglBitmap2D to genereate normal maps from textures.
  3 Filters are supported. (4 Samples, 3x3 and 5x5)
16-06-2005
- Method LoadCubeMapClass removed
- LoadCubeMap returnvalue is now the Texture paramter. Such as LoadTextures
- virtual abstract method GenTexture in class TglBitmap now is protected
12-06-2005
- now support DescriptionFlag in LoadTga. Allows vertical flipped images to be loaded as normal
10-06-2005
- little enhancement for IsPowerOfTwo
- TglBitmap1D.GenTexture now tests NPOT Textures
06-06-2005
- some little name changes. All properties or function with Texture in name are
  now without texture in name. We have allways texture so we dosn't name it.
03-06-2005
- GenTexture now tests if texture is NPOT and NPOT-Texture are supported or
  TextureTarget is GL_TEXTURE_RECTANGLE. Else it raised an exception.
02-06-2005
- added support for GL_ARB_texture_rectangle, GL_EXT_texture_rectangle and GL_NV_texture_rectangle
25-04-2005
- Function Unbind added
- call of SetFilter or SetTextureWrap if TextureID exists results in setting properties to opengl texture.
21-04-2005
- class TglBitmapCubeMap added (allows to Create Cubemaps)
29-03-2005
- Added Support for PNG Images. (http://pngdelphi.sourceforge.net/)
  To Enable png's use the define pngimage
22-03-2005
- New Functioninterface added
- Function GetPixel added
27-11-2004
- Property BuildMipMaps renamed to MipMap
21-11-2004
- property Name removed.
- BuildMipMaps is now a set of 3 values. None, GluBuildMipmaps and SGIS_generate_mipmap
22-05-2004
- property name added. Only used in glForms!
26-11-2003
- property FreeDataAfterGenTexture is now available as default (default = true)
- BuildMipmaps now implemented in TglBitmap1D (i've forgotten it)
- function MoveMemory replaced with function Move (little speed change)
- several calculations stored in variables (little speed change)
29-09-2003
- property BuildMipsMaps added (default = True)
  if BuildMipMaps isn't set GenTextures uses glTexImage[12]D else it use gluBuild[12]dMipmaps
- property FreeDataAfterGenTexture added (default = True)
  if FreeDataAfterGenTexture is set the texturedata were deleted after the texture was generated.
- parameter DisableOtherTextureUnits of Bind removed
- parameter FreeDataAfterGeneration of GenTextures removed
12-09-2003
- TglBitmap dosn't delete data if class was destroyed (fixed)
09-09-2003
- Bind now enables TextureUnits (by params)
- GenTextures can leave data (by param)
- LoadTextures now optimal
03-09-2003
- Performance optimization in AddFunc
- procedure Bind moved to subclasses
- Added new Class TglBitmap1D to support real OpenGL 1D Textures
19-08-2003
- Texturefilter and texturewrap now also as defaults
  Minfilter = GL_LINEAR_MIPMAP_LINEAR
  Magfilter = GL_LINEAR
  Wrap(str) = GL_CLAMP_TO_EDGE
- Added new format tfCompressed to create a compressed texture.
- propertys IsCompressed, TextureSize and IsResident added
  IsCompressed and TextureSize only contains data from level 0
18-08-2003
- Added function AddFunc to add PerPixelEffects to Image
- LoadFromFunc now based on AddFunc
- Invert now based on AddFunc
- SwapColors now based on AddFunc
16-08-2003
- Added function FlipHorz
15-08-2003
- Added function LaodFromFunc to create images with function
- Added function FlipVert
- Added internal format RGB(A) if GL_EXT_bgra or OpenGL 1.2 isn't supported
29-07-2003
- Added Alphafunctions to calculate alpha per function
- Added Alpha from ColorKey using alphafunctions
28-07-2003
- First full functionally Version of glBitmap
- Support for 24Bit and 32Bit TGA Pictures added
25-07-2003
- begin of programming
***********************************************************)
unit glBitmap;

interface

{$X+,H+,O+}

{$define pngimage}
// PNG Support: to enable pngsupport you must add the define "pngimage" or uncomment above.
// And you must install a copy of pgnimage. You can download it from http://pngdelphi.sourceforge.net/

{$ifdef pngimage}
  {$define Store16bits}
{$endif}

{$define NO_NATIVE_GL}
// To enable the dglOpenGL Header you must define "NO_NATIVE_GL" or uncomment above.
// With native GL then bindings are staticlly declared to support other headers or use of glBitmap in DLLs.

// Features
// TODO 4: MipMaps implementieren. Bei allen Funtionen muss ein Level angebbar sein.
// TODO 5: Zusätzliche Datentypen imlementieren. RGB(A)12, RGB(A)16, Float

uses
  Windows, Graphics, Classes, SysUtils, JPEG
  {$ifdef NO_NATIVE_GL}, dglOpenGL{$endif}
  {$ifdef pngimage}, pngimage{$endif}
  ;

{$ifndef NO_NATIVE_GL}
// Native OpenGL Implementation
type
  PByteBool = ^ByteBool;

var
  gLastContext: HGLRC;
  
const
  // Generell
  GL_VERSION = $1F02;
  GL_EXTENSIONS = $1F03;

  GL_TRUE = 1;
  GL_FALSE = 0;

  GL_TEXTURE_1D = $0DE0;
  GL_TEXTURE_2D = $0DE1;

  GL_MAX_TEXTURE_SIZE = $0D33;
  GL_PACK_ALIGNMENT = $0D05;
  GL_UNPACK_ALIGNMENT = $0CF5;

  // Textureformats
  GL_RGB = $1907;
  GL_RGB4 = $804F;
  GL_RGB8 = $8051;
  GL_RGBA = $1908;
  GL_RGBA4 = $8056;
  GL_RGBA8 = $8058;
  GL_BGR = $80E0;
  GL_BGRA = $80E1;
  GL_ALPHA4 = $803B;
  GL_ALPHA8 = $803C;
  GL_LUMINANCE4 = $803F;
  GL_LUMINANCE8 = $8040;
  GL_LUMINANCE4_ALPHA4 = $8043;
  GL_LUMINANCE8_ALPHA8 = $8045;
  GL_DEPTH_COMPONENT = $1902;

  GL_UNSIGNED_BYTE = $1401;
  GL_ALPHA = $1906;
  GL_LUMINANCE = $1909;
  GL_LUMINANCE_ALPHA = $190A;

  GL_TEXTURE_WIDTH = $1000;
  GL_TEXTURE_HEIGHT = $1001;
  GL_TEXTURE_INTERNAL_FORMAT = $1003;
  GL_TEXTURE_RED_SIZE = $805C;
  GL_TEXTURE_GREEN_SIZE = $805D;
  GL_TEXTURE_BLUE_SIZE = $805E;
  GL_TEXTURE_ALPHA_SIZE = $805F;
  GL_TEXTURE_LUMINANCE_SIZE = $8060;

  // Dataformats
  GL_UNSIGNED_SHORT_5_6_5 = $8363;
  GL_UNSIGNED_SHORT_5_6_5_REV = $8364;
  GL_UNSIGNED_SHORT_4_4_4_4_REV = $8365;
  GL_UNSIGNED_SHORT_1_5_5_5_REV = $8366;
  GL_UNSIGNED_INT_2_10_10_10_REV = $8368;

  // Filter
  GL_NEAREST = $2600;
  GL_LINEAR = $2601;
  GL_NEAREST_MIPMAP_NEAREST = $2700;
  GL_LINEAR_MIPMAP_NEAREST = $2701;
  GL_NEAREST_MIPMAP_LINEAR = $2702;
  GL_LINEAR_MIPMAP_LINEAR = $2703;
  GL_TEXTURE_MAG_FILTER = $2800;
  GL_TEXTURE_MIN_FILTER = $2801;

  // Wrapmodes
  GL_TEXTURE_WRAP_S = $2802;
  GL_TEXTURE_WRAP_T = $2803;
  GL_CLAMP = $2900;
  GL_REPEAT = $2901;
  GL_CLAMP_TO_EDGE = $812F;
  GL_CLAMP_TO_BORDER = $812D;
  GL_TEXTURE_WRAP_R = $8072;

  GL_MIRRORED_REPEAT = $8370;

  // Border Color
  GL_TEXTURE_BORDER_COLOR = $1004;

  // Texgen
  GL_NORMAL_MAP = $8511;
  GL_REFLECTION_MAP = $8512;
  GL_S = $2000;
  GL_T = $2001;
  GL_R = $2002;
  GL_TEXTURE_GEN_MODE = $2500;
  GL_TEXTURE_GEN_S = $0C60;
  GL_TEXTURE_GEN_T = $0C61;
  GL_TEXTURE_GEN_R = $0C62;

  // Cubemaps
  GL_MAX_CUBE_MAP_TEXTURE_SIZE = $851C;
  GL_TEXTURE_CUBE_MAP = $8513;
  GL_TEXTURE_BINDING_CUBE_MAP = $8514;
  GL_TEXTURE_CUBE_MAP_POSITIVE_X = $8515;
  GL_TEXTURE_CUBE_MAP_NEGATIVE_X = $8516;
  GL_TEXTURE_CUBE_MAP_POSITIVE_Y = $8517;
  GL_TEXTURE_CUBE_MAP_NEGATIVE_Y = $8518;
  GL_TEXTURE_CUBE_MAP_POSITIVE_Z = $8519;
  GL_TEXTURE_CUBE_MAP_NEGATIVE_Z = $851A;

  GL_TEXTURE_RECTANGLE_ARB = $84F5;

  // GL_SGIS_generate_mipmap
  GL_GENERATE_MIPMAP = $8191;

  // GL_EXT_texture_compression_s3tc
  GL_COMPRESSED_RGB_S3TC_DXT1_EXT = $83F0;
  GL_COMPRESSED_RGBA_S3TC_DXT1_EXT = $83F1;
  GL_COMPRESSED_RGBA_S3TC_DXT3_EXT = $83F2;
  GL_COMPRESSED_RGBA_S3TC_DXT5_EXT = $83F3;

  // GL_EXT_texture_filter_anisotropic
  GL_TEXTURE_MAX_ANISOTROPY_EXT = $84FE;
  GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT = $84FF;

  // GL_ARB_texture_compression
  GL_COMPRESSED_RGB = $84ED;
  GL_COMPRESSED_RGBA = $84EE;
  GL_COMPRESSED_ALPHA = $84E9;
  GL_COMPRESSED_LUMINANCE = $84EA;
  GL_COMPRESSED_LUMINANCE_ALPHA = $84EB;

  // Extensions
var
  GL_VERSION_1_2,
  GL_VERSION_1_3,
  GL_VERSION_1_4,
  GL_VERSION_2_0,

  GL_ARB_texture_border_clamp,
  GL_ARB_texture_cube_map,
  GL_ARB_texture_compression,
  GL_ARB_texture_non_power_of_two,
  GL_ARB_texture_rectangle,
  GL_ARB_texture_mirrored_repeat,
  GL_EXT_bgra,
  GL_EXT_texture_edge_clamp,
  GL_EXT_texture_cube_map,
  GL_EXT_texture_compression_s3tc,
  GL_EXT_texture_filter_anisotropic,
  GL_EXT_texture_rectangle,
  GL_NV_texture_rectangle,
  GL_IBM_texture_mirrored_repeat,
  GL_SGIS_generate_mipmap: Boolean;

  // Funtions
const

{$ifdef UNIX}
  libglu = 'libGLU.so.1';
  libopengl = 'libGL.so.1';
{$else}
  libglu = 'glu32.dll';
  libopengl = 'opengl32.dll';
{$endif}

  function wglGetProcAddress(ProcName: PChar): Pointer; stdcall; external libopengl;
  function glGetString(name: Cardinal): PChar; stdcall; external libopengl;

  procedure glEnable(cap: Cardinal); stdcall; external libopengl;
  procedure glDisable(cap: Cardinal); stdcall; external libopengl;
  procedure glGetIntegerv(pname: Cardinal; params: PInteger); stdcall; external libopengl;

  procedure glTexImage1D(target: Cardinal; level, internalformat, width, border: Integer; format, atype: Cardinal; const pixels: Pointer); stdcall; external libopengl;
  procedure glTexImage2D(target: Cardinal; level, internalformat, width, height, border: Integer; format, atype: Cardinal; const pixels: Pointer); stdcall; external libopengl;

  procedure glGenTextures(n: Integer; Textures: PDWORD); stdcall; external libopengl;
  procedure glBindTexture(target: Cardinal; Texture: Cardinal); stdcall; external libopengl;
  procedure glDeleteTextures(n: Integer; const textures: PDWORD); stdcall; external libopengl;

  procedure glReadPixels(x, y: Integer; width, height: Integer; format, atype: Cardinal; pixels: Pointer); stdcall; external libopengl;
  procedure glPixelStorei(pname: Cardinal; param: Integer); stdcall; external libopengl;
  procedure glGetTexImage(target: Cardinal; level: Integer; format: Cardinal; _type: Cardinal; pixels: Pointer); stdcall; external libopengl;

  function glAreTexturesResident(n: Integer; const Textures: PDWORD; residences: PByteBool): ByteBool;  stdcall; external libopengl;
  procedure glTexParameteri(target: Cardinal; pname: Cardinal; param: Integer); stdcall; external libopengl;
  procedure glTexParameterfv(target: Cardinal; pname: Cardinal; const param: PSingle); stdcall; external libopengl;
  procedure glGetTexLevelParameteriv(target: Cardinal; level: Integer; pname: Cardinal; params: PInteger); stdcall; external libopengl;
  procedure glTexGeni(coord, pname: Cardinal; param: Integer); stdcall; external libopengl;

  function gluBuild1DMipmaps(Target: Cardinal; Components, Width: Integer; Format, atype: Cardinal; Data: Pointer): Integer; stdcall; external libglu;
  function gluBuild2DMipmaps(Target: Cardinal; Components, Width, Height: Integer; Format, aType: Cardinal; Data: Pointer): Integer; stdcall; external libglu;

var
  glCompressedTexImage2D : procedure(target: Cardinal; level: Integer; internalformat: Cardinal; width, height: Integer; border: Integer; imageSize: Integer; const data: Pointer); {$IFDEF Win32}stdcall; {$ELSE}cdecl; {$ENDIF}
  glCompressedTexImage1D : procedure(target: Cardinal; level: Integer; internalformat: Cardinal; width: Integer; border: Integer; imageSize: Integer; const data: Pointer); {$IFDEF Win32}stdcall; {$ELSE}cdecl; {$ENDIF}
  glGetCompressedTexImage : procedure(target: Cardinal; level: Integer; img: Pointer); {$IFNDEF CLR}{$IFDEF Win32}stdcall; {$ELSE}cdecl; {$ENDIF}{$ENDIF}
{$endif}


type
  TglBitmap = class;

  // Exception
  EglBitmapException = Exception;
  EglBitmapSizeToLargeException = EglBitmapException;
  EglBitmapNonPowerOfTwoException = EglBitmapException;
  EglBitmapUnsupportedInternalFormat = EglBitmapException;

  // Functions
  TglBitmapPixelDesc = packed record
    RedRange: Cardinal;
    RedShift: Shortint;
    GreenRange: Cardinal;
    GreenShift: Shortint;
    BlueRange: Cardinal;
    BlueShift: Shortint;
    AlphaRange: Cardinal;
    AlphaShift: Shortint;
  end;

  TglBitmapPixelData = packed record
    Red: Cardinal;
    Green: Cardinal;
    Blue: Cardinal;
    Alpha: Cardinal;

    PixelDesc: TglBitmapPixelDesc;
  end;

  TglBitmapPixelPositionFields = set of (ffX, ffY, ffZ);
  TglBitmapPixelPosition = record
    Fields : TglBitmapPixelPositionFields;
    X : Word;
    Y : Word;
    Z : Word;
  end;

  TglBitmapFunctionRec = record
    Sender : TglBitmap;
    Size: TglBitmapPixelPosition;
    Position: TglBitmapPixelPosition;
    Source: TglBitmapPixelData;
    Dest: TglBitmapPixelData;
    Data: Pointer;
  end;

  TglBitmapFunction = procedure(var FuncRec: TglBitmapFunctionRec);

  TglBitmapGetPixel = procedure (
    const Pos: TglBitmapPixelPosition;
    var Pixel: TglBitmapPixelData) of object;

  TglBitmapSetPixel = procedure (
    const Pos: TglBitmapPixelPosition;
    const Pixel: TglBitmapPixelData) of object;

  // Settings
  TglBitmapFileType = (ftBMP, ftTGA, ftJPEG, {$ifdef pngimage}ftPNG, {$endif}ftDDS);
  TglBitmapFileTypes = set of TglBitmapFileType;

  TglBitmapFormat = (tfDefault, tf4BitsPerChanel, tf8BitsPerChanel, tfCompressed);
  TglBitmapMipMap = (mmNone, mmMipmap, mmMipmapGlu);
  TglBitmapNormalMapFunc = (nm4Samples, nmSobel, nm3x3, nm5x5);
  TglBitmapInternalFormat = (
    ifEmpty,
    // 4 Bit
    ifDXT1,
    // 8 Bit
    ifDXT3,
    ifDXT5,
    ifAlpha,
    ifLuminance,
    ifDepth8,
    // 16 Bit
    ifLuminanceAlpha,
    ifRGBA4,
    ifR5G6B5,
    ifRGB5A1,
    // 24 Bit
    ifBGR8,
    ifRGB8,
    // 32 Bit
    ifBGRA8,
    ifRGBA8,
    ifRGB10A2
  );

  // Pixelmapping
  TglBitmapMapFunc = procedure (const Pixel: TglBitmapPixelData; var pDest: pByte);
  TglBitmapUnMapFunc = procedure (var pData: pByte; var Pixel: TglBitmapPixelData);

  // Base Class
  TglBitmap = class
  protected
    FID: Cardinal;
    FTarget: Cardinal;
    FFormat: TglBitmapFormat;
    FMipMap: TglBitmapMipMap;
    FAnisotropic: Integer;
    FBorderColor: array [0..3] of single;

    FDeleteTextureOnFree: Boolean;
    FFreeDataAfterGenTexture: Boolean;

    // Propertys
    FDataPtr: PByte;
    FInternalFormat: TglBitmapInternalFormat;
    FDimension: TglBitmapPixelPosition;

    FIsResident: Boolean;

    // Mapping
    FPixelSize: Integer;
    FLineSize: Integer;
    FUnmapFunc: TglBitmapUnMapFunc;
    FMapFunc: TglBitmapMapFunc;

    // Filtering
    FFilterMin: Integer;
    FFilterMag: Integer;

    // Texturwarp
    FWrapS: Integer;
    FWrapT: Integer;
    FWrapR: Integer;

    FGetPixelFunc: TglBitmapGetPixel;
    FSetPixelFunc: TglBitmapSetPixel;

    function GetData: PByte;
    procedure SetDataPtr(Ptr: PByte; Format: TglBitmapInternalFormat; Width: Integer = -1; Height: Integer = -1; Depth: Integer = -1); virtual;

    {$ifdef pngimage}
    function LoadPng(const Stream: TStream): Boolean; virtual;
    {$endif}
    function LoadDDS(const Stream: TStream): Boolean; virtual;
    function LoadTga(const Stream: TStream): Boolean; virtual;
    function LoadJpg(const Stream: TStream): Boolean; virtual;
    function LoadBmp(const Stream: TStream): Boolean; virtual;

    {$ifdef pngimage}
    procedure SavePng(const Stream: TStream);
    {$endif}
    procedure SaveDDS(const Stream: TStream);
    procedure SaveTga(const Stream: TStream);
    procedure SaveJpg(const Stream: TStream);
    procedure SaveBmp(const Stream: TStream);

    procedure CreateID;
    procedure SetupParameters(var BuildWithGlu: Boolean);
    procedure SelectFormat(Format: TglBitmapInternalFormat; var glFormat, glInternalFormat, glType: Cardinal; CanConvertImage: Boolean = True);

    procedure GenTexture(TestTextureSize: Boolean = True); virtual; abstract;

    procedure SetAnisotropic(const Value: Integer);
    procedure SetInternalFormat(const Value: TglBitmapInternalFormat);

    function FlipHorz: Boolean; virtual;
    function FlipVert: Boolean; virtual;
    function FlipDepth: Boolean; virtual;

    function GetDepth: Integer;
    function GetHeight: Integer;
    function GetWidth: Integer;

    property Width: Integer read GetWidth;
    property Height: Integer read GetHeight;
    property Depth: Integer read GetDepth;
  public
    // propertys
    property ID: Cardinal read FID;
    property Target: Cardinal read FTarget write FTarget;
    property Format: TglBitmapFormat read FFormat write FFormat;
    property InternalFormat: TglBitmapInternalFormat read FInternalFormat write SetInternalFormat;
    property Dimension: TglBitmapPixelPosition read FDimension;

    property DataPtr: PByte read GetData;

    property MipMap: TglBitmapMipMap read FMipMap write FMipMap;
    property Anisotropic: Integer read FAnisotropic write SetAnisotropic;

    property DeleteTextureOnFree: Boolean read FDeleteTextureOnFree write FDeleteTextureOnFree;
    property FreeDataAfterGenTexture: Boolean read FFreeDataAfterGenTexture write FFreeDataAfterGenTexture;

    property IsResident: boolean read FIsResident;

    // Construction and Destructions Methods
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    constructor Create(); overload;
    constructor Create(FileName: String); overload;
    constructor Create(Stream: TStream); overload;
    constructor CreateFromResourceName(Instance: Cardinal; Resource: String; ResType: PAnsiChar = nil);
    constructor Create(Instance: Cardinal; Resource: String; ResType: PAnsiChar = nil); overload;
    constructor Create(Instance: Cardinal; ResourceID: Integer; ResType: PAnsiChar); overload;
    constructor Create(Size: TglBitmapPixelPosition; Format: TglBitmapInternalFormat); overload;
    constructor Create(Size: TglBitmapPixelPosition; Format: TglBitmapInternalFormat; Func: TglBitmapFunction; Data: Pointer = nil); overload;

    function Clone: TglBitmap;

    // Loading Methods
    procedure LoadFromFile(FileName: String);
    procedure LoadFromStream(Stream: TStream); virtual;
    procedure LoadFromResource(Instance: Cardinal; Resource: String; ResType: PAnsiChar = nil);
    procedure LoadFromResourceID(Instance: Cardinal; ResourceID: Integer; ResType: PAnsiChar);
    procedure LoadFromFunc(Size: TglBitmapPixelPosition; Func: TglBitmapFunction; Format: TglBitmapInternalFormat; Data: Pointer = nil);

    procedure SaveToFile(FileName: String; FileType: TglBitmapFileType);
    procedure SaveToStream(Stream: TStream; FileType: TglBitmapFileType); virtual;

    function AddFunc(Source: TglBitmap; Func: TglBitmapFunction; CreateTemp: Boolean; Format: TglBitmapInternalFormat; Data: Pointer = nil): boolean; overload;
    function AddFunc(Func: TglBitmapFunction; CreateTemp: Boolean; Data: Pointer = nil): boolean; overload;

    function AssignToBitmap(const Bitmap: TBitmap): boolean; virtual; abstract;
    function AssignFromBitmap(const Bitmap: TBitmap): boolean; virtual; abstract;
    function AssignAlphaToBitmap(const Bitmap: TBitmap): boolean; virtual; abstract;

    function AddAlphaFromFunc(Func: TglBitmapFunction; Data: Pointer = nil): boolean; virtual;
    function AddAlphaFromBitmap(Bitmap: TBitmap; Func: TglBitmapFunction = nil; Data: Pointer = nil): boolean;
    function AddAlphaFromFile(FileName: String; Func: TglBitmapFunction = nil; Data: Pointer = nil): boolean;
    function AddAlphaFromStream(Stream: TStream; Func: TglBitmapFunction = nil; Data: Pointer = nil): boolean;
    function AddAlphaFromResource(Instance: Cardinal; Resource: String; ResType: PAnsiChar = nil; Func: TglBitmapFunction = nil; Data: Pointer = nil): boolean;
    function AddAlphaFromResourceID(Instance: Cardinal; ResourceID: Integer; ResType: PAnsiChar; Func: TglBitmapFunction = nil; Data: Pointer = nil): boolean;
    function AddAlphaFromglBitmap(glBitmap: TglBitmap; Func: TglBitmapFunction = nil; Data: Pointer = nil): boolean;

    function AddAlphaFromColorKey(Red, Green, Blue: Byte; Deviation: Byte = 0): Boolean;
    function AddAlphaFromColorKeyRange(Red, Green, Blue: Cardinal; Deviation: Cardinal = 0): Boolean;
    function AddAlphaFromColorKeyFloat(Red, Green, Blue: Single; Deviation: Single = 0): Boolean;

    function AddAlphaFromValue(Alpha: Byte): Boolean;
    function AddAlphaFromValueRange(Alpha: Cardinal): Boolean;
    function AddAlphaFromValueFloat(Alpha: Single): Boolean;

    function RemoveAlpha: Boolean; virtual;

    function ConvertTo(NewFormat: TglBitmapInternalFormat): boolean; virtual;

    // Other
    procedure FillWithColor(Red, Green, Blue: Byte; Alpha : Byte = 255);
    procedure FillWithColorRange(Red, Green, Blue: Cardinal; Alpha : Cardinal = $FFFFFFFF);
    procedure FillWithColorFloat(Red, Green, Blue: Single; Alpha : Single = 1);

    procedure Invert(UseRGB: Boolean = true; UseAlpha: Boolean = false);

    procedure SetFilter(Min, Mag : Integer);
    procedure SetWrap(S: Integer = GL_CLAMP_TO_EDGE;
      T: Integer = GL_CLAMP_TO_EDGE; R: Integer = GL_CLAMP_TO_EDGE);

    procedure SetBorderColor(Red, Green, Blue, Alpha: Single);

    procedure GetPixel (const Pos: TglBitmapPixelPosition; var Pixel: TglBitmapPixelData); virtual;
    procedure SetPixel (const Pos: TglBitmapPixelPosition; const Pixel: TglBitmapPixelData); virtual;

    // Generation
    procedure Unbind(DisableTextureUnit: Boolean = True); virtual;
    procedure Bind(EnableTextureUnit: Boolean = True); virtual;
  end;


  TglBitmap2D = class(TglBitmap)
  protected
    // Bildeinstellungen
    FLines: array of PByte;

    procedure GetDXTColorBlock(pData: pByte; relX, relY: Integer; var Pixel: TglBitmapPixelData);
    procedure GetPixel2DDXT1(const Pos: TglBitmapPixelPosition; var Pixel: TglBitmapPixelData);
    procedure GetPixel2DDXT3(const Pos: TglBitmapPixelPosition; var Pixel: TglBitmapPixelData);
    procedure GetPixel2DDXT5(const Pos: TglBitmapPixelPosition; var Pixel: TglBitmapPixelData);
    procedure GetPixel2DUnmap(const Pos: TglBitmapPixelPosition; var Pixel: TglBitmapPixelData);

    procedure SetPixel2DUnmap(const Pos: TglBitmapPixelPosition; const Pixel: TglBitmapPixelData);

    function GetScanline(Index: Integer): Pointer;

    procedure SetDataPtr(Ptr: PByte; Format: TglBitmapInternalFormat; Width: Integer = -1; Height: Integer = -1; Depth: Integer = -1); override;
    procedure UploadData (Target, Format, InternalFormat, Typ: Cardinal; BuildWithGlu: Boolean);
  public
    // propertys
    property Width;
    property Height;

    property Scanline[Index: Integer]: Pointer read GetScanline;

    procedure AfterConstruction; override;

    function AssignToBitmap(const Bitmap: TBitmap): boolean; override;
    function AssignFromBitmap(const Bitmap: TBitmap): boolean; override;
    function AssignAlphaToBitmap(const Bitmap: TBitmap): boolean; override;

    procedure GrabScreen(Top, Left, Right, Bottom: Integer; Format: TglBitmapInternalFormat);
    procedure GetDataFromTexture;

    // Other
    function FlipHorz: Boolean; override;
    function FlipVert: Boolean; override;

    procedure ToNormalMap(Func: TglBitmapNormalMapFunc = nm3x3; Scale: Single = 2; UseAlpha: Boolean = False);

    // Generation
    procedure GenTexture(TestTextureSize: Boolean = True); override;
  end;


  TglBitmapCubeMap = class(TglBitmap2d)
  protected
    fGenMode: Integer;

    // Hide GenTexture
    procedure GenTexture(TestTextureSize: Boolean = True); reintroduce;
  public
    procedure AfterConstruction; override;

    procedure GenerateCubeMap(CubeTarget: Cardinal; TestTextureSize: Boolean = true);

    procedure Unbind(DisableTexCoordsGen: Boolean = true; DisableTextureUnit: Boolean = True); reintroduce; virtual;
    procedure Bind(EnableTexCoordsGen: Boolean = true; EnableTextureUnit: Boolean = True); reintroduce; virtual;
  end;


  TglBitmapNormalMap = class(TglBitmapCubeMap)
  public
    procedure AfterConstruction; override;

    procedure GenerateNormalMap(Size: Integer = 32; TestTextureSize: Boolean = true);
  end;


  TglBitmap1D = class(TglBitmap)
  protected
    procedure GetPixel1DUnmap(const Pos: TglBitmapPixelPosition; var Pixel: TglBitmapPixelData);

    procedure SetDataPtr(Ptr: PByte; Format: TglBitmapInternalFormat; Width: Integer = -1; Height: Integer = -1; Depth: Integer = -1); override;
    procedure UploadData (Target, Format, InternalFormat, Typ: Cardinal; BuildWithGlu: Boolean);
  public
    // propertys
    property Width;

    procedure AfterConstruction; override;

    function AssignToBitmap(const Bitmap: TBitmap): boolean; override;
    function AssignFromBitmap(const Bitmap: TBitmap): boolean; override;
    function AssignAlphaToBitmap(const Bitmap: TBitmap): boolean; override;

    // Other
    function FlipHorz: Boolean; override;

    // Generation
    procedure GenTexture(TestTextureSize: Boolean = True); override;
  end;


// methods and vars for Defaults
procedure glBitmapSetDefaultFormat(Format: TglBitmapFormat);
procedure glBitmapSetDefaultFilter(Min, Mag: Integer);
procedure glBitmapSetDefaultWrap(S: Integer = GL_CLAMP_TO_EDGE; T: Integer = GL_CLAMP_TO_EDGE; R: Integer = GL_CLAMP_TO_EDGE);

procedure glBitmapSetDefaultDeleteTextureOnFree(DeleteTextureOnFree: Boolean);
procedure glBitmapSetDefaultFreeDataAfterGenTexture(FreeData: Boolean);

function glBitmapGetDefaultFormat: TglBitmapFormat;
procedure glBitmapGetDefaultFilter(var Min, Mag: Integer);
procedure glBitmapGetDefaultTextureWrap(var S, T, R: Integer);

function glBitmapGetDefaultDeleteTextureOnFree: Boolean;
function glBitmapGetDefaultFreeDataAfterGenTexture: Boolean;

// Formatfunctions
function glBitmapPosition(X: Integer = -1; Y: Integer = -1; Z: Integer = -1): TglBitmapPixelPosition;

function FormatGetSize (Format: TglBitmapInternalFormat): Single;
function FormatIsCompressed(Format: TglBitmapInternalFormat): boolean;
function FormatIsUncompressed(Format: TglBitmapInternalFormat): boolean;
function FormatIsEmpty(Format: TglBitmapInternalFormat): boolean;
function FormatHasAlpha(Format: TglBitmapInternalFormat): Boolean;
procedure FormatPreparePixel(var Pixel: TglBitmapPixelData; Format: TglBitmapInternalFormat);
function FormatGetWithoutAlpha(Format: TglBitmapInternalFormat): TglBitmapInternalFormat;
function FormatGetWithAlpha(Format: TglBitmapInternalFormat): TglBitmapInternalFormat;


// Call LoadingMethods
function LoadTexture(Filename: String; var Texture: Cardinal; LoadFromRes : Boolean; Instance: Cardinal = 0): Boolean;

function LoadCubeMap(PositiveX, NegativeX, PositiveY, NegativeY, PositiveZ, NegativeZ: String; var Texture: Cardinal; LoadFromRes : Boolean; Instance: Cardinal = 0): Boolean;

function LoadNormalMap(Size: Integer; var Texture: Cardinal): Boolean;


var
  glBitmapDefaultFormat: TglBitmapFormat;
  glBitmapDefaultFilterMin: Integer;
  glBitmapDefaultFilterMag: Integer;
  glBitmapDefaultWrapS: Integer;
  glBitmapDefaultWrapT: Integer;
  glBitmapDefaultWrapR: Integer;

  glBitmapDefaultDeleteTextureOnFree: Boolean;
  glBitmapDefaultFreeDataAfterGenTextures: Boolean;


function CreateGrayPalette: HPALETTE;


implementation

uses
  Math;


{$ifndef NO_NATIVE_GL}
procedure ReadOpenGLExtensions;
var
  Context: HGLRC;
  Buffer: String;
  MajorVersion, MinorVersion: Integer;


  procedure TrimVersionString(Buffer: string; var Major, Minor: Integer);
  var
    Separator: Integer;
  begin
    Minor := 0;
    Major := 0;

    Separator := Pos('.', Buffer);

    if (Separator > 1) and (Separator < Length(Buffer)) and
       (Buffer[Separator - 1] in ['0'..'9']) and
       (Buffer[Separator + 1] in ['0'..'9']) then begin

      Dec(Separator);
      while (Separator > 0) and (Buffer[Separator] in ['0'..'9'])
        do Dec(Separator);

      Delete(Buffer, 1, Separator);
      Separator := Pos('.', Buffer) + 1;

      while (Separator <= Length(Buffer)) and (AnsiChar(Buffer[Separator]) in ['0'..'9']) do
        Inc(Separator);

      Delete(Buffer, Separator, 255);
      Separator := Pos('.', Buffer);

      Major := StrToInt(Copy(Buffer, 1, Separator - 1));
      Minor := StrToInt(Copy(Buffer, Separator + 1, 1));
    end;
  end;


  function CheckExtension(const Extension: string): Boolean;
  var
    ExtPos: Integer;
  begin
    ExtPos := Pos(Extension, Buffer);
    Result := ExtPos > 0;
    if Result
      then Result :=
        ((ExtPos + Length(Extension) - 1) = Length(Buffer)) or not (Buffer[ExtPos + Length(Extension)] in ['_', 'A'..'Z', 'a'..'z']);
  end;


begin
  Context := wglGetCurrentContext;

  if Context <> gLastContext then begin
    gLastContext := Context;

    // Version
    Buffer := glGetString(GL_VERSION);
    TrimVersionString(Buffer, MajorVersion, MinorVersion);

    GL_VERSION_1_2 := False;
    GL_VERSION_1_3 := False;
    GL_VERSION_1_4 := False;
    GL_VERSION_2_0 := False;

    if MajorVersion = 1 then begin
      if MinorVersion >= 1 then begin
        if MinorVersion >= 2
          then GL_VERSION_1_2 := True;

        if MinorVersion >= 3
          then GL_VERSION_1_3 := True;

        if MinorVersion >= 4
          then GL_VERSION_1_4 := True;
      end;
    end;

    if MajorVersion >= 2 then
    begin
      GL_VERSION_1_2 := True;
      GL_VERSION_1_3 := True;
      GL_VERSION_1_4 := True;
      GL_VERSION_2_0 := True;
    end;

    // Extensions
    Buffer := glGetString(GL_EXTENSIONS);
    GL_ARB_texture_border_clamp       := CheckExtension('GL_ARB_texture_border_clamp');
    GL_ARB_texture_cube_map           := CheckExtension('GL_ARB_texture_cube_map');
    GL_ARB_texture_compression        := CheckExtension('GL_ARB_texture_compression');
    GL_ARB_texture_non_power_of_two   := CheckExtension('GL_ARB_texture_non_power_of_two');
    GL_ARB_texture_rectangle          := CheckExtension('GL_ARB_texture_rectangle');
    GL_ARB_texture_mirrored_repeat    := CheckExtension('GL_ARB_texture_mirrored_repeat');
    GL_EXT_bgra                       := CheckExtension('GL_EXT_bgra');
    GL_EXT_texture_edge_clamp         := CheckExtension('GL_EXT_texture_edge_clamp');
    GL_EXT_texture_cube_map           := CheckExtension('GL_EXT_texture_cube_map');
    GL_EXT_texture_compression_s3tc   := CheckExtension('GL_EXT_texture_compression_s3tc');
    GL_EXT_texture_filter_anisotropic := CheckExtension('GL_EXT_texture_filter_anisotropic');
    GL_EXT_texture_rectangle          := CheckExtension('GL_EXT_texture_rectangle');
    GL_NV_texture_rectangle           := CheckExtension('GL_NV_texture_rectangle');
    GL_IBM_texture_mirrored_repeat    := CheckExtension('GL_IBM_texture_mirrored_repeat');
    GL_SGIS_generate_mipmap           := CheckExtension('GL_SGIS_generate_mipmap');

    // Funtions
    if GL_VERSION_1_3 then begin
      // Loading Core
      glCompressedTexImage1D := wglGetProcAddress('glCompressedTexImage1D');
      glCompressedTexImage2D := wglGetProcAddress('glCompressedTexImage2D');
      glGetCompressedTexImage := wglGetProcAddress('glGetCompressedTexImage');
    end else begin
      // Try loading Extension
      glCompressedTexImage1D := wglGetProcAddress('glCompressedTexImage1DARB');
      glCompressedTexImage2D := wglGetProcAddress('glCompressedTexImage2DARB');
      glGetCompressedTexImage := wglGetProcAddress('glGetCompressedTexImageARB');
    end;
  end;
end;
{$endif}


function glBitmapPosition(X, Y, Z: Integer): TglBitmapPixelPosition;
begin
  Result.Fields := [];

  if X >= 0 then
    Result.Fields := Result.Fields + [ffX];
  if Y >= 0 then
    Result.Fields := Result.Fields + [ffY];
  if Z >= 0 then
    Result.Fields := Result.Fields + [ffZ];

  Result.X := Max(0, X);
  Result.Y := Max(0, Y);
  Result.Z := Max(0, Z);
end;


const
  UNSUPPORTED_INTERNAL_FORMAT = 'the given format isn''t supported by this function.';

  PIXEL_DESC_ALPHA : TglBitmapPixelDesc = (
    RedRange   : $00; RedShift   :  0;
    GreenRange : $00; GreenShift :  0;
    BlueRange  : $00; BlueShift  :  0;
    AlphaRange : $FF; AlphaShift :  0 );

  PIXEL_DESC_LUMINANCE : TglBitmapPixelDesc = (
    RedRange   : $FF; RedShift   :  0;
    GreenRange : $FF; GreenShift :  0;
    BlueRange  : $FF; BlueShift  :  0;
    AlphaRange : $00; AlphaShift :  0 );

  PIXEL_DESC_DEPTH8 : TglBitmapPixelDesc = (
    RedRange   : $FF; RedShift   :  0;
    GreenRange : $FF; GreenShift :  0;
    BlueRange  : $FF; BlueShift  :  0;
    AlphaRange : $00; AlphaShift :  0 );

  PIXEL_DESC_LUMINANCEALPHA : TglBitmapPixelDesc = (
    RedRange   : $FF; RedShift   :  0;
    GreenRange : $FF; GreenShift :  0;
    BlueRange  : $FF; BlueShift  :  0;
    AlphaRange : $FF; AlphaShift :  8 );

  PIXEL_DESC_RGBA4 : TglBitmapPixelDesc = (
    RedRange   : $0F; RedShift   :  8;
    GreenRange : $0F; GreenShift :  4;
    BlueRange  : $0F; BlueShift  :  0;
    AlphaRange : $0F; AlphaShift : 12 );

  PIXEL_DESC_R5G6B5 : TglBitmapPixelDesc = (
    RedRange   : $1F; RedShift   : 11;
    GreenRange : $3F; GreenShift :  5;
    BlueRange  : $1F; BlueShift  :  0;
    AlphaRange : $00; AlphaShift :  0 );

  PIXEL_DESC_RGB5A1 : TglBitmapPixelDesc = (
    RedRange   : $1F; RedShift   : 10;
    GreenRange : $1F; GreenShift :  5;
    BlueRange  : $1F; BlueShift  :  0;
    AlphaRange : $01; AlphaShift : 15 );

  PIXEL_DESC_RGB8 : TglBitmapPixelDesc = (
    RedRange   : $FF; RedShift   :  0;
    GreenRange : $FF; GreenShift :  8;
    BlueRange  : $FF; BlueShift  : 16;
    AlphaRange : $00; AlphaShift :  0 );

  PIXEL_DESC_RGBA8 : TglBitmapPixelDesc = (
    RedRange   : $FF; RedShift   :  0;
    GreenRange : $FF; GreenShift :  8;
    BlueRange  : $FF; BlueShift  : 16;
    AlphaRange : $FF; AlphaShift : 24 );

  PIXEL_DESC_BGR8 : TglBitmapPixelDesc = (
    RedRange   : $FF; RedShift   : 16;
    GreenRange : $FF; GreenShift :  8;
    BlueRange  : $FF; BlueShift  :  0;
    AlphaRange : $00; AlphaShift :  0 );

  PIXEL_DESC_BGRA8 : TglBitmapPixelDesc = (
    RedRange   : $FF; RedShift   : 16;
    GreenRange : $FF; GreenShift :  8;
    BlueRange  : $FF; BlueShift  :  0;
    AlphaRange : $FF; AlphaShift : 24 );

  PIXEL_DESC_RGB10A2 : TglBitmapPixelDesc = (
    RedRange   : $3FF; RedShift   : 20;
    GreenRange : $3FF; GreenShift : 10;
    BlueRange  : $3FF; BlueShift  :  0;
    AlphaRange : $003; AlphaShift : 30 );

(*
** Mapping
*)

procedure MapAlpha(const Pixel: TglBitmapPixelData; var pDest: pByte);
begin
  pDest^ := Pixel.Alpha;
  Inc(pDest);
end;


procedure MapLuminance(const Pixel: TglBitmapPixelData; var pDest: pByte);
begin
  pDest^ := Trunc(Pixel.Red * 0.3 + Pixel.Green * 0.59 + Pixel.Blue * 0.11);
  Inc(pDest);
end;


procedure MapDepth8(const Pixel: TglBitmapPixelData; var pDest: pByte);
begin
  pDest^ := (Pixel.Red + Pixel.Green + Pixel.Blue) div 3;
  Inc(pDest);
end;


procedure MapLuminanceAlpha(const Pixel: TglBitmapPixelData; var pDest: pByte);
begin
  pDest^ := Trunc(Pixel.Red * 0.3 + Pixel.Green * 0.59 + Pixel.Blue * 0.11);
  Inc(pDest);

  pDest^ := Pixel.Alpha;
  Inc(pDest);
end;


procedure MapRGBA4(const Pixel: TglBitmapPixelData; var pDest: pByte);
begin
  pWord(pDest)^ :=
    Pixel.Alpha shl PIXEL_DESC_RGBA4.AlphaShift or
    Pixel.Red   shl PIXEL_DESC_RGBA4.RedShift   or
    Pixel.Green shl PIXEL_DESC_RGBA4.GreenShift or
    Pixel.Blue;

  Inc(pDest, 2);
end;


procedure MapR5G6B5(const Pixel: TglBitmapPixelData; var pDest: pByte);
begin
  pWord(pDest)^ :=
    Pixel.Red   shl PIXEL_DESC_R5G6B5.RedShift   or
    Pixel.Green shl PIXEL_DESC_R5G6B5.GreenShift or
    Pixel.Blue;

  Inc(pDest, 2);
end;


procedure MapRGB5A1(const Pixel: TglBitmapPixelData; var pDest: pByte);
begin
  pWord(pDest)^ :=
    Pixel.Alpha shl PIXEL_DESC_RGB5A1.AlphaShift or
    Pixel.Red   shl PIXEL_DESC_RGB5A1.RedShift   or
    Pixel.Green shl PIXEL_DESC_RGB5A1.GreenShift or
    Pixel.Blue;

  Inc(pDest, 2);
end;


procedure MapRGB8(const Pixel: TglBitmapPixelData; var pDest: pByte);
begin
  pDest^ := Pixel.Red;
  Inc(pDest);

  pDest^ := Pixel.Green;
  Inc(pDest);

  pDest^ := Pixel.Blue;
  Inc(pDest);
end;


procedure MapBGR8(const Pixel: TglBitmapPixelData; var pDest: pByte);
begin
  pDest^ := Pixel.Blue;
  Inc(pDest);

  pDest^ := Pixel.Green;
  Inc(pDest);

  pDest^ := Pixel.Red;
  Inc(pDest);
end;


procedure MapRGBA8(const Pixel: TglBitmapPixelData; var pDest: pByte);
begin
  pDWord(pDest)^ :=
    Pixel.Alpha shl PIXEL_DESC_RGBA8.AlphaShift or
    Pixel.Blue  shl PIXEL_DESC_RGBA8.BlueShift  or
    Pixel.Green shl PIXEL_DESC_RGBA8.GreenShift or
    Pixel.Red;

  Inc(pDest, 4);
end;


procedure MapBGRA8(const Pixel: TglBitmapPixelData; var pDest: pByte);
begin
  pDWord(pDest)^ :=
    Pixel.Alpha shl PIXEL_DESC_BGRA8.AlphaShift or
    Pixel.Red   shl PIXEL_DESC_BGRA8.RedShift or
    Pixel.Green shl PIXEL_DESC_BGRA8.GreenShift or
    Pixel.Blue;

  Inc(pDest, 4);
end;


procedure MapRGB10A2(const Pixel: TglBitmapPixelData; var pDest: pByte);
begin
  pDWord(pDest)^ :=
    Pixel.Alpha shl PIXEL_DESC_RGB10A2.AlphaShift or
    Pixel.Red   shl PIXEL_DESC_RGB10A2.RedShift   or
    Pixel.Green shl PIXEL_DESC_RGB10A2.GreenShift or
    Pixel.Blue;

  Inc(pDest, 4);
end;


function FormatGetMapFunc(Format: TglBitmapInternalFormat): TglBitmapMapFunc;
begin
  case Format of
    ifAlpha:          Result := MapAlpha;
    ifLuminance:      Result := MapLuminance;
    ifDepth8:         Result := MapDepth8;
    ifLuminanceAlpha: Result := MapLuminanceAlpha;
    ifRGBA4:          Result := MapRGBA4;
    ifR5G6B5:         Result := MapR5G6B5;
    ifRGB5A1:         Result := MapRGB5A1;
    ifRGB8:           Result := MapRGB8;
    ifBGR8:           Result := MapBGR8;
    ifRGBA8:          Result := MapRGBA8;
    ifBGRA8:          Result := MapBGRA8;
    ifRGB10A2:        Result := MapRGB10A2;
  else
    raise EglBitmapUnsupportedInternalFormat.Create('FormatGetMapFunc - ' + UNSUPPORTED_INTERNAL_FORMAT);
  end;
end;


(*
** Unmapping
*)
procedure UnMapAlpha(var pData: pByte; var Pixel: TglBitmapPixelData);
begin
  Pixel.Alpha := pData^;
  Pixel.Red   := Pixel.PixelDesc.RedRange;
  Pixel.Green := Pixel.PixelDesc.GreenRange;
  Pixel.Blue  := Pixel.PixelDesc.BlueRange;

  Inc(pData);
end;


procedure UnMapLuminance(var pData: pByte; var Pixel: TglBitmapPixelData);
begin
  Pixel.Alpha := 255;
  Pixel.Red   := pData^;
  Pixel.Green := pData^;
  Pixel.Blue  := pData^;

  Inc(pData);
end;


procedure UnMapDepth8(var pData: pByte; var Pixel: TglBitmapPixelData);
begin
  Pixel.Alpha := 255;
  Pixel.Red   := pData^;
  Pixel.Green := pData^;
  Pixel.Blue  := pData^;

  Inc(pData);
end;


procedure UnMapLuminanceAlpha(var pData: pByte; var Pixel: TglBitmapPixelData);
begin
  Pixel.Red   := pData^;
  Pixel.Green := pData^;
  Pixel.Blue  := pData^;
  Inc(pData);

  Pixel.Alpha := pData^;
  Inc(pData);
end;


procedure UnMapRGBA4(var pData: pByte; var Pixel: TglBitmapPixelData);
var
  Temp: Word;
begin
  Temp := pWord(pData)^;

  Pixel.Alpha := Temp shr PIXEL_DESC_RGBA4.AlphaShift and PIXEL_DESC_RGBA4.AlphaRange;
  Pixel.Red   := Temp shr PIXEL_DESC_RGBA4.RedShift   and PIXEL_DESC_RGBA4.RedRange;
  Pixel.Green := Temp shr PIXEL_DESC_RGBA4.GreenShift and PIXEL_DESC_RGBA4.GreenRange;
  Pixel.Blue  := Temp                                 and PIXEL_DESC_RGBA4.BlueRange;

  Inc(pData, 2);
end;


procedure UnMapR5G6B5(var pData: pByte; var Pixel: TglBitmapPixelData);
var
  Temp: Word;
begin
  Temp := pWord(pData)^;

  Pixel.Alpha := Pixel.PixelDesc.AlphaRange;
  Pixel.Red   := Temp shr PIXEL_DESC_R5G6B5.RedShift   and PIXEL_DESC_R5G6B5.RedRange;
  Pixel.Green := Temp shr PIXEL_DESC_R5G6B5.GreenShift and PIXEL_DESC_R5G6B5.GreenRange;
  Pixel.Blue  := Temp                                  and PIXEL_DESC_R5G6B5.BlueRange;

  Inc(pData, 2);
end;


procedure UnMapRGB5A1(var pData: pByte; var Pixel: TglBitmapPixelData);
var
  Temp: Word;
begin
  Temp := pWord(pData)^;

  Pixel.Alpha := Temp shr PIXEL_DESC_RGB5A1.AlphaShift and PIXEL_DESC_RGB5A1.AlphaRange;
  Pixel.Red   := Temp shr PIXEL_DESC_RGB5A1.RedShift   and PIXEL_DESC_RGB5A1.RedRange;
  Pixel.Green := Temp shr PIXEL_DESC_RGB5A1.GreenShift and PIXEL_DESC_RGB5A1.GreenRange;
  Pixel.Blue  := Temp                                  and PIXEL_DESC_RGB5A1.BlueRange;

  Inc(pData, 2);
end;


procedure UnMapRGB8(var pData: pByte; var Pixel: TglBitmapPixelData);
begin
  Pixel.Alpha := Pixel.PixelDesc.AlphaRange;

  Pixel.Red   := pData^;
  Inc(pData);

  Pixel.Green := pData^;
  Inc(pData);

  Pixel.Blue  := pData^;
  Inc(pData);
end;


procedure UnMapBGR8(var pData: pByte; var Pixel: TglBitmapPixelData);
begin
  Pixel.Alpha := Pixel.PixelDesc.AlphaRange;

  Pixel.Blue  := pData^;
  Inc(pData);

  Pixel.Green := pData^;
  Inc(pData);

  Pixel.Red   := pData^;
  Inc(pData);
end;


procedure UnMapRGBA8(var pData: pByte; var Pixel: TglBitmapPixelData);
begin
  Pixel.Red   := pData^;
  Inc(pData);

  Pixel.Green := pData^;
  Inc(pData);

  Pixel.Blue  := pData^;
  Inc(pData);

  Pixel.Alpha := pData^;
  Inc(pData);
end;


procedure UnMapBGRA8(var pData: pByte; var Pixel: TglBitmapPixelData);
begin
  Pixel.Blue  := pData^;
  Inc(pData);

  Pixel.Green := pData^;
  Inc(pData);

  Pixel.Red   := pData^;
  Inc(pData);

  Pixel.Alpha := pData^;
  Inc(pData);
end;


procedure UnMapRGB10A2(var pData: pByte; var Pixel: TglBitmapPixelData);
var
  Temp: DWord;
begin
  Temp := pDWord(pData)^;

  Pixel.Alpha := Temp shr PIXEL_DESC_RGB10A2.AlphaShift and PIXEL_DESC_RGB10A2.AlphaRange;
  Pixel.Red   := Temp shr PIXEL_DESC_RGB10A2.RedShift   and PIXEL_DESC_RGB10A2.RedRange;
  Pixel.Green := Temp shr PIXEL_DESC_RGB10A2.GreenShift and PIXEL_DESC_RGB10A2.GreenRange;
  Pixel.Blue  := Temp                                   and PIXEL_DESC_RGB10A2.BlueRange;

  Inc(pData, 4);
end;


function FormatGetUnMapFunc(Format: TglBitmapInternalFormat): TglBitmapUnMapFunc;
begin
  case Format of
    ifAlpha:          Result := UnmapAlpha;
    ifLuminance:      Result := UnMapLuminance;
    ifDepth8:         Result := UnMapDepth8;
    ifLuminanceAlpha: Result := UnMapLuminanceAlpha;
    ifRGBA4:          Result := UnMapRGBA4;
    ifR5G6B5:         Result := UnMapR5G6B5;
    ifRGB5A1:         Result := UnMapRGB5A1;
    ifRGB8:           Result := UnMapRGB8;
    ifBGR8:           Result := UnMapBGR8;
    ifRGBA8:          Result := UnMapRGBA8;
    ifBGRA8:          Result := UnMapBGRA8;
    ifRGB10A2:        Result := UnMapRGB10A2;
  else
    raise EglBitmapUnsupportedInternalFormat.Create('FormatGetUnMapFunc - ' + UNSUPPORTED_INTERNAL_FORMAT);
  end;
end;

(*
** Tools
*)
function FormatGetSize (Format: TglBitmapInternalFormat): Single;
begin
  case Format of
    ifEmpty:
      Result := 0;

    ifDXT1:
      Result := 0.5;

    ifAlpha, ifLuminance, ifDepth8, ifDXT3, ifDXT5:
      Result := 1;

    ifLuminanceAlpha, ifRGBA4, ifRGB5A1, ifR5G6B5:
      Result := 2;

    ifBGR8, ifRGB8:
      Result := 3;

    ifBGRA8, ifRGBA8, ifRGB10A2:
      Result := 4;
  else
    raise EglBitmapUnsupportedInternalFormat.Create('FormatGetSize - ' + UNSUPPORTED_INTERNAL_FORMAT);
  end;
end;


function FormatIsCompressed(Format: TglBitmapInternalFormat): boolean;
begin
  Result := Format in [ifDXT1, ifDXT3, ifDXT5];
end;


function FormatIsUncompressed(Format: TglBitmapInternalFormat): boolean;
begin
  Result := Format in [ifAlpha, ifLuminance, ifDepth8, ifLuminanceAlpha, ifRGBA4, ifRGB5A1, ifR5G6B5, ifBGR8, ifRGB8, ifBGRA8, ifRGBA8, ifRGB10A2];
end;


function FormatIsEmpty(Format: TglBitmapInternalFormat): boolean;
begin
  Result := Format = ifEmpty;
end;


function FormatHasAlpha(Format: TglBitmapInternalFormat): Boolean;
begin
  Result := Format in [ifDXT1, ifDXT3, ifDXT5 ,ifAlpha, ifLuminanceAlpha, ifRGBA4, ifRGB5A1, ifBGRA8, ifRGBA8, ifRGB10A2];
end;


procedure FormatPreparePixel(var Pixel: TglBitmapPixelData; Format: TglBitmapInternalFormat);
begin
  FillChar(Pixel, SizeOf(Pixel), #0);

  case Format of
    ifAlpha:
      Pixel.PixelDesc := PIXEL_DESC_ALPHA;
    ifLuminance:
      Pixel.PixelDesc := PIXEL_DESC_LUMINANCE;
    ifDepth8:
      Pixel.PixelDesc := PIXEL_DESC_DEPTH8;
    ifLuminanceAlpha:
      Pixel.PixelDesc := PIXEL_DESC_LUMINANCEALPHA;
    ifRGBA4:
      Pixel.PixelDesc := PIXEL_DESC_RGBA4;
    ifR5G6B5:
      Pixel.PixelDesc := PIXEL_DESC_R5G6B5;
    ifRGB5A1:
      Pixel.PixelDesc := PIXEL_DESC_RGB5A1;
    ifDXT1, ifDXT3, ifDXT5, ifBGRA8:
      Pixel.PixelDesc := PIXEL_DESC_BGRA8;
    ifBGR8:
      Pixel.PixelDesc := PIXEL_DESC_BGR8;
    ifRGB8:
      Pixel.PixelDesc := PIXEL_DESC_RGB8;
    ifRGBA8:
      Pixel.PixelDesc := PIXEL_DESC_RGBA8;
    ifRGB10A2:
      Pixel.PixelDesc := PIXEL_DESC_RGB10A2;
  end;

  Pixel.Red   := Pixel.PixelDesc.RedRange;
  Pixel.Green := Pixel.PixelDesc.GreenRange;
  Pixel.Blue  := Pixel.PixelDesc.BlueRange;
  Pixel.Alpha := Pixel.PixelDesc.AlphaRange;
end;


function FormatGetWithoutAlpha(Format: TglBitmapInternalFormat): TglBitmapInternalFormat;
begin
  case Format of
    ifAlpha:
      Result := ifLuminance;
    ifLuminanceAlpha:
      Result := ifLuminance;
    ifRGBA4:
      Result := ifR5G6B5;
    ifRGB5A1:
      Result := ifR5G6B5;
    ifBGRA8:
      Result := ifBGR8;
    ifRGBA8:
      Result := ifRGB8;
    ifRGB10A2:
      Result := ifRGB8;
  else
    Result := Format;
  end;
end;


function FormatGetWithAlpha(Format: TglBitmapInternalFormat): TglBitmapInternalFormat;
begin
  case Format of
    ifLuminance:
      Result := ifLuminanceAlpha;
    ifR5G6B5:
      Result := ifRGB5A1;
    ifBGR8:
      Result := ifBGRA8;
    ifRGB8:
      Result := ifRGBA8;
  else
    Result := Format;
  end;
end;


function FormatGetUncompressed(Format: TglBitmapInternalFormat): TglBitmapInternalFormat;
begin
  case Format of
    ifDXT1:
      Result := ifRGB5A1;
    ifDXT3:
      Result := ifRGBA8;
    ifDXT5:
      Result := ifRGBA8;
  else
    Result := Format;
  end;
end;


function FormatGetImageSize(Size: TglBitmapPixelPosition; Format: TglBitmapInternalFormat): Integer;
begin
  if (Size.X = 0) and (Size.Y = 0) and (Size.Z = 0) then
    Result := 0
  else
    Result := Trunc(Max(Size.Z, 1) * Max(Size.Y, 1) * Max(Size.X, 1) * FormatGetSize(Format));
end;


function FormatGetSupportedFiles(Format: TglBitmapInternalFormat): TglBitmapFileTypes;
begin
  Result := [ftDDS];

  if Format in [ifLuminance, ifAlpha, ifDepth8, ifR5G6B5, ifBGR8] then
    Result := Result + [ftBMP];

  {$ifdef pngimage}
  if Format in [ifLuminance, ifAlpha, ifDepth8, ifLuminanceAlpha, ifBGR8, ifBGRA8] then
    Result := Result + [ftPNG];
  {$endif}

  if Format in [ifLuminance, ifAlpha, ifDepth8, ifLuminanceAlpha, ifBGR8, ifBGRA8] then
    Result := Result + [ftTGA];

  if Format in [ifLuminance, ifAlpha, ifDepth8, ifBGR8] then
    Result := Result + [ftJPEG];
end;


function IsPowerOfTwo (Number: Integer): Boolean;
begin
  while Number and 1 = 0 do
    Number := Number shr 1;

  Result := Number = 1;
end;


function CreateGrayPalette: HPALETTE;
var
  Idx: Integer;
  Pal: PLogPalette;
begin
  GetMem(Pal, SizeOf(TLogPalette) + (SizeOf(TPaletteEntry) * 256));

  Pal.palVersion := $300;
  Pal.palNumEntries := 256;

  {$IFOPT R+}
    {$DEFINE TEMPRANGECHECK}
    {$R-}
  {$ENDIF}

  for Idx := 0 to 256 - 1 do begin
    Pal.palPalEntry[Idx].peRed   := Idx;
    Pal.palPalEntry[Idx].peGreen := Idx;
    Pal.palPalEntry[Idx].peBlue  := Idx;
    Pal.palPalEntry[Idx].peFlags := 0;
  end;

  {$IFDEF TEMPRANGECHECK}
    {$UNDEF TEMPRANGECHECK}
    {$R+}
  {$ENDIF}

  Result := CreatePalette(Pal^);

  FreeMem(Pal);
end;


(*
** Helper functions
*)
function LoadTexture(Filename: String; var Texture: Cardinal; LoadFromRes : Boolean; Instance: Cardinal): Boolean;
var
  glBitmap: TglBitmap2D;
begin
  Result := false;
  Texture := 0;

  if Instance = 0 then
    Instance := HInstance;

  if (LoadFromRes)
    then glBitmap := TglBitmap2D.CreateFromResourceName(Instance, FileName)
    else glBitmap := TglBitmap2D.Create(FileName);

  try
    glBitmap.DeleteTextureOnFree := False;
    glBitmap.FreeDataAfterGenTexture := False;
    glBitmap.GenTexture(True);
    if (glBitmap.ID > 0) then begin
      Texture := glBitmap.ID;
      Result := True;
    end;
  finally
    glBitmap.Free;
  end;
end;


function LoadCubeMap(PositiveX, NegativeX, PositiveY, NegativeY, PositiveZ, NegativeZ: String; var Texture: Cardinal; LoadFromRes : Boolean; Instance: Cardinal): Boolean;
var
  CM: TglBitmapCubeMap;
begin
  Texture := 0;

  if Instance = 0 then
    Instance := HInstance;

  CM := TglBitmapCubeMap.Create;
  try
    CM.DeleteTextureOnFree := False;

    // Maps
    if (LoadFromRes)
      then CM.LoadFromResource(Instance, PositiveX)
      else CM.LoadFromFile(PositiveX);
    CM.GenerateCubeMap(GL_TEXTURE_CUBE_MAP_POSITIVE_X);

    if (LoadFromRes)
      then CM.LoadFromResource(Instance, NegativeX)
      else CM.LoadFromFile(NegativeX);
    CM.GenerateCubeMap(GL_TEXTURE_CUBE_MAP_NEGATIVE_X);

    if (LoadFromRes)
      then CM.LoadFromResource(Instance, PositiveY)
      else CM.LoadFromFile(PositiveY);
    CM.GenerateCubeMap(GL_TEXTURE_CUBE_MAP_POSITIVE_Y);

    if (LoadFromRes)
      then CM.LoadFromResource(Instance, NegativeY)
      else CM.LoadFromFile(NegativeY);
    CM.GenerateCubeMap(GL_TEXTURE_CUBE_MAP_NEGATIVE_Y);

    if (LoadFromRes)
      then CM.LoadFromResource(Instance, PositiveZ)
      else CM.LoadFromFile(PositiveZ);
    CM.GenerateCubeMap(GL_TEXTURE_CUBE_MAP_POSITIVE_Z);

    if (LoadFromRes)
      then CM.LoadFromResource(Instance, NegativeZ)
      else CM.LoadFromFile(NegativeZ);
    CM.GenerateCubeMap(GL_TEXTURE_CUBE_MAP_NEGATIVE_Z);

    Texture := CM.ID;
    Result := True;
  finally
    CM.Free;
  end;
end;


function LoadNormalMap(Size: Integer; var Texture: Cardinal): Boolean;
var
  NM: TglBitmapNormalMap;
begin
  Texture := 0;

  NM := TglBitmapNormalMap.Create;
  try
    NM.DeleteTextureOnFree := False;
    NM.GenerateNormalMap(Size);

    Texture := NM.ID;
    Result := True;
  finally
    NM.Free;
  end;
end;


(*
** Defaults
*)
procedure glBitmapSetDefaultFormat(Format: TglBitmapFormat);
begin
  glBitmapDefaultFormat := Format;
end;


procedure glBitmapSetDefaultDeleteTextureOnFree(DeleteTextureOnFree: Boolean);
begin
  glBitmapDefaultDeleteTextureOnFree := DeleteTextureOnFree;
end;


procedure glBitmapSetDefaultFilter(Min, Mag: Integer);
begin
  case min of
    GL_NEAREST:
      glBitmapDefaultFilterMin := GL_NEAREST;
    GL_LINEAR:
      glBitmapDefaultFilterMin := GL_LINEAR;
    GL_NEAREST_MIPMAP_NEAREST:
      glBitmapDefaultFilterMin := GL_NEAREST_MIPMAP_NEAREST;
    GL_LINEAR_MIPMAP_NEAREST:
      glBitmapDefaultFilterMin := GL_LINEAR_MIPMAP_NEAREST;
    GL_NEAREST_MIPMAP_LINEAR:
      glBitmapDefaultFilterMin := GL_NEAREST_MIPMAP_LINEAR;
    GL_LINEAR_MIPMAP_LINEAR:
      glBitmapDefaultFilterMin := GL_LINEAR_MIPMAP_LINEAR;
  else
    raise EglBitmapException.Create('glBitmapSetDefaultFilter - Unknow Minfilter.');
  end;

  case mag of
    GL_NEAREST:
      glBitmapDefaultFilterMag := GL_NEAREST;
    GL_LINEAR:
      glBitmapDefaultFilterMag := GL_LINEAR;
  else
    raise EglBitmapException.Create('glBitmapSetDefaultFilter - Unknow Magfilter.');
  end;
end;


procedure glBitmapSetDefaultWrap(S: Integer; T: Integer; R: Integer);
begin
  case S of
    GL_CLAMP:
      glBitmapDefaultWrapS := GL_CLAMP;
    GL_REPEAT:
      glBitmapDefaultWrapS := GL_REPEAT;
    GL_CLAMP_TO_EDGE:
      glBitmapDefaultWrapS := GL_CLAMP_TO_EDGE;
    GL_CLAMP_TO_BORDER:
      glBitmapDefaultWrapS := GL_CLAMP_TO_BORDER;
  else
    raise EglBitmapException.Create('glBitmapSetDefaultWrap - Unknow Texturewrap(s).');
  end;

  case T of
    GL_CLAMP:
      glBitmapDefaultWrapT := GL_CLAMP;
    GL_REPEAT:
      glBitmapDefaultWrapT := GL_REPEAT;
    GL_CLAMP_TO_EDGE:
      glBitmapDefaultWrapT := GL_CLAMP_TO_EDGE;
    GL_CLAMP_TO_BORDER:
      glBitmapDefaultWrapT := GL_CLAMP_TO_BORDER;
  else
    raise EglBitmapException.Create('glBitmapSetDefaultWrap - Unknow Texturewrap(t).');
  end;

  case R of
    GL_CLAMP:
      glBitmapDefaultWrapR := GL_CLAMP;
    GL_REPEAT:
      glBitmapDefaultWrapR := GL_REPEAT;
    GL_CLAMP_TO_EDGE:
      glBitmapDefaultWrapR := GL_CLAMP_TO_EDGE;
    GL_CLAMP_TO_BORDER:
      glBitmapDefaultWrapR := GL_CLAMP_TO_BORDER;
  else
    raise EglBitmapException.Create('glBitmapSetDefaultWrap - Unknow Texturewrap(r).');
  end;
end;


procedure glBitmapSetDefaultFreeDataAfterGenTexture(FreeData: Boolean);
begin
  glBitmapDefaultFreeDataAfterGenTextures := FreeData;
end;


function glBitmapGetDefaultFormat: TglBitmapFormat;
begin
  Result := glBitmapDefaultFormat;
end;


function glBitmapGetDefaultDeleteTextureOnFree: Boolean;
begin
  Result := glBitmapDefaultDeleteTextureOnFree;
end;


procedure glBitmapGetDefaultFilter(var Min, Mag: Integer);
begin
  Min := glBitmapDefaultFilterMin;
  Mag := glBitmapDefaultFilterMag;
end;


procedure glBitmapGetDefaultTextureWrap(var S, T, R: Integer);
begin
  S := glBitmapDefaultWrapS;
  T := glBitmapDefaultWrapT;
  R := glBitmapDefaultWrapR;
end;


function glBitmapGetDefaultFreeDataAfterGenTexture: Boolean;
begin
  Result := glBitmapDefaultFreeDataAfterGenTextures;
end;


{ TglBitmap }

procedure TglBitmap.AfterConstruction;
begin
  inherited;

  FID := 0;
  FTarget := 0;
  FMipMap := mmMipmap;
  FIsResident := False;

  // get defaults
  FFreeDataAfterGenTexture := glBitmapGetDefaultFreeDataAfterGenTexture;
  FDeleteTextureOnFree := glBitmapGetDefaultDeleteTextureOnFree;

  FFormat := glBitmapGetDefaultFormat;

  glBitmapGetDefaultFilter(FFilterMin, FFilterMag);
  glBitmapGetDefaultTextureWrap(FWrapS, FWrapT, FWrapR);
end;


procedure TglBitmap.BeforeDestruction;
begin
  SetDataPtr(nil, ifEmpty);

  if ((ID > 0) and (FDeleteTextureOnFree))
    then glDeleteTextures(1, @ID);

  inherited;
end;


constructor TglBitmap.Create;
begin
  {$ifndef NO_NATIVE_GL}
  ReadOpenGLExtensions;
  {$endif}

  if (ClassType = TglBitmap) then
    raise EglBitmapException.Create('Don''t create TglBitmap directly. Use TglBitmap1D or TglBitmap2D.');

  inherited Create;
end;


constructor TglBitmap.Create(FileName: String);
begin
  Create;
  LoadFromFile(FileName);
end;


constructor TglBitmap.CreateFromResourceName(Instance: Cardinal; Resource: String; ResType: PAnsiChar);
begin
  Create;
  LoadFromResource(Instance, Resource, ResType);
end;


constructor TglBitmap.Create(Instance: Cardinal; Resource: String;
  ResType: PAnsiChar);
begin
  Create;
  LoadFromResource(Instance, Resource, ResType);
end;


constructor TglBitmap.Create(Stream: TStream);
begin
  Create;
  LoadFromStream(Stream);
end;


constructor TglBitmap.Create(Instance: Cardinal; ResourceID: Integer; ResType: PAnsiChar);
begin
  Create;
  LoadFromResourceID(Instance, ResourceID, ResType);
end;


constructor TglBitmap.Create(Size: TglBitmapPixelPosition;
  Format: TglBitmapInternalFormat);
var
  Image: pByte;
  ImageSize: Integer;
begin
  Create;

  ImageSize := FormatGetImageSize(Size, Format);
  GetMem(Image, ImageSize);
  try
    FillChar(Image^, ImageSize, #$FF);

    SetDataPtr(Image, Format, Size.X, Size.Y, Size.Z);
  except
    FreeMem(Image);
  end;
end;


constructor TglBitmap.Create(Size: TglBitmapPixelPosition;
  Format: TglBitmapInternalFormat; Func: TglBitmapFunction; Data: Pointer);
begin
  Create;
  LoadFromFunc(Size, Func, Format, Data);
end;


function TglBitmap.Clone: TglBitmap;
var
  Temp: TglBitmap;
  TempPtr: pByte;
  Size: Integer;
begin
  Result := nil;

  Temp := ClassType.Create as TglBitmap;
  try
    Size := FormatGetImageSize(glBitmapPosition(Width, Height, Depth), FInternalFormat);

    GetMem(TempPtr, Size);
    try
      Move(GetData^, TempPtr^, Size);
      Temp.SetDataPtr(TempPtr, FInternalFormat, Width, Height, Depth);

      Temp.FTarget := FTarget;
      Temp.FFormat := FFormat;
      Temp.FMipMap := FMipMap;
      Temp.FAnisotropic := FAnisotropic;
      Temp.FDeleteTextureOnFree := FDeleteTextureOnFree;
      Temp.FFreeDataAfterGenTexture := FFreeDataAfterGenTexture;
      Temp.FFilterMin := FFilterMin;
      Temp.FFilterMag := FFilterMag;
      Temp.FWrapS := FWrapS;
      Temp.FWrapT := FWrapT;
      Temp.FWrapR := FWrapR;

      Result := Temp;
    except
      FreeMem(TempPtr);
    end;
  except
    FreeAndNil(Temp);
  end;
end;


procedure TglBitmap.LoadFromFile(FileName: String);
var
  FS: TFileStream;
begin
  FS := TFileStream.Create(FileName, fmOpenRead);
  try
    FS.Position := 0;
    LoadFromStream(FS);
  finally
    FS.Free;
  end;
end;


procedure TglBitmap.LoadFromStream(Stream: TStream);
begin
  {$ifdef pngimage}
  if (not LoadPng(Stream))
    then
  {$endif}
  if (not LoadDDS(Stream))
    then
  if (not LoadTga(Stream))
    then
  if (not LoadJpg(Stream))
    then
  if (not LoadBmp(Stream))
    then raise EglBitmapException.Create('TglBitmap.LoadFromStream - Couldn''t load Stream. It''s possible to be an unknow Streamtype.');
end;


procedure TglBitmap.LoadFromResource(Instance: Cardinal; Resource: String; ResType: PAnsiChar);
var
  RS: TResourceStream;
  TempPos: Integer;
  ResTypeStr: String;
  TempResType: PAnsiChar;
begin
  if Assigned(ResType) then
    TempResType := ResType
  else
    begin
      TempPos := Pos('.', Resource);
      ResTypeStr := UpperCase(Copy(Resource, TempPos + 1, Length(Resource) - TempPos));
      Resource   := UpperCase(Copy(Resource, 0, TempPos -1));
      TempResType := PAnsiChar(ResTypeStr);
    end;

  RS := TResourceStream.Create(Instance, Resource, TempResType);
  try
    LoadFromStream(RS);
  finally
    RS.Free;
  end;
end;


procedure TglBitmap.LoadFromResourceID(Instance: Cardinal; ResourceID: Integer; ResType: PAnsiChar);
var
  RS: TResourceStream;
begin
  RS := TResourceStream.CreateFromID(Instance, ResourceID, ResType);
  try
    LoadFromStream(RS);
  finally
    RS.Free;
  end;
end;


procedure TglBitmap.LoadFromFunc(Size: TglBitmapPixelPosition;
  Func: TglBitmapFunction; Format: TglBitmapInternalFormat; Data: Pointer);
var
  Image: pByte;
  ImageSize: Integer;
begin
  ImageSize := FormatGetImageSize(Size, Format);
  GetMem(Image, ImageSize);
  try
    FillChar(Image^, ImageSize, #$FF);

    SetDataPtr(Image, Format, Size.X, Size.Y, Size.Z);
  except
    FreeMem(Image);
  end;

  AddFunc(Self, Func, False, Format, Data)
end;


procedure TglBitmap.SaveToFile(FileName: String; FileType: TglBitmapFileType);
var
  FS: TFileStream;
begin
  FS := TFileStream.Create(FileName, fmCreate);
  try
    FS.Position := 0;
    SaveToStream(FS, FileType);
  finally
    FS.Free;
  end;
end;


procedure TglBitmap.SaveToStream(Stream: TStream; FileType: TglBitmapFileType); 
begin
  case FileType of
    ftBMP: SaveBMP(Stream);
    ftTGA: SaveTGA(Stream);
    ftJPEG: SaveJPG(Stream);
    {$ifdef pngimage}
    ftPNG: SavePng(Stream);
    {$endif}
    ftDDS: SaveDDS(Stream);
  end;
end;


function TglBitmap.AddAlphaFromBitmap(Bitmap: TBitmap;
  Func: TglBitmapFunction; Data: Pointer): boolean;
var
  glBitmap: TglBitmap2D;
begin
  glBitmap := TglBitmap2D.Create;
  try
    glBitmap.AssignFromBitmap(Bitmap);

    Result := AddAlphaFromglBitmap(glBitmap, Func, Data);
  finally
    glBitmap.Free;
  end;
end;


function TglBitmap.AddAlphaFromFile(FileName: String;
  Func: TglBitmapFunction; Data: Pointer): boolean;
var
  FS: TFileStream;
begin
  FS := TFileStream.Create(FileName, fmOpenRead);
  try
    Result := AddAlphaFromStream(FS, Func, Data);
  finally
    FS.Free;
  end;
end;


function TglBitmap.AddAlphaFromStream(Stream: TStream;
  Func: TglBitmapFunction; Data: Pointer): boolean;
var
  glBitmap: TglBitmap2D;
begin
  assert(Assigned(GetData()), 'TglBitmap.AddAlphaFromStream - AddAlpha can only called if data where loaded.');

  glBitmap := TglBitmap2D.Create(Stream);
  try
    Result := AddAlphaFromglBitmap(glBitmap, Func, Data);
  finally
    glBitmap.Free;
  end;
end;


function TglBitmap.AddAlphaFromResource(Instance: Cardinal; Resource: String;
  ResType: PAnsiChar; Func: TglBitmapFunction; Data: Pointer): boolean;
var
  RS: TResourceStream;
  TempPos: Integer;
  ResTypeStr: String;
  TempResType: PAnsiChar;
begin
  if Assigned(ResType) then
    TempResType := ResType
  else
    begin
      TempPos := Pos('.', Resource);
      ResTypeStr := UpperCase(Copy(Resource, TempPos + 1, Length(Resource) - TempPos));
      Resource   := UpperCase(Copy(Resource, 0, TempPos -1));
      TempResType := PAnsiChar(ResTypeStr);
    end;

  RS := TResourceStream.Create(Instance, Resource, TempResType);
  try
    Result := AddAlphaFromStream(RS, Func, Data);
  finally
    RS.Free;
  end;
end;


function TglBitmap.AddAlphaFromResourceID(Instance: Cardinal; ResourceID: Integer;
  ResType: PAnsiChar; Func: TglBitmapFunction; Data: Pointer): boolean;
var
  RS: TResourceStream;
begin
  RS := TResourceStream.CreateFromID(Instance, ResourceID, ResType);
  try
    Result := AddAlphaFromStream(RS, Func, Data);
  finally
    RS.Free;
  end;
end;


procedure glBitmapColorKeyAlphaFunc(var FuncRec: TglBitmapFunctionRec);
begin
  with FuncRec do begin
    Dest.Red   := Source.Red;
    Dest.Green := Source.Green;
    Dest.Blue  := Source.Blue;

    with TglBitmapPixelData(Data^) do
      if ((Dest.Red   <= Red  ) and (Dest.Red   >= PixelDesc.RedRange  ) and
          (Dest.Green <= Green) and (Dest.Green >= PixelDesc.GreenRange) and
          (Dest.Blue  <= Blue ) and (Dest.Blue  >= PixelDesc.BlueRange ))
        then Dest.Alpha := 0
        else Dest.Alpha := Dest.PixelDesc.AlphaRange;
  end;
end;


function TglBitmap.AddAlphaFromColorKey(Red, Green, Blue, Deviation: Byte): Boolean;
begin
  Result := AddAlphaFromColorKeyFloat(Red / $FF, Green / $FF, Blue / $FF, Deviation / $FF);
end;


function TglBitmap.AddAlphaFromColorKeyRange(Red, Green, Blue: Cardinal; Deviation: Cardinal = 0): Boolean;
var
  Data: TglBitmapPixelData;
begin
  FormatPreparePixel(Data, FormatGetWithAlpha(FInternalFormat));

  Result := AddAlphaFromColorKeyFloat(
    Red   / Data.PixelDesc.RedRange,
    Green / Data.PixelDesc.GreenRange,
    Blue  / Data.PixelDesc.BlueRange,
    Deviation / Max(Data.PixelDesc.RedRange, Max(Data.PixelDesc.GreenRange, Data.PixelDesc.BlueRange)));
end;


function TglBitmap.AddAlphaFromColorKeyFloat(Red, Green, Blue: Single; Deviation: Single = 0): Boolean;
var
  TempR, TempG, TempB: Cardinal;
  Data: TglBitmapPixelData;
begin
  FormatPreparePixel(Data, FormatGetWithAlpha(FInternalFormat));

  // Calculate Colorrange
  with Data.PixelDesc do begin
    TempR := Trunc(RedRange   * Deviation);
    TempG := Trunc(GreenRange * Deviation);
    TempB := Trunc(BlueRange  * Deviation);

    Data.Red   := Min(RedRange,   Trunc(RedRange   * Red)   + TempR);
    RedRange   := Max(0,          Trunc(RedRange   * Red)   - TempR);
    Data.Green := Min(GreenRange, Trunc(GreenRange * Green) + TempG);
    GreenRange := Max(0,          Trunc(GreenRange * Green) - TempG);
    Data.Blue  := Min(BlueRange,  Trunc(BlueRange  * Blue)  + TempB);
    BlueRange  := Max(0,          Trunc(BlueRange  * Blue)  - TempB);
    Data.Alpha := 0;
    AlphaRange := 0;
  end;

  Result := AddAlphaFromFunc(glBitmapColorKeyAlphaFunc, @Data);
end;


procedure glBitmapValueAlphaFunc(var FuncRec: TglBitmapFunctionRec);
begin
  with FuncRec do begin
    Dest.Red   := Source.Red;
    Dest.Green := Source.Green;
    Dest.Blue  := Source.Blue;

    with TglBitmapPixelData(Data^) do
      Dest.Alpha := Alpha;
  end;
end;


function TglBitmap.AddAlphaFromValue(Alpha: Byte): Boolean;
begin
  Result := AddAlphaFromValueFloat(Alpha / $FF);
end;


function TglBitmap.AddAlphaFromValueFloat(Alpha: Single): Boolean;
var
  Data: TglBitmapPixelData;
begin
  FormatPreparePixel(Data, FormatGetWithAlpha(FInternalFormat));

  with Data.PixelDesc do 
    Data.Alpha := Min(AlphaRange, Max(0, Round(AlphaRange * Alpha)));

  Result := AddAlphaFromFunc(glBitmapValueAlphaFunc, @Data);
end;


function TglBitmap.AddAlphaFromValueRange(Alpha: Cardinal): Boolean;
var
  Data: TglBitmapPixelData;
begin
  FormatPreparePixel(Data, FormatGetWithAlpha(FInternalFormat));

  Result := AddAlphaFromValueFloat(Alpha / Data.PixelDesc.AlphaRange);
end;


procedure glBitmapInvertFunc(var FuncRec: TglBitmapFunctionRec);
begin
  with FuncRec do begin
    Dest.Red   := Source.Red;
    Dest.Green := Source.Green;
    Dest.Blue  := Source.Blue;
    Dest.Alpha := Source.Alpha;

    if (Integer(Data) and $1 > 0) then begin
      Dest.Red   := Dest.Red   xor Dest.PixelDesc.RedRange;
      Dest.Green := Dest.Green xor Dest.PixelDesc.GreenRange;
      Dest.Blue  := Dest.Blue  xor Dest.PixelDesc.BlueRange;
    end;

    if (Integer(Data) and $2 > 0) then begin
      Dest.Alpha := Dest.Alpha xor Dest.PixelDesc.AlphaRange;
    end;
  end;
end;


procedure TglBitmap.Invert(UseRGB, UseAlpha: Boolean);
begin
  if ((UseRGB) or (UseAlpha))
    then AddFunc(glBitmapInvertFunc, False, Pointer(Integer(UseAlpha) shl 1 or Integer(UseRGB)));
end;


procedure TglBitmap.SetFilter(Min, Mag: Integer);
begin
  case Min of
    GL_NEAREST:
      FFilterMin := GL_NEAREST;
    GL_LINEAR:
      FFilterMin := GL_LINEAR;
    GL_NEAREST_MIPMAP_NEAREST:
      FFilterMin := GL_NEAREST_MIPMAP_NEAREST;
    GL_LINEAR_MIPMAP_NEAREST:
      FFilterMin := GL_LINEAR_MIPMAP_NEAREST;
    GL_NEAREST_MIPMAP_LINEAR:
      FFilterMin := GL_NEAREST_MIPMAP_LINEAR;
    GL_LINEAR_MIPMAP_LINEAR:
      FFilterMin := GL_LINEAR_MIPMAP_LINEAR;
  else
    raise EglBitmapException.Create('TglBitmap.SetFilter - Unknow Minfilter.');
  end;

  case Mag of
    GL_NEAREST:
      FFilterMag := GL_NEAREST;
    GL_LINEAR:
      FFilterMag := GL_LINEAR;
  else
    raise EglBitmapException.Create('TglBitmap.SetFilter - Unknow Magfilter.');
  end;

  // If texture is created then assign filter
  if ID > 0 then begin
    Bind(False);

    glTexParameteri(Target, GL_TEXTURE_MAG_FILTER, FFilterMag);
    if (MipMap = mmNone) or (Target = GL_TEXTURE_RECTANGLE_ARB) then begin
      case FFilterMin of
        GL_NEAREST, GL_LINEAR:
          glTexParameteri(Target, GL_TEXTURE_MIN_FILTER, FFilterMin);
        GL_NEAREST_MIPMAP_NEAREST, GL_NEAREST_MIPMAP_LINEAR:
          glTexParameteri(Target, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        GL_LINEAR_MIPMAP_NEAREST, GL_LINEAR_MIPMAP_LINEAR:
          glTexParameteri(Target, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
      end;
    end else
      glTexParameteri(Target, GL_TEXTURE_MIN_FILTER, FFilterMin);
  end;
end;


procedure TglBitmap.SetWrap(S: Integer; T: Integer; R: Integer);
begin
  case S of
    GL_CLAMP:
      FWrapS := GL_CLAMP;
    GL_REPEAT:
      FWrapS := GL_REPEAT;
    GL_CLAMP_TO_EDGE:
      begin
        if GL_VERSION_1_2 or GL_EXT_texture_edge_clamp then
          FWrapS := GL_CLAMP_TO_EDGE
        else
          FWrapS := GL_CLAMP;
      end;
    GL_CLAMP_TO_BORDER:
      begin
        if GL_VERSION_1_3 or GL_ARB_texture_border_clamp then
          FWrapS := GL_CLAMP_TO_BORDER
        else
          FWrapS := GL_CLAMP;
      end;
    GL_MIRRORED_REPEAT:
      begin
        if GL_VERSION_1_4 or GL_ARB_texture_mirrored_repeat or GL_IBM_texture_mirrored_repeat then
          FWrapS := GL_MIRRORED_REPEAT
        else
          raise EglBitmapException.Create('TglBitmap.SetWrap - Unsupported Texturewrap GL_MIRRORED_REPEAT (S).');
      end;
  else
    raise EglBitmapException.Create('TglBitmap.SetWrap - Unknow Texturewrap (S).');
  end;

  case T of
    GL_CLAMP:
      FWrapT := GL_CLAMP;
    GL_REPEAT:
      FWrapT := GL_REPEAT;
    GL_CLAMP_TO_EDGE:
      begin
        if GL_VERSION_1_2 or GL_EXT_texture_edge_clamp then
          FWrapT := GL_CLAMP_TO_EDGE
        else
          FWrapT := GL_CLAMP;
      end;
    GL_CLAMP_TO_BORDER:
      begin
        if GL_VERSION_1_3 or GL_ARB_texture_border_clamp then
          FWrapT := GL_CLAMP_TO_BORDER
        else
          FWrapT := GL_CLAMP;
      end;
    GL_MIRRORED_REPEAT:
      begin
        if GL_VERSION_1_4 or GL_ARB_texture_mirrored_repeat or GL_IBM_texture_mirrored_repeat then
          FWrapT := GL_MIRRORED_REPEAT
        else
          raise EglBitmapException.Create('TglBitmap.SetWrap - Unsupported Texturewrap GL_MIRRORED_REPEAT (T).');
      end;
  else
    raise EglBitmapException.Create('TglBitmap.SetWrap - Unknow Texturewrap (T).');
  end;

  case R of
    GL_CLAMP:
      FWrapR := GL_CLAMP;
    GL_REPEAT:
      FWrapR := GL_REPEAT;
    GL_CLAMP_TO_EDGE:
      begin
        if GL_VERSION_1_2 or GL_EXT_texture_edge_clamp then
          FWrapR := GL_CLAMP_TO_EDGE
        else
          FWrapR := GL_CLAMP;
      end;
    GL_CLAMP_TO_BORDER:
      begin
        if GL_VERSION_1_3 or GL_ARB_texture_border_clamp then
          FWrapR := GL_CLAMP_TO_BORDER
        else
          FWrapR := GL_CLAMP;
      end;
    GL_MIRRORED_REPEAT:
      begin
        if GL_VERSION_1_4 or GL_ARB_texture_mirrored_repeat or GL_IBM_texture_mirrored_repeat then
          FWrapR := GL_MIRRORED_REPEAT
        else
          raise EglBitmapException.Create('TglBitmap.SetWrap - Unsupported Texturewrap GL_MIRRORED_REPEAT (R).');
      end;
  else
    raise EglBitmapException.Create('TglBitmap.SetWrap - Unknow Texturewrap (R).');
  end;

  if ID > 0 then begin
    Bind (False);
    glTexParameteri(Target, GL_TEXTURE_WRAP_S, FWrapS);
    glTexParameteri(Target, GL_TEXTURE_WRAP_T, FWrapT);
    glTexParameteri(Target, GL_TEXTURE_WRAP_R, FWrapR);
  end;
end;


function TglBitmap.GetData: PByte;
begin
  Result := FDataPtr;
end;


procedure TglBitmap.SetDataPtr(Ptr: PByte; Format: TglBitmapInternalFormat; Width, Height, Depth: Integer);
begin
  // Data
  if FDataPtr <> Ptr then begin
    if (Assigned(FDataPtr))
      then FreeMem(FDataPtr);

    FDataPtr := Ptr;
  end;

  if Ptr = nil then begin
    FInternalFormat := ifEmpty;
    FPixelSize := 0;
    FLineSize := 0;
  end else begin
    if Width <> -1 then begin
      FDimension.Fields := FDimension.Fields + [ffX];
      FDimension.X := Width;
    end;

    if Height <> -1 then begin
      FDimension.Fields := FDimension.Fields + [ffY];
      FDimension.Y := Height;
    end;

    if Depth <> -1 then begin
      FDimension.Fields := FDimension.Fields + [ffZ];
      FDimension.Z := Depth;
    end;

    FInternalFormat := Format;
    FPixelSize := Trunc(FormatGetSize(FInternalFormat));
    FLineSize :=  Trunc(FormatGetSize(FInternalFormat) * Self.Width);
  end;
end;


function TglBitmap.LoadBmp(const Stream: TStream): Boolean;
var
  bmp: TBitmap;
  StreamPos: Int64;
  Temp: array[0..1]of char;
begin
  Result := False;

  // reading first two bytes to test file and set cursor back to begin
  StreamPos := Stream.Position;
  Stream.Read(Temp[0], 2);
  Stream.Position := StreamPos;

  // if Bitmap then read file.
  if ((Temp[0] = 'B') and (Temp[1] = 'M')) then begin
    bmp := TBitmap.Create;
    try
      bmp.LoadFromStream(Stream);
      if bmp.PixelFormat in [pfDevice, pf1Bit, pf4Bit, pf15Bit, pfCustom]
        then bmp.PixelFormat := pf24bit;
      Result := AssignFromBitmap(bmp);
    finally
      bmp.Free;
    end;
  end;
end;


function TglBitmap.LoadJpg(const Stream: TStream): Boolean;
var
  bmp: TBitmap;
  jpg: TJPEGImage;
  StreamPos: Int64;
  Temp: array[0..1]of char;
begin
  Result := False;

  // reading first two bytes to test file and set cursor back to begin
  StreamPos := Stream.Position;
  Stream.Read(Temp[0], 2);
  Stream.Position := StreamPos;

  // if Bitmap then read file.
  if ((Temp[0] = chr($FF)) and (Temp[1] = chr($D8))) then begin
    bmp := TBitmap.Create;
    try
      jpg := TJPEGImage.Create;
      try
        jpg.LoadFromStream(Stream);
        bmp.Assign(jpg);
        Result := AssignFromBitmap(bmp);
      finally
        jpg.Free;
      end;
    finally
      bmp.Free;
    end;
  end;
end;


const
  DDS_MAGIC                   = $20534444;

  // DDS_header.dwFlags
  DDSD_CAPS                   = $00000001;
  DDSD_HEIGHT                 = $00000002;
  DDSD_WIDTH                  = $00000004;
  DDSD_PITCH                  = $00000008;
  DDSD_PIXELFORMAT            = $00001000;
  DDSD_MIPMAPCOUNT            = $00020000;
  DDSD_LINEARSIZE             = $00080000;
  DDSD_DEPTH                  = $00800000;

  // DDS_header.sPixelFormat.dwFlags
  DDPF_ALPHAPIXELS            = $00000001;
  DDPF_FOURCC                 = $00000004;
  DDPF_INDEXED                = $00000020;
  DDPF_RGB                    = $00000040;

  // DDS_header.sCaps.dwCaps1
  DDSCAPS_COMPLEX             = $00000008;
  DDSCAPS_TEXTURE             = $00001000;
  DDSCAPS_MIPMAP              = $00400000;

  // DDS_header.sCaps.dwCaps2
  DDSCAPS2_CUBEMAP            = $00000200;
  DDSCAPS2_CUBEMAP_POSITIVEX  = $00000400;
  DDSCAPS2_CUBEMAP_NEGATIVEX  = $00000800;
  DDSCAPS2_CUBEMAP_POSITIVEY  = $00001000;
  DDSCAPS2_CUBEMAP_NEGATIVEY  = $00002000;
  DDSCAPS2_CUBEMAP_POSITIVEZ  = $00004000;
  DDSCAPS2_CUBEMAP_NEGATIVEZ  = $00008000;
  DDSCAPS2_VOLUME             = $00200000;

  D3DFMT_DXT1                 = $31545844;
  D3DFMT_DXT3                 = $33545844;
  D3DFMT_DXT5                 = $35545844;

type
  TDDSPixelFormat = packed record
    dwSize: Cardinal;
    dwFlags: Cardinal;
    dwFourCC: Cardinal;
    dwRGBBitCount: Cardinal;
    dwRBitMask: Cardinal;
    dwGBitMask: Cardinal;
    dwBBitMask: Cardinal;
    dwAlphaBitMask: Cardinal;
  end;

  TDDSCaps = packed record
    dwCaps1: Cardinal;
    dwCaps2: Cardinal;
    dwDDSX: Cardinal;
    dwReserved: Cardinal;
  end;

  TDDSHeader = packed record
(*
    case boolean of
    TRUE:
    (
*)
      dwMagic: Cardinal;
      dwSize: Cardinal;
      dwFlags: Cardinal;
      dwHeight: Cardinal;
      dwWidth: Cardinal;
      dwPitchOrLinearSize: Cardinal;
      dwDepth: Cardinal;
      dwMipMapCount: Cardinal;
      dwReserved: array[0..10] of Cardinal;
      PixelFormat: TDDSPixelFormat;
      Caps: TDDSCaps;
      dwReserved2: Cardinal;
(*
    );
    FALSE:
    (
      Data: array[0..127] of byte;
    );
*)

  end;


function TglBitmap.LoadDDS(const Stream: TStream): Boolean;

var

  Header: TDDSHeader;

  StreamPos: Int64;

  Y, LineSize: Cardinal;

//  MipMapCount, X, Y, XSize, YSize: Cardinal;
  RowSize: Cardinal;
  NewImage, pData: pByte;
  Format: TglBitmapInternalFormat;

  function RaiseEx : Exception;
  begin
    Result := EglBitmapException.Create('TglBitmap.LoadDDS - unsupported Pixelformat found.');
  end;

  function GetInternalFormat: TglBitmapInternalFormat;

    function GetBitSize(BitSet: Cardinal): Integer;
    begin
      Result := 0;

      while BitSet > 0 do begin
        if (BitSet and $1) = 1
          then Inc(Result);

        BitSet := BitSet shr 1;
      end;
    end;

  begin
    with Header.PixelFormat do begin
      // Compresses
      if (dwFlags and DDPF_FOURCC) > 0 then begin
        case Header.PixelFormat.dwFourCC of
          D3DFMT_DXT1: Result := ifDXT1;
          D3DFMT_DXT3: Result := ifDXT3;
          D3DFMT_DXT5: Result := ifDXT5;
        else
          raise RaiseEx;
        end;
      end else

      // RGB
      if (dwFlags and (DDPF_RGB or DDPF_ALPHAPIXELS)) > 0 then begin
        case dwRGBBitCount of
           8:
            begin
              if dwFlags and DDPF_ALPHAPIXELS > 0
                then Result := ifAlpha
                else Result := ifLuminance;
            end;
          16:
            begin
              if dwFlags and DDPF_ALPHAPIXELS > 0 then begin
                // Alpha
                case GetBitSize(dwRBitMask) of
                  5: Result := ifRGB5A1;
                  4: Result := ifRGBA4;
                else
                  Result := ifLuminanceAlpha;
                end;
              end else begin
                // no Alpha
                Result := ifR5G6B5;
              end;
            end;
          24:
            begin
              if dwRBitMask > dwBBitMask
                then Result := ifBGR8
                else Result := ifRGB8;
            end;
          32:
            begin
              if GetBitSize(dwRBitMask) = 10
                then Result := ifRGB10A2
                else

              if dwRBitMask > dwBBitMask
                then Result := ifBGRA8
                else Result := ifRGBA8;
            end;
        else
          raise RaiseEx;
        end;
      end else
        raise RaiseEx;
    end;
  end;

begin
  Result := False;

  // Header
  StreamPos := Stream.Position;
  Stream.Read(Header, sizeof(Header));

  if ((Header.dwMagic <> DDS_MAGIC) or (Header.dwSize <> 124) or
     ((Header.dwFlags and DDSD_PIXELFORMAT) = 0) or ((Header.dwFlags and DDSD_CAPS) = 0)) then begin
    Stream.Position := StreamPos;
    Exit;
  end;

  // Pixelformat
//  if Header.dwFlags and DDSD_MIPMAPCOUNT <> 0
//    then MipMapCount := Header.dwMipMapCount
//    else MipMapCount := 1;

  Format := GetInternalFormat;
  LineSize := Trunc(Header.dwWidth * FormatGetSize(Format));

  GetMem(NewImage, Header.dwHeight * LineSize);
  try

    pData := NewImage;

    // Compressed
    if (Header.PixelFormat.dwFlags and DDPF_FOURCC) > 0 then begin
      RowSize := Header.dwPitchOrLinearSize div Header.dwWidth;

      for Y := 0 to Header.dwHeight -1 do begin
        Stream.Read(pData^, RowSize);
        Inc(pData, LineSize);
      end;
    end else

    // RGB(A)
    if (Header.PixelFormat.dwFlags and (DDPF_RGB or DDPF_ALPHAPIXELS)) > 0 then begin
      RowSize := Header.dwPitchOrLinearSize;

      for Y := 0 to Header.dwHeight -1 do begin
        Stream.Read(pData^, RowSize);
        Inc(pData, LineSize);
      end;
    end
      else raise RaiseEx;

    SetDataPtr(NewImage, Format, Header.dwWidth, Header.dwHeight);

    Result := True;
  except
    FreeMem(NewImage);
  end;
end;


type
  TTGAHeader = packed record
    ImageID: Byte;
    ColorMapType: Byte;
    ImageType: Byte;
    ColorMapSpec: Array[0..4] of Byte;
    OrigX: Word;
    OrigY: Word;
    Width: Word;
    Height: Word;
    Bpp: Byte;
    ImageDes: Byte;
  end;

const
  TGA_UNCOMPRESSED_RGB = 2;
  TGA_UNCOMPRESSED_GRAY = 3;
  TGA_COMPRESSED_RGB = 10;
  TGA_COMPRESSED_GRAY = 11;

function TglBitmap.LoadTga(const Stream: TStream): Boolean;
var
  Header: TTGAHeader;
  NewImage, pData: PByte;
  StreamPos: Int64;
  PixelSize, LineSize, YStart, YEnd, YInc: Integer;
  Format: TglBitmapInternalFormat;

  procedure ReadUncompressed;
  var
    RowSize: Integer;
  begin
    RowSize := Header.Width * PixelSize;

    // copy line by line
    while YStart <> YEnd + YInc do begin
      pData := NewImage;
      Inc(pData, YStart * LineSize);

      Stream.Read(pData^, RowSize);
      Inc(YStart, YInc);
    end;
  end;

  procedure ReadCompressed;
  var
    Temp: Byte;
    TempBuf: Array [0..3]of Byte;
    Idx, LinePixels, PixelsRead, PixelsToRead: Integer;
    CacheStream: TMemoryStream;

    procedure CheckLine;
    begin
      if LinePixels >= Header.Width then begin
        LinePixels := 0;
        pData := NewImage;
        Inc(YStart, YInc);
        Inc(pData, YStart * LineSize);
      end;
    end;


    procedure Read(var Buffer; Count: Integer);
    var
      BytesRead: Integer;
    begin
      if (CacheStream.Position + Count) > CacheStream.Size then begin
        BytesRead := 0;

        // Read Data
        if CacheStream.Size - CacheStream.Position > 0 then begin
          BytesRead := CacheStream.Size - CacheStream.Position;
          CacheStream.Read(Buffer, CacheStream.Size - CacheStream.Position);
        end;

        // Reload Data
        CacheStream.Size := Min(2048, Stream.Size - Stream.Position);
        CacheStream.Position := 0;
        CacheStream.CopyFrom(Stream, CacheStream.Size);
        CacheStream.Position := 0;

        // Read else
        if Count - BytesRead > 0 then
          CacheStream.Read(pByteArray(@Buffer)^[BytesRead], Count - BytesRead);
      end else
        CacheStream.Read(Buffer, Count);
    end;


  begin
    CacheStream := TMemoryStream.Create;
    try
      PixelsToRead := Header.Width * Header.Height;
      PixelsRead := 0;
      LinePixels := 0;

      pData := NewImage;
      Inc(pData, YStart * LineSize);

      // Read until all Pixels
      repeat
        Read(Temp, 1);

        if Temp and $80 > 0 then begin
          Read(TempBuf, PixelSize);

          // repeat Pixel
          for Idx := 0 to Temp and $7F do begin
            CheckLine;

            Move(TempBuf, pData^, PixelSize);
            Inc(pData, PixelSize);

            Inc(PixelsRead);
            Inc(LinePixels);
          end;
        end else begin
          for Idx := 0 to Temp and $7F do begin
            CheckLine;

            Read(pData^, PixelSize);
            Inc(pData, PixelSize);

            Inc(PixelsRead);
            Inc(LinePixels);
          end;
        end;
      until PixelsRead >= PixelsToRead;
    finally
      FreeAndNil(CacheStream);
    end;
  end;

begin
  Result := False;

  // reading header to test file and set cursor back to begin
  StreamPos := Stream.Position;
  Stream.Read(Header, SizeOf(Header));
  Stream.Position := StreamPos;

  // no colormapped files
  if (Header.ColorMapType = 0) then begin
    if Header.ImageType in [TGA_UNCOMPRESSED_RGB, TGA_UNCOMPRESSED_GRAY, TGA_COMPRESSED_RGB, TGA_COMPRESSED_GRAY] then begin
      case Header.Bpp of
         8: Format := ifAlpha;
        16: Format := ifLuminanceAlpha;
        24: Format := ifBGR8;
        32: Format := ifBGRA8;
      else
        raise EglBitmapException.Create('TglBitmap.LoadTga - unsupported BitsPerPixel found.');
      end;

      PixelSize := Trunc(FormatGetSize(Format));
      LineSize := Trunc(Header.Width * PixelSize);

      GetMem(NewImage, LineSize * Header.Height);
      try
        // Set Streampos to start of data
        Stream.Position := StreamPos + SizeOf(Header);

        // skip ImageID
        if Header.ImageID <> 0 then
          Stream.Position := Stream.Position + Header.ImageID;

        // Row direction
        if (Header.ImageDes and $20 > 0) then begin
          YStart := 0;
          YEnd := Header.Height -1;
          YInc := 1;
        end else begin
          YStart := Header.Height -1;
          YEnd := 0;
          YInc := -1;
        end;

        // Read Image
        case Header.ImageType of
          TGA_UNCOMPRESSED_RGB, TGA_UNCOMPRESSED_GRAY:
            ReadUncompressed;
          TGA_COMPRESSED_RGB, TGA_COMPRESSED_GRAY:
            ReadCompressed;
        end;

        SetDataPtr(NewImage, Format, Header.Width, Header.Height);

        Result := True;
      except
        FreeMem(NewImage);
      end;
    end;
  end;
end;


{$ifdef pngimage}
function TglBitmap.LoadPng(const Stream: TStream): Boolean;
var
  StreamPos: Int64;
  Png: TPNGObject;
  Header: Array[0..7] of Char;
  Row, Col, PixSize, LineSize: Integer;
  NewImage, pSource, pDest, pAlpha: pByte;
  Format: TglBitmapInternalFormat;

const
  PngHeader: Array[0..7] of Char = (#137, #80, #78, #71, #13, #10, #26, #10);

begin
  Result := False;

  StreamPos := Stream.Position;
  Stream.Read(Header[0], SizeOf(Header));
  Stream.Position := StreamPos;

  {Test if the header matches}
  if Header = PngHeader then begin
    Png := TPNGObject.Create;
    try
      Png.LoadFromStream(Stream);

      case Png.Header.ColorType of
        COLOR_GRAYSCALE:
          Format := ifLuminance;
        COLOR_GRAYSCALEALPHA:
          Format := ifLuminanceAlpha;
        COLOR_RGB:
          Format := ifBGR8;
        COLOR_RGBALPHA:
          Format := ifBGRA8;
      else
        raise EglBitmapException.Create ('TglBitmap.LoadPng - Unsupported Colortype found.');
      end;

      PixSize := Trunc(FormatGetSize(Format));
      LineSize := Integer(Png.Header.Width) * PixSize;

      GetMem(NewImage, LineSize * Integer(Png.Header.Height));
      try
        pDest := NewImage;

        case Png.Header.ColorType of
          COLOR_RGB, COLOR_GRAYSCALE:
            begin
              for Row := 0 to Png.Height -1 do begin
                Move (Png.Scanline[Row]^, pDest^, LineSize);
                Inc(pDest, LineSize);
              end;
            end;
          COLOR_RGBALPHA, COLOR_GRAYSCALEALPHA:
            begin
              PixSize := PixSize -1;

              for Row := 0 to Png.Height -1 do begin
                pSource := Png.Scanline[Row];
                pAlpha := pByte(Png.AlphaScanline[Row]);

                for Col := 0 to Png.Width -1 do begin
                  Move (pSource^, pDest^, PixSize);
                  Inc(pSource, PixSize);
                  Inc(pDest, PixSize);

                  pDest^ := pAlpha^;
                  inc(pAlpha);
                  Inc(pDest);
                end;
              end;
            end;
          else
            raise EglBitmapException.Create ('TglBitmap.LoadPng - Unsupported Colortype found.');
        end;

        SetDataPtr(NewImage, Format, Png.Header.Width, Png.Header.Height);

        Result := True;
      except
        FreeMem(NewImage);
      end;
    finally
      Png.Free;
    end;
  end;
end;
{$endif}


{$ifdef pngimage}
procedure TglBitmap.SavePng(const Stream: TStream); 
var
  Png: TPNGObject;

  pSource, pDest: pByte;
  X, Y, PixSize: Integer;
  ColorType: Cardinal;
  Alpha: Boolean;
begin
  if ftPNG in FormatGetSupportedFiles (InternalFormat) then begin
    case FInternalFormat of
      ifAlpha, ifLuminance, ifDepth8:
        begin
          ColorType := COLOR_GRAYSCALE;
          PixSize := 1;
          Alpha := False;
        end;
      ifLuminanceAlpha:
        begin
          ColorType := COLOR_GRAYSCALEALPHA;
          PixSize := 1;
          Alpha := True;
        end;
      ifBGR8, ifRGB8:
        begin
          ColorType := COLOR_RGB;
          PixSize := 3;
          Alpha := False;
        end;
      ifBGRA8, ifRGBA8:
        begin
          ColorType := COLOR_RGBALPHA;
          PixSize := 3;
          Alpha := True
        end;
      else
        raise EglBitmapUnsupportedInternalFormat.Create('SavePng - ' + UNSUPPORTED_INTERNAL_FORMAT);
    end;

    Png := TPNGObject.CreateBlank(ColorType, 8, Width, Height);
    try
      // Copy ImageData
      pSource := GetData;
      for Y := 0 to Height -1 do begin
        pDest := png.ScanLine[Y];

        for X := 0 to Width -1 do begin
          Move(pSource^, pDest^, PixSize);

          Inc(pDest, PixSize);
          Inc(pSource, PixSize);

          if Alpha then begin
            png.AlphaScanline[Y]^[X] := pSource^;
            Inc(pSource);
          end;
        end;
      end;

      // Save to Stream
      Png.SaveToStream(Stream);
    finally
      FreeAndNil(Png);
    end;
  end
    else raise EglBitmapUnsupportedInternalFormat.Create('SavePng - ' + UNSUPPORTED_INTERNAL_FORMAT);
end;
{$endif}


procedure TglBitmap.SaveDDS(const Stream: TStream);
var
  Header: TDDSHeader;
  Pix: TglBitmapPixelData;
begin
  if FormatIsUncompressed(FInternalFormat) then begin
    if FInternalFormat = ifAlpha
      then FormatPreparePixel(Pix, ifLuminance)
      else FormatPreparePixel(Pix, FInternalFormat);

    // Generell
    ZeroMemory(@Header, SizeOf(Header));

    Header.dwMagic := DDS_MAGIC;
    Header.dwSize := 124;
    Header.dwFlags := DDSD_PITCH or DDSD_CAPS or DDSD_PIXELFORMAT;

    if Width > 0 then begin
      Header.dwWidth := Width;
      Header.dwFlags := Header.dwFlags or DDSD_WIDTH;
    end;

    if Height > 0 then begin
      Header.dwHeight := Height;
      Header.dwFlags := Header.dwFlags or DDSD_HEIGHT;
    end;

    if Depth > 0 then begin
      Header.dwDepth := Depth;
      Header.dwFlags := Header.dwFlags or DDSD_DEPTH;
    end;

    Header.dwPitchOrLinearSize := FLineSize;
    Header.dwMipMapCount := 1;

    // Caps
    Header.Caps.dwCaps1 := DDSCAPS_TEXTURE;

    // Pixelformat
    Header.PixelFormat.dwSize := Sizeof(Header.PixelFormat);
    Header.PixelFormat.dwFlags := DDPF_RGB;

    if FormatHasAlpha(FInternalFormat) and (FInternalFormat <> ifAlpha)
      then Header.PixelFormat.dwFlags := Header.PixelFormat.dwFlags or DDPF_ALPHAPIXELS;

    Header.PixelFormat.dwRGBBitCount  := Trunc(FormatGetSize(FInternalFormat) * 8);
    Header.PixelFormat.dwRBitMask     := Pix.PixelDesc.RedRange   shl Pix.PixelDesc.RedShift;
    Header.PixelFormat.dwGBitMask     := Pix.PixelDesc.GreenRange shl Pix.PixelDesc.GreenShift;
    Header.PixelFormat.dwBBitMask     := Pix.PixelDesc.BlueRange  shl Pix.PixelDesc.BlueShift;
    Header.PixelFormat.dwAlphaBitMask := Pix.PixelDesc.AlphaRange shl Pix.PixelDesc.AlphaShift;

    // Write
    Stream.Write(Header, SizeOf(Header));

    Stream.Write(GetData^, FormatGetImageSize(glBitmapPosition(Width, Height, Depth), FInternalFormat));
  end
    else raise EglBitmapUnsupportedInternalFormat.Create('SaveDDS - ' + UNSUPPORTED_INTERNAL_FORMAT);
end;


procedure TglBitmap.SaveTga(const Stream: TStream);
var
  Header: TTGAHeader;
begin
  if ftTGA in FormatGetSupportedFiles (InternalFormat) then begin
    ZeroMemory(@Header, SizeOf(Header));
    case FInternalFormat of
      ifAlpha, ifLuminance, ifDepth8, ifLuminanceAlpha:
        begin
          Header.ImageType := TGA_UNCOMPRESSED_GRAY;
          if FInternalFormat <> ifLuminanceAlpha
            then Header.Bpp := 8
            else Header.Bpp := 16;
        end;
      ifBGR8, ifBGRA8:
        begin
          Header.ImageType := TGA_UNCOMPRESSED_RGB;
          if FInternalFormat <> ifBGRA8
            then Header.Bpp := 24
            else Header.Bpp := 32;
        end;
    end;

    Header.Width := Width;
    Header.Height := Height;
    Header.ImageDes := $20;

    if FInternalFormat in [ifLuminanceAlpha, ifBGRA8]
      then Header.ImageDes := Header.ImageDes or $08;

    Stream.Write(Header, SizeOf(Header));

    Stream.Write(GetData^, FormatGetImageSize(glBitmapPosition(Width, Height, Depth), FInternalFormat));
  end
    else raise EglBitmapUnsupportedInternalFormat.Create('SaveTga - ' + UNSUPPORTED_INTERNAL_FORMAT);
end;


procedure TglBitmap.SaveJpg(const Stream: TStream);
var
  Bmp: TBitmap;
  Jpg: TJPEGImage;
begin
  if ftJPEG in FormatGetSupportedFiles (InternalFormat) then begin
    Bmp := TBitmap.Create;
    try
      Jpg := TJPEGImage.Create;
      try
        AssignToBitmap(Bmp);

        if FInternalFormat in [ifAlpha, ifLuminance, ifDepth8] then begin
          Jpg.Grayscale := True;
          Jpg.PixelFormat := jf8Bit;
        end;

        Jpg.Assign(Bmp);

        Jpg.SaveToStream(Stream);
      finally
        FreeAndNil(Jpg);
      end;
    finally
      FreeAndNil(Bmp);
    end;
  end
    else raise EglBitmapUnsupportedInternalFormat.Create('SaveJpg - ' + UNSUPPORTED_INTERNAL_FORMAT);
end;


procedure TglBitmap.SaveBmp(const Stream: TStream); 
var
  Bmp: TBitmap;
begin
  if ftBMP in FormatGetSupportedFiles (InternalFormat) then begin
    Bmp := TBitmap.Create;
    try
      AssignToBitmap(Bmp);

      Bmp.SaveToStream(Stream);
    finally
      FreeAndNil(Bmp);
    end;
  end
    else raise EglBitmapUnsupportedInternalFormat.Create('SaveBmp - ' + UNSUPPORTED_INTERNAL_FORMAT);
end;


procedure TglBitmap.Bind(EnableTextureUnit: Boolean);
begin
  if EnableTextureUnit
    then glEnable(Target);

  if ID > 0
    then glBindTexture(Target, ID);
end;


procedure TglBitmap.Unbind(DisableTextureUnit: Boolean);
begin
  if DisableTextureUnit
    then glDisable(Target);

  glBindTexture(Target, 0);
end;


procedure TglBitmap.GetPixel(const Pos: TglBitmapPixelPosition;
  var Pixel: TglBitmapPixelData);
begin
  if Assigned (FGetPixelFunc)
    then FGetPixelFunc(Pos, Pixel);
end;


procedure TglBitmap.SetPixel (const Pos: TglBitmapPixelPosition;
  const Pixel: TglBitmapPixelData);
begin
  if Assigned (FSetPixelFunc)
    then FSetPixelFunc(Pos, Pixel);
end;


procedure TglBitmap.CreateID;
begin
  // Generate Texture
  if ID <> 0
    then glDeleteTextures(1, @ID);

  glGenTextures(1, @ID);

  Bind(False);
end;


procedure TglBitmap.SetupParameters(var BuildWithGlu: Boolean);
begin
  // Set up parameters
  SetWrap(FWrapS, FWrapT, FWrapR);
  SetFilter(FFilterMin, FFilterMag);
  SetAnisotropic(FAnisotropic);
  SetBorderColor(FBorderColor[0], FBorderColor[1], FBorderColor[2], FBorderColor[3]);

  // Mip Maps generation Mode
  BuildWithGlu := False;

  if (MipMap = mmMipmap) then begin
    if (GL_VERSION_1_4 or GL_SGIS_generate_mipmap)
      then glTexParameteri(Target, GL_GENERATE_MIPMAP, GL_TRUE)
      else BuildWithGlu := True;
  end else
  if (MipMap = mmMipmapGlu)
    then BuildWithGlu := True;
end;


procedure TglBitmap.SelectFormat(Format: TglBitmapInternalFormat; var glFormat, glInternalFormat, glType: Cardinal; CanConvertImage: Boolean = True);

  procedure Check12;
  begin
    if not GL_VERSION_1_2 then
      raise EglBitmapUnsupportedInternalFormat.Create('TglBitmap.SelectFormat - You need at least OpenGL 1.2 to support these format.');
  end;

begin
  glType := GL_UNSIGNED_BYTE;

  // selecting Format
  case Format of
    ifAlpha:
      glFormat := GL_ALPHA;
    ifLuminance:
      glFormat := GL_LUMINANCE;
    ifDepth8:
      glFormat := GL_DEPTH_COMPONENT;
    ifLuminanceAlpha:
      glFormat := GL_LUMINANCE_ALPHA;
    ifBGR8:
      begin
        if (GL_VERSION_1_2 or GL_EXT_bgra) then begin
          glFormat := GL_BGR;
        end else begin
          if CanConvertImage
            then ConvertTo(ifRGB8);
          glFormat := GL_RGB;
        end;
      end;
    ifBGRA8:
      begin
        if (GL_VERSION_1_2 or GL_EXT_bgra) then begin
          glFormat := GL_BGRA;
        end else begin
          if CanConvertImage
            then ConvertTo(ifRGBA8);
          glFormat := GL_RGBA;
        end;
      end;
    ifRGB8:
      glFormat := GL_RGB;
    ifRGBA8:
      glFormat := GL_RGBA;
    ifRGBA4:
      begin
        Check12;
        glFormat := GL_BGRA;
        glType := GL_UNSIGNED_SHORT_4_4_4_4_REV;
      end;
    ifRGB5A1:
      begin
        Check12;
        glFormat := GL_BGRA;
        glType := GL_UNSIGNED_SHORT_1_5_5_5_REV;
      end;
    ifRGB10A2:
      begin
        Check12;
        glFormat := GL_BGRA;
        glType := GL_UNSIGNED_INT_2_10_10_10_REV;
      end;
    ifR5G6B5:
      begin
        Check12;
        glFormat := GL_BGR;
        glType := GL_UNSIGNED_SHORT_5_6_5_REV;
      end;
  else
    glFormat := 0;
  end;

  // Selecting InternalFormat
  case Format of
    ifDXT1, ifDXT3, ifDXT5:
      begin
        if GL_EXT_texture_compression_s3tc then begin
          case Format of
            ifDXT1:
              glInternalFormat := GL_COMPRESSED_RGBA_S3TC_DXT1_EXT;
            ifDXT3:
              glInternalFormat := GL_COMPRESSED_RGBA_S3TC_DXT3_EXT;
            ifDXT5:
              glInternalFormat := GL_COMPRESSED_RGBA_S3TC_DXT5_EXT;
          end;
        end else begin
          // Compression isn't supported so convert to RGBA
          if CanConvertImage
            then ConvertTo(ifRGBA8);
          glFormat := GL_RGBA;
          glInternalFormat := GL_RGBA8;
        end;
      end;
    ifAlpha:
      begin
        case Self.Format of
          tf4BitsPerChanel:
            glInternalFormat := GL_ALPHA4;
          tf8BitsPerChanel:
            glInternalFormat := GL_ALPHA8;
          tfCompressed:
            begin
              if (GL_ARB_texture_compression or GL_VERSION_1_3)
                then glInternalFormat := GL_COMPRESSED_ALPHA
                else glInternalFormat := GL_ALPHA;
            end;
        else
          glInternalFormat := GL_ALPHA;
        end;
      end;
    ifLuminance:
      begin
        case Self.Format of
          tf4BitsPerChanel:
            glInternalFormat := GL_LUMINANCE4;
          tf8BitsPerChanel:
            glInternalFormat := GL_LUMINANCE8;
          tfCompressed:
            begin
              if (GL_ARB_texture_compression or GL_VERSION_1_3)
                then glInternalFormat := GL_COMPRESSED_LUMINANCE
                else glInternalFormat := GL_LUMINANCE;
            end;
        else
          glInternalFormat := GL_LUMINANCE;
        end;
      end;
    ifDepth8:
      begin
        glInternalFormat := GL_DEPTH_COMPONENT;
      end;
    ifLuminanceAlpha:
      begin
        case Self.Format of
          tf4BitsPerChanel:
            glInternalFormat := GL_LUMINANCE4_ALPHA4;
          tf8BitsPerChanel:
            glInternalFormat := GL_LUMINANCE8_ALPHA8;
          tfCompressed:
            begin
              if (GL_ARB_texture_compression or GL_VERSION_1_3)
                then glInternalFormat := GL_COMPRESSED_LUMINANCE_ALPHA
                else glInternalFormat := GL_LUMINANCE_ALPHA;
            end;
        else
          glInternalFormat := GL_LUMINANCE_ALPHA;
        end;
      end;
    ifBGR8, ifRGB8:
      begin
        case Self.Format of
          tf4BitsPerChanel:
            glInternalFormat := GL_RGB4;
          tf8BitsPerChanel:
            glInternalFormat := GL_RGB8;
          tfCompressed:
            begin
              if (GL_ARB_texture_compression or GL_VERSION_1_3) then begin
                glInternalFormat := GL_COMPRESSED_RGB
              end else begin
                if (GL_EXT_texture_compression_s3tc)
                  then glInternalFormat := GL_COMPRESSED_RGB_S3TC_DXT1_EXT
                  else glInternalFormat := GL_RGB;
              end;
            end;
        else
          glInternalFormat := GL_RGB;
        end;
      end;
    ifBGRA8, ifRGBA8, ifRGBA4, ifRGB5A1, ifRGB10A2, ifR5G6B5:
      begin
        case Self.Format of
          tf4BitsPerChanel:
            glInternalFormat := GL_RGBA4;
          tf8BitsPerChanel:
            glInternalFormat := GL_RGBA8;
          tfCompressed:
            begin
              if (GL_ARB_texture_compression or GL_VERSION_1_3) then begin
                glInternalFormat := GL_COMPRESSED_RGBA
              end else begin
                if (GL_EXT_texture_compression_s3tc)
                  then glInternalFormat := GL_COMPRESSED_RGBA_S3TC_DXT1_EXT
                  else glInternalFormat := GL_RGBA;
              end;
            end;
        else
          glInternalFormat := GL_RGBA;
        end;
      end;
  end;
end;


function TglBitmap.FlipDepth: Boolean;
begin
  Result := False;
end;


function TglBitmap.FlipHorz: Boolean;
begin
  Result := False;
end;


function TglBitmap.FlipVert: Boolean;
begin
  Result := False;
end;


procedure glBitmapFillWithColorFunc(var FuncRec: TglBitmapFunctionRec);
type
  PglBitmapPixelData = ^TglBitmapPixelData;
begin
  with FuncRec do begin
    Dest.Red   := PglBitmapPixelData(Data)^.Red;
    Dest.Green := PglBitmapPixelData(Data)^.Green;
    Dest.Blue  := PglBitmapPixelData(Data)^.Blue;
    Dest.Alpha := PglBitmapPixelData(Data)^.Alpha;
  end;
end;


procedure TglBitmap.FillWithColor(Red, Green, Blue, Alpha: Byte);
begin
  FillWithColorFloat(Red / $FF, Green / $FF, Blue / $FF, Alpha / $FF);
end;


procedure TglBitmap.FillWithColorFloat(Red, Green, Blue, Alpha: Single);
var
  Data: TglBitmapPixelData;
begin
  FormatPreparePixel(Data, FInternalFormat);

  Data.Red   := Max(0, Min(Data.PixelDesc.RedRange,   Trunc(Data.PixelDesc.RedRange   * Red)));
  Data.Green := Max(0, Min(Data.PixelDesc.GreenRange, Trunc(Data.PixelDesc.GreenRange * Green)));
  Data.Blue  := Max(0, Min(Data.PixelDesc.BlueRange,  Trunc(Data.PixelDesc.BlueRange  * Blue)));
  Data.Alpha := Max(0, Min(Data.PixelDesc.AlphaRange, Trunc(Data.PixelDesc.AlphaRange * Alpha)));

  AddFunc(glBitmapFillWithColorFunc, False, @Data);
end;


procedure TglBitmap.FillWithColorRange(Red, Green, Blue, Alpha: Cardinal);
var
  Data: TglBitmapPixelData;
begin
  FormatPreparePixel(Data, FormatGetWithAlpha(FInternalFormat));

  FillWithColorFloat(
    Red   / Data.PixelDesc.RedRange,
    Green / Data.PixelDesc.GreenRange,
    Blue  / Data.PixelDesc.BlueRange,
    Alpha / Data.PixelDesc.AlphaRange);
end;


procedure TglBitmap.SetAnisotropic(const Value: Integer);
var
  MaxAniso: Integer;
begin
  FAnisotropic := Value;

  if (ID > 0) then begin
    if GL_EXT_texture_filter_anisotropic then begin
      if FAnisotropic > 0 then begin
        Bind(False);

        glGetIntegerv(GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, @MaxAniso);

        if Value > MaxAniso then
          FAnisotropic := MaxAniso;

        glTexParameteri(Target, GL_TEXTURE_MAX_ANISOTROPY_EXT, FAnisotropic);
      end;
    end else begin
      FAnisotropic := 0;
    end;
  end;
end;


procedure TglBitmap.SetInternalFormat(const Value: TglBitmapInternalFormat);
begin
  if FInternalFormat <> Value then
    if FormatGetSize(Value) <> FormatGetSize(FInternalFormat) then
      raise EglBitmapUnsupportedInternalFormat.Create('TglBitmap.SetInternalFormat - ' + UNSUPPORTED_INTERNAL_FORMAT);

  // Update whatever
  SetDataPtr(GetData, Value);
end;


function TglBitmap.AddFunc(Func: TglBitmapFunction; CreateTemp: Boolean;
  Data: Pointer): boolean;
begin
  Result := AddFunc(Self, Func, CreateTemp, FInternalFormat, Data);
end;


function TglBitmap.AddFunc(Source: TglBitmap; Func: TglBitmapFunction;
  CreateTemp: Boolean; Format: TglBitmapInternalFormat; Data: Pointer): boolean;
var
  pDest, NewImage, pSource: pByte;
  TempDepth, TempHeight, TempWidth: Integer;
  MapFunc: TglBitmapMapFunc;
  UnMapFunc: TglBitmapUnMapFunc;

  FuncRec: TglBitmapFunctionRec;
begin
  assert (Assigned (GetData()));

  Result := False;

  if Assigned (Source.GetData()) and FormatIsUncompressed(Format) and
     ((Source.Depth > 0) or (Source.Height > 0) or (Source.Width > 0)) then begin

    // inkompatible Formats so CreateTemp
    if FormatGetSize(Format) <> FormatGetSize(FInternalFormat) then
      CreateTemp := True;

    // Values
    TempDepth := Max(1, Source.Depth);
    TempHeight := Max(1, Source.Height);
    TempWidth := Max(1, Source.Width);

    FuncRec.Sender := Self;
    FuncRec.Data := Data;

    NewImage := nil;

    if CreateTemp then begin
      GetMem(NewImage, Trunc(FormatGetSize(Format) * TempDepth * TempHeight * TempWidth));
      pDest := NewImage;
    end
      else pDest := GetData;

    try
      // Mapping
      MapFunc := FormatGetMapFunc(Format);
      FormatPreparePixel(FuncRec.Dest, Format);
      FormatPreparePixel(FuncRec.Source, Source.InternalFormat);

      FuncRec.Size := Source.Dimension;
      FuncRec.Position.Fields := FuncRec.Size.Fields;

      if FormatIsUncompressed(Source.InternalFormat) then begin
        // Uncompressed Images
        pSource := Source.GetData;
        UnMapFunc := FormatGetUnMapFunc(Source.InternalFormat);

        FuncRec.Position.Z := 0;
        while FuncRec.Position.Z < TempDepth do begin
          FuncRec.Position.Y := 0;
          while FuncRec.Position.Y < TempHeight do begin
            FuncRec.Position.X := 0;
            while FuncRec.Position.X < TempWidth do begin
              // Get Data
              UnMapFunc(pSource, FuncRec.Source);
              // Func
              Func(FuncRec);
              // Set Data
              MapFunc(FuncRec.Dest, pDest);
              Inc(FuncRec.Position.X);
            end;
            Inc(FuncRec.Position.Y);
          end;
          Inc(FuncRec.Position.Z);
        end;
      end else begin
        // Compressed Images
        FuncRec.Position.Z := 0;
        while FuncRec.Position.Z < TempDepth do begin
          FuncRec.Position.Y := 0;
          while FuncRec.Position.Y < TempHeight do begin
            FuncRec.Position.X := 0;
            while FuncRec.Position.X < TempWidth do begin
              // Get Data
              FGetPixelFunc(FuncRec.Position, FuncRec.Source);
              // Func
              Func(FuncRec);
              // Set Data
              MapFunc(FuncRec.Dest, pDest);
              Inc(FuncRec.Position.X);
            end;
            Inc(FuncRec.Position.Y);
          end;
          Inc(FuncRec.Position.Z);
        end;
      end;

      // Updating Image or InternalFormat
      if CreateTemp
        then SetDataPtr(NewImage, Format)
        else

      if Format <> FInternalFormat
        then SetInternalFormat(Format);

      Result := True;
    except
      if CreateTemp
        then FreeMem(NewImage);
    end;
  end;
end;


procedure glBitmapConvertCopyFunc(var FuncRec: TglBitmapFunctionRec);
begin
  with FuncRec do begin
    if Source.PixelDesc.RedRange > 0 then
      Dest.Red   := Source.Red;

    if Source.PixelDesc.GreenRange > 0 then
      Dest.Green := Source.Green;

    if Source.PixelDesc.BlueRange > 0 then
      Dest.Blue  := Source.Blue;

    if Source.PixelDesc.AlphaRange > 0 then
      Dest.Alpha := Source.Alpha;
  end;
end;


procedure glBitmapConvertCalculateRGBAFunc(var FuncRec: TglBitmapFunctionRec);
begin
  with FuncRec do begin
    if Source.PixelDesc.RedRange > 0 then
      Dest.Red   := Round(Dest.PixelDesc.RedRange   * Source.Red   / Source.PixelDesc.RedRange);

    if Source.PixelDesc.GreenRange > 0 then
      Dest.Green := Round(Dest.PixelDesc.GreenRange * Source.Green / Source.PixelDesc.GreenRange);

    if Source.PixelDesc.BlueRange > 0 then
      Dest.Blue  := Round(Dest.PixelDesc.BlueRange  * Source.Blue  / Source.PixelDesc.BlueRange);

    if Source.PixelDesc.AlphaRange > 0 then
      Dest.Alpha := Round(Dest.PixelDesc.AlphaRange * Source.Alpha / Source.PixelDesc.AlphaRange);
  end;
end;


procedure glBitmapConvertShiftRGBAFunc(var FuncRec: TglBitmapFunctionRec);
begin
  with FuncRec do
    with TglBitmapPixelDesc(Data^) do begin
      if Source.PixelDesc.RedRange > 0 then
        Dest.Red   := Source.Red   shr RedShift;

      if Source.PixelDesc.GreenRange > 0 then
        Dest.Green := Source.Green shr GreenShift;

      if Source.PixelDesc.BlueRange > 0 then
        Dest.Blue  := Source.Blue  shr BlueShift;

      if Source.PixelDesc.AlphaRange > 0 then
        Dest.Alpha := Source.Alpha shr AlphaShift;
    end;
end;


function TglBitmap.ConvertTo(NewFormat: TglBitmapInternalFormat): boolean;
var
  Source, Dest: TglBitmapPixelData;
  PixelDesc: TglBitmapPixelDesc;

  function CopyDirect: Boolean;
  begin
    Result :=
      ((Source.PixelDesc.RedRange   = Dest.PixelDesc.RedRange)   or (Source.PixelDesc.RedRange   = 0) or (Dest.PixelDesc.RedRange   = 0)) and
      ((Source.PixelDesc.GreenRange = Dest.PixelDesc.GreenRange) or (Source.PixelDesc.GreenRange = 0) or (Dest.PixelDesc.GreenRange = 0)) and
      ((Source.PixelDesc.BlueRange  = Dest.PixelDesc.BlueRange)  or (Source.PixelDesc.BlueRange  = 0) or (Dest.PixelDesc.BlueRange  = 0)) and
      ((Source.PixelDesc.AlphaRange = Dest.PixelDesc.AlphaRange) or (Source.PixelDesc.AlphaRange = 0) or (Dest.PixelDesc.AlphaRange = 0));
  end;

  function CanShift: Boolean;
  begin
    Result :=
      ((Source.PixelDesc.RedRange   >= Dest.PixelDesc.RedRange  ) or (Source.PixelDesc.RedRange   = 0) or (Dest.PixelDesc.RedRange   = 0)) and
      ((Source.PixelDesc.GreenRange >= Dest.PixelDesc.GreenRange) or (Source.PixelDesc.GreenRange = 0) or (Dest.PixelDesc.GreenRange = 0)) and
      ((Source.PixelDesc.BlueRange  >= Dest.PixelDesc.BlueRange ) or (Source.PixelDesc.BlueRange  = 0) or (Dest.PixelDesc.BlueRange  = 0)) and
      ((Source.PixelDesc.AlphaRange >= Dest.PixelDesc.AlphaRange) or (Source.PixelDesc.AlphaRange = 0) or (Dest.PixelDesc.AlphaRange = 0));
  end;

  function GetShift(Source, Dest: Cardinal) : ShortInt;
  begin
    Result := 0;

    while (Source > Dest) and (Source > 0) do begin
      Inc(Result);
      Source := Source shr 1;
    end;
  end;

begin
  if NewFormat <> FInternalFormat then begin
    FormatPreparePixel(Source, FInternalFormat);
    FormatPreparePixel(Dest, NewFormat);

    if CopyDirect
      then Result := AddFunc(Self, glBitmapConvertCopyFunc, False, NewFormat)
      else
    if CanShift then begin
      PixelDesc.RedShift   := GetShift(Source.PixelDesc.RedRange,   Dest.PixelDesc.RedRange);
      PixelDesc.GreenShift := GetShift(Source.PixelDesc.GreenRange, Dest.PixelDesc.GreenRange);
      PixelDesc.BlueShift  := GetShift(Source.PixelDesc.BlueRange,  Dest.PixelDesc.BlueRange);
      PixelDesc.AlphaShift := GetShift(Source.PixelDesc.AlphaRange, Dest.PixelDesc.AlphaRange);

      Result := AddFunc(Self, glBitmapConvertShiftRGBAFunc, False, NewFormat, @PixelDesc);
    end
      else Result := AddFunc(Self, glBitmapConvertCalculateRGBAFunc, False, NewFormat);
  end
    else Result := True;
end;


function TglBitmap.RemoveAlpha: Boolean;
begin
  Result := False;

  if (Assigned(GetData())) then begin
    if not (FormatIsUncompressed(FInternalFormat) or FormatHasAlpha(FInternalFormat)) then
      raise EglBitmapUnsupportedInternalFormat.Create('TglBitmap.RemoveAlpha - ' + UNSUPPORTED_INTERNAL_FORMAT);

    Result := ConvertTo(FormatGetWithoutAlpha(FInternalFormat));
  end;
end;


function TglBitmap.AddAlphaFromFunc(Func: TglBitmapFunction;
  Data: Pointer): boolean;
begin
  Result := False;

  if (Assigned(GetData())) then begin
    if not FormatIsUncompressed(FInternalFormat) then
      raise EglBitmapUnsupportedInternalFormat.Create('TglBitmap.AddAlphaFromFunc - ' + UNSUPPORTED_INTERNAL_FORMAT);

    Result := AddFunc(Self, Func, False, FormatGetWithAlpha(FInternalFormat), Data);
  end;
end;


function TglBitmap.GetDepth: Integer;
begin
  if ffZ in FDimension.Fields then
    Result := FDimension.Z
  else
    Result := -1;
end;


function TglBitmap.GetHeight: Integer;
begin
  if ffY in FDimension.Fields then
    Result := FDimension.Y
  else
    Result := -1;
end;


function TglBitmap.GetWidth: Integer;
begin
  if ffX in FDimension.Fields then
    Result := FDimension.X
  else
    Result := -1;
end;


procedure glBitmapAlphaFunc(var FuncRec: TglBitmapFunctionRec);
var
  Temp: Single;
begin
  with FuncRec do begin
    Temp :=
      Source.Red   / Source.PixelDesc.RedRange   * 0.3 +
      Source.Green / Source.PixelDesc.GreenRange * 0.59 +
      Source.Blue  / Source.PixelDesc.BlueRange  * 0.11;

    Dest.Alpha := Round (Dest.PixelDesc.AlphaRange * Temp);
  end;
end;


function TglBitmap.AddAlphaFromglBitmap(glBitmap: TglBitmap;
  Func: TglBitmapFunction; Data: Pointer): boolean;
var
  pDest, pDest2, pSource: pByte;
  TempDepth, TempHeight, TempWidth: Integer;
//  Pos, Size: TglBitmapPixelPosition;
//  SourcePix, DestPix: TglBitmapPixelData;
  MapFunc: TglBitmapMapFunc;
  DestUnMapFunc, UnMapFunc: TglBitmapUnMapFunc;

  FuncRec: TglBitmapFunctionRec;
begin
  Result := False;

  if ((glBitmap.Width = Width) and (glBitmap.Height = Height)) then begin
    // Convert to Data with Alpha
    Result := ConvertTo(FormatGetWithAlpha(FormatGetUncompressed(FInternalFormat)));

    if not Assigned(Func)
      then Func := glBitmapAlphaFunc;

    // Values
    TempDepth := Max(1, glBitmap.Depth);
    TempHeight := Max(1, glBitmap.Height);
    TempWidth := Max(1, glBitmap.Width);

    FuncRec.Sender := Self;
    FuncRec.Data := Data;

    pDest := GetData;
    pDest2 := GetData;
    pSource := glBitmap.GetData;

    // Mapping
    FormatPreparePixel(FuncRec.Dest, InternalFormat);
    FormatPreparePixel(FuncRec.Source, glBitmap.InternalFormat);
    MapFunc := FormatGetMapFunc(InternalFormat);
    DestUnMapFunc := FormatGetUnMapFunc(InternalFormat);
    UnMapFunc := FormatGetUnMapFunc(glBitmap.InternalFormat);

    FuncRec.Size := Dimension;
    FuncRec.Position.Fields := FuncRec.Size.Fields;

    FuncRec.Position.Z := 0;
    while FuncRec.Position.Z < TempDepth do begin
      FuncRec.Position.Y := 0;
      while FuncRec.Position.Y < TempHeight do begin
        FuncRec.Position.X := 0;
        while FuncRec.Position.X < TempWidth do begin
          // Get Data
          UnMapFunc(pSource, FuncRec.Source);
          DestUnMapFunc(pDest2, FuncRec.Dest);
          // Func
          Func(FuncRec);
          // Set Data
          MapFunc(FuncRec.Dest, pDest);
          Inc(FuncRec.Position.X);
        end;
        Inc(FuncRec.Position.Y);
      end;
      Inc(FuncRec.Position.Z);
    end;
  end;
end;


procedure TglBitmap.SetBorderColor(Red, Green, Blue, Alpha: Single);
begin
  FBorderColor[0] := Red;
  FBorderColor[1] := Green;
  FBorderColor[2] := Blue;
  FBorderColor[3] := Alpha;

  if ID > 0 then begin
    Bind (False);

    glTexParameterfv(FTarget, GL_TEXTURE_BORDER_COLOR, @fBorderColor[0]);
  end;
end;


{ TglBitmap2D }

procedure TglBitmap2D.SetDataPtr(Ptr: PByte; Format: TglBitmapInternalFormat; Width, Height, Depth: Integer);
var
  Idx, LineWidth: Integer;
begin
  inherited;

  // Format
  if FormatIsUncompressed(Format) then begin
    FUnmapFunc := FormatGetUnMapFunc(Format);
    FGetPixelFunc := GetPixel2DUnmap;

    FMapFunc := FormatGetMapFunc(Format);
    FSetPixelFunc := SetPixel2DUnmap;

    // Assigning Data
    if Assigned(GetData()) then begin
      SetLength(FLines, GetHeight);

      LineWidth := Trunc(GetWidth * FormatGetSize(FInternalFormat));

      for Idx := 0 to GetHeight -1
        do FLines [Idx] := PByte(Integer(GetData) + (Idx * LineWidth));
    end
      else SetLength(FLines, 0);
  end else begin
    SetLength(FLines, 0);

    FSetPixelFunc := nil;

    case Format of
      ifDXT1:
        FGetPixelFunc := GetPixel2DDXT1;
      ifDXT3:
        FGetPixelFunc := GetPixel2DDXT3;
      ifDXT5:
        FGetPixelFunc := GetPixel2DDXT5;
    else
      FGetPixelFunc := nil;
    end;
  end;
end;


function TglBitmap2D.AssignToBitmap(const Bitmap: TBitmap): boolean;
var
  Row, RowSize: Integer;
  pSource, pData: PByte;
begin
  Result := False;

  if Assigned(GetData()) then begin
    if Assigned(Bitmap) then begin
      Bitmap.Width := Width;
      Bitmap.Height := Height;

      // Copy Data
      pSource := GetData();

      case FInternalFormat of
        ifAlpha, ifLuminance, ifDepth8:
          begin
            Bitmap.PixelFormat := pf8bit;
            Bitmap.Palette := CreateGrayPalette;
          end;
        ifR5G6B5:
          Bitmap.PixelFormat := pf16bit;
        ifBGR8:
          Bitmap.PixelFormat := pf24bit;
        ifBGRA8:
          Bitmap.PixelFormat := pf32bit;
      end;

      RowSize := Trunc(Width * FormatGetSize(FInternalFormat));

      for Row := 0 to Height -1 do begin
        pData := Bitmap.Scanline[Row];
        if Assigned(pData) then begin
          Move(pSource^, pData^, RowSize);
          Inc(pSource, RowSize);
        end;
      end;

      Result := True;
    end;
  end;
end;


function TglBitmap2D.AssignAlphaToBitmap(const Bitmap: TBitmap): boolean;
var
  Row, Col, AlphaInterleave: Integer;
  pSource, pDest: PByte;
begin
  Result := False;

  if Assigned(GetData()) then begin
    if FInternalFormat in [ifAlpha, ifLuminanceAlpha, ifBGRA8] then begin
      if Assigned(Bitmap) then begin
        Bitmap.Width := Width;
        Bitmap.Height := Height;
        Bitmap.Palette := CreateGrayPalette;
        Bitmap.PixelFormat := pf8bit;

        case FInternalFormat of
          ifLuminanceAlpha:
            AlphaInterleave := 1;
          ifBGRA8:
            AlphaInterleave := 3;
        else
          AlphaInterleave := 0;
        end;

        // Copy Data
        pSource := GetData();

        for Row := 0 to Height -1 do begin
          pDest := Bitmap.Scanline[Row];
          if Assigned(pDest) then begin
            for Col := 0 to Width -1 do begin
              Inc(pSource, AlphaInterleave);
              pDest^ := pSource^;
              Inc(pDest);
              Inc(pSource, 1);
            end;
          end;
        end;

        Result := True;
      end;
    end;
  end;
end;


function TglBitmap2D.AssignFromBitmap(const Bitmap: TBitmap): boolean;
var
  pSource, pData, pTempData: PByte;
  Row, RowSize, TempWidth, TempHeight: Integer;
  IntFormat: TglBitmapInternalFormat;
begin
  Result := False;

  if (Assigned(Bitmap)) then begin
    // Copy Data
    case Bitmap.PixelFormat of
      pf8bit:
        IntFormat := ifLuminance;
      pf15bit:
        IntFormat := ifRGB5A1;
      pf16bit:
        IntFormat := ifR5G6B5;
      pf24bit:
        IntFormat := ifBGR8;
      pf32bit:
        IntFormat := ifBGRA8;
      else
        raise EglBitmapException.Create('TglBitmap2D.AssignFromBitmap - Invalid Pixelformat.');
    end;

    TempWidth := Bitmap.Width;
    TempHeight := Bitmap.Height;

    RowSize := Trunc(TempWidth * FormatGetSize(IntFormat));

    GetMem(pData, TempHeight * RowSize);
    try
      pTempData := pData;

      for Row := 0 to TempHeight -1 do begin
        pSource := Bitmap.Scanline[Row];

        if (Assigned(pSource)) then begin
          Move(pSource^, pTempData^, RowSize);
          Inc(pTempData, RowSize);
        end;
      end;

      SetDataPtr(pData, IntFormat, TempWidth, TempHeight);

      Result := True;
    except
      FreeMem(pData);
    end;
  end;
end;


procedure TglBitmap2D.GetDXTColorBlock(pData: pByte; relX, relY: Integer; var Pixel: TglBitmapPixelData);
type
  PDXT1Chunk = ^TDXT1Chunk;
  TDXT1Chunk = packed record
    Color1: WORD;
    Color2: WORD;
    Pixels: array [0..3] of byte;
  end;

var
  BasePtr: pDXT1Chunk;
  PixPos: Integer;
  Colors: array [0..3] of TRGBQuad;
begin
  BasePtr := pDXT1Chunk(pData);

  PixPos := BasePtr^.Pixels[relY] shr (relX * 2) and $3;

  if PixPos in [0, 2, 3] then begin
    Colors[0].rgbRed      := BasePtr^.Color1 and $F800 shr 8;
    Colors[0].rgbGreen    := BasePtr^.Color1 and $07E0 shr 3;
    Colors[0].rgbBlue     := BasePtr^.Color1 and $001F shl 3;
    Colors[0].rgbReserved := 255;
  end;

  if PixPos in [1, 2, 3] then begin
    Colors[1].rgbRed      := BasePtr^.Color2 and $F800 shr 8;
    Colors[1].rgbGreen    := BasePtr^.Color2 and $07E0 shr 3;
    Colors[1].rgbBlue     := BasePtr^.Color2 and $001F shl 3;
    Colors[1].rgbReserved := 255;
  end;

  if PixPos = 2 then begin
    Colors[2].rgbRed      := (Colors[0].rgbRed   * 67 + Colors[1].rgbRed   * 33) div 100;
    Colors[2].rgbGreen    := (Colors[0].rgbGreen * 67 + Colors[1].rgbGreen * 33) div 100;
    Colors[2].rgbBlue     := (Colors[0].rgbBlue  * 67 + Colors[1].rgbBlue  * 33) div 100;
    Colors[2].rgbReserved := 255;
  end;

  if PixPos = 3 then begin
    Colors[3].rgbRed      := (Colors[0].rgbRed   * 33 + Colors[1].rgbRed   * 67) div 100;
    Colors[3].rgbGreen    := (Colors[0].rgbGreen * 33 + Colors[1].rgbGreen * 67) div 100;
    Colors[3].rgbBlue     := (Colors[0].rgbBlue  * 33 + Colors[1].rgbBlue  * 67) div 100;
    if BasePtr^.Color1 > BasePtr^.Color2
      then Colors[3].rgbReserved := 255
      else Colors[3].rgbReserved := 0;
  end;

  Pixel.Red   := Colors[PixPos].rgbRed;
  Pixel.Green := Colors[PixPos].rgbGreen;
  Pixel.Blue  := Colors[PixPos].rgbBlue;
  Pixel.Alpha := Colors[PixPos].rgbReserved;
end;


procedure TglBitmap2D.GetPixel2DDXT1(const Pos: TglBitmapPixelPosition; var Pixel: TglBitmapPixelData);
var
  BasePtr: pByte;
  PosX, PosY: Integer;
begin
  inherited;

  if (Pos.Y <= Height) and (Pos.X <= Width) then begin
    PosX := Pos.X div 4;
    PosY := Pos.Y div 4;

    BasePtr := GetData;
    Inc(BasePtr, (PosY * Width div 4 + PosX) * 8);

    GetDXTColorBlock(BasePtr, Pos.X - PosX * 4, Pos.Y - PosY * 4, Pixel);
  end;
end;


procedure TglBitmap2D.GetPixel2DDXT3(const Pos: TglBitmapPixelPosition; var Pixel: TglBitmapPixelData);
type
  PDXT3AlphaChunk = ^TDXT3AlphaChunk;
  TDXT3AlphaChunk = array [0..3] of WORD;

var
  ColorPtr: pByte;
  AlphaPtr: PDXT3AlphaChunk;
  PosX, PosY, relX, relY: Integer;
begin
  inherited;

  if (Pos.Y <= Height) and (Pos.X <= Width) then begin
    PosX := Pos.X div 4;
    PosY := Pos.Y div 4;
    relX := Pos.X - PosX * 4;
    relY := Pos.Y - PosY * 4;

    // get color value
    AlphaPtr := PDXT3AlphaChunk(GetData);
    Inc(AlphaPtr, (PosY * Width div 4 + PosX) * 2);

    ColorPtr := pByte(AlphaPtr);
    Inc(ColorPtr, 8);

    GetDXTColorBlock(ColorPtr, relX, relY, Pixel);

    // extracting alpha
    Pixel.Alpha := AlphaPtr^[relY] shr (4 * relX) and $0F shl 4;
  end;
end;


procedure TglBitmap2D.GetPixel2DDXT5(const Pos: TglBitmapPixelPosition; var Pixel: TglBitmapPixelData);
var
  ColorPtr: pByte;
  AlphaPtr: PInt64;
  PixPos, PosX, PosY, relX, relY: Integer;
  Alpha0, Alpha1: Byte;
begin
  inherited;

  if (Pos.Y <= Height) and (Pos.X <= Width) then begin
    PosX := Pos.X div 4;
    PosY := Pos.Y div 4;
    relX := Pos.X - PosX * 4;
    relY := Pos.Y - PosY * 4;

    // get color value
    AlphaPtr := PInt64(GetData);
    Inc(AlphaPtr, (PosY * Width div 4 + PosX) * 2);

    ColorPtr := pByte(AlphaPtr);
    Inc(ColorPtr, 8);

    GetDXTColorBlock(ColorPtr, relX, relY, Pixel);

    // extracting alpha
    Alpha0 := AlphaPtr^ and $FF;
    Alpha1 := AlphaPtr^ shr 8 and $FF;

    PixPos := AlphaPtr^ shr (16 + (relY * 4 + relX) * 3) and $07;

    // use alpha 0
    if PixPos = 0 then begin
      Pixel.Alpha := Alpha0;
    end else

    // use alpha 1
    if PixPos = 1 then begin
      Pixel.Alpha := Alpha1;
    end else

    // alpha interpolate 7 Steps
    if Alpha0 > Alpha1 then begin
      Pixel.Alpha := ((8 - PixPos) * Alpha0 + (PixPos - 1) * Alpha1) div 7;
    end else

    // alpha is 100% transparent or not transparent
    if PixPos >= 6 then begin
      if PixPos = 6
        then Pixel.Alpha := 0
        else Pixel.Alpha := 255;
    end else

    // alpha interpolate 5 Steps
    begin
      Pixel.Alpha := ((6 - PixPos) * Alpha0 + (PixPos - 1) * Alpha1) div 5;
    end;
  end;
end;


procedure TglBitmap2D.GetPixel2DUnmap(const Pos: TglBitmapPixelPosition; var Pixel: TglBitmapPixelData);
var
  pTemp: pByte;
begin
  pTemp := FLines[Pos.Y];
  Inc(pTemp, Pos.X * fPixelSize);

  FUnmapFunc(pTemp, Pixel);
end;


procedure TglBitmap2D.SetPixel2DUnmap(const Pos: TglBitmapPixelPosition; const Pixel: TglBitmapPixelData);
var
  pTemp: pByte;
begin
  pTemp := FLines[Pos.Y];
  Inc(pTemp, Pos.X * fPixelSize);

  FMapFunc(Pixel, pTemp);
end;


function TglBitmap2D.FlipHorz: Boolean;
var
  Col, Row: Integer;
  pTempDest, pDest, pSource: pByte;
  Size, RowSize, ImgSize: Integer;
begin
  Result := Inherited FlipHorz;

  if Assigned(GetData()) then begin
    pSource := GetData();
    Size := Trunc(FormatGetSize(FInternalFormat));

    RowSize := Width * Size;
    ImgSize := Height * RowSize;

    GetMem(pDest, ImgSize);
    try
      pTempDest := pDest;

      Dec(pTempDest, RowSize + Size);
      for Row := 0 to Height -1 do begin
        Inc(pTempDest, RowSize * 2);
        for Col := 0 to Width -1 do begin
          Move(pSource^, pTempDest^, Size);

          Inc(pSource, Size);
          Dec(pTempDest, Size);
        end;
      end;

      SetDataPtr(pDest, InternalFormat);

      Result := True;
    except
      FreeMem(pDest);
    end;
  end;
end;


function TglBitmap2D.FlipVert: Boolean;
var
  Row: Integer;
  pTempDest, pDest, pSource: pByte;
  Size, RowSize: Integer;
begin
  Result := Inherited FlipVert;

  if Assigned(GetData()) then begin
    pSource := GetData();
    Size := Trunc(FormatGetSize(FInternalFormat));

    RowSize := Width * Size;

    GetMem(pDest, Height * RowSize);
    try
      pTempDest := pDest;

      Inc(pTempDest, Width * (Height -1) * Size);

      for Row := 0 to Height -1 do begin
        Move(pSource^, pTempDest^, RowSize);

        Dec(pTempDest, RowSize);
        Inc(pSource, RowSize);
      end;

      SetDataPtr(pDest, InternalFormat);

      Result := True;
    except
      FreeMem(pDest);
    end;
  end;
end;


procedure TglBitmap2D.UploadData (Target, Format, InternalFormat, Typ: Cardinal; BuildWithGlu: Boolean);
begin
  glPixelStorei(GL_UNPACK_ALIGNMENT, 1);

  // Upload data
  if FInternalFormat in [ifDXT1, ifDXT3, ifDXT5]
    then glCompressedTexImage2D(Target, 0, InternalFormat, Width, Height, 0, Trunc(Width * Height * FormatGetSize(FInternalFormat)), GetData)
    else

  if BuildWithGlu
    then gluBuild2DMipmaps(Target, InternalFormat, Width, Height, Format, Typ, GetData)
    else glTexImage2D(Target, 0, InternalFormat, Width, Height, 0, Format, Typ, GetData);

  // Freigeben
  if (FreeDataAfterGenTexture)
    then SetDataPtr(nil, ifEmpty);
end;


procedure TglBitmap2D.GenTexture(TestTextureSize: Boolean);
var
  BuildWithGlu, PotTex, TexRec: Boolean;
  glFormat, glInternalFormat, glType: Cardinal;
  TexSize: Integer;
begin
  if Assigned(GetData()) then begin
    // Check Texture Size
    if (TestTextureSize) then begin
      glGetIntegerv(GL_MAX_TEXTURE_SIZE, @TexSize);

      if ((Height > TexSize) or (Width > TexSize))
        then raise EglBitmapSizeToLargeException.Create('TglBitmap2D.GenTexture - The size for the texture is to large. It''s may be not conform with the Hardware.');

      PotTex := IsPowerOfTwo (Height) and IsPowerOfTwo (Width);
      TexRec := (GL_ARB_texture_rectangle or GL_EXT_texture_rectangle or GL_NV_texture_rectangle) and
                (Target = GL_TEXTURE_RECTANGLE_ARB);

      if not (PotTex or GL_ARB_texture_non_power_of_two or GL_VERSION_2_0 or TexRec)
        then raise EglBitmapNonPowerOfTwoException.Create('TglBitmap2D.GenTexture - Rendercontex dosn''t support non power of two texture.');
    end;

    CreateId;

    SetupParameters(BuildWithGlu);
    SelectFormat(InternalFormat, glFormat, glInternalFormat, glType);

    UploadData(Target, glFormat, glInternalFormat, glType, BuildWithGlu);

    // Infos sammeln
    glAreTexturesResident(1, @ID, @FIsResident);
  end;
end;


procedure TglBitmap2D.AfterConstruction;
begin
  inherited;

  Target := GL_TEXTURE_2D;
  FGetPixelFunc := nil;
end;


type
  TMaxtrixItem = record
    X, Y: Integer;
    W: Single;
  end;

  PglBitmapToNormalMapRec = ^TglBitmapToNormalMapRec;
  TglBitmapToNormalMapRec = Record
    Scale: Single;
    Heights: array of Single;
    MatrixU : array of TMaxtrixItem;
    MatrixV : array of TMaxtrixItem;
  end;

const
  oneover255 = 1 / 255;

procedure glBitmapToNormalMapPrepareFunc (var FuncRec: TglBitmapFunctionRec);
var
  Val: Single;
begin
  with FuncRec do begin
    Val := Source.Red * 0.3 + Source.Green * 0.59 + Source.Blue *  0.11;
    PglBitmapToNormalMapRec (Data)^.Heights[Position.Y * Size.X + Position.X] := Val * oneover255;
  end;
end;


procedure glBitmapToNormalMapPrepareAlphaFunc (var FuncRec: TglBitmapFunctionRec);
begin
  with FuncRec do
    PglBitmapToNormalMapRec (Data)^.Heights[Position.Y * Size.X + Position.X] := Source.Alpha * oneover255;
end;


procedure glBitmapToNormalMapFunc (var FuncRec: TglBitmapFunctionRec);
type
  TVec = Array[0..2] of Single;
var
  Idx: Integer;
  du, dv: Double;
  Len: Single;
  Vec: TVec;

  function GetHeight(X, Y: Integer): Single;
  begin
    with FuncRec do begin
      X := Max(0, Min(Size.X -1, X));
      Y := Max(0, Min(Size.Y -1, Y));

      Result := PglBitmapToNormalMapRec (Data)^.Heights[Y * Size.X + X];
    end;
  end;

begin
  with FuncRec do begin
    with PglBitmapToNormalMapRec (Data)^ do begin
      du := 0;
      for Idx := Low(MatrixU) to High(MatrixU) do
        du := du + GetHeight(Position.X + MatrixU[Idx].X, Position.Y + MatrixU[Idx].Y) * MatrixU[Idx].W;

      dv := 0;
      for Idx := Low(MatrixU) to High(MatrixU) do
        dv := dv + GetHeight(Position.X + MatrixV[Idx].X, Position.Y + MatrixV[Idx].Y) * MatrixV[Idx].W;

      Vec[0] := -du * Scale;
      Vec[1] := -dv * Scale;
      Vec[2] := 1;
    end;

    // Normalize
    Len := 1 / Sqrt(Sqr(Vec[0]) + Sqr(Vec[1]) + Sqr(Vec[2]));
    if Len <> 0 then begin
      Vec[0] := Vec[0] * Len;
      Vec[1] := Vec[1] * Len;
      Vec[2] := Vec[2] * Len;
    end;

    // Farbe zuweisem
    Dest.Red   := Trunc((Vec[0] + 1) * 127.5);
    Dest.Green := Trunc((Vec[1] + 1) * 127.5);
    Dest.Blue  := Trunc((Vec[2] + 1) * 127.5);
  end;
end;


procedure TglBitmap2D.ToNormalMap(Func: TglBitmapNormalMapFunc; Scale: Single; UseAlpha: Boolean);
var
  Rec: TglBitmapToNormalMapRec;

  procedure SetEntry (var Matrix: array of TMaxtrixItem; Index, X, Y: Integer; W: Single);
  begin
    if (Index >= Low(Matrix)) and (Index <= High(Matrix)) then begin
      Matrix[Index].X := X;
      Matrix[Index].Y := Y;
      Matrix[Index].W := W;
    end;
  end;

begin
  if not FormatIsUncompressed(FInternalFormat) then
    raise EglBitmapUnsupportedInternalFormat.Create('TglBitmap2D.ToNormalMap - ' + UNSUPPORTED_INTERNAL_FORMAT);

  if Scale > 100
    then Rec.Scale := 100
    else
  if Scale < -100
    then Rec.Scale := -100
    else Rec.Scale := Scale;

  SetLength(Rec.Heights, Width * Height);
  try
    case Func of
      nm4Samples:
        begin
          SetLength(Rec.MatrixU, 2);
          SetEntry(Rec.MatrixU, 0, -1,  0, -0.5);
          SetEntry(Rec.MatrixU, 1,  1,  0,  0.5);

          SetLength(Rec.MatrixV, 2);
          SetEntry(Rec.MatrixV, 0,  0,  1,  0.5);
          SetEntry(Rec.MatrixV, 1,  0, -1, -0.5);
        end;
      nmSobel:
        begin
          SetLength(Rec.MatrixU, 6);
          SetEntry(Rec.MatrixU, 0, -1,  1, -1.0);
          SetEntry(Rec.MatrixU, 1, -1,  0, -2.0);
          SetEntry(Rec.MatrixU, 2, -1, -1, -1.0);
          SetEntry(Rec.MatrixU, 3,  1,  1,  1.0);
          SetEntry(Rec.MatrixU, 4,  1,  0,  2.0);
          SetEntry(Rec.MatrixU, 5,  1, -1,  1.0);

          SetLength(Rec.MatrixV, 6);
          SetEntry(Rec.MatrixV, 0, -1,  1,  1.0);
          SetEntry(Rec.MatrixV, 1,  0,  1,  2.0);
          SetEntry(Rec.MatrixV, 2,  1,  1,  1.0);
          SetEntry(Rec.MatrixV, 3, -1, -1, -1.0);
          SetEntry(Rec.MatrixV, 4,  0, -1, -2.0);
          SetEntry(Rec.MatrixV, 5,  1, -1, -1.0);
        end;
      nm3x3:
        begin
          SetLength(Rec.MatrixU, 6);
          SetEntry(Rec.MatrixU, 0, -1,  1, -1/6);
          SetEntry(Rec.MatrixU, 1, -1,  0, -1/6);
          SetEntry(Rec.MatrixU, 2, -1, -1, -1/6);
          SetEntry(Rec.MatrixU, 3,  1,  1,  1/6);
          SetEntry(Rec.MatrixU, 4,  1,  0,  1/6);
          SetEntry(Rec.MatrixU, 5,  1, -1,  1/6);

          SetLength(Rec.MatrixV, 6);
          SetEntry(Rec.MatrixV, 0, -1,  1,  1/6);
          SetEntry(Rec.MatrixV, 1,  0,  1,  1/6);
          SetEntry(Rec.MatrixV, 2,  1,  1,  1/6);
          SetEntry(Rec.MatrixV, 3, -1, -1, -1/6);
          SetEntry(Rec.MatrixV, 4,  0, -1, -1/6);
          SetEntry(Rec.MatrixV, 5,  1, -1, -1/6);
        end;
      nm5x5:
        begin
          SetLength(Rec.MatrixU, 20);
          SetEntry(Rec.MatrixU,  0, -2,  2, -1 / 16);
          SetEntry(Rec.MatrixU,  1, -1,  2, -1 / 10);
          SetEntry(Rec.MatrixU,  2,  1,  2,  1 / 10);
          SetEntry(Rec.MatrixU,  3,  2,  2,  1 / 16);
          SetEntry(Rec.MatrixU,  4, -2,  1, -1 / 10);
          SetEntry(Rec.MatrixU,  5, -1,  1, -1 /  8);
          SetEntry(Rec.MatrixU,  6,  1,  1,  1 /  8);
          SetEntry(Rec.MatrixU,  7,  2,  1,  1 / 10);
          SetEntry(Rec.MatrixU,  8, -2,  0, -1 / 2.8);
          SetEntry(Rec.MatrixU,  9, -1,  0, -0.5);
          SetEntry(Rec.MatrixU, 10,  1,  0,  0.5);
          SetEntry(Rec.MatrixU, 11,  2,  0,  1 / 2.8);
          SetEntry(Rec.MatrixU, 12, -2, -1, -1 / 10);
          SetEntry(Rec.MatrixU, 13, -1, -1, -1 /  8);
          SetEntry(Rec.MatrixU, 14,  1, -1,  1 /  8);
          SetEntry(Rec.MatrixU, 15,  2, -1,  1 / 10);
          SetEntry(Rec.MatrixU, 16, -2, -2, -1 / 16);
          SetEntry(Rec.MatrixU, 17, -1, -2, -1 / 10);
          SetEntry(Rec.MatrixU, 18,  1, -2,  1 / 10);
          SetEntry(Rec.MatrixU, 19,  2, -2,  1 / 16);

          SetLength(Rec.MatrixV, 20);
          SetEntry(Rec.MatrixV,  0, -2,  2,  1 / 16);
          SetEntry(Rec.MatrixV,  1, -1,  2,  1 / 10);
          SetEntry(Rec.MatrixV,  2,  0,  2,  0.25);
          SetEntry(Rec.MatrixV,  3,  1,  2,  1 / 10);
          SetEntry(Rec.MatrixV,  4,  2,  2,  1 / 16);
          SetEntry(Rec.MatrixV,  5, -2,  1,  1 / 10);
          SetEntry(Rec.MatrixV,  6, -1,  1,  1 /  8);
          SetEntry(Rec.MatrixV,  7,  0,  1,  0.5);
          SetEntry(Rec.MatrixV,  8,  1,  1,  1 /  8);
          SetEntry(Rec.MatrixV,  9,  2,  1,  1 / 16);
          SetEntry(Rec.MatrixV, 10, -2, -1, -1 / 16);
          SetEntry(Rec.MatrixV, 11, -1, -1, -1 /  8);
          SetEntry(Rec.MatrixV, 12,  0, -1, -0.5);
          SetEntry(Rec.MatrixV, 13,  1, -1, -1 /  8);
          SetEntry(Rec.MatrixV, 14,  2, -1, -1 / 10);
          SetEntry(Rec.MatrixV, 15, -2, -2, -1 / 16);
          SetEntry(Rec.MatrixV, 16, -1, -2, -1 / 10);
          SetEntry(Rec.MatrixV, 17,  0, -2, -0.25);
          SetEntry(Rec.MatrixV, 18,  1, -2, -1 / 10);
          SetEntry(Rec.MatrixV, 19,  2, -2, -1 / 16);
        end;
    end;

    // Daten Sammeln
    if UseAlpha and FormatHasAlpha(FInternalFormat)
      then AddFunc(glBitmapToNormalMapPrepareAlphaFunc, False, @Rec)
      else AddFunc(glBitmapToNormalMapPrepareFunc, False, @Rec);

    // Neues Bild berechnen
    AddFunc(glBitmapToNormalMapFunc, False, @Rec);
  finally
    SetLength(Rec.Heights, 0);
  end;
end;



procedure TglBitmap2D.GrabScreen(Top, Left, Right, Bottom: Integer; Format: TglBitmapInternalFormat);
var
  Temp: pByte;
  Size: Integer;
  glFormat, glInternalFormat, glType: Cardinal;
begin
  if not FormatIsUncompressed(Format) then
    raise EglBitmapUnsupportedInternalFormat.Create('TglBitmap2D.GrabScreen - ' + UNSUPPORTED_INTERNAL_FORMAT);

  // Only to select Formats
  SelectFormat(Format, glFormat, glInternalFormat, glType, False);

  Size := FormatGetImageSize(glBitmapPosition(Right - Left, Bottom - Top), Format);
  GetMem(Temp, Size);
  try
    glPixelStorei(GL_PACK_ALIGNMENT, 1);
    glReadPixels(Left, Top, Right - Left, Bottom - Top, glFormat, glType, Temp);

    // Set Data
    SetDataPtr(Temp, Format, Right - Left, Bottom - Top);

    // Flip
    FlipVert;
  except
    FreeMem(Temp);
  end;
end;


procedure TglBitmap2D.GetDataFromTexture;
var
  Temp: pByte;
  TempWidth, TempHeight, RedSize, GreenSize, BlueSize, AlphaSize, LumSize: Integer;
  TempType, TempIntFormat: Cardinal;
  IntFormat: TglBitmapInternalFormat;
begin
  Bind;

  // Request Data
  glGetTexLevelParameteriv(Target, 0, GL_TEXTURE_WIDTH, @TempWidth);
  glGetTexLevelParameteriv(Target, 0, GL_TEXTURE_HEIGHT, @TempHeight);
  glGetTexLevelParameteriv(Target, 0, GL_TEXTURE_INTERNAL_FORMAT, @TempIntFormat);

  glGetTexLevelParameteriv(Target, 0, GL_TEXTURE_RED_SIZE, @RedSize);
  glGetTexLevelParameteriv(Target, 0, GL_TEXTURE_GREEN_SIZE, @GreenSize);
  glGetTexLevelParameteriv(Target, 0, GL_TEXTURE_BLUE_SIZE, @BlueSize);
  glGetTexLevelParameteriv(Target, 0, GL_TEXTURE_ALPHA_SIZE, @AlphaSize);
  glGetTexLevelParameteriv(Target, 0, GL_TEXTURE_LUMINANCE_SIZE, @LumSize);

  // Get glBitmapInternalFormat from TempIntFormat
  TempType := GL_UNSIGNED_BYTE;
  case TempIntFormat of
    GL_ALPHA:
      IntFormat := ifAlpha;
    GL_LUMINANCE:
      IntFormat := ifLuminance;
    GL_LUMINANCE_ALPHA:
      IntFormat := ifLuminanceAlpha;
    GL_RGB4:
      begin
        IntFormat := ifR5G6B5;
        TempIntFormat := GL_RGB;
        TempType := GL_UNSIGNED_SHORT_5_6_5;
      end;
    GL_RGB, GL_RGB8:
      IntFormat := ifRGB8;
    GL_RGBA, GL_RGBA4, GL_RGBA8:
      begin
        if (RedSize = 4) and (BlueSize = 4) and (GreenSize = 4) and (AlphaSize = 4) then begin
          IntFormat := ifRGBA4;
          TempIntFormat := GL_BGRA;
          TempType := GL_UNSIGNED_SHORT_4_4_4_4_REV;
        end else
        if (RedSize = 5) and (BlueSize = 5) and (GreenSize = 5) and (AlphaSize = 1) then begin
          IntFormat := ifRGB5A1;
          TempIntFormat := GL_BGRA;
          TempType := GL_UNSIGNED_SHORT_1_5_5_5_REV;
        end else begin
          IntFormat := ifRGBA8;
        end;
      end;
    GL_BGR:
      IntFormat := ifBGR8;
    GL_BGRA:
      IntFormat := ifBGRA8;
    GL_COMPRESSED_RGB_S3TC_DXT1_EXT:
      IntFormat := ifDXT1;
    GL_COMPRESSED_RGBA_S3TC_DXT1_EXT:
      IntFormat := ifDXT1;
    GL_COMPRESSED_RGBA_S3TC_DXT3_EXT:
      IntFormat := ifDXT3;
    GL_COMPRESSED_RGBA_S3TC_DXT5_EXT:
      IntFormat := ifDXT5;
  else
    IntFormat := ifEmpty;
  end;

  // Getting data from OpenGL
  GetMem(Temp, FormatGetImageSize(glBitmapPosition(TempWidth, TempHeight), IntFormat));
  try
    if FormatIsCompressed(IntFormat) and (GL_VERSION_1_3 or GL_ARB_texture_compression) then
      glGetCompressedTexImage(Target, 0, Temp)
    else
      glGetTexImage(Target, 0, TempIntFormat, TempType, Temp);

    SetDataPtr(Temp, IntFormat, TempWidth, TempHeight);
  except
    FreeMem(Temp);
  end;
end;


function TglBitmap2D.GetScanline(Index: Integer): Pointer;
begin
  if (Index >= Low(FLines)) and (Index <= High(FLines))
    then Result := FLines[Index]
    else Result := nil;
end;


{ TglBitmap1D }


procedure TglBitmap1D.SetDataPtr(Ptr: PByte; Format: TglBitmapInternalFormat; Width: Integer = -1; Height: Integer = -1; Depth: Integer = -1);
begin
  inherited;

  if FormatIsUncompressed(Format) then begin
    FUnmapFunc := FormatGetUnMapFunc(Format);
    FGetPixelFunc := GetPixel1DUnmap;
  end;
end;


procedure TglBitmap1D.GetPixel1DUnmap(const Pos: TglBitmapPixelPosition; var Pixel: TglBitmapPixelData);
var
  pTemp: pByte;
begin
  pTemp := GetData;
  Inc(pTemp, Pos.X * fPixelSize);

  FUnmapFunc(pTemp, Pixel);
end;


function TglBitmap1D.AssignToBitmap(const Bitmap: TBitmap): boolean;
var
  RowSize: Integer;
  pSource, pData: PByte;
begin
  Result := False;

  if Assigned(GetData()) then begin
    if Assigned(Bitmap) then begin
      Bitmap.Width := Width;
      Bitmap.Height := 1;

      // Copy Data
      pSource := GetData();

      case FInternalFormat of
        ifAlpha, ifLuminance, ifDepth8:
          begin
            Bitmap.PixelFormat := pf8bit;
            Bitmap.Palette := CreateGrayPalette;
          end;
        ifLuminanceAlpha:
          Bitmap.PixelFormat := pf16bit;
        ifBGR8:
          Bitmap.PixelFormat := pf24bit;
        ifBGRA8:
          Bitmap.PixelFormat := pf32bit;
      end;

      RowSize := Trunc(Width * FormatGetSize(FInternalFormat));

      pData := Bitmap.Scanline[0];
      if Assigned(pData) then
        Move(pSource^, pData^, RowSize);

      Result := True;
    end;
  end;
end;


function TglBitmap1D.AssignAlphaToBitmap(const Bitmap: TBitmap): boolean;
var
  Col, AlphaInterleave: Integer;
  pSource, pDest: PByte;
begin
  Result := False;

  if Assigned(GetData()) then begin
    if FInternalFormat in [ifAlpha, ifLuminanceAlpha, ifBGRA8] then begin
      if Assigned(Bitmap) then begin
        Bitmap.Width := Width;
        Bitmap.Height := 1;
        Bitmap.Palette := CreateGrayPalette;
        Bitmap.PixelFormat := pf8bit;

        case FInternalFormat of
          ifLuminanceAlpha:
            AlphaInterleave := 1;
          ifBGRA8:
            AlphaInterleave := 3;
        else
          AlphaInterleave := 0;
        end;

        // Copy Data
        pSource := GetData();
        pDest := Bitmap.Scanline[0];

        if Assigned(pDest) then begin
          for Col := 0 to Width -1 do begin
            Inc(pSource, AlphaInterleave);
            pDest^ := pSource^;
            Inc(pDest);
            Inc(pSource, 1);
          end;
        end;

        Result := True;
      end;
    end;
  end;
end;


function TglBitmap1D.AssignFromBitmap(const Bitmap: TBitmap): boolean;
var
  pSource, pData: PByte;
  TempWidth, RowSize: Integer;
  IntFormat: TglBitmapInternalFormat;
begin
  Result := False;

  if (Assigned(Bitmap)) then begin
    // Copy Data
    case Bitmap.PixelFormat of
      pf8bit:
        IntFormat := ifLuminance;
      pf16bit:
        IntFormat := ifLuminanceAlpha;
      pf24bit:
        IntFormat := ifBGR8;
      pf32bit:
        IntFormat := ifBGRA8;
      else
        raise EglBitmapException.Create('TglBitmap1D.AssignFromBitmap - Invalid Pixelformat.');
    end;

    TempWidth := Bitmap.Width;
    RowSize := Trunc(TempWidth * FormatGetSize(IntFormat));

    GetMem(pData, RowSize);
    try
      pSource := Bitmap.Scanline[0];

      if (Assigned(pSource)) then
        Move(pSource^, pData^, RowSize);

      SetDataPtr(pData, IntFormat, TempWidth);

      Result := True;
    except
      FreeMem(pData);
    end;
  end;
end;


function TglBitmap1D.FlipHorz: Boolean;
var
  Col: Integer;
  pTempDest, pDest, pSource: pByte;
begin
  Result := Inherited FlipHorz;

  if Assigned(GetData()) and FormatIsUncompressed(FInternalFormat) then begin
    pSource := GetData();

    GetMem(pDest, FLineSize);
    try
      pTempDest := pDest;

      Inc(pTempDest, FLineSize);
      for Col := 0 to Width -1 do begin
        Move(pSource^, pTempDest^, FPixelSize);

        Inc(pSource, FPixelSize);
        Dec(pTempDest, FPixelSize);
      end;

      SetDataPtr(pDest, FInternalFormat);

      Result := True;
    finally
      FreeMem(pDest);
    end;
  end;
end;


procedure TglBitmap1D.UploadData (Target, Format, InternalFormat, Typ: Cardinal; BuildWithGlu: Boolean);
begin
  // Upload data
  if FInternalFormat in [ifDXT1, ifDXT3, ifDXT5]
    then glCompressedTexImage1D(Target, 0, InternalFormat, Width, 0, Trunc(Width * FormatGetSize(FInternalFormat)), GetData)
    else

  // Upload data
  if BuildWithGlu
    then gluBuild1DMipmaps(Target, InternalFormat, Width, Format, Typ, PByte(GetData()))
    else glTexImage1D(Target, 0, InternalFormat, Width, 0, Format, Typ, PByte(GetData()));

  // Freigeben
  if (FreeDataAfterGenTexture)
    then SetDataPtr(nil, ifEmpty);
end;


procedure TglBitmap1D.GenTexture(TestTextureSize: Boolean);
var
  BuildWithGlu, TexRec: Boolean;
  glFormat, glInternalFormat, glType: Cardinal;
  TexSize: Integer;
begin
  if Assigned(GetData()) then begin
    // Check Texture Size
    if (TestTextureSize) then begin
      glGetIntegerv(GL_MAX_TEXTURE_SIZE, @TexSize);

      if (Width > TexSize)
        then raise EglBitmapSizeToLargeException.Create('TglBitmap1D.GenTexture - The size for the texture is to large. It''s may be not conform with the Hardware.');

      TexRec := (GL_ARB_texture_rectangle or GL_EXT_texture_rectangle or GL_NV_texture_rectangle) and
                (Target = GL_TEXTURE_RECTANGLE_ARB);

      if not (IsPowerOfTwo (Width) or GL_ARB_texture_non_power_of_two or GL_VERSION_2_0 or TexRec)
        then raise EglBitmapNonPowerOfTwoException.Create('TglBitmap1D.GenTexture - Rendercontex dosn''t support non power of two texture.');
    end;

    CreateId;

    SetupParameters(BuildWithGlu);
    SelectFormat(InternalFormat, glFormat, glInternalFormat, glType);

    UploadData(Target, glFormat, glInternalFormat, glType, BuildWithGlu);

    // Infos sammeln
    glAreTexturesResident(1, @ID, @FIsResident);
  end;
end;


procedure TglBitmap1D.AfterConstruction;
begin
  inherited;

  Target := GL_TEXTURE_1D;
end;


{ TglBitmapCubeMap }

procedure TglBitmapCubeMap.AfterConstruction;
begin
  inherited;

  if not (GL_VERSION_1_3 or GL_ARB_texture_cube_map or GL_EXT_texture_cube_map) then
    raise EglBitmapException.Create('TglBitmapCubeMap.AfterConstruction - CubeMaps are unsupported.');

  SetWrap; // set all to GL_CLAMP_TO_EDGE
  Target := GL_TEXTURE_CUBE_MAP;
  fGenMode := GL_REFLECTION_MAP;
end;


procedure TglBitmapCubeMap.Bind(EnableTexCoordsGen, EnableTextureUnit: Boolean);
begin
  inherited Bind (EnableTextureUnit);

  if EnableTexCoordsGen then begin
    glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, fGenMode);
    glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, fGenMode);
    glTexGeni(GL_R, GL_TEXTURE_GEN_MODE, fGenMode);
    glEnable(GL_TEXTURE_GEN_S);
    glEnable(GL_TEXTURE_GEN_T);
    glEnable(GL_TEXTURE_GEN_R);
  end;
end;


procedure TglBitmapCubeMap.GenerateCubeMap(CubeTarget: Cardinal; TestTextureSize: Boolean);
var
  glFormat, glInternalFormat, glType: Cardinal;
  BuildWithGlu: Boolean;
  TexSize: Integer;
begin
  // Check Texture Size
  if (TestTextureSize) then begin
    glGetIntegerv(GL_MAX_CUBE_MAP_TEXTURE_SIZE, @TexSize);

    if ((Height > TexSize) or (Width > TexSize))
      then raise EglBitmapSizeToLargeException.Create('TglBitmapCubeMap.GenTexture - The size for the Cubemap is to large. It''s may be not conform with the Hardware.');

    if not ((IsPowerOfTwo (Height) and IsPowerOfTwo (Width)) or GL_VERSION_2_0 or GL_ARB_texture_non_power_of_two)
      then raise EglBitmapNonPowerOfTwoException.Create('TglBitmapCubeMap.GenTexture - Cubemaps dosn''t support non power of two texture.');
  end;

  // create Texture
  if ID = 0 then begin
    CreateID;
    SetupParameters(BuildWithGlu);
  end;

  SelectFormat(InternalFormat, glFormat, glInternalFormat, glType);

  UploadData (CubeTarget, glFormat, glInternalFormat, glType, BuildWithGlu);
end;


procedure TglBitmapCubeMap.GenTexture(TestTextureSize: Boolean);
begin
  Assert(False, 'TglBitmapCubeMap.GenTexture - Don''t call GenTextures directly.');
end;


procedure TglBitmapCubeMap.Unbind(DisableTexCoordsGen,
  DisableTextureUnit: Boolean);
begin
  inherited Unbind (DisableTextureUnit);

  if DisableTexCoordsGen then begin
    glDisable(GL_TEXTURE_GEN_S);
    glDisable(GL_TEXTURE_GEN_T);
    glDisable(GL_TEXTURE_GEN_R);
  end;
end;


{ TglBitmapNormalMap }

type
  TVec = Array[0..2] of Single;
  TglBitmapNormalMapGetVectorFunc = procedure (var Vec: TVec; const Position: TglBitmapPixelPosition; const HalfSize: Integer);

  PglBitmapNormalMapRec = ^TglBitmapNormalMapRec;
  TglBitmapNormalMapRec = record
    HalfSize : Integer;
    Func: TglBitmapNormalMapGetVectorFunc;
  end;


procedure glBitmapNormalMapPosX(var Vec: TVec; const Position: TglBitmapPixelPosition; const HalfSize: Integer);
begin
  Vec[0] := HalfSize;
  Vec[1] := - (Position.Y + 0.5 - HalfSize);
  Vec[2] := - (Position.X + 0.5 - HalfSize);
end;


procedure glBitmapNormalMapNegX(var Vec: TVec; const Position: TglBitmapPixelPosition; const HalfSize: Integer);
begin
  Vec[0] := - HalfSize;
  Vec[1] := - (Position.Y + 0.5 - HalfSize);
  Vec[2] := Position.X + 0.5 - HalfSize;
end;


procedure glBitmapNormalMapPosY(var Vec: TVec; const Position: TglBitmapPixelPosition; const HalfSize: Integer);
begin
  Vec[0] := Position.X + 0.5 - HalfSize;
  Vec[1] := HalfSize;
  Vec[2] := Position.Y + 0.5 - HalfSize;
end;


procedure glBitmapNormalMapNegY(var Vec: TVec; const Position: TglBitmapPixelPosition; const HalfSize: Integer);
begin
  Vec[0] := Position.X + 0.5 - HalfSize;
  Vec[1] := - HalfSize;
  Vec[2] := - (Position.Y + 0.5 - HalfSize);
end;


procedure glBitmapNormalMapPosZ(var Vec: TVec; const Position: TglBitmapPixelPosition; const HalfSize: Integer);
begin
  Vec[0] := Position.X + 0.5 - HalfSize;
  Vec[1] := - (Position.Y + 0.5 - HalfSize);
  Vec[2] := HalfSize;
end;


procedure glBitmapNormalMapNegZ(var Vec: TVec; const Position: TglBitmapPixelPosition; const HalfSize: Integer);
begin
  Vec[0] := - (Position.X + 0.5 - HalfSize);
  Vec[1] := - (Position.Y + 0.5 - HalfSize);
  Vec[2] := - HalfSize;
end;


procedure glBitmapNormalMapFunc(var FuncRec: TglBitmapFunctionRec);
var
  Vec : TVec;
  Len: Single;
begin
  with FuncRec do begin
    with PglBitmapNormalMapRec (Data)^ do begin
      Func(Vec, Position, HalfSize);

      // Normalize
      Len := 1 / Sqrt(Sqr(Vec[0]) + Sqr(Vec[1]) + Sqr(Vec[2]));
      if Len <> 0 then begin
        Vec[0] := Vec[0] * Len;
        Vec[1] := Vec[1] * Len;
        Vec[2] := Vec[2] * Len;
      end;

      // Scale Vector and AddVectro
      Vec[0] := Vec[0] * 0.5 + 0.5;
      Vec[1] := Vec[1] * 0.5 + 0.5;
      Vec[2] := Vec[2] * 0.5 + 0.5;
    end;

    // Set Color
    Dest.Red   := Round(Vec[0] * 255);
    Dest.Green := Round(Vec[1] * 255);
    Dest.Blue  := Round(Vec[2] * 255);
  end;
end;


procedure TglBitmapNormalMap.AfterConstruction;
begin
  inherited;

  fGenMode := GL_NORMAL_MAP;
end;


procedure TglBitmapNormalMap.GenerateNormalMap(Size: Integer;
  TestTextureSize: Boolean);
var
  Rec: TglBitmapNormalMapRec;
  SizeRec: TglBitmapPixelPosition;
begin
  Rec.HalfSize := Size div 2;

  FreeDataAfterGenTexture := False;

  SizeRec.Fields := [ffX, ffY];
  SizeRec.X := Size;
  SizeRec.Y := Size;

  // Positive X
  Rec.Func := glBitmapNormalMapPosX;
  LoadFromFunc (SizeRec, glBitmapNormalMapFunc, ifBGR8, @Rec);
  GenerateCubeMap(GL_TEXTURE_CUBE_MAP_POSITIVE_X, TestTextureSize);

  // Negative X
  Rec.Func := glBitmapNormalMapNegX;
  LoadFromFunc (SizeRec, glBitmapNormalMapFunc, ifBGR8, @Rec);
  GenerateCubeMap(GL_TEXTURE_CUBE_MAP_NEGATIVE_X, TestTextureSize);

  // Positive Y
  Rec.Func := glBitmapNormalMapPosY;
  LoadFromFunc (SizeRec, glBitmapNormalMapFunc, ifBGR8, @Rec);
  GenerateCubeMap(GL_TEXTURE_CUBE_MAP_POSITIVE_Y, TestTextureSize);

  // Negative Y
  Rec.Func := glBitmapNormalMapNegY;
  LoadFromFunc (SizeRec, glBitmapNormalMapFunc, ifBGR8, @Rec);
  GenerateCubeMap(GL_TEXTURE_CUBE_MAP_NEGATIVE_Y, TestTextureSize);

  // Positive Z
  Rec.Func := glBitmapNormalMapPosZ;
  LoadFromFunc (SizeRec, glBitmapNormalMapFunc, ifBGR8, @Rec);
  GenerateCubeMap(GL_TEXTURE_CUBE_MAP_POSITIVE_Z, TestTextureSize);

  // Negative Z
  Rec.Func := glBitmapNormalMapNegZ;
  LoadFromFunc (SizeRec, glBitmapNormalMapFunc, ifBGR8, @Rec);
  GenerateCubeMap(GL_TEXTURE_CUBE_MAP_NEGATIVE_Z, TestTextureSize);
end;


initialization
  glBitmapSetDefaultFormat(tfDefault);
  glBitmapSetDefaultFilter(GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR);
  glBitmapSetDefaultWrap(GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE);

  glBitmapSetDefaultFreeDataAfterGenTexture(True);
  glBitmapSetDefaultDeleteTextureOnFree(True);

finalization

end.
