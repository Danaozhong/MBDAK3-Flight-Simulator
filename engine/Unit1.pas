(*
#######################################################################
#######################################################################
#######################################################################
#######################################################################
####################### (c) 2007 IceFire Editions #####################
#######################################################################
#######################################################################
#######################################################################
#######################################################################

MBDAK3 // main-engine


-= dedicated 2 =-

3dfx...
worlds fastest pc accelerators.

-= coded by =-
[3dfx] IceFire

-= history =-
9.3.07:
started adding a collision system

19.3.07:
-collision functional now
-integrating a font system not based on DirectX (exportation on OpenGL oder Glide?)

27.3.07:
-yaw-pitch-roll is now integrated in collision function
-integrated skybox.

30.3.07:
-trying to implementate a Shadow-Volume-Stencil-Shadow...

2.4.07:
-Shadow implementation still not working.
-Headers changed to JEDI DX8.

4.4.07:
-looks like if the shadows are working now, but they still look very jagged... have to optimize them.
-source code have to be cleaned.

12.4.07:
-shadow implementation now complete (Depth-Fail).. but has some color problems on ATI Radeon X1600 Pro Cards...
-source code a bit optimized.

22.4.07:
-intregrating OBJ-models.
some theoretical stuff about the models:
-Alien aircraft are required
-Alien stations are required (may look a bit like OBJ)
-Lifepower-Rings (Billboarding)
-Munition-Rings
-Plane-Upgrade-rings

Shoots: Array of RECORD
  vXPos:       Single;
  vYPos:       Single;
  vZPos:       Single;
  vXDirection: Single;
  vYDirection: Single;
  vSpeed:      Single;
  vDamage:     Single;
  vSprite:     Integer;
  vByPlayer:   Boolean;
END;

11.7.07:
some stuff done, integrated a particle sys for the plane engine, will now trying to integrate a shoot system.

13.7.07:
-position lamps integrated, improved aircraft controls...

01.8.07:
-"hot phase", menu is almost done with preview window, configuration settings are now used.
-begin with audio support. will search for cool engine sounds soon.
-current line count: ~8000

17.8.07:
-shots integrated
-collision converter optimized
-support for high-poly-col-systems

20.9.07:
-many things done, changed the model system to a dynamic model handler based on ms3d models.
-packed the video functions in external dll files.
-created a dll file for d3d, opengl file in progress.

23.9.07:
-source code cleaned up, the opengl-dll makes great progress (alpha blending running on opengl & gilde).
-got mbdak3 running on a voodoo banshee (D3D, 640x480x16, no fx at all).

4.10.07:
-lighting in now also working in d3d. made some bugfixes, the code often ends in a exception.

8.10.07:
-build a small town. engine running now n1ce and fast.
*)


unit Unit1;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, ShellAPI,
  Dialogs, ExtCtrls, StdCtrls, Math, WinSock, structures, Models3D, MS3DModelHandler;

  //----------------------------------------------------------------------------
  // struct GenericShadowVolume
  // class for shadows ;)
  //----------------------------------------------------------------------------
type
  TShadowVolume = class
  private
    VertexBufferID: Integer;
  public
    procedure BuildFromCollisionMesh(vCOLID: COLMODELS; vLight: Vector3D);
    procedure ResetShadowVolume;
    procedure ShadowRender;
  end;
  
  //----------------------------------------------------------------------------
  // struct TForm1
  // class of the render form
  //----------------------------------------------------------------------------
  TForm1 = class(TForm)
    lbl_Fonttype: TLabel;
    t_RestorePlane: TTimer;
    Shoot_Timer1: TTimer;
    Timer_Light: TTimer;
    Timer_Speed: TTimer;
    GroupBox1: TGroupBox;
    Timer_FPS: TTimer;
    Render_Timer: TTimer;
    GroupBox2: TGroupBox;
    Timer_Audio_Flow: TTimer;
    Timer_Explode: TTimer;

    //form funct
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
    Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
    Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

    //timers
    procedure Timer_Audio_FlowTimer(Sender: TObject);
    procedure Timer_FPSTimer(Sender: TObject);
    procedure Shoot_Timer1Timer(Sender: TObject);
    procedure Timer_LightTimer(Sender: TObject);
    procedure Timer_SpeedTimer(Sender: TObject);
    procedure t_RestorePlaneTimer(Sender: TObject);
    procedure Render_TimerTimer(Sender: TObject);
    procedure Timer_ExplodeTimer(Sender: TObject);

    //gfx funct
    procedure RenderScene;
    procedure ReleaseScene;
    procedure BuildGenericCollisionSystem;
    procedure DrawFireSprite(vPlane: Integer; I: Integer);
    procedure LoadConfig;
    procedure CreateShootByPlayer(vPlane: Integer; vPosition: Vector3D; vBULRef: Integer);
    procedure DrawRedHit;
    function RenderShadow: HResult;
    function DrawShadow: HResult;
    procedure DrawText (vText: String; XPOS: Integer; YPOS: Integer; vScaling: Single);
    procedure LoadMap(FileName: String);

    //math funct
    function Load3DCollision(vFileName: String): Integer;
    function Check3DCollision(ColID1: COLMODELS; P1: Vector3D; ColID2: COLMODELS; P2: Vector3D; Scale1: Single; Scale2: Single; Yaw1: Single; Yaw2: Single; Pitch1: Single; Pitch2: Single; Roll1: Single; Roll2: Single): Boolean;
    function ScaleTriangle(Triangle: Triangle3D; Scale: Single): Triangle3D;
    function AddPointToTriangle(Triangle: Triangle3D; Point: Vector3D): Triangle3D;
    function TriangleYawPitchRoll(Triangle: Triangle3D; Yaw: Single; Pitch: Single; Roll: Single): Triangle3D;
    function Vector3DYawPitchRoll(Vertex: Vector3D; Yaw: Single; Pitch: Single; Roll: Single): Vector3D;
    function SphereCollision(P1: Vector3D; P2: Vector3D; SP1: Single; SP2: Single): Boolean;
    function BerechneKollision(Tri1A: Vector3D; Tri1B: Vector3D; Tri1C: Vector3D; Tri2A: Vector3D; Tri2B: Vector3D; Tri2C: Vector3D): Boolean;
    function LineHitsPlaneFast(LineA: Vector3D; LineB: Vector3D; Plane: Plane3D): Vector3D;
    function PlaneFromPoints(P1: Vector3D; P2: Vector3D; P3: Vector3D): Plane3D;
    function Betrag (vZahl: Single): Single;
    function GetMax(Z1: Single; Z2: Single; Z3: Single): Integer;
    procedure BuildCurrentPlaneColModel(vPlaneID: Integer);
    procedure CreateOctree();
    function TryToArrangeSphereInOctree(SpherePos: Vector3D; Rad: Single): Vector3DInt;

    //help funct
    function FtoDW(f: Single): DWORD;
    function StrToFloatEx(vString: String): Real;
    function StrToColor(vStr: String): TColor;
    function IsFileInUse(vName: String): Boolean;
    function GetIP: String;
    procedure MakePlayerDamage (vDamage: Integer; vPlane: Integer);
    procedure SetPlayerEngineFreq(vPlane: Integer);
    procedure ExplodeAirCraft(vPlane: Integer);
    procedure ResetAirCraft(vPlane: Integer);

    //audio proc
    procedure PlayMusic(SoundBuffer: Integer; Looped: Boolean);
    procedure PlaySound(SoundBuffer: Integer; Looped: Boolean);
    function CreateSoundBufferFromFile(vFile: String): TAudio;
    function CreateMusicBufferFromFile(vFile: String): TAudio;
    procedure FlowMusic(SoundBuffer: Integer; Time: Integer; Down: Boolean; IsMusic: Boolean);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

(*
#######################################################################
#######################################################################
######################### DEFINITIONEN ################################
#######################################################################
#######################################################################
*)

const
  //all renderstates (based on the dx-api, emulated in the openGL-DLL):
  //===================================================================
  RS_ZENABLE                   = 7;    (* D3DZBUFFERTYPE (or TRUE/FALSE for legacy) *)
  RS_FILLMODE                  = 8;    (* D3DFILLMODE *)
  RS_SHADEMODE                 = 9;    (* D3DSHADEMODE *)
  RS_LINEPATTERN               = 10;   (* D3DLINEPATTERN *)
  RS_ZWRITEENABLE              = 14;   (* TRUE to enable z writes *)
  RS_ALPHATESTENABLE           = 15;   (* TRUE to enable alpha tests *)
  RS_LASTPIXEL                 = 16;   (* TRUE for last-pixel on lines *)
  RS_SRCBLEND                  = 19;   (* D3DBLEND *)
  RS_DESTBLEND                 = 20;   (* D3DBLEND *)
  RS_CULLMODE                  = 22;   (* D3DCULL *)
  RS_ZFUNC                     = 23;   (* D3DCMPFUNC *)
  RS_ALPHAREF                  = 24;   (* D3DFIXED *)
  RS_ALPHAFUNC                 = 25;   (* D3DCMPFUNC *)
  RS_DITHERENABLE              = 26;   (* TRUE to enable dithering *)
  RS_ALPHABLENDENABLE          = 27;   (* TRUE to enable alpha blending *)
  RS_FOGENABLE                 = 28;   (* TRUE to enable fog blending *)
  RS_SPECULARENABLE            = 29;   (* TRUE to enable specular *)
  RS_ZVISIBLE                  = 30;   (* TRUE to enable z checking *)
  RS_FOGCOLOR                  = 34;   (* D3DCOLOR *)
  RS_FOGTABLEMODE              = 35;   (* D3DFOGMODE *)
  RS_FOGSTART                  = 36;   (* Fog start (for both vertex and pixel fog) *)
  RS_FOGEND                    = 37;   (* Fog end      *)
  RS_FOGDENSITY                = 38;   (* Fog density  *)
  RS_ZBIAS                     = 47;   (* LONG Z bias *)
  RS_RANGEFOGENABLE            = 48;   (* Enables range-based fog *)
  RS_STENCILENABLE             = 52;   (* BOOL enable/disable stenciling *)
  RS_STENCILFAIL               = 53;   (* D3DSTENCILOP to do if stencil test fails *)
  RS_STENCILZFAIL              = 54;   (* D3DSTENCILOP to do if stencil test passes and Z test fails *)
  RS_STENCILPASS               = 55;   (* D3DSTENCILOP to do if both stencil and Z tests pass *)
  RS_STENCILFUNC               = 56;   (* D3DCMPFUNC fn.  Stencil Test passes if ((ref & mask) stencilfn (stencil & mask)) is true *)
  RS_STENCILREF                = 57;   (* Reference value used in stencil test *)
  RS_STENCILMASK               = 58;   (* Mask value used in stencil test *)
  RS_STENCILWRITEMASK          = 59;   (* Write mask applied to values written to stencil buffer *)
  RS_TEXTUREFACTOR             = 60;   (* D3DCOLOR used for multi-texture blend *)
  RS_LIGHTING                  = 137;
  
  //all texture stages:
  //===================
  TSS_COLOROP        =  1; { D3DTEXTUREOP - per-stage blending controls for color channels }
  TSS_COLORARG1      =  2; { D3DTA_* (texture arg) }
  TSS_COLORARG2      =  3; { D3DTA_* (texture arg) }
  TSS_ALPHAOP        =  4; { D3DTEXTUREOP - per-stage blending controls for alpha channel }
  TSS_ALPHAARG1      =  5; { D3DTA_* (texture arg) }
  TSS_ALPHAARG2      =  6; { D3DTA_* (texture arg) }
  TSS_BUMPENVMAT00   =  7; { float (bump mapping matrix) }
  TSS_BUMPENVMAT01   =  8; { float (bump mapping matrix) }
  TSS_BUMPENVMAT10   =  9; { float (bump mapping matrix) }
  TSS_BUMPENVMAT11   = 10; { float (bump mapping matrix) }
  TSS_TEXCOORDINDEX  = 11; { identifies which set of texture coordinates index this texture }
  TSS_ADDRESSU       = 13; { D3DTEXTUREADDRESS for U coordinate }
  TSS_ADDRESSV       = 14; { D3DTEXTUREADDRESS for V coordinate }
  TSS_BORDERCOLOR    = 15; { D3DCOLOR }
  TSS_MAGFILTER      = 16; { D3DTEXTUREFILTER filter to use for magnification }
  TSS_MINFILTER      = 17; { D3DTEXTUREFILTER filter to use for minification }
  TSS_MIPFILTER      = 18; { D3DTEXTUREFILTER filter to use between mipmaps during minification }
  TSS_MIPMAPLODBIAS  = 19; { float Mipmap LOD bias }
  TSS_MAXMIPLEVEL    = 20; { DWORD 0..(n-1) LOD index of largest map to use (0 == largest) }
  TSS_MAXANISOTROPY  = 21; { DWORD maximum anisotropy }
  TSS_BUMPENVLSCALE  = 22; { float scale for bump map luminance }
  TSS_BUMPENVLOFFSET = 23; { float offset for bump map luminance }
  TSS_TEXTURETRANSFORMFLAGS = 24; { D3DTEXTURETRANSFORMFLAGS controls texture transform }
  TSS_ADDRESSW       = 25; { D3DTEXTUREADDRESS for W coordinate }
  TSS_COLORARG0      = 26; { D3DTA_* third arg for triadic ops }
  TSS_ALPHAARG0      = 27; { D3DTA_* third arg for triadic ops }
  TSS_RESULTARG      = 28;  { D3DTA_* arg for result (CURRENT or TEMP) }

  //texture stages values:
  TADDRESS_WRAP           = 1;
  TADDRESS_MIRROR         = 2;
  TADDRESS_CLAMP          = 3;
  TADDRESS_BORDER         = 4;
  TADDRESS_MIRRORONCE     = 5;

  CMP_NEVER          = 1;
  CMP_LESS           = 2;
  CMP_EQUAL          = 3;
  CMP_LESSEQUAL      = 4;
  CMP_GREATER        = 5;
  CMP_NOTEQUAL       = 6;
  CMP_GREATEREQUAL   = 7;
  CMP_ALWAYS         = 8;

  BLEND_ZERO              = 1;
  BLEND_ONE               = 2;
  BLEND_SRCCOLOR          = 3;
  BLEND_INVSRCCOLOR       = 4;
  BLEND_SRCALPHA          = 5;
  BLEND_INVSRCALPHA       = 6;
  BLEND_DESTALPHA         = 7;
  BLEND_INVDESTALPHA      = 8;
  BLEND_DESTCOLOR         = 9;
  BLEND_INVDESTCOLOR      = 10;
  BLEND_SRCALPHASAT       = 11;
  BLEND_BOTHSRCALPHA      = 12;
  BLEND_BOTHINVSRCALPHA   = 13;

  TSS_TCI_PASSTHRU                           = $00000000;
  TSS_TCI_CAMERASPACENORMAL                  = $00010000;
  TSS_TCI_CAMERASPACEPOSITION                = $00020000;
  TSS_TCI_CAMERASPACEREFLECTIONVECTOR        = $00030000;

  TOP_DISABLE              = 1;      // disables stage
  TOP_SELECTARG1           = 2;      // the default
  TOP_SELECTARG2           = 3;
  TOP_MODULATE             = 4;      // multiply args together
  TOP_MODULATE2X           = 5;      // multiply and  1 bit
  TOP_MODULATE4X           = 6;      // multiply and  2 bits
  TOP_ADD                  =  7;   // add arguments together
  TOP_ADDSIGNED            =  8;   // add with -0.5 bias
  TOP_ADDSIGNED2X          =  9;   // as above but left  1 bit
  TOP_SUBTRACT             = 10;   // Arg1 - Arg2, with no saturation
  TOP_ADDSMOOTH            = 11;   // add 2 args, subtract product
  TOP_BLENDDIFFUSEALPHA    = 12; // iterated alpha
  TOP_BLENDTEXTUREALPHA    = 13; // texture alpha
  TOP_BLENDFACTORALPHA     = 14; // alpha from D3DRENDERSTATE_TEXTUREFACTOR
  // Linear alpha blend with pre-multiplied arg1 input: Arg1 + Arg2*(1-Alpha)
  TOP_BLENDTEXTUREALPHAPM  = 15; // texture alpha
  TOP_BLENDCURRENTALPHA    = 16; // by alpha of current color
  TOP_PREMODULATE            = 17;     // modulate with next texture before use
  TOP_MODULATEALPHA_ADDCOLOR = 18;     // Arg1.RGB + Arg1.A*Arg2.RGB
                                       // COLOROP only
  TOP_MODULATECOLOR_ADDALPHA = 19;     // Arg1.RGB*Arg2.RGB + Arg1.A
                                         // COLOROP only
  TOP_MODULATEINVALPHA_ADDCOLOR = 20;  // (1-Arg1.A)*Arg2.RGB + Arg1.RGB
                                          // COLOROP only
  TOP_MODULATEINVCOLOR_ADDALPHA = 21;  // (1-Arg1.RGB)*Arg2.RGB + Arg1.
                                          // COLOROP only

  // Bump mapping
  TOP_BUMPENVMAP           = 22; // per pixel env map perturbation
  TOP_BUMPENVMAPLUMINANCE  = 23; // with luminance channel
  // This can do either diffuse or specular bump mapping with correct input.
  // Performs the function (Arg1.R*Arg2.R + Arg1.G*Arg2.G + Arg1.B*Arg2.B)
  // where each component has been scaled and offset to make it signed.
  // The result is replicated into all four (including alpha) channels.
  // This is a valid COLOROP only.
  TOP_DOTPRODUCT3          = 24;
  // Triadic ops
  TOP_MULTIPLYADD          = 25; // Arg0 + Arg1*Arg2
  TOP_LERP                 = 26; // (Arg0)*Arg1 + (1-Arg0)*Arg2


  TA_SELECTMASK        = $0000000f;  // mask for arg selector
  TA_DIFFUSE           = $00000000;  // select diffuse color (read only)
  TA_CURRENT           = $00000001;  // select stage destination register (read/write)
  TA_TEXTURE           = $00000002;  // select texture color (read only)
  TA_TFACTOR           = $00000003;  // select RENDERSTATE_TEXTUREFACTOR (read only)
  TA_SPECULAR          = $00000004;  // select specular color (read only)
  TA_TEMP              = $00000005;  // select temporary register color (read/write)
  TA_COMPLEMENT        = $00000010;  // take 1.0 - x (read modifier)
  TA_ALPHAREPLICATE    = $00000020;  // replicate alpha to color components (read modifier)

  //shade constants
  SHADE_FLAT      = 1;
  SHADE_GOURAUD   = 2;
  SHADE_PHONG     = 3;

  //stencil buffer const
  STENCILOP_KEEP     = 1;
  STENCILOP_ZERO     = 2;
  STENCILOP_REPLACE  = 3;
  STENCILOP_INCRSAT  = 4;
  STENCILOP_DECRSAT  = 5;
  STENCILOP_INVERT   = 6;
  STENCILOP_INCR     = 7;
  STENCILOP_DECR     = 8;

  //Cullmode const
  CULL_NONE       = 1;
  CULL_CW         = 2;
  CULL_CCW        = 3;

  //lightmodes
  LT_POINT     = 101;     //point light
  LT_DIRECTION = 102;     //directional light
  Pi180 = Pi/180.0;       //Ein Winkel mit dieser Konstante multipliziert ergibt diesen Winkel im Bogenmaß
  MAX_SHOTS = 100;        //how many shots are allowed in the scene
  MAX_SMOKE_SPRITES = 70; //anzahl der player-düsenflammen
  SMOKE_DIST = 0.02;      //distance between the smoke puffs
  OCTREE_SIZE = 10;        //size of the collision octree

var

  //Systemvariablen:
  //================
  Form1: TForm1;
  ApplicationPath: String; //Pfad der Anwendung
  TexturePath:     String; //path to the texture folder
  ErrorStr:        String; //error helper
  MapName:         String; //file name of the mna
  vMin:            Single;
  Minimized:       Boolean;
  FPSMultiply:     Single;


  //Configuration:
  //==============
  ScreenWidth:     Integer;
  ScreenHeight:    Integer;
  ColorDepth:      Integer;
  ConfigFilePath:  String;
  UseShadows:      Boolean;
  RenderACShadows: Boolean;
  RenderTRShadows: Boolean;
  EnableParticle:  Boolean;
  EnableFog:       Boolean;
  UseAudio:        Boolean;
  UseMusic:        Boolean;
  UseSounds:       Boolean;
  MusicVolume:     Integer;
  SoundVolume:     Integer;
  FarClippingPlane:Integer;
  FogColor:        TColor;
  FogBegin:        Single;
  UseFullScreen:   Boolean;

  //FMOD-Sound-System:
  //==================
  BGMusic:         TAudio;



  //AUDIO-Variablen:
  //================
  //help vars required to flow the audio buffers
  vTimerCurrentVol:Single;
  vTimerFinVol:    Integer;
  vTimerDown:      Boolean;
  vTimerVolStep:   Single;
  vTimerValue:     Integer;
  vTimerMaxValue:  Integer;
  vTimerChannel:   Integer;

  //Spiele-Daten:
  //=============
  Descent:              Boolean;
  Climb:                Boolean;
  GoLeft:               Boolean;
  GoRight:              Boolean;
  GoTop:                Boolean;
  GoDown:               Boolean;
  Shooting:             Boolean;

  //Kameraposition
  CameraPos:           Camera;
  Running:             Boolean;
  Paused:              Boolean;
  ShowExitScreen:      Boolean;
  vAirCraftSpeed:      String;
  vFPS:                Integer;
  vCurrentFPS:         Integer;

  //the Livepower bar
  LifePowerBG:        Integer;
  LifePowerFG:        Integer;

  //font texture
  vFont:              Integer;
  vFontSize:          Integer;

  //color & rect help var
  vColor:             TColor;
  SRECT:              TRECT;

  //default col meshes
  COLMeshes: Array of COLMODELS;
  COLCount: LongInt;

   vColOctree:        Octree3D;

  //light source (useful for shadows)
  LVector:	      Vector3D;

  Sun:                LightMode;
  SunID:              Integer;
  
  //some fx textzres
  ShadowTexture:      Integer;
  FireTexture:        Integer;
  HitTexture:         Integer;

  //skybox
  SkyBox: RECORD
        //Die Skybox wird hier als leeres Grundgerüst erstellt
        vSkyBox3DModel: Integer;
        vDistanceToPlane: Real;
        //Die Texturen der SkyBox:
        SkyTexture1   : Integer;
        SkyTexture2   : Integer;
        SkyTexture3   : Integer;
        SkyTexture4   : Integer;
        SkyTexture5   : Integer;
        SkyTexture6   : Integer;
  end;

  //sprite help vars
  vPosition:          Vector2D;
  Scaling:            Vector2D;
  RCenter:            Vector2D;

  //players
  Players: Array of RECORD
    XPOS:               Real;
    YPOS:               Real;
    ZPOS:               Real;
    Speed:              Real;

    HWinkel:            Real;
    VWinkel:            Real;

    HAcceleration:      Real;
    VAcceleration:      Real;

    vModelScale:        Real;
    v3DModel:           LongInt;
    v3DModelFull:       LongInt;
    v3DModelDamaged:    LongInt;
    v3DModelDestroyed:  LongInt;
    v3DCOLModel:        LongInt;
    vCurrentColModel:   COLMODELS;
    vMax:               Vector3D;
    vMin:               Vector3D;
    vLivePower:         Integer;
    vDeath:             Boolean;
    vExploded:          Boolean;
    HDistanceToCam:     Real;
    VDistanceToCam:     Real;
    vCrashImmune:       Boolean;
    vSmogParticle:      Array of Vector3D;
    vCurrentSmogParticle: Integer;
    vDistToNextDrop:    Single;
    vPoints:            Array of RECORD
      vPosition:        Vector3D;
      vName:            String;
    END;
    vEnginePoints:      Array of Vector3D;
    vRedSplash:         Boolean;
    vPointCount:        Integer;
    vEnginePointCount:  Integer;
    vShoot_1_Source:    Vector3D;
    vShoot_2a_Source:   Vector3D;
    vShoot_2b_Source:   Vector3D;
    vShootMode:         Integer;
    vShooting:          Boolean;
    vLight_Left:        Vector3D;
    vLight_Right:       Vector3D;
    vLightEnabled:      Boolean;
    vLight_Left_ID:     Integer;
    vLight_Right_ID:    Integer;
    Plane_Light_Left:   LongInt;
    Plane_Light_Right:  LongInt;
    vEngineSound:       TAudio;
    vCrashSound:        TAudio;
    vExplosionSound:    TAudio;

    vShadowVolume:      TShadowVolume;
  end;

  PlayerCount: Integer;
  ActivePlane: Integer;

  //----------------------------------------------------------------------------
  // 3D-Modelle
  //----------------------------------------------------------------------------
  vModels3D: Array Of Model3D;
  vModelCount: Integer;
  //----------------------------------------------------------------------------
  // IDE-Bausteine
  //----------------------------------------------------------------------------
  vIDE: Array of RECORD
    vName:    String;
    vModelID: Integer;
    vColID:   Integer;
  end;
  IDECount: Integer;

  //----------------------------------------------------------------------------
  // ODE-Bausteine
  //----------------------------------------------------------------------------
  vODE: Array of RECORD
    vName: String;
    vColID:            Integer;
    v3DFullModel:      Integer;
    v3DDamagedModel:   Integer;
    v3DDestroyedModel: Integer;
    vLifePower:        Integer;
  end;
  vODECount: Integer;

  //----------------------------------------------------------------------------
  // IPL-Objekte
  //----------------------------------------------------------------------------
  vIPL: Array of RECORD
    vIDE:   Integer;        //IDE-ID
    vXPOS:  Real;           //X-Position
    vYPOS:  Real;           //Y-Position
    vZPOS:  Real;           //Z-Position
    vYaw:   Real;           //H. Drehung
    vPitch: Real;           //V. Neigung
    vRoll:  Real;           //H. Rolle
    vVisible:    Boolean;   //if visible
    vModelScale: Real;      //Skalierungsfaktor des Modelles
    vCollision:  Boolean;   //Ob das Objekt ne Kollision hat
    vColExcl:    Boolean;   //if this object should be checked anytime
    vColMDL:     COLMODELS; //Ein 3D-Modell, welches bereits an die entsprechende Position transferiert wurde.
    vShowShadow: Boolean;   //Ob das Objekt einen Schatten wirft.
    vShadowVlms: TShadowVolume; //Das Schattenmodell
  end;
  IPLCount: Integer;

  //----------------------------------------------------------------------------
  // OBJ-Objekte
  //----------------------------------------------------------------------------
  vOBJ: Array of RECORD
    vIDE:            Integer;      //ODE-ID
    vXPOS:           Real;         //X-Position
    vYPOS:           Real;         //Y-Position
    vZPOS:           Real;         //Z-Position
    vYaw:            Real;         //H. Drehung
    vPitch:          Real;         //V. Neigung
    vRoll:           Real;         //H. Rolle
    vModelScale:     Real;         //Skalierungsfaktor des Modelles
    vCollision:      Boolean;      //Ob das Objekt ne Kollision hat
    vColMDL:         COLMODELS;    //Ein 3D-Modell, welches bereits an die entsprechende Position transferiert wurde.
    vShowShadow:     Boolean;      //Ob das Objekt einen Schatten wirft.
    vShadowVlms:     Array of TShadowVolume; //Die einzelnen Schattenmodelle (für jede Lichtquelle)
    vShadowCount:    Integer;
    vLifePower:      Integer;      //Lebenspower
    vDestroyable:    Boolean;      //Ob zerstörbar
    vModelID:        Integer;      //Das 3D-Modell (wird verwendet, um einen dauerhaften Verweis auf ein Mesh zu haben)
  end;
  OBJCount: Integer;

  //----------------------------------------------------------------------------
  // BUL-Objekte (declaration of the shots)
  //----------------------------------------------------------------------------
  vBUL: Array of RECORD
    vName:           String;       //Der Name der BUL
    vIDE:            Integer;      //IDE-ID
    vScale:          Real;         //Skalierungsfaktor
    vDamage:         Real;         //Lebenspower
    vSpeed:          Real;         //Wie schnell
    vShootTime:      Integer;      //Schusszeit in ms
  end;
  BULCount: Integer;

  //----------------------------------------------------------------------------
  // LAS-Objekte (active shots)
  //----------------------------------------------------------------------------
  vLAS: Array of RECORD
    vBULID:          Integer;      //Der Name der BUL
    vXPOS:           Real;         //X-Position
    vYPOS:           Real;         //Y-Position
    vZPOS:           Real;         //Z-Position
    vDirection:      Vector3D;     //Die Richtung
    vYaw:            Real;
    vPitch:          Real;
    vByPlayer:       Boolean;
    vActive:         Boolean;
  end;
  LASCount: Integer;
implementation

{$R *.dfm}

//------------------------------------------------------------------------------
// Load3DModel()
// loads a milkshape 3d from a file
//------------------------------------------------------------------------------
function Load3DModel(vFileName: String): Integer;
  //Diese Funktion läd ein MS3D-File in ein 3D-Modell-Mesh
begin
    If Copy(vFileName, 0, Length(ApplicationPath)) <> ApplicationPath then
    begin
      vFileName := ApplicationPath + vFileName;
    end;
    //sshowmessage (vfilename);
    vModelCount :=vModelCount + 1;
    SetLength (vModels3D, vModelCount + 1);

    vModels3D[vModelCount] := LoadMS3DModel(vFileName, TexturePath);
    Result := vModelCount;
end;

//------------------------------------------------------------------------------
// RenderModel3D()
// renders a Model3D (declared in Models3D.pas) using textures
//------------------------------------------------------------------------------
procedure RenderModel3D(ID: Integer);
begin
    vModels3D[ID].Render();
end;

//------------------------------------------------------------------------------
// RenderModel3DEx()
// renders a Model3D (declared in Models3D.pas) without textures
//------------------------------------------------------------------------------
procedure RenderModel3DEx(ID: Integer);
begin
    vModels3D[ID].RenderEx();
end;

//------------------------------------------------------------------------------
// FormCreate()
// initalisation stuff
//------------------------------------------------------------------------------
procedure TForm1.FormCreate(Sender: TObject);
  var I: Integer;
  var vRenderMode:     RenderMode;
  var vSceneArguments: SceneArguments;
  var RESULT:          Integer;
begin
        //sys vars
        ApplicationPath := ExtractFilePath (Application.ExeName);
        TexturePath := ExtractFilePath(Application.ExeName) + 'data\3d\textures_medium\';
        ConfigFilePath := ApplicationPath + 'config\config.ini';

        LoadConfig;

        //load audio buffer
        If UseAudio = True then
        begin
          a_InitAudio;
        end;
        
        //set up some default settings
        vMin := 0.0001;
        vCurrentFPS := 60;
        Running := True;
        Paused := False;
        ShowExitScreen := False;
        FPSMultiply :=1;

        //Ladepause:
        Application.ProcessMessages;

        //Maus verstecken:
        ShowCursor (False);
        Form1.Left := 0;
        Form1.Top := 0;
        Form1.Width := ScreenWidth + (Form1.Width - Form1.ClientWidth);
        Form1.Height := ScreenHeight + (Form1.Height - Form1.ClientHeight);
        Form1.BorderWidth := 0;

        //yes, baby ^^
        vRenderMode.vWindowed := Not(UseFullScreen);

        If vRenderMode.vWindowed = True then
        begin
          Form1.BorderStyle := bsSingle;
        end
        else
        begin
          Form1.BorderStyle := bsNone;
        end;
        vRenderMode.vUseTnL := True;
        vRenderMode.ScreenWidth := ScreenWidth;
        vRenderMode.ScreenHeight := ScreenHeight;
        vRenderMode.ColorDepth := ColorDepth;
        if UseShadows = True then vRenderMode.StencilBits := 4 else vRenderMode.StencilBits := 0;
        vRenderMode.WindowHWND := Form1.Handle;
        //init render device

        RESULT := r_Init(vRenderMode);
        If RESULT <> 1 then
        begin
          ShowMessage (IntToStr(RESULT) + ': Initialisation of the grafic interface failed.');
          Application.Terminate;
          ExitProcess(PROCESS_TERMINATE);
          Close;
        end;

        //load map
        LoadMap(MapName);

        vSceneArguments.vRad := PI/4;
        vSceneArguments.vFormat := ScreenWidth/ScreenHeight;
        vSceneArguments.vNearClippingPlane := 0.1;
        vSceneArguments.vFarClippingPlane := FarClippingPlane;
        vSceneArguments.vFogEnabled := EnableFog;
        vSceneArguments.vFogBegin := FogBegin;
        vSceneArguments.vFogColor := FogColor;
        //init scene
        r_InitScene(vSceneArguments);

        //load some specific bitmaps
        vFontSize := 16;
        LifePowerBG := r_CreateTextureFromFileEx(PChar(ApplicationPath + '\data\hud\lifestream-bg.bmp'), 128, 128, RGB(0, 255, 0));
        LifePowerFG := r_CreateTextureFromFileEx(PChar(ApplicationPath + '\data\hud\lifestream.bmp'), 127, 127, RGB(0, 255, 0));
        vFont := r_CreateTextureFromFileEx(PChar(ApplicationPath + '\data\hud\font.bmp'), vFontSize * 16, vFontSize * 16, RGB(0, 255, 0));

        //Create sun
        Sun.Diffuse.r := 1.0;
        Sun.Diffuse.g := 0.6;
        Sun.Diffuse.b := 0.5;
        Sun.Ambient.r := 0.2;
        Sun.Ambient.g := 0.2;
        Sun.Ambient.b := 0.2;
        Sun.Specular.R := 1;
        Sun.Specular.G := 1;
        Sun.Specular.B := 1;
        Sun.Range := 1000;
        Sun.LightMode := LT_DIRECTION;
        Sun.Direction.X := -LVector.X;
        Sun.Direction.Z := -LVector.Z;
        Sun.Direction.Y := -LVector.Y;
        SunID := r_CreateLight(Sun);
        r_SetLight(SunID);
        r_EnableLight(SunID, True);
        
        Players[ActivePlane].Speed := 0.1;
        SetLength(vLAS, MAX_SHOTS + 1);
        SetLength(Players[ActivePlane].vSmogParticle, MAX_SMOKE_SPRITES * Players[ActivePlane].vEnginePointCount);
       
        BuildGenericCollisionSystem;
        CreateOctree;
        
        //create shadows
        If UseShadows = True then
        begin
          If RenderACShadows = True then
          begin
            For I := 1 To PlayerCount do
            begin
              Players[I].vShadowVolume := TShadowVolume.Create;
              Players[I].vShadowVolume.VertexBufferID := r_CreateVertexBufferEx();
            end;
          end;
          If RenderTRShadows = True then
          begin
            vIPL[1].vShowShadow := False;
            For I := 2 To IPLCount do
            begin
              If vIPL[I].vShowShadow = True then
              begin
                vIPL[I].vShadowVlms := TShadowVolume.Create;
                vIPL[I].vShadowVlms.VertexBufferID := r_CreateVertexBufferEx();
                vIPL[I].vShadowVlms.ResetShadowVolume;
                vIPL[I].vShadowVlms.BuildFromCollisionMesh(vIPL[I].vColMDL, LVector);
              end;
            end;
          end;
        end;

        Render_Timer.Enabled := True;
end;

//------------------------------------------------------------------------------
// LoadConfig()
// load config
//------------------------------------------------------------------------------
procedure TForm1.LoadConfig;
  var F1: TextFile;
  var Line, Command, Value: String;
  var Position: Integer;
  var InitPath: String;
begin
  //load default config
  UseShadows := False;
  RenderACShadows := False;
  RenderTRShadows := False;
  ScreenWidth := 640;
  ScreenHeight:= 480;
  ColorDepth := 32;
  UseAudio := False;
  UseMusic := False;
  UseSounds := False;
  MusicVolume := 0;
  SoundVolume := 0;
  EnableParticle := False;
  EnableFog := False;
  FarClippingPlane := 25;
  UseFullScreen := True;

  If FileExists(ConfigFilePath) = True then
  begin
      If IsFileInUse (ConfigFilePath) = False then
      begin
          AssignFile(F1, ConfigFilePath);
          Reset(F1);
            while not EOF(F1) do
            begin
                  Readln(F1, Line);
                  If Line <> '' then
                  begin
                          Position := Pos ('=', Line);
                          Command := Copy (Line, 0, Position -1);
                          Value := Copy (Line, Position +1, 999);
                          if Command = 'SCREENWIDTH' then
                          begin
                            ScreenWidth := StrToInt(Value);
                          end
                          else if Command = 'SCREENHEIGHT' then
                          begin
                            ScreenHeight := StrToInt(Value);
                          end
                          else if Command = 'COLOR_DEPTH' then
                          begin
                            ColorDepth := StrToInt(Value);
                          end
                          else if Command = 'ENABLE_AUDIO' then
                          begin
                            If Value='0' then UseAudio := False else UseAudio := True;
                          end
                          else if Command = 'USE_MUSIC' then
                          begin
                            If Value='0' then UseMusic := False else UseMusic := True;
                          end
                          else if Command = 'USE_SOUNDS' then
                          begin
                            If Value='0' then UseSounds := False else UseSounds := True;
                          end
                          else if Command = 'MUSIC_VOLUME' then
                          begin
                            MusicVolume := StrToInt(Value);
                          end
                          else if Command = 'SOUND_VOLUME' then
                          begin
                            SoundVolume := StrToInt(Value);
                          end
                          else if Command ='USE_STENCIL' then
                          begin
                            If Value='0' then UseShadows := False else UseShadows := True;
                          end
                          else if Command ='RENDER_AIRCRAFT_SHADOWS' then
                          begin
                            If Value='0' then RenderACShadows := False else RenderACShadows := True;
                          end
                          else if Command ='RENDER_TERRAIN_SHADOWS' then
                          begin
                            If Value='0' then RenderTRShadows := False else RenderTRShadows := True;
                          end
                          else if Command ='USE_PARTICLE' then
                          begin
                            If Value='0' then EnableParticle := False else EnableParticle := True;
                          end
                          else if Command ='USE_FOG' then
                          begin
                            If Value='0' then EnableFog := False else EnableFog := True;
                          end
                          else if Command = 'TEXTURE_DETAIL' then
                          begin
                            //switch texture quality
                            If StrToInt(Value) = 2 then
                            begin
                              TexturePath := ExtractFilePath(Application.ExeName) + 'data\3d\textures_very_high\';
                            end
                            else if StrToInt(Value) = 1 then
                            begin
                              TexturePath := ExtractFilePath(Application.ExeName) + 'data\3d\textures_high\';
                            end
                            else if Value = '0' then
                            begin
                              TexturePath := ExtractFilePath(Application.ExeName) + 'data\3d\textures_medium\';
                            end
                            else if Value = '-1' then
                            begin
                              TexturePath := ExtractFilePath(Application.ExeName) + 'data\3d\textures_low\';
                            end
                            else if Value = '-2' then
                            begin
                              TexturePath := ExtractFilePath(Application.ExeName) + 'data\3d\textures_very_low\';
                            end;
                          end
                          else if Command = 'FULLSCREEN' then
                          begin
                            If Value='0' then UseFullScreen := False else UseFullScreen := True;
                          end
                          else if Command = 'FAR_CLIPPING_PLANE' then
                          begin
                            FarClippingPlane := StrToInt(Value);
                          end;
                  end;
            end;
           CloseFile(F1);
      end;
  end;

  //load file with map informations (pc specific due special name (set by ip adress)
  InitPath := ApplicationPath + '\mbdak3' + GetIP + '.ini';

  If FileExists(InitPath) = True then
  begin
      If IsFileInUse (InitPath) = False then
      begin
          AssignFile(F1, InitPath);
          Reset(F1);
            while not EOF(F1) do
            begin
                  Readln(F1, Line);
                  If Line <> '' then
                  begin
                          Position := Pos ('=', Line);
                          Command := Copy (Line, 0, Position -1);
                          Value := Copy (Line, Position +1, 999);
                          if Command = 'MAP_NAME' then
                          begin
                            MapName := Value;
                          end;
                  end;
            end;
           CloseFile(F1);
           //delete temporary file
           DeleteFile(InitPath);
      end;
  end
  else
  begin
    //load default map
    MapName := 'maps\level1.map';
  end;
end;

//------------------------------------------------------------------------------
// RenderScene()
// init render proc
//------------------------------------------------------------------------------
procedure TForm1.RenderScene;
var
  //loop vars
  I:                  LongInt;
  K:                  Integer;
  L:                  Integer;
  M:                  Integer;
  //kollision datas
  vDrawPosition:      Vector3D;
  TempVector:         Vector3D;
  TempVector2:        Vector3D;
  ColVector1:         Vector3D;
  ColVector2:         Vector3D;
  vecDirection:       Vector3D;
  SpriteDatas:        SpriteMode;
  vCollisionDetected: Boolean;
  vCurrentColModel:   COLMODELS;
  vPlaneXMin,
  vPlaneYMin,
  vPlaneZMin,
  vPlaneXMax,
  vPlaneYMax,
  vPlaneZMax: Single;
  vTreeXMin,
  vTreeYMin,
  vTreeZMin,
  vTreeXMax,
  vTreeYMax,
  vTreeZMax: Integer;


  //FPS-Speed-automatisation
  BeginTime:          Cardinal;
  TimeDiff:           Cardinal;

  //plane control vars
  H_AngleMax,
  H_AngleAcc,
  H_AngleMult,

  V_AngleMax,
  V_AngleAcc,

  S_SpeedMax,
  S_SpeedNormal,
  S_SpeedMin,
  S_SpeedAcc:         Single;

  //smoke puffs
  SmokePuffCount:     Integer;
  VecDirDivided:      Vector3D;
begin
  While Running = True do
  begin
  //----------------------------------------------------------------------------
  // check d3 related stuff  --------------------------------------------------
  //----------------------------------------------------------------------------
  //check if the form has lost focus
  If Form1.Focused = False then
  begin
    Form1.BorderStyle := bsSingle;
    Minimized := True;
    Timer_Light.Enabled := False;
    Application.ProcessMessages;
    Continue;
  end
  else
  begin
    If Minimized = True then
    begin
      If UseFullScreen = False then Form1.BorderStyle := bsNone;
      Form1.SetFocus;
      Minimized := False;
      Timer_Light.Enabled := True;
      //restore device
      r_RestoreScene;
    end;
  end;


  //FPS-Synchronisieren:
  BeginTime := GetTickCount();

  //----------------------------------------------------------------------------
  //Spiel-Resultate berechnen:  ------------------------------------------------
  //----------------------------------------------------------------------------
  If Paused = False then
  begin
  //set up plane datas
  H_AngleMax := 45;
  H_AngleAcc := 30 * Players[ActivePlane].Speed;
  H_AngleMult := 0.1;

  V_AngleMax := 45;
  V_AngleAcc := 20 * Players[ActivePlane].Speed;

  S_SpeedMax := 0.15;
  S_SpeedNormal := 0.08;
  S_SpeedMin := 0.05;
  S_SpeedAcc := 0.005;

  With Players[ActivePlane] do
  begin
    If vLivePower > 0 then
    begin
      // horizontal acceleralation: --------------------------------------------
      If GoLeft = True then
      begin
        if HAcceleration > -H_AngleMax then
        begin
          HAcceleration := HAcceleration - H_AngleAcc * FPSMultiply;
          If HAcceleration < -H_AngleMax then HAcceleration := -H_AngleMax;
        end;
      end
      else if GoRight = True then
      begin
        if HAcceleration < H_AngleMax then
        begin
          HAcceleration := HAcceleration + H_AngleAcc * FPSMultiply;
          If HAcceleration > H_AngleMax then HAcceleration := H_AngleMax;
        end;
      end
      else
      begin
        If Betrag(HAcceleration) > 0 then
        begin
          If HAcceleration > 0 then
          begin
            HAcceleration := HAcceleration - H_AngleAcc * FPSMultiply;
            if HAcceleration < 0 then HAcceleration := 0;
          end
          else if HAcceleration < 0 then
          begin
            HAcceleration := HAcceleration + H_AngleAcc * FPSMultiply;
            if HAcceleration > 0 then HAcceleration := 0;
          end;
        end;
      end;

      HWinkel := HWinkel + Hacceleration * H_AngleMult * FPSMultiply;

      // speed acceleralation: -------------------------------------------------
      If GoTop = True then
      begin
        If Timer_Speed.Enabled = False then
        begin
          Speed := S_SpeedMax;
          Timer_Speed.Enabled := True;
        end;
      end;
      If GoDown = True then
      begin
        If Timer_Speed.Enabled = False then
        begin
          Speed := S_SpeedMin;
          Timer_Speed.Enabled := True;
        end;
      end;

      If (Timer_Speed.Tag = 1) or (Timer_Speed.Enabled = False) then
      begin
        If Speed > S_SpeedNormal then
        begin
          Speed := Speed  - S_SpeedAcc * FPSMultiply;
          If Speed < S_SpeedNormal then Speed := S_SpeedNormal;
        end;
        If Speed < S_SpeedNormal then
        begin
          Speed := Speed  + S_SpeedAcc * FPSMultiply;
          If Speed > S_SpeedNormal then Speed := S_SpeedNormal;
        end;
      end;
      // vertical acceleralation: ----------------------------------------------
      If Climb = True then
      begin
        if VAcceleration < V_AngleMax then
        begin
          VAcceleration := VAcceleration + V_AngleAcc * FPSMultiply;
          if VAcceleration > V_AngleMax then VAcceleration := V_AngleMax;
        end;
      end
      else if Descent = True then
      begin
        if VAcceleration > -V_AngleMax then
        begin
          VAcceleration := VAcceleration - V_AngleAcc * FPSMultiply;
          if VAcceleration < -V_AngleMax then VAcceleration := -V_AngleMax;
        end;
      end
      else
      begin
        If Betrag(VAcceleration) > 0 then
        begin
          If VAcceleration > 0 then
          begin
            VAcceleration := VAcceleration - V_AngleAcc * FPSMultiply;
            if VAcceleration < 0 then VAcceleration := 0;
          end
          else if VAcceleration < 0 then
          begin
            VAcceleration := VAcceleration + V_AngleAcc * FPSMultiply;
            if VAcceleration > 0 then VAcceleration := 0;
          end;
        end;
      end;
    end
    else
    begin
      // plane destroyed: ------------------------------------------------------
      if vExploded = False then
      begin
        if Speed > 0.05 then
        begin
          Speed := Speed - 0.0005  * FPSMultiply;
        end;
        if Speed < 0.05 then
        begin
          Speed := 0.05;
        end;
        if VAcceleration > -30 then
        begin
          VAcceleration := VAcceleration - 0.4   * FPSMultiply ;
        end;
        HAcceleration := HAcceleration - 1  * FPSMultiply;
      end;
    end;

    // set direction vector ----------------------------------------------------
    vecDirection.X := 0;
    vecDirection.Y := 0;
    vecDirection.Z := -Speed  * FPSMultiply;

    //calculate distance to next flame drop
    vDistToNextDrop := vDistToNextDrop + vecDirection.Z;

    vecDirection := Vector3DYawPitchRoll(vecDirection, HWinkel, 0, VAcceleration);

    //set up the direction vector
    XPOS := XPOS + vecDirection.X;
    YPOS := YPOS + vecDirection.Y;
    ZPOS := ZPOS + vecDirection.Z;

    //set engine freq:
    SetPlayerEngineFreq(1);

    if vEnginePointCount > 0 then
    begin
      For K := 1 To vEnginePointCount do
      begin
        If vDistToNextDrop <= 0 then
        begin
          SmokePuffCount := Trunc(-vDistToNextDrop / SMOKE_DIST) + 1;

          vDistToNextDrop := SMOKE_DIST;
          //Pitch miteinbeiehen:
          TempVector := vEnginePoints[K];
          //we'll have to reverse the pitch and the roll due the rotated model
          TempVector := Vector3DYawPitchRoll(TempVector, HWinkel, HAcceleration, VAcceleration);

          VecDirDivided.X := VecDirection.X / SmokePuffCount;
          VecDirDivided.Y := VecDirection.Y / SmokePuffCount;
          VecDirDivided.Z := VecDirection.Z / SmokePuffCount;

          L := SmokePuffCount;
          While L > 1 do
          begin
            L := L - 1;
            vCurrentSmogParticle := vCurrentSmogParticle + 1;
            If vCurrentSmogParticle > MAX_SMOKE_SPRITES * vEnginePointCount then
            begin
              vCurrentSmogParticle := 1;
            end;
            if vExploded = False then
            begin
              vSmogParticle[vCurrentSmogParticle].X := XPOS + TempVector.X - VecDirDivided.X * L;
              vSmogParticle[vCurrentSmogParticle].Y := YPOS + TempVector.Y - VecDirDivided.Y * L;
              vSmogParticle[vCurrentSmogParticle].Z := ZPOS + TempVector.Z - VecDirDivided.Z * L;
            end
            else
            begin
              vSmogParticle[vCurrentSmogParticle].X := 0;
              vSmogParticle[vCurrentSmogParticle].Y := -2000;
              vSmogParticle[vCurrentSmogParticle].Z := 0;
            end;
          end;
        end;
      end;
    end;

    //create a bullet while shooting
    if (Shooting = True) and (vExploded = False) then
    begin
      if Shoot_Timer1.Enabled = False then
      begin
        Shoot_Timer1.Enabled := True;
        If vShootMode = 1 then
        begin
          //only use single shot
          CreateShootByPlayer(ActivePlane, vShoot_1_Source, 1);
        end
        else if vShootMode = 2 then
        begin
          //create a double shot
          CreateShootByPlayer(ActivePlane, vShoot_2a_Source, 1);
          CreateShootByPlayer(ActivePlane, vShoot_2b_Source, 1);
        end;
      end;
    end;
  end;

  //Kollisionen berechnen:
  ColVector1.X := 0;
  ColVector1.Y := 0;
  ColVector1.Z := 0;

  BuildCurrentPlaneColModel(ActivePlane);
  vCollisionDetected := False;

  vCurrentColModel.SPHCount := 1;
  SetLength(vCurrentColModel.Spheres, 2);
  For I := 1 To vColOctree.GlobalSphereCount do
  begin
    vCurrentColModel.Spheres[1] := vIPL[vColOctree.GlobalSpheres[I].vIPLRef].vColMDL.Spheres[vColOctree.GlobalSpheres[I].vSphereRef];
    If Check3DCollision(vCurrentColModel, ColVector1, Players[ActivePlane].vCurrentColModel, ColVector1, 1, 1, 0, 0, 0, 0, 0, 0) = True then
    begin
      //yes, collision detected!
      if vIPL[vColOctree.GlobalSpheres[I].vIPLRef].vColExcl = True then
      begin
        if Players[ActivePlane].vExploded = False then
        begin
          //set aircraft a bit back and change direction
          with Players[ActivePlane] do
          begin
            //set pos back
            XPOS := XPOS - vecDirection.X;
            YPOS := YPOS - vecDirection.Y;
            ZPOS := ZPOS - vecDirection.Z;
          end;
        end;
      end;
      if (Players[ActivePlane].vCrashImmune = False) and (vIPL[vColOctree.GlobalSpheres[I].vIPLRef].vCollision = True) then
      begin
        //collision detected!
        MakePlayerDamage(15, ActivePlane);
        t_RestorePlane.Enabled := True;
        Players[ActivePlane].vCrashImmune := True;
        Players[ActivePlane].vRedSplash := True;
      end;
      //quit loop
      vCollisionDetected := True;
      Break;
    end;
  end;

  If vCollisionDetected = False then
  begin
    //now, check the octree sphere datas
    //first, we need to get a list of all boxes in witch our plane is in
    vPlaneXMin := Players[ActivePlane].vMin.X + vColOctree.XDiff;
    vPlaneYMin := Players[ActivePlane].vMin.Y + vColOctree.YDiff;
    vPlaneZMin := Players[ActivePlane].vMin.Z + vColOctree.ZDiff;
    vPlaneXMax := Players[ActivePlane].vMax.X + vColOctree.XDiff;
    vPlaneYMax := Players[ActivePlane].vMax.Y + vColOctree.YDiff;
    vPlaneZMax := Players[ActivePlane].vMax.Z + vColOctree.ZDiff;
    vTreeXMin := Trunc(vPlaneXMin / OCTREE_SIZE);
    vTreeXMax := Trunc(vPlaneXMax / OCTREE_SIZE) + 1;
    vTreeYMin := Trunc(vPlaneYMin / OCTREE_SIZE);
    vTreeYMax := Trunc(vPlaneYMax / OCTREE_SIZE) + 1;
    vTreeZMin := Trunc(vPlaneZMin / OCTREE_SIZE);
    vTreeZMax := Trunc(vPlaneZMax / OCTREE_SIZE) + 1;
    For I := vTreeXMin To vTreeXMax do
    begin
      If (I >= 0) and (I <= vColOctree.XCount) then
      begin
      For K := vTreeYMin To vTreeYMax do
      begin
        If (K >= 0) and (K <= vColOctree.YCount) then
        begin
        For L := vTreeZMin To vTreeZMax do
        begin
          If (L >= 0) and (L <= vColOctree.ZCount) then
          begin
          //showmessage (inttostr(l));
          If (vColOctree.Subtrees[I][K][L].SphereCount > 0) and (vCollisionDetected = False) then
          begin
            For M := 1 To vColOctree.Subtrees[I][K][L].SphereCount do
            begin
              vCurrentColModel.Spheres[1] := vIPL[vColOctree.Subtrees[I][K][L].Spheres[M].vIPLRef].vColMDL.Spheres[vColOctree.Subtrees[I][K][L].Spheres[M].vSphereRef];
              If Check3DCollision(vCurrentColModel, ColVector1, Players[ActivePlane].vCurrentColModel, ColVector1, 1, 1, 0, 0, 0, 0, 0, 0) = True then
              begin
                //yes, collision detected!
                if vIPL[vColOctree.Subtrees[I][K][L].Spheres[M].vIPLRef].vColExcl = True then
                begin
                  if Players[ActivePlane].vExploded = False then
                  begin
                    //set aircraft a bit back and change direction
                    with Players[ActivePlane] do
                    begin
                      //set pos back
                      XPOS := XPOS - vecDirection.X;
                      YPOS := YPOS - vecDirection.Y;
                      ZPOS := ZPOS - vecDirection.Z;
                    end;
                  end;
                end;
                if (Players[ActivePlane].vCrashImmune = False) and (vIPL[vColOctree.Subtrees[I][K][L].Spheres[M].vIPLRef].vCollision = True) then
                begin
                  //collision detected!
                  MakePlayerDamage(15, ActivePlane);
                  t_RestorePlane.Enabled := True;
                  Players[ActivePlane].vCrashImmune := True;
                  Players[ActivePlane].vRedSplash := True;
                end;
                //quit loop
                vCollisionDetected := True;
                Break;
              end;
            end;
          end;
        end;
        end;
      end;
      end;
    end;
    end;
  end;
  end;
    //BackBuffer löschen:
    r_ClearBackBuffer(UseShadows);

        //----------------------------------------------------------------------
        //Kameraposition deklarieren: ------------------------------------------
        //----------------------------------------------------------------------

        CameraPos.X := Players[ActivePlane].XPOS + Players[ActivePlane].HDistanceToCam  * sin(Players[ActivePlane].HWinkel * Pi180);
        CameraPos.Y := Players[ActivePlane].YPOS + Players[ActivePlane].VDistanceToCam;
        CameraPos.Z := Players[ActivePlane].ZPOS + Players[ActivePlane].HDistanceToCam  * cos(Players[ActivePlane].HWinkel * Pi180);
        CameraPos.AX := Players[ActivePlane].XPOS - SkyBox.vDistanceToPlane * sin(Players[ActivePlane].HWinkel * Pi180);
        CameraPos.AY := Players[ActivePlane].YPOS;
        CameraPos.AZ := Players[ActivePlane].ZPOS - SkyBox.vDistanceToPlane * cos(Players[ActivePlane].HWinkel * Pi180);
        CameraPos.RX := 0;
        CameraPos.RY := 1;
        CameraPos.RZ := 0;

        r_BeginScene(CameraPos);

        //----------------------------------------------------------------------
        //Lichter aktivieren:  -------------------------------------------------
        //----------------------------------------------------------------------
        if Players[ActivePlane].vLightEnabled = True then
        begin
          //Licht-Eigenschaften setzen.
          TempVector := Vector3DYawPitchRoll(Players[ActivePlane].vLight_Right, Players[ActivePlane].HWinkel, Players[ActivePlane].HAcceleration, Players[ActivePlane].VAcceleration);
          TempVector2.X := Players[ActivePlane].XPOS + TempVector.X;
          TempVector2.Y := Players[ActivePlane].YPOS + TempVector.Y;
          TempVector2.Z := Players[ActivePlane].ZPOS + TempVector.Z;
          r_UpdateLightPosition(Players[ActivePlane].vLight_Right_ID, TempVector2);
          r_SetLight(Players[ActivePlane].vLight_Right_ID);

          TempVector := Vector3DYawPitchRoll(Players[ActivePlane].vLight_Left, Players[ActivePlane].HWinkel, Players[ActivePlane].HAcceleration, Players[ActivePlane].VAcceleration);
          TempVector2.X := Players[ActivePlane].XPOS + TempVector.X;
          TempVector2.Y := Players[ActivePlane].YPOS + TempVector.Y;
          TempVector2.Z := Players[ActivePlane].ZPOS + TempVector.Z;
          r_UpdateLightPosition(Players[ActivePlane].vLight_Left_ID, TempVector2);
          r_SetLight(Players[ActivePlane].vLight_Left_ID);
        end;

        //set up render states
        r_SetRenderState( RS_LIGHTING,       0);

        if EnableFog = True then
        begin
          r_SetRenderState(RS_FOGENABLE,     1 );
        end
        else
        begin
          r_SetRenderState(RS_FOGENABLE,     0 );
        end;

        //----------------------------------------------------------------------
        //SkyBox rendern: ------------------------------------------------------
        //----------------------------------------------------------------------
        //set render & texture stages for skybox
        r_SetRenderState(RS_ZENABLE, 0);
        r_SetTextureStageState (0, TSS_ADDRESSU, TADDRESS_CLAMP);
        r_SetTextureStageState (0, TSS_ADDRESSV, TADDRESS_CLAMP);

        //Hinten
        r_SetTexture(SkyBox.SkyTexture1);
        r_MatrixTranslation(CameraPos.X, CameraPos.Y, CameraPos.Z - SkyBox.vDistanceToPlane);
        r_MatrixRotation (180, 0, 0);
        r_MatrixScaling(SkyBox.vDistanceToPlane, SkyBox.vDistanceToPlane, SkyBox.vDistanceToPlane);
        RenderModel3DEx (SkyBox.vSkyBox3DModel);

        //Links
        r_SetTexture(SkyBox.SkyTexture2);
        r_MatrixTranslation(CameraPos.X + SkyBox.vDistanceToPlane, CameraPos.Y, CameraPos.Z);
        r_MatrixRotation (90, 0, 0);
        r_MatrixScaling(SkyBox.vDistanceToPlane, SkyBox.vDistanceToPlane, SkyBox.vDistanceToPlane);
        RenderModel3DEx (SkyBox.vSkyBox3DModel);

        //Rechts
        r_SetTexture(SkyBox.SkyTexture3);
        r_MatrixTranslation(CameraPos.X - SkyBox.vDistanceToPlane, CameraPos.Y, CameraPos.Z);
        r_MatrixRotation (-90, 0, 0);
        r_MatrixScaling(SkyBox.vDistanceToPlane, SkyBox.vDistanceToPlane, SkyBox.vDistanceToPlane);
        RenderModel3DEx (SkyBox.vSkyBox3DModel);

        //Vorne
        r_SetTexture(SkyBox.SkyTexture4);
        r_MatrixTranslation(CameraPos.X, CameraPos.Y, CameraPos.Z + SkyBox.vDistanceToPlane);
        r_MatrixRotation (0, 0, 0);
        r_MatrixScaling(SkyBox.vDistanceToPlane, SkyBox.vDistanceToPlane, SkyBox.vDistanceToPlane);
        RenderModel3DEx (SkyBox.vSkyBox3DModel);

        //Oben
        r_SetTexture(SkyBox.SkyTexture5);
        r_MatrixTranslation(CameraPos.X, CameraPos.Y + SkyBox.vDistanceToPlane, CameraPos.Z);
        r_MatrixRotation (0, -90, 0);
        r_MatrixScaling(SkyBox.vDistanceToPlane, SkyBox.vDistanceToPlane, SkyBox.vDistanceToPlane);
        RenderModel3DEx (SkyBox.vSkyBox3DModel);

        //Unten
        r_SetTexture(SkyBox.SkyTexture6);
        r_MatrixTranslation(CameraPos.X, CameraPos.Y - SkyBox.vDistanceToPlane, CameraPos.Z);
        r_MatrixRotation (0, 90, 0 );
        r_MatrixScaling(SkyBox.vDistanceToPlane, SkyBox.vDistanceToPlane, SkyBox.vDistanceToPlane);
        RenderModel3DEx (SkyBox.vSkyBox3DModel);
                 
        //restore render states
        r_SetLight(SunID);
        r_EnableLight(SunID, True);
        r_SetRenderState(RS_ZENABLE, 1);
        r_SetRenderState(RS_LIGHTING, 1);
        r_SetTextureStageState (0, TSS_ADDRESSU, TADDRESS_WRAP);
        r_SetTextureStageState (0, TSS_ADDRESSV, TADDRESS_WRAP);
        
        //----------------------------------------------------------------------
        //Alle IPLS rendern: ---------------------------------------------------
        //----------------------------------------------------------------------
        For I := 1 To IPLCount do
        begin
          If vIPL[I].vVisible = True then
          begin
            r_MatrixTranslation(vIPL[I].vXPOS, vIPL[I].vYPOS, vIPL[I].vZPOS);
            r_MatrixRotation(vIPL[I].vYaw, vIPL[I].vPitch, vIPL[I].vRoll);
            r_MatrixScaling(vIPL[I].vModelScale, vIPL[I].vModelScale, vIPL[I].vModelScale);
            RenderModel3D (vIDE[vIPL[I].vIDE].vModelID);
          end;
        end;

        //----------------------------------------------------------------------
        //Player rendern:  -----------------------------------------------------
        //----------------------------------------------------------------------
        //Position des Flugzeugs setzen:
        r_MatrixTranslation(Players[ActivePlane].XPOS, Players[ActivePlane].YPOS, Players[ActivePlane].ZPOS);
        r_MatrixRotation(Players[ActivePlane].HWinkel, Players[ActivePlane].VAcceleration, Players[ActivePlane].HAcceleration);
        r_MatrixScaling(Players[ActivePlane].vModelScale, Players[ActivePlane].vModelScale, Players[ActivePlane].vModelScale);
        RenderModel3D(Players[ActivePlane].v3DModel);

        //----------------------------------------------------------------------
        //Schatten rendern:  ---------------------------------------------------
        //----------------------------------------------------------------------
        r_SetRenderState(RS_ZFUNC, CMP_LESS);
        r_SetRenderState(RS_LIGHTING, 0);

        If UseShadows = True then
        begin
          //Z-BIAS auf einen niedrigeren Wert setzen:

          //Matrix auf die Ausgangsposition setzen:
          r_MatrixTranslation(0, 0, 0);
          If RenderACShadows = True then
          begin
            For I := 1 To PlayerCount do
            begin
              Players[I].vShadowVolume.ResetShadowVolume;
              Players[I].vShadowVolume.BuildFromCollisionMesh(Players[I].vCurrentColModel, LVector);
            end;
          end;
          RenderShadow;
          DrawShadow;
        end;
        r_SetRenderState(RS_ZFUNC, CMP_LESSEQUAL);

        //----------------------------------------------------------------------
        //Schüsse rendern:  ----------------------------------------------------
        //----------------------------------------------------------------------
        for I := 1 to MAX_SHOTS do
        begin
            if vLAS[I].vActive = True then
            begin
              vLAS[I].vXPOS := vLAS[I].vXPOS + vLAS[I].vDirection.X * FPSMultiply;
              vLAS[I].vYPOS := vLAS[I].vYPOS + vLAS[I].vDirection.Y * FPSMultiply;
              vLAS[I].vZPOS := vLAS[I].vZPOS + vLAS[I].vDirection.Z * FPSMultiply;
              r_MatrixTranslation(vLAS[I].vXPOS, vLAS[I].vYPOS, vLAS[I].vZPOS);
              r_MatrixRotation(vLAS[I].vYaw, vLAS[I].vPitch, 0);
              r_MatrixScaling(vBUL[vLAS[I].vBULID].vScale, vBUL[vLAS[I].vBULID].vScale, vBUL[vLAS[I].vBULID].vScale);
              RenderModel3D(VIDE[vBUL[vLAS[I].vBULID].vIDE].vModelID);
            end;
        end;


        //----------------------------------------------------------------------
        //Partikel rendern:  ---------------------------------------------------
        //----------------------------------------------------------------------
        //enabling alpha
        if EnableParticle = True then
        begin
          r_SetRenderState(RS_ALPHABLENDENABLE, 1);
          r_SetRenderState( RS_ALPHATESTENABLE, 1);
          r_SetRenderState( RS_ALPHAREF, 1);
          r_SetRenderState( RS_ALPHAFUNC, CMP_GREATEREQUAL );
          r_SetRenderState( RS_SRCBLEND,  BLEND_SRCALPHA );
          r_SetRenderState( RS_DESTBLEND, BLEND_ONE );
          r_SetTextureStageState(0, TSS_ALPHAOP, TOP_MODULATE);
          r_SetTextureStageState(0, TSS_ALPHAARG1, TA_TEXTURE);
          r_SetTextureStageState(0, TSS_ALPHAARG2, TA_TEXTURE);
          //Player-Smoke--------------------------------------------------------
          For I := 1 To PlayerCount do
          begin
            if (Players[I].vEnginePointCount > 0) and (Players[I].vExploded = False) then
            begin
              For K := 1 To Players[I].vEnginePointCount do
              begin
                //render the fire particels - we have to sort them by their z position in order to get a usable result.
                //for-next-loops do not support reverse countings (i--), so we'll go another way over the while.
                L := Players[I].vCurrentSmogParticle;
                while L > 1 do
                begin
                  L := L -1;
                  DrawFireSprite(I, L);
                end;

                L := MAX_SMOKE_SPRITES + 1;
                while L > Players[I].vCurrentSmogParticle + 1 do
                begin
                  L := L -1;
                  DrawFireSprite(I, L);
                end;
              end;
            end;
          end;
        end;
        //----------------------------------------------------------------------
        //Das HUD rendern: -----------------------------------------------------
        //----------------------------------------------------------------------
        If (Players[ActivePlane].vRedSplash = True) and (Players[ActivePlane].vDeath = False) then
        begin
          //show a red splash in front of the screen
          DrawRedHit;
        end;

        //reRstore alpha states
        r_SetRenderState(RS_ALPHABLENDENABLE, 0);
        r_SetRenderState( RS_ALPHATESTENABLE, 0);
        
        r_SetRenderState( RS_SRCBLEND,  BLEND_ONE );
        r_SetRenderState( RS_DESTBLEND, BLEND_ZERO );
        r_SetTextureStageState(0, TSS_ALPHAARG1, TA_TEXTURE);
        r_SetTextureStageState(0, TSS_ALPHAARG2, TA_DIFFUSE);

        //restore render states
        r_SetRenderState(RS_FOGENABLE, 0 );
        //----------------------------------------------------------------------
        //render SPRITES: ------------------------------------------------------
        //----------------------------------------------------------------------

        r_StartSprites();
          //Daten des Sprites laden:
          SpriteDatas.Bottom := 0;
          SpriteDatas.Right := 0;
          SpriteDatas.Color := $FFFFFFFF;
          SpriteDatas.Rotation := 0;
          SpriteDatas.ScaleX := 1.0;
          SpriteDatas.ScaleY := 1.0;

          SpriteDatas.Left := 10;
          SpriteDatas.Top := 10;
          SpriteDatas.Texture := LifePowerBG;
          SpriteDatas.Width := 128;
          SpriteDatas.Height := 16;
          r_DrawSprite(SpriteDatas);

          SpriteDatas.Left := 11;
          SpriteDatas.Top := 11;
          SpriteDatas.Texture := LifePowerFG;
          SpriteDatas.Width := Trunc(Players[ActivePlane].vLivePower/100 * 126);
          SpriteDatas.Height := 14;
          r_DrawSprite(SpriteDatas);

          vAirCraftSpeed := FormatFloat('0.00', Players[ActivePlane].Speed * 10) + ' Mach';
          DrawText (vAirCraftSpeed, ScreenWidth - 200, 10, 1);
          DrawText (IntToStr(vCurrentFPS) + ' fps', ScreenWidth - 200, 30, 1);
          If vCurrentFPS < 10 then
          begin
            DrawText('Warning: The game is running very slow.', 30, 30, 1);
            DrawText('We recomment to reduce the image quality.', 30, 60, 1);

          end;

          If ShowExitScreen = True then
          begin
            DrawText ('-= Press ESC again to quit =-', Trunc(ScreenWidth / 2) - 100, Trunc(ScreenHeight /2) - 20, 1);
          end
          else if Paused = True then
          begin
            DrawText ('-= Paused =-', Trunc(ScreenWidth / 2) - 40, Trunc(ScreenHeight /2) - 20, 1);
          end
          else if Players[ActivePlane].vExploded = True then
          begin
            DrawText ('-= Your plane has exploded. Press Q to reset. =-', Trunc(ScreenWidth / 2) - 200, Trunc(ScreenHeight /2) - 20, 1);
          end;

        r_EndSprites();

      //Blitten
      r_EndScene();
      vFPS := vFPS + 1;
      TimeDiff := GetTickCount - BeginTime;
      FPSMultiply := 0.06 * TimeDiff;
    Application.ProcessMessages;
  end;

  Close;
end;

//------------------------------------------------------------------------------
// BuildCurrentPlaneColModel()
// builds a col model of the current position/yaw/pitch/scale, etc
//------------------------------------------------------------------------------
procedure TForm1.BuildCurrentPlaneColModel(vPlaneID: Integer);
  var K, L, vColID, TempTrianglesCount: Integer;
  var Position: Vector3D;
  var TempTriangle: Triangle3D;
  var t_MaxX, t_MaxY, t_MaxZ, t_MinX, t_MinY, t_MinZ: Single;
begin
  //pre-arrange player collision model
  SetLength(Players[vPlaneID].vCurrentColModel.Spheres, 0);
  vColID := Players[vPlaneID].v3DCOLModel;
    If COLMeshes[vColID].SPHCount > 0 then
    begin
      Players[vPlaneID].vCurrentColModel.SPHCount := COLMeshes[vColID].SPHCount;
      SetLength(Players[vPlaneID].vCurrentColModel.Spheres, Players[vPlaneID].vCurrentColModel.SPHCount + 1);
      For K := 1 To COLMeshes[vColID].SPHCount do
      begin
        //Nun müssen alle Dreiecke überprüft werden:
        If COLMeshes[vColID].Spheres[K].TRICount > 0 then
        begin
          Position := Vector3DYawPitchRoll(COLMeshes[vColID].Spheres[K].Point, Players[vPlaneID].HWinkel, Players[vPlaneID].HAcceleration, Players[vPlaneID].VAcceleration);
          Position.X := Position.X * Players[vPlaneID].vModelScale;
          Position.Y := Position.Y * Players[vPlaneID].vModelScale;
          Position.Z := Position.Z * Players[vPlaneID].vModelScale;
          Players[vPlaneID].vCurrentColModel.Spheres[K].Point.X := Position.X + Players[vPlaneID].XPOS;
          Players[vPlaneID].vCurrentColModel.Spheres[K].Point.Y := Position.Y + Players[vPlaneID].YPOS;
          Players[vPlaneID].vCurrentColModel.Spheres[K].Point.Z := Position.Z + Players[vPlaneID].ZPOS;
          Players[vPlaneID].vCurrentColModel.Spheres[K].Radius := Betrag(COLMeshes[vColID].Spheres[K].Radius);
          t_MaxX := Players[vPlaneID].vCurrentColModel.Spheres[K].Point.X + Players[vPlaneID].vCurrentColModel.Spheres[K].Radius;
          t_MaxY := Players[vPlaneID].vCurrentColModel.Spheres[K].Point.Y + Players[vPlaneID].vCurrentColModel.Spheres[K].Radius;
          t_MaxZ := Players[vPlaneID].vCurrentColModel.Spheres[K].Point.Z + Players[vPlaneID].vCurrentColModel.Spheres[K].Radius;
          t_MinX := Players[vPlaneID].vCurrentColModel.Spheres[K].Point.X - Players[vPlaneID].vCurrentColModel.Spheres[K].Radius;
          t_MinY := Players[vPlaneID].vCurrentColModel.Spheres[K].Point.Y - Players[vPlaneID].vCurrentColModel.Spheres[K].Radius;
          t_MinZ := Players[vPlaneID].vCurrentColModel.Spheres[K].Point.Z - Players[vPlaneID].vCurrentColModel.Spheres[K].Radius;

          If K = 1 then
          begin
            //reset datas
            Players[vPlaneID].vMax.X := t_MaxX;
            Players[vPlaneID].vMax.Y := t_MaxY;
            Players[vPlaneID].vMax.Z := t_MaxZ;
            Players[vPlaneID].vMin.X := t_MinX;
            Players[vPlaneID].vMin.Y := t_MinY;
            Players[vPlaneID].vMin.Z := t_MinZ;
          end
          else
          begin
            If Players[vPlaneID].vMax.X < t_MaxX then Players[vPlaneID].vMax.X := t_MaxX;
            If Players[vPlaneID].vMax.Y < t_MaxY then Players[vPlaneID].vMax.Y := t_MaxY;
            If Players[vPlaneID].vMax.Z < t_MaxZ then Players[vPlaneID].vMax.Z := t_MaxZ;
            If Players[vPlaneID].vMin.X > t_MinX then Players[vPlaneID].vMin.X := t_MinX;
            If Players[vPlaneID].vMin.Y > t_MinY then Players[vPlaneID].vMin.Y := t_MinY;
            If Players[vPlaneID].vMin.Z > t_MinZ then Players[vPlaneID].vMin.Z := t_MinZ;
          end;
          //Array erstellen:
          TempTrianglesCount := Players[vPlaneID].vCurrentColModel.Spheres[K].TRICount;
          Players[vPlaneID].vCurrentColModel.Spheres[K].TRICount := Players[vPlaneID].vCurrentColModel.Spheres[K].TRICount + COLMeshes[vColID].Spheres[K].TRICount;
          SetLength(Players[vPlaneID].vCurrentColModel.Spheres[K].Triangles, Players[vPlaneID].vCurrentColModel.Spheres[K].TRICount + 1);
          //Nun jedes Dreieck hinzufügen:
          For L := 1 To COLMeshes[vColID].Spheres[K].TRICount do
          begin
            TempTriangle := COLMeshes[vColID].Spheres[K].Triangles[L];
            TempTriangle := TriangleYawPitchRoll(TempTriangle, Players[vPlaneID].HWinkel, Players[vPlaneID].HAcceleration, Players[vPlaneID].VAcceleration);
            TempTriangle := ScaleTriangle(TempTriangle, Players[vPlaneID].vModelScale);
            Position.X := Players[vPlaneID].XPOS;
            Position.Y := Players[vPlaneID].YPOS;
            Position.Z := Players[vPlaneID].ZPOS;
            Players[vPlaneID].vCurrentColModel.Spheres[K].Triangles[TempTrianglesCount + L] := AddPointToTriangle(TempTriangle, Position);
            //Damit wäre alle Dreiecke kopiert...
          end; //Ende Dreiecksliste
        end; //Ende Anzahl-der-Dreiecke-Check

      end; //Ende SphereListe
  end; //Ende Anzahl-der-Sphere-Check
end;

//------------------------------------------------------------------------------
// KeyDown()
// kb controls
//------------------------------------------------------------------------------
procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Running = False then Exit;
  if Key = VK_LEFT then GoLeft := True;
  if Key = VK_RIGHT then GoRight := True;
  if Key = VK_UP then Descent := True;
  if Key = VK_DOWN then Climb := True;
  if Key = VK_CONTROL then GoDown := True;
  If Key = VK_SHIFT then GoTop := True;
  If Key = VK_SPACE then Shooting := True;
  If Key = Ord('Q') then ResetAirCraft(ActivePlane);
  If Key = Ord('A') then MakePlayerDamage(10, ActivePlane);
end;

//------------------------------------------------------------------------------
// KeyUp()
// release vars
//------------------------------------------------------------------------------
procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Running = False then Exit;
  if Key = VK_ESCAPE then
  begin
    If ShowExitScreen = False then
    begin
      ShowExitScreen := True;
      Paused := True;
    end
    else
    begin
      Running := False;
    end;
    Exit;
  end;

  //if not escape, quit from exit screen
  If ShowExitScreen = True then
  begin
    ShowExitScreen := False;
    Paused := False;
  end;

  If Key = Ord('P') then
  begin
    Paused := Not(Paused);
  end;

  //Steuerung
  if Key = VK_LEFT then GoLeft := False;
  if Key = VK_RIGHT then GoRight := False;
  if Key = VK_UP then Descent := False;
  if Key = VK_DOWN then Climb := False;
  if Key = VK_CONTROL then GoDown := False;
  If Key = VK_SHIFT then GoTop := False;
  If Key = VK_SPACE then
  begin
    Shooting := False;
    Shoot_Timer1.Enabled := False;
  end;
end;

//------------------------------------------------------------------------------
// FormClose()
// call cleanup function
//------------------------------------------------------------------------------
procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //Alle Daten wieder aufräumen:
  ReleaseScene;
  Application.ProcessMessages;
  ShellExecute (Application.Handle, 'open',  PChar (ApplicationPath + '\MBDAK 3.exe'), '-nointro', nil, SW_SHOWNORMAL);
  Action := caFree;
  Application.Terminate;
  ExitProcess(PROCESS_TERMINATE);
end;

//------------------------------------------------------------------------------
// ReleaseScene()
// delete everything
//------------------------------------------------------------------------------
procedure TForm1.ReleaseScene;
begin
  //disable timers
  Timer_Light.Enabled := False;
  Render_Timer.Enabled := False;
  Timer_Explode.Enabled := False;
  
  Running := False;
  Application.ProcessMessages;
  //call dll destructor
  r_DeviceCleanUp();
  a_AudioCleanUp();
  
  //show cursor
  ShowCursor (True);
end;

//------------------------------------------------------------------------------
// RenderTimre()
// calls the render function
//------------------------------------------------------------------------------
procedure TForm1.Render_TimerTimer(Sender: TObject);

begin
  //Die Render-Prozedur wird mit einem Timer gestartet.
  //So stellt man sicher, dass das Formular bereits geladen ist.
  //Ist zwar etwas unüblich, funktioniert aber...
  If Render_Timer.Tag = 1 then
  begin
    Timer_Light.Enabled := True;
    Timer_FPS.Enabled := True;
    Render_Timer.Tag := 0;
    Render_Timer.Enabled := False;
    Form1.SetFocus;
    Application.BringToFront;

    //play music
    PlayMusic(BGMusic.Buffer, True);
    PlaySound(Players[ActivePlane].vEngineSound.Buffer, True);
    RenderScene;
  end;
  end;

//------------------------------------------------------------------------------
// LoadMap()
// parses a map file
//------------------------------------------------------------------------------
procedure TForm1.LoadMap(FileName: String);
  //Variablen:
  //----------

  //allgemeine Variablen:
  var F1:               TextFile;
  var Line:             String;
  var Command:          String;
  var Value:            String;
  var Position:         Integer;
  var I:                Integer;
  var Found:            Boolean;
  var TempName:         String;
  var LightConfig:      LightMode;
  //var Farbe:            D3DCOLORVALUE;
begin

    If FileExists(FileName) = False then
    begin
      ShowMessage ('The map cannot be found.');
      Close;
    end;
    While IsFileInUse(FileName) = True do
    begin
      //wait for the map file to be ready
      Application.ProcessMessages;
    end;

    AssignFile(F1, FileName);
    Reset(F1);
      while not EOF(F1) do
      begin
        Readln(F1, Line);
          if Line <> '' then
          begin
          //Jetzt alle Details laden:
          Position := Pos ('=', Line);

            If Position <> 0 then
            begin
                Command := Copy (Line, 1, Position -1);
                Value := Copy (Line, Position +1, 100);
                if Command = 'PLAYERID' then
                begin
                  //Neue Player-ID erstellen (benötigt für Multiplayer ;D)
                  PlayerCount := StrToInt(Value);
                  SetLength(Players, PlayerCount + 1);
                end
                else if Command = 'PLAYERMODEL' then
                begin
                  //Vereinfachte Funktion zum Laden. Die Funktion gibt die 3D-Model-ID zurück.
                  Players[PlayerCount].v3DModelFull := Load3DModel(Value);
                end
                else if Command = 'PLAYERMODELDAMAGED' then
                begin
                  //Vereinfachte Funktion zum Laden. Die Funktion gibt die 3D-Model-ID zurück.
                  Players[PlayerCount].v3DModelDamaged := Load3DModel(PChar(Value));
                end
                else if Command = 'PLAYERMODELDESTROYED' then
                begin
                  //Vereinfachte Funktion zum Laden. Die Funktion gibt die 3D-Model-ID zurück.
                  Players[PlayerCount].v3DModelDestroyed := Load3DModel(PChar(Value));
                end
                else if Command = 'PLAYERCOLLISIONMODEL' then
                begin
                  //Das Kollisionsmodell des aktuellen Flugzeugs
                  Players[PlayerCount].v3DCOLModel := Load3DCollision(Value);
                end
                else if Command = 'PLAYERHEALTH' then
                begin
                  //Legt die Anfangslebensenergie fest.
                  Players[PlayerCount].vLivePower := StrToInt(Value);
                  MakePlayerDamage(0, PlayerCount);
                end
                else if Command = 'PLAYERMODELSCALE' then
                begin
                  //Skalierungsfaktor des 3D-Models:
                  Players[PlayerCount].vModelScale := StrToFloatEx(Value);
                end
                else if Command = 'PLAYERMODELYDIFF' then
                begin
                  //Y-Differenz zur Kamera
                  Players[PlayerCount].VDistanceToCam := StrToFloatEx(Value);
                end
                else if Command = 'PLAYERX' then
                begin
                  Players[PlayerCount].XPOS := StrToFloatEx(Value);
                end
                else if Command = 'PLAYERY' then
                begin
                  Players[PlayerCount].YPOS := StrToFloatEx(Value);
                end
                else if Command = 'PLAYERZ' then
                begin
                  Players[PlayerCount].ZPOS := StrToFloatEx(Value);
                end
                else if Command = 'SUNX' then
                begin
                  LVector.x := StrToFloatEx(Value);
                end
                else if Command = 'SUNY' then
                begin
                  LVector.y := StrToFloatEx(Value);
                end
                else if Command = 'SUNZ' then
                begin
                  LVector.z := StrToFloatEx(Value);
                end
                else if Command = 'PLAYERANGLE' then
                begin
                  //Y-Differenz zur Kamera
                  Players[PlayerCount].HWinkel := StrToFloatEx(Value);
                end
                else if Command = 'PLAYERMODELCAMDIST' then
                begin
                  //Abstand des Flugzeuges zur Kamera
                  Players[PlayerCount].HDistanceToCam := StrToFloatEx(Value);
                end
                else if Command = 'ACTIVEPLAYER' then
                begin
                  //welches Flugzeug dem Spieler gehört
                  ActivePlane := StrToInt(Value);
                end
                else if Command = 'BGMUSIC' then
                begin
                  //hintergrundmusik
                  BGMusic := CreateMusicBufferFromFile(Value);
                end
                else if Command = 'SND_CRASH' then
                begin
                  Players[PlayerCount].vCrashSound := CreateSoundBufferFromFile(Value);
                end
                else if Command = 'SND_ENGINE' then
                begin
                  Players[PlayerCount].vEngineSound := CreateSoundBufferFromFile(Value);
                end
                else if Command = 'SND_EXPLOSION' then
                begin
                  Players[PlayerCount].vExplosionSound := CreateSoundBufferFromFile(Value);
                end
                else if Command = 'SKYBOX_FRONT' then
                begin
                  SkyBox.SkyTexture1 := r_CreateTextureFromFile(PChar(Value));
                end
                else if Command = 'SKYBOX_RIGHT' then
                begin
                  SkyBox.SkyTexture2 := r_CreateTextureFromFile(PChar( Value));
                end
                else if Command = 'SKYBOX_LEFT' then
                begin
                  SkyBox.SkyTexture3 := r_CreateTextureFromFile(PChar(Value));
                end
                else if Command = 'SKYBOX_BACK' then
                begin
                  SkyBox.SkyTexture4 := r_CreateTextureFromFile(PChar(Value));
                end
                else if Command = 'SKYBOX_TOP' then
                begin
                  SkyBox.SkyTexture5 := r_CreateTextureFromFile(PChar(Value));
                end
                else if Command = 'SKYBOX_BOTTOM' then
                begin
                  SkyBox.SkyTexture6 := r_CreateTextureFromFile(PChar(Value));
                end
                else if Command = 'SKYBOX_3DMODEL' then
                begin
                  SkyBox.vSkyBox3DModel := Load3DModel(PChar(ApplicationPath + Value));
                end
                else if Command = 'FOG_COLOR' then
                begin
                  FogColor := StrToColor(Value);
                end
                else if Command = 'FOG_BEGIN' then
                begin
                  FogBegin := StrToFloatEx(Value);
                end
                else if Command = 'SKYBOX_DISTANCE' then
                begin
                  SkyBox.vDistanceToPlane := StrToInt(Value);
                end
                else if Command = 'SHADOW_TEXTURE' then
                begin
                  ShadowTexture := r_CreateTextureFromFile(PChar(Value));
                end
                else if Command = 'HIT_TEXTURE' then
                begin
                  HitTexture := r_CreateTextureFromFile(PChar(Value));
                end
                else if Command = 'ENGINE_FIRE_TEXTURE' then
                begin
                  FireTexture := r_CreateTextureFromFile(PChar(Value));
                end
                else if Command = 'PLAYER_SHOOT_MODE' then
                begin
                  //weapon mode
                  if Value = 'SINGLE' then
                  begin
                    Players[PlayerCount].vShootMode := 1;
                  end
                  else if Value = 'DOUBLE' then
                  begin
                    Players[PlayerCount].vShootMode := 2;
                  end
                  else
                  begin
                    Players[PlayerCount].vShootMode := 0;
                  end;
                end
                else if Command = 'SINGLE_SHOT' then
                begin
                  For I := 1 To Players[PlayerCount].vPointCount do
                  begin
                    If Players[PlayerCount].vPoints[I].vName = Value then
                    begin
                      //Fireposition besetzen:
                      Players[PlayerCount].vShoot_1_Source := Players[PlayerCount].vPoints[I].vPosition;
                      Break;
                    end;
                  end;
                end
                else if Command = 'DOUBLE_SHOT_1' then
                begin
                  For I := 1 To Players[PlayerCount].vPointCount do
                  begin
                    If Players[PlayerCount].vPoints[I].vName = Value then
                    begin
                      //double shot #2
                      Players[PlayerCount].vShoot_2a_Source := Players[PlayerCount].vPoints[I].vPosition;
                      Break;
                    end;
                  end;
                end
                else if Command = 'DOUBLE_SHOT_2' then
                begin
                  For I := 1 To Players[PlayerCount].vPointCount do
                  begin
                    If Players[PlayerCount].vPoints[I].vName = Value then
                    begin
                      //double shot #2a
                      Players[PlayerCount].vShoot_2b_Source := Players[PlayerCount].vPoints[I].vPosition;
                      Break;
                    end;
                  end;
                end;
            end
            else
            begin
              Command := Copy(Line, 1, 3);
              If Command = 'IDE' then
              begin
                //IDE-Bausteine-Deklaration
                IDECount := IDECount + 1;
                SetLength(vIDE, IDECount +1);
                Line := Copy (Line, 4, 999);
                //Den Namen auslesen:
                Position := Pos(',', Line);
                vIDE[IDECount].vName := Trim(Copy(Line, 1, Position -1));
                Line := Trim (Copy(Line, Position + 2, 999));
                //Dateiname und Kollisionsobjekte laden:
                Position := Pos(',', Line);
                Command := Trim(Copy(Line, 1, Position -1));
                Value := Trim (Copy(Line, Position + 2, 999));
                vIDE[IDECount].vModelID := Load3DModel(PChar(Command));
                vIDE[IDECount].vColID := Load3DCollision(Value);
              end
              else If Command = 'IPL' then
              begin
                //IPL-Objekte laden:
                Line := Copy (Line, 4, 999);
                Position := Pos (',', Line);

                //Den Namen der IDE laden:
                Command := Trim(Copy (Line, 1, Position -1));
                Line := Copy(Line, Position + 2, 999);
                Found := False;

                For I := 1 To IDECount do
                begin
                  If vIDE[I].vName = Command then
                  begin
                    Found := True;
                    IPLCount := IPLCount + 1;
                    SetLength (vIPL, IPLCount + 1);
                    vIPL[IPLCount].vIDE := I;
                    Break;
                  end;
                end;

                If Found = True then
                begin
                  //Gab es ein Problem beim Laden?
                  //Wenn die IDE nicht gefunden wurde, wird dieses Objekt übersprungen.
                  //XPOS
                  Position := Pos (',', Line);
                  Command := Copy (Line, 1, Position -1);
                  Line := Copy(Line, Position + 2, 999);
                  vIPL[IPLCount].vXPOS := StrToFloatEx(Command);
                  //YPOS
                  Position := Pos (',', Line);
                  Command := Copy (Line, 1, Position -1);
                  Line := Copy(Line, Position + 2, 999);
                  vIPL[IPLCount].vYPOS := StrToFloatEx(Command);
                  //ZPOS
                  Position := Pos (',', Line);
                  Command := Copy (Line, 1, Position -1);
                  Line := Copy(Line, Position + 2, 999);
                  vIPL[IPLCount].vZPOS := StrToFloatEx(Command);
                  //Yaw
                  Position := Pos (',', Line);
                  Command := Copy (Line, 1, Position -1);
                  Line := Copy(Line, Position + 2, 999);
                  vIPL[IPLCount].vYaw := StrToFloatEx(Command);
                  //Pitch
                  Position := Pos (',', Line);
                  Command := Copy (Line, 1, Position -1);
                  Line := Copy(Line, Position + 2, 999);
                  vIPL[IPLCount].vPitch := StrToFloatEx(Command);
                  //Roll
                  Position := Pos (',', Line);
                  Command := Copy (Line, 1, Position -1);
                  Line := Copy(Line, Position + 2, 999);
                  vIPL[IPLCount].vRoll := StrToFloatEx(Command);
                  //Scale
                  Position := Pos (',', Line);
                  Command := Copy (Line, 1, Position -1);
                  Line := Copy(Line, Position + 2, 999);
                  vIPL[IPLCount].vModelScale := StrToFloatEx(Command);
                  //Visible
                  Position := Pos (',', Line);
                  Command := Copy (Line, 1, Position -1);
                  Line := Copy(Line, Position + 2, 999);
                  If Command = '1' then vIPL[IPLCount].vVisible := True else vIPL[IPLCount].vVisible := False;
                  //Collision
                  Position := Pos (',', Line);
                  Command := Copy (Line, 1, Position -1);
                  Line := Copy(Line, Position + 2, 999);
                  If Command = '1' then vIPL[IPLCount].vCollision := True else vIPL[IPLCount].vCollision := False;
                  //Collision
                  Position := Pos (',', Line);
                  Command := Copy (Line, 1, Position -1);
                  Line := Copy(Line, Position + 2, 1);
                  If Command = '1' then vIPL[IPLCount].vColExcl := True else vIPL[IPLCount].vColExcl := False;
                  //shadow
                  If Line = '1' then vIPL[IPLCount].vShowShadow := True else vIPL[IPLCount].vShowShadow := False;
                end;
              end
              else If Command = 'BUL' then
              begin
                //BUL-Deklarationen laden:
                Line := Copy (Line, 4, 999);

                Position := Pos (',', Line);
                //Den Namen der BUL laden:
                TempName := Trim(Copy (Line, 1, Position -1));
                Line := Copy(Line, Position + 2, 999);

                Position := Pos (',', Line);
                //Den Namen der IDE laden:
                Command := Trim(Copy (Line, 1, Position -1));
                Line := Copy(Line, Position + 2, 999);
                Found := False;

                For I := 1 To IDECount do
                begin
                  If vIDE[I].vName = Command then
                  begin
                    Found := True;
                    BULCount := BULCount + 1;
                    SetLength (vBUL, BULCount + 1);
                    vBUL[BULCount].vIDE := I;
                    vBUL[BULCount].vName := TempName;
                    Break;
                  end;
                end;

                If Found = True then
                begin
                  //Gab es ein Problem beim Laden?
                  //Wenn die IDE nicht gefunden wurde, wird dieses Objekt übersprungen.
                  //Scale
                  Position := Pos (',', Line);
                  Command := Copy (Line, 1, Position -1);
                  Line := Copy(Line, Position + 2, 999);
                  vBUL[BULCount].vScale := StrToFloatEx(Command);
                  //Power
                  Position := Pos (',', Line);
                  Command := Copy (Line, 1, Position -1);
                  Line := Copy(Line, Position + 2, 999);
                  vBUL[BULCount].vDamage := StrToFloatEx(Command);
                  //Speed & Shoottime
                  Position := Pos (',', Line);
                  Command := Copy (Line, 1, Position -1);
                  Value := Copy(Line, Position + 2, 999);
                  vBUL[BULCount].vSpeed := StrToFloatEx(Command);
                  vBUL[BULCount].vShootTime := StrToInt(Value);

                end;
              end
              else if Command = 'PNT' then
              begin
                //Wir deklarieren einen Punkt
                Players[PlayerCount].vPointCount := Players[PlayerCount].vPointCount + 1;
                SetLength(Players[PlayerCount].vPoints, Players[PlayerCount].vPointCount +1);
                Line := Copy (Line, 4, 999);
                //Den Namen auslesen:
                Position := Pos(',', Line);
                Players[PlayerCount].vPoints[Players[PlayerCount].vPointCount].vName := Trim(Copy(Line, 1, Position -1));
                Line := Trim (Copy(Line, Position + 2, 999));
                //load coords:
                Position := Pos(',', Line);
                Command := Trim(Copy(Line, 1, Position -1));
                Line := Trim (Copy(Line, Position + 2, 999));
                Players[PlayerCount].vPoints[Players[PlayerCount].vPointCount].vPosition.X := StrToFloatEx(Command);
                Position := Pos(',', Line);
                Command := Trim(Copy(Line, 1, Position -1));
                Value := Trim (Copy(Line, Position + 2, 999));
                Players[PlayerCount].vPoints[Players[PlayerCount].vPointCount].vPosition.Y := StrToFloatEx(Command);
                Players[PlayerCount].vPoints[Players[PlayerCount].vPointCount].vPosition.Z := StrToFloatEx(Value);
                if Players[PlayerCount].vPoints[Players[PlayerCount].vPointCount].vName = 'ENGINE' then
                begin
                  //Es handelt sich um die Deklaration einer neuen Turbine:
                  Players[PlayerCount].vEnginePointCount := Players[PlayerCount].vEnginePointCount + 1;
                  SetLength(Players[PlayerCount].vEnginePoints, Players[PlayerCount].vEnginePointCount + 1);
                  Players[PlayerCount].vEnginePoints[Players[PlayerCount].vEnginePointCount] := Players[PlayerCount].vPoints[Players[PlayerCount].vPointCount].vPosition;
                end
                else if Players[PlayerCount].vPoints[Players[PlayerCount].vPointCount].vName = 'LEFT_LIGHT' then
                begin
                  Players[PlayerCount].vLight_Left := Players[PlayerCount].vPoints[Players[PlayerCount].vPointCount].vPosition;
                  //Farbe
                  LightConfig.Specular.r := 1.0;
                  LightConfig.Specular.g := 1.0;
                  LightConfig.Specular.b := 1.0;
                  LightConfig.Diffuse.r := 0.0;
                  LightConfig.Diffuse.g := 1.0;
                  LightConfig.Diffuse.b := 0.0;
                  LightConfig.Ambient.r := 0.0;
                  LightConfig.Ambient.g := 1.0;
                  LightConfig.Ambient.b := 0.0;
                  LightConfig.Range := 0.5;
                  LightConfig.Attenuation1 := 25;
                  LightConfig.LightMode := LT_POINT;

                  Players[PlayerCount].vLight_Left_ID := r_CreateLight(LightConfig);
                  r_SetLight(Players[PlayerCount].vLight_Left_ID);
                  r_EnableLight(Players[PlayerCount].vLight_Left_ID, FALSE);
                end
                else if Players[PlayerCount].vPoints[Players[PlayerCount].vPointCount].vName = 'RIGHT_LIGHT' then
                begin
                  Players[PlayerCount].vLight_Right := Players[PlayerCount].vPoints[Players[PlayerCount].vPointCount].vPosition;
                  LightConfig.Specular.r := 1.0;
                  LightConfig.Specular.g := 1.0;
                  LightConfig.Specular.b := 1.0;
                  LightConfig.Diffuse.r := 1.0;
                  LightConfig.Diffuse.g := 0.0;
                  LightConfig.Diffuse.b := 0.0;
                  LightConfig.Ambient.r := 1.0;
                  LightConfig.Ambient.g := 0.0;
                  LightConfig.Ambient.b := 0.0;
                  LightConfig.Range := 0.5;
                  LightConfig.Attenuation1 := 25;
                  LightConfig.LightMode := LT_POINT;
                  Players[PlayerCount].vLight_Right_ID := r_CreateLight(LightConfig);
                  r_SetLight(Players[PlayerCount].vLight_Right_ID);
                  r_EnableLight(Players[PlayerCount].vLight_Right_ID, FALSE);
                end;
              end;
            end;
          end;
          //Nächste Zeile auslesen
        end;
      CloseFile(F1);
end;

//------------------------------------------------------------------------------
// DrawText()
// draws a 2d render sprite
//------------------------------------------------------------------------------
procedure TForm1.DrawText (vText: String; XPOS: Integer; YPOS: Integer; vScaling: Single);
  var I: Integer;
  var vTempSize: Integer;
  var vFontData: SpriteMode;
begin

    vText := UpperCase (vText);
    vTempSize := Trunc(vFontSize * vScaling);
    vFontData.Texture := vFont;
    vFontData.ScaleX := vScaling;
    vFontData.ScaleY := vScaling;
    vFontData.Left := XPOS;
    vFontData.Top := YPOS;
    vFontData.Rotation := 0;
    vFontData.Color := $FFFFFFFF;
    vFontData.Width := vFontSize;
    vFontData.Height := vFontSize;
    For I := 1 To Length(vText) do
    begin

      //Buchstaben
           if vText[I] = 'A' then begin SRECT.Top := 2 * vFontSize; SRECT.Left := 0 * vFontSize; end
      else if vText[I] = 'B' then begin SRECT.Top := 2 * vFontSize; SRECT.Left := 1 * vFontSize; end
      else if vText[I] = 'C' then begin SRECT.Top := 2 * vFontSize; SRECT.Left := 2 * vFontSize; end
      else if vText[I] = 'D' then begin SRECT.Top := 2 * vFontSize; SRECT.Left := 3 * vFontSize; end
      else if vText[I] = 'E' then begin SRECT.Top := 2 * vFontSize; SRECT.Left := 4 * vFontSize; end
      else if vText[I] = 'F' then begin SRECT.Top := 2 * vFontSize; SRECT.Left := 5 * vFontSize; end
      else if vText[I] = 'G' then begin SRECT.Top := 2 * vFontSize; SRECT.Left := 6 * vFontSize; end
      else if vText[I] = 'H' then begin SRECT.Top := 2 * vFontSize; SRECT.Left := 7 * vFontSize; end
      else if vText[I] = 'I' then begin SRECT.Top := 2 * vFontSize; SRECT.Left := 8 * vFontSize; end
      else if vText[I] = 'J' then begin SRECT.Top := 2 * vFontSize; SRECT.Left := 9 * vFontSize; end
      else if vText[I] = 'K' then begin SRECT.Top := 2 * vFontSize; SRECT.Left := 10 * vFontSize; end
      else if vText[I] = 'L' then begin SRECT.Top := 2 * vFontSize; SRECT.Left := 11 * vFontSize; end
      else if vText[I] = 'M' then begin SRECT.Top := 2 * vFontSize; SRECT.Left := 12 * vFontSize; end
      else if vText[I] = 'N' then begin SRECT.Top := 2 * vFontSize; SRECT.Left := 13 * vFontSize; end
      else if vText[I] = 'O' then begin SRECT.Top := 2 * vFontSize; SRECT.Left := 14 * vFontSize; end
      else if vText[I] = 'P' then begin SRECT.Top := 2 * vFontSize; SRECT.Left := 15 * vFontSize; end
      else if vText[I] = 'Q' then begin SRECT.Top := 3 * vFontSize; SRECT.Left := 0 * vFontSize; end
      else if vText[I] = 'R' then begin SRECT.Top := 3 * vFontSize; SRECT.Left := 1 * vFontSize; end
      else if vText[I] = 'S' then begin SRECT.Top := 3 * vFontSize; SRECT.Left := 2 * vFontSize; end
      else if vText[I] = 'T' then begin SRECT.Top := 3 * vFontSize; SRECT.Left := 3 * vFontSize; end
      else if vText[I] = 'U' then begin SRECT.Top := 3 * vFontSize; SRECT.Left := 4 * vFontSize; end
      else if vText[I] = 'V' then begin SRECT.Top := 3 * vFontSize; SRECT.Left := 5 * vFontSize; end
      else if vText[I] = 'W' then begin SRECT.Top := 3 * vFontSize; SRECT.Left := 6 * vFontSize; end
      else if vText[I] = 'X' then begin SRECT.Top := 3 * vFontSize; SRECT.Left := 7 * vFontSize; end
      else if vText[I] = 'Y' then begin SRECT.Top := 3 * vFontSize; SRECT.Left := 8 * vFontSize; end
      else if vText[I] = 'Z' then begin SRECT.Top := 3 * vFontSize; SRECT.Left := 9 * vFontSize; end
      //Zahlen
      else if vText[I] = '0' then begin SRECT.Top := 1 * vFontSize; SRECT.Left := 0 * vFontSize; end
      else if vText[I] = '1' then begin SRECT.Top := 1 * vFontSize; SRECT.Left := 1 * vFontSize; end
      else if vText[I] = '2' then begin SRECT.Top := 1 * vFontSize; SRECT.Left := 2 * vFontSize; end
      else if vText[I] = '3' then begin SRECT.Top := 1 * vFontSize; SRECT.Left := 3 * vFontSize; end
      else if vText[I] = '4' then begin SRECT.Top := 1 * vFontSize; SRECT.Left := 4 * vFontSize; end
      else if vText[I] = '5' then begin SRECT.Top := 1 * vFontSize; SRECT.Left := 5 * vFontSize; end
      else if vText[I] = '6' then begin SRECT.Top := 1 * vFontSize; SRECT.Left := 6 * vFontSize; end
      else if vText[I] = '7' then begin SRECT.Top := 1 * vFontSize; SRECT.Left := 7 * vFontSize; end
      else if vText[I] = '8' then begin SRECT.Top := 1 * vFontSize; SRECT.Left := 8 * vFontSize; end
      else if vText[I] = '9' then begin SRECT.Top := 1 * vFontSize; SRECT.Left := 9 * vFontSize; end
      //Sonderzeichen:
      else if vText[I] = ',' then begin SRECT.Top := 0 * vFontSize; SRECT.Left := 0 * vFontSize; end
      else if vText[I] = '!' then begin SRECT.Top := 0 * vFontSize; SRECT.Left := 1 * vFontSize; end
      else if vText[I] = '"' then begin SRECT.Top := 0 * vFontSize; SRECT.Left := 2 * vFontSize; end
      else if vText[I] = '$' then begin SRECT.Top := 0 * vFontSize; SRECT.Left := 3 * vFontSize; end
      else if vText[I] = '%' then begin SRECT.Top := 0 * vFontSize; SRECT.Left := 4 * vFontSize; end
      else if vText[I] = '&' then begin SRECT.Top := 0 * vFontSize; SRECT.Left := 5 * vFontSize; end
      else if vText[I] = '/' then begin SRECT.Top := 0 * vFontSize; SRECT.Left := 6 * vFontSize; end
      else if vText[I] = '(' then begin SRECT.Top := 0 * vFontSize; SRECT.Left := 7 * vFontSize; end
      else if vText[I] = ')' then begin SRECT.Top := 0 * vFontSize; SRECT.Left := 8 * vFontSize; end
      else if vText[I] = '=' then begin SRECT.Top := 0 * vFontSize; SRECT.Left := 9 * vFontSize; end
      else if vText[I] = '?' then begin SRECT.Top := 0 * vFontSize; SRECT.Left := 10 * vFontSize; end
      else if vText[I] = '.' then begin SRECT.Top := 0 * vFontSize; SRECT.Left := 11 * vFontSize; end
      else if vText[I] = ';' then begin SRECT.Top := 0 * vFontSize; SRECT.Left := 12 * vFontSize; end
      else if vText[I] = ':' then begin SRECT.Top := 0 * vFontSize; SRECT.Left := 13 * vFontSize; end
      else if vText[I] = '-' then begin SRECT.Top := 0 * vFontSize; SRECT.Left := 14 * vFontSize; end
      else if vText[I] = '[' then begin SRECT.Top := 1 * vFontSize; SRECT.Left := 10 * vFontSize; end
      else if vText[I] = ']' then begin SRECT.Top := 1 * vFontSize; SRECT.Left := 11 * vFontSize; end
      //sonst nichts anzeigen:
      else begin SRECT.Top:= 3 * vFontSize; SRECT.Left := 15 * vFontSize; end;
      vFontData.Right := SRECT.Left;
      vFontData.Bottom := SRECT.Top;
      r_DrawSprite(vFontData);
      vFontData.Left := vFontData.Left + Trunc((9 /16) * vTempSize);
    end;
end;


//------------------------------------------------------------------------------
// MakePlayerDamage()
// damages a player
//------------------------------------------------------------------------------
procedure TForm1.MakePlayerDamage (vDamage: Integer; vPlane: Integer);
  var NewHealth: Integer;
begin
  If Players[vPlane].vExploded = True then Exit;
  NewHealth := Players[vPlane].vLivePower - vDamage;
  If NewHealth < 0 then
  begin
    if NewHealth < -50 then
    begin
      //total damage
      ExplodeAirCraft(vPlane);
    end;
    NewHealth := 0;
  end;

  If vDamage > 0 then
  begin
    //play sound
    PlaySound(Players[vPlane].vCrashSound.Buffer, False);
  end;
  Players[vPlane].vLivePower := NewHealth;

  If NewHealth > 50 then
  begin
    Players[vPlane].v3DModel := Players[vPlane].v3DModelFull;
  end
  else if (NewHealth <= 50) and (NewHealth > 0) then
  begin
    Players[vPlane].v3DModel := Players[vPlane].v3DModelDamaged;
  end
  else
  begin
    if Players[vPlane].vDeath = False then
    begin
      Players[vPlane].v3DModel := Players[vPlane].v3DModelDestroyed;
      if vPlane = ActivePlane then Timer_Explode.Enabled := True;
      Players[vPlane].vDeath := True;
      Players[vPlane].vExploded := False;
    end
    else
    begin
      if Players[vPlane].vExploded = False then
      begin
        //if hit one more time, explode
        ExplodeAirCraft(vPlane);
      end;
    end;
  end;

end;

//------------------------------------------------------------------------------
// ExplodeAirCraft()
// destroys a plane
//------------------------------------------------------------------------------
procedure TForm1.ExplodeAirCraft(vPlane: Integer);
begin

  //disable aircraft
  with Players[vPlane] do
  begin
    vLightEnabled := False;
    vLivePower := 0;
    vDeath := True;
    vExploded := True;
    Timer_Explode.Enabled := False;
    Timer_Light.Enabled := False;
    vShooting := False;

    Speed := 0;

    r_EnableLight(vLight_Left_ID, False);
    r_EnableLight(vLight_Right_ID, False);
    a_StopAudioBuffer(Players[vPlane].vEngineSound.Buffer);
    PlaySound(Players[vPlane].vExplosionSound.Buffer, False);
  end;

 end;

//------------------------------------------------------------------------------
// ResetAirCraft()
// resets a plane
//------------------------------------------------------------------------------
procedure TForm1.ResetAirCraft(vPlane: Integer);
begin
  //disable aircraft
  with Players[vPlane] do
  begin
    v3DModel := v3DModelFull;
    vLightEnabled := False;
    vLivePower := 100;
    vDeath := False;
    vExploded := False;
    Timer_Explode.Enabled := False;
    Timer_Light.Enabled := True;
    Speed := 0;
    HWinkel := 0;
    HAcceleration := 0;
    VAcceleration := 0;
    If a_CheckIfAudioBufferIsPlayed(Players[vPlane].vEngineSound.Buffer) = False then
    begin
      PlaySound(Players[vPlane].vEngineSound.Buffer, True);
    end;
  end;
end;

//------------------------------------------------------------------------------
// SetPlayerEngineFreq()
// sets the freq of a player engine
//------------------------------------------------------------------------------
procedure TForm1.SetPlayerEngineFreq(vPlane: Integer);
  var CurrentFreq: Integer;
begin
  If Players[vPlane].Speed <> 0 then
  begin
    CurrentFreq := Trunc(Players[vPlane].vEngineSound.Default_Freq * (((Players[vPlane].Speed - 0.1) * 3)  + 1));
  end
  else
  begin
    CurrentFreq := 0;
    a_StopAudioBuffer(Players[vPlane].vEngineSound.Buffer);
  end;
  If CurrentFreq <> Players[vPlane].vEngineSound.Current_Freq then
  begin
    Players[vPlane].vEngineSound.Current_Freq := CurrentFreq;
    a_SetFrequency(Players[vPlane].vEngineSound.Buffer, CurrentFreq);
  end;
end;



//------------------------------------------------------------------------------
// Load3DCollision()
// loads a collision file
//------------------------------------------------------------------------------
function TForm1.Load3DCollision(vFileName: String): Integer;
  //Diese Funktion läd ein Collisions-File in ein COL-Modell-Mesh
 //Variablen:
  //----------

  //allgemeine Variablen:
  var F1:               TextFile;
  var Line:             String;
  var Command:          String;
  var Value:            String;
  var Position:         Integer;
begin
    if FileExists(ApplicationPath + vFileName) = False then
    begin
      RESULT := -1;
      Exit;
    end;

    COLCount := COLCount + 1;
    SetLength (COLMeshes, COLCount + 1);

  //Kollision laden ;D
  try
    AssignFile(F1, ApplicationPath + vFileName);
    Reset(F1);
      while not EOF(F1) do
      begin
        Readln(F1, Line);
          if Line <> '' then
          begin
          //Jetzt alle Details laden:
          Position := Pos ('=', Line);
            If Position <> 0 then
            begin
                Command := Copy (Line, 1, Position -1);
                Value := Copy (Line, Position +1, 100);

                if Command = 'CREATE' then
                begin
                  //Neues Subcollisionsobjekt erstellen:
                  If Value = 'SPHERE' then
                  begin
                    //Neue Sphere erstellen:
                    COLMeshes[COLCount].SPHCount := COLMeshes[COLCount].SPHCount +1;
                    SetLength(COLMeshes[COLCount].Spheres, COLMeshes[COLCount].SPHCount + 1);
                  end
                  else if Value = 'TRIANGLE' then
                  begin
                    //Der Sphere ein neues Dreieck hinzufügen:
                    COLMeshes[COLCount].Spheres[COLMeshes[COLCount].SPHCount].TRICount := COLMeshes[COLCount].Spheres[COLMeshes[COLCount].SPHCount].TRICount + 1;
                    SetLength(COLMeshes[COLCount].Spheres[COLMeshes[COLCount].SPHCount].Triangles, COLMeshes[COLCount].Spheres[COLMeshes[COLCount].SPHCount].TRICount + 1);
                  end;
                end
                else if Command = 'X' then
                begin
                  //X-Position der Sphere definieren:
                  COLMeshes[COLCount].Spheres[COLMeshes[COLCount].SPHCount].Point.X := StrToFloatEx(Value);
                end
                else if Command = 'Y' then
                begin
                  //X-Position der Sphere definieren:
                  COLMeshes[COLCount].Spheres[COLMeshes[COLCount].SPHCount].Point.Y := StrToFloatEx(Value);
                end
                else if Command = 'Z' then
                begin
                  //Y-Position der Sphere definieren:
                  COLMeshes[COLCount].Spheres[COLMeshes[COLCount].SPHCount].Point.Z := StrToFloatEx(Value);
                end
                else if Command = 'RADIUS' then
                begin
                  //Z-Position der Sphere definieren:
                  COLMeshes[COLCount].Spheres[COLMeshes[COLCount].SPHCount].Radius := StrToFloatEx(Value);
                end
                //Dem akutuellem Dreieck die Koordinaten zuweisen:
                else if Command = 'P1X' then
                begin
                  COLMeshes[COLCount].Spheres[COLMeshes[COLCount].SPHCount].Triangles[COLMeshes[COLCount].Spheres[COLMeshes[COLCount].SPHCount].TRICount].P1.X := StrToFloatEx(Value);
                end
                else if Command = 'P1Y' then
                begin
                  COLMeshes[COLCount].Spheres[COLMeshes[COLCount].SPHCount].Triangles[COLMeshes[COLCount].Spheres[COLMeshes[COLCount].SPHCount].TRICount].P1.Y := StrToFloatEx(Value);
                end
                else if Command = 'P1Z' then
                begin
                  COLMeshes[COLCount].Spheres[COLMeshes[COLCount].SPHCount].Triangles[COLMeshes[COLCount].Spheres[COLMeshes[COLCount].SPHCount].TRICount].P1.Z := StrToFloatEx(Value);
                end
                else if Command = 'P2X' then
                begin
                  COLMeshes[COLCount].Spheres[COLMeshes[COLCount].SPHCount].Triangles[COLMeshes[COLCount].Spheres[COLMeshes[COLCount].SPHCount].TRICount].P2.X := StrToFloatEx(Value);
                end
                else if Command = 'P2Y' then
                begin
                  COLMeshes[COLCount].Spheres[COLMeshes[COLCount].SPHCount].Triangles[COLMeshes[COLCount].Spheres[COLMeshes[COLCount].SPHCount].TRICount].P2.Y := StrToFloatEx(Value);
                end
                else if Command = 'P2Z' then
                begin
                  COLMeshes[COLCount].Spheres[COLMeshes[COLCount].SPHCount].Triangles[COLMeshes[COLCount].Spheres[COLMeshes[COLCount].SPHCount].TRICount].P2.Z := StrToFloatEx(Value);
                end
                else if Command = 'P3X' then
                begin
                  COLMeshes[COLCount].Spheres[COLMeshes[COLCount].SPHCount].Triangles[COLMeshes[COLCount].Spheres[COLMeshes[COLCount].SPHCount].TRICount].P3.X := StrToFloatEx(Value);
                end
                else if Command = 'P3Y' then
                begin
                  COLMeshes[COLCount].Spheres[COLMeshes[COLCount].SPHCount].Triangles[COLMeshes[COLCount].Spheres[COLMeshes[COLCount].SPHCount].TRICount].P3.Y := StrToFloatEx(Value);
                end
                else if Command = 'P3Z' then
                begin
                  COLMeshes[COLCount].Spheres[COLMeshes[COLCount].SPHCount].Triangles[COLMeshes[COLCount].Spheres[COLMeshes[COLCount].SPHCount].TRICount].P3.Z := StrToFloatEx(Value);
                end;
            end;
          end;
      end;
      CloseFile(F1);
    except
      //ERROR LOADING THE COLLISION MESHES!
    end;

    RESULT := COLCount;

end;


//------------------------------------------------------------------------------
// CreateOctree()
// creates a collision octree
//------------------------------------------------------------------------------
procedure TForm1.CreateOctree();
  var
  vCurrentMax: Single;
  I, K, L, M: Integer;
  MaxX,
  MaxY,
  MaxZ,
  MinX,
  MinY,
  MinZ:    Single;
  SphereList: Array of Sphere3DRef;
  SphereCount: Integer;
  OctPosition: Vector3DInt;
  vCurrentSphere: Vector3D;
begin
  MinX := -1;
  MinY := -1;
  MinZ := -1;
  MaxX := -1;
  MaxY := -1;
  MaxZ := -1;
  SphereCount := 0;
  SetLength(vColOctree.GlobalSpheres, 0);
  vColOctree.GlobalSphereCount := 0;
  SetLength(vColOctree.SubTrees, 0);

  //find maximal dimensions
   For I := 1 TO IPLCount do
   begin
        if (vIPL[I].vCollision = True) or (vIPL[I].vColExcl = True) then
        begin
          if vIPL[I].vVisible = True then
          begin
            if vIPL[I].vColMDL.SPHCount > 0 then
            begin
              For K := 1 To vIPL[I].vColMDL.SPHCount do
              begin
                SphereCount := SphereCount + 1;
                SetLength(SphereList, SphereCount + 1);
                SphereList[SphereCount].vIPLRef := I;
                SphereList[SphereCount].vSphereRef := K;

                //they're not relevant for the octree system, so ignore them
                If vIPL[I].vColMDL.Spheres[K].Radius < OCTREE_SIZE * 2 then
                begin
                  //get max
                  vCurrentMax := vIPL[I].vColMDL.Spheres[K].Point.X + vIPL[I].vColMDL.Spheres[K].Radius;
                  If vCurrentMax > MaxX then MaxX := vCurrentMax;
                  vCurrentMax := vIPL[I].vColMDL.Spheres[K].Point.Y + vIPL[I].vColMDL.Spheres[K].Radius;
                  If vCurrentMax > MaxY then MaxY := vCurrentMax;
                  vCurrentMax := vIPL[I].vColMDL.Spheres[K].Point.Z + vIPL[I].vColMDL.Spheres[K].Radius;
                  If vCurrentMax > MaxZ then MaxZ := vCurrentMax;

                  //get min
                  vCurrentMax := vIPL[I].vColMDL.Spheres[K].Point.X - vIPL[I].vColMDL.Spheres[K].Radius;
                  If vCurrentMax < MinX then MinX := vCurrentMax;
                  vCurrentMax := vIPL[I].vColMDL.Spheres[K].Point.Y - vIPL[I].vColMDL.Spheres[K].Radius;
                  If vCurrentMax < MinY then MinY := vCurrentMax;
                  vCurrentMax := vIPL[I].vColMDL.Spheres[K].Point.Z - vIPL[I].vColMDL.Spheres[K].Radius;
                  If vCurrentMax < MinZ then MinZ := vCurrentMax;
                end;
              end;
            end;
          end;
       end;
   end;
   vColOctree.XCount := Trunc((MaxX - MinX) / OCTREE_SIZE) + 1;
   vColOctree.YCount := Trunc((MaxY - MinY) / OCTREE_SIZE) + 1;
   vColOctree.ZCount := Trunc((MaxZ - MinZ) / OCTREE_SIZE) + 1;
   vColOctree.XDiff := -MinX;
   vColOctree.YDiff := -MinY;
   vColOctree.ZDiff := -MinZ;
   SetLength(vColOctree.SubTrees, vColOctree.XCount + 1);
   For I := 0 To vColOctree.XCount do
   begin
    SetLength(vColOctree.SubTrees[I], vColOctree.YCount + 1);
    For K := 0 To vColOctree.YCount do
    begin
      SetLength(vColOctree.SubTrees[I][K], vColOctree.ZCount + 1);
    end;
   end;
   
  M := 1;
  While M <= SphereCount do
  begin
    vCurrentSphere.X := vIPL[SphereList[M].vIPLRef].vColMDL.Spheres[SphereList[M].vSphereRef].Point.X - MinX;
    vCurrentSphere.Y := vIPL[SphereList[M].vIPLRef].vColMDL.Spheres[SphereList[M].vSphereRef].Point.Y - MinY;
    vCurrentSphere.Z := vIPL[SphereList[M].vIPLRef].vColMDL.Spheres[SphereList[M].vSphereRef].Point.Z - MinZ;

    OctPosition := TryToArrangeSphereInOctree(vCurrentSphere, vIPL[SphereList[M].vIPLRef].vColMDL.Spheres[SphereList[M].vSphereRef].Radius);
    If OctPosition.X <> -1 then
    begin
      //sphere is in octree, copy informations and go on with the next one
      I := OctPosition.X;
      K := OctPosition.Y;
      L := OctPosition.Z;
      vColOctree.SubTrees[I][K][L].SphereCount := vColOctree.SubTrees[I][K][L].SphereCount + 1;
      SetLength (vColOctree.SubTrees[I][K][L].Spheres, vColOctree.SubTrees[I][K][L].SphereCount + 1);
      vColOctree.SubTrees[I][K][L].Spheres[vColOctree.SubTrees[I][K][L].SphereCount].vIPLRef := SphereList[M].vIPLRef;
      vColOctree.SubTrees[I][K][L].Spheres[vColOctree.SubTrees[I][K][L].SphereCount].vSphereRef := SphereList[M].vSphereRef;
      SphereList[M] := SphereList[SphereCount];
      SphereCount := SphereCount - 1;
    end
    else
    begin
      M := M + 1;
    end;
  end;

   //kk, all spheres have been tested!
   vColOctree.GlobalSphereCount := SphereCount;
   SetLength(vColOctree.GlobalSpheres, SphereCount + 1);
   For I := 1 To SphereCount do
   begin
    vColOctree.GlobalSpheres[I] := SphereList[I];
   end;
end;

//------------------------------------------------------------------------------
// Check3DCollision()
// check col
//------------------------------------------------------------------------------
function TForm1.Check3DCollision(ColID1: COLMODELS; P1: Vector3D; ColID2: COLMODELS; P2: Vector3D; Scale1: Single; Scale2: Single; Yaw1: Single; Yaw2: Single; Pitch1: Single; Pitch2: Single; Roll1: Single; Roll2: Single): Boolean;
  var I: LongInt;
  var K: LongInt;
  var L: LongInt;
  var M: LongInt;
  //Für die SpherenKollision:
  var TempRadius1: Single;
  var TempRadius2: Single;
  var TempPos1: Vector3D;
  var TempPos2: Vector3D;
  //Für die Dreieckskollision:
  var TempTriangle1: Triangle3D;
  var TempTriangle2: Triangle3D;
  var TempTriangle1A: Triangle3D;
  var TempTriangle2A: Triangle3D;
  var TempVector: Vector3D;
begin
  If (ColID1.SPHCount = 0) or (ColID2.SPHCount = 0) then
  begin
    //Ja, wie soll hier ne Kollision entstehen...
    RESULT := False;
    Exit;
  end;

  //Wir müssen zunächst alle Spheren durchgehen... in einem solchen Fall müssen wir anschliessend die Dreiecke checken.
  For I := 1 To ColID1.SPHCount do
  begin
    //Skalierungsfaktor und Ortsposition einsetzen:
    TempVector.X := ColID1.Spheres[I].Point.X * Scale1;
    TempVector.Y := ColID1.Spheres[I].Point.Y * Scale1;
    TempVector.Z := ColID1.Spheres[I].Point.Z * Scale1;
    //Zunächst mal die Yaw-Pitch-Roll miteinbeziehen:
    TempVector := Vector3DYawPitchRoll(TempVector, Yaw1, Pitch1, Roll1);
    TempPos1.X := P1.X + TempVector.X;
    TempPos1.Y := P1.Y + TempVector.Y;
    TempPos1.Z := P1.Z + TempVector.Z;
    TempRadius1 := (ColID1.Spheres[I].Radius * Scale1);
    For K := 1 To ColID2.SPHCount do
    begin
      //Dasselbe für die Spheren des anderen Objekts:
      TempVector.X := ColID2.Spheres[K].Point.X * Scale2;
      TempVector.Y := ColID2.Spheres[K].Point.Y * Scale2;
      TempVector.Z := ColID2.Spheres[K].Point.Z * Scale2;
      //Zunächst mal die Yaw-Pitch-Roll miteinbeziehen:
      TempVector := Vector3DYawPitchRoll(TempVector, Yaw2, Pitch2, Roll2);
      TempPos2.X := P2.X + TempVector.X;
      TempPos2.Y := P2.Y + TempVector.Y;
      TempPos2.Z := P2.Z + TempVector.Z;
      TempRadius2 := (ColID2.Spheres[K].Radius * Scale2);

      //Überprüfen ob es eine Kollision gab:
      If SphereCollision(TempPos1, TempPos2, TempRadius1, TempRadius2) = True then
      begin
        //Die Spheren kollidieren!
        //Nun müssen wir die Kollision auf Dreiecksebene durchführen:
        //Wieviele Spiele wurden aufgegeben, weil sie diese simple Zeile nicht verstanden haben...
        If (ColID1.Spheres[I].TRICount = 0) or (ColID2.Spheres[K].TRICount = 0) then
        begin
          //Nun, es gibt keine Dreiecke in den Spheren...
          //:D
          //ich liebe meinen flexibelen Quellcode, bis man mich dabei erwischte.... okay, nonsense ^^
          RESULT := True;
          Exit;
        end;

        //Ach, ach, jetzt sollen wir die Kollisionsüberprüfung auf Dreiecksebene machen:
        For L := 1 To ColID1.Spheres[I].TRICount do
        begin
          //Temporäres Dreieck berechnen:
          //Zuallererst die Skalierung der Dreiecke berechnen:
          TempTriangle1 := ScaleTriangle (ColID1.Spheres[I].Triangles[L], Scale1);
          //Yaw-Pitch-Roll
          TempTriangle1 := TriangleYawPitchRoll(TempTriangle1, Yaw1, Pitch1, Roll1);
          //Die aktuelle Position des Dreieckes berechnen:
          TempTriangle1 := AddPointToTriangle (TempTriangle1, P1);

          For M := 1 To ColID2.Spheres[K].TRICount do
          begin
            //temporäres Dreieck berechnen (skalieren):
            TempTriangle2 := ScaleTriangle(ColID2.Spheres[K].Triangles[M], Scale2);
            //Yaw-Pitch-Roll-Einbeziehen:
            TempTriangle2 := TriangleYawPitchRoll(TempTriangle2, Yaw2, Pitch2, Roll2);
            //Die aktuelle Position des Dreieckes berechnen:
            TempTriangle2 := AddPointToTriangle (TempTriangle2, P2);

            //Dreieckskollision überprüfen
            If BerechneKollision(TempTriangle1.P1, TempTriangle1.P2, TempTriangle1.P3, TempTriangle2.P1, TempTriangle2.P2, TempTriangle2.P3) = True then
            begin
              RESULT := True;
              Exit;
            end;
          end;
        end;
      end;
    end;
  end;

  //Wenn immer noch keine Kollision gefunden wurde, beenden:
  RESULT := False;
end;

//------------------------------------------------------------------------------
// TryToArrangeSphereInOctree()
// checks if a sphere is placed in a octree
//------------------------------------------------------------------------------
function TForm1.TryToArrangeSphereInOctree(SpherePos: Vector3D; Rad: Single): Vector3DInt;
  var SphereXMax, SphereYMax, SphereZMax,
      SphereXMin, SPhereYMin, SphereZMin: Single;
      XMax, YMax, ZMax: Integer;
      XMin, YMin, ZMin: Integer;
begin
  Rad := Betrag(Rad);
  SphereXMax := SpherePos.X + Rad;
  SphereYMax := SpherePos.Y + Rad;
  SphereZMax := SpherePos.Z + Rad;
  SphereXMin := SpherePos.X - Rad;
  SphereYMin := SpherePos.Y - Rad;
  SphereZMin := SpherePos.Z - Rad;

  XMax := Trunc(SphereXMax / OCTREE_SIZE);
  YMax := Trunc(SphereYMax / OCTREE_SIZE);
  ZMax := Trunc(SphereZMax / OCTREE_SIZE);
  XMin := Trunc(SphereXMin / OCTREE_SIZE);
  YMin := Trunc(SphereYMin / OCTREE_SIZE);
  ZMin := Trunc(SphereZMin / OCTREE_SIZE);

  If (XMax = XMin) And (YMax = YMin) And (ZMax = ZMin) then
  begin
    RESULT.X := XMax;
    RESULT.Y := YMax;
    RESULT.Z := ZMax;
  end
  else
  begin
    RESULT.X := -1;
    RESULT.Y := -1;
    RESULT.Z := -1;
  end;
end;

//------------------------------------------------------------------------------
// ScaleTriangle()
// scales a triangle
//------------------------------------------------------------------------------
function TForm1.ScaleTriangle(Triangle: Triangle3D; Scale: Single): Triangle3D;
begin
  //Vektor mit Position addieren:
  RESULT.P1.X := Triangle.P1.X * Scale;
  RESULT.P1.Y := Triangle.P1.Y * Scale;
  RESULT.P1.Z := Triangle.P1.Z * Scale;
  RESULT.P2.X := Triangle.P2.X * Scale;
  RESULT.P2.Y := Triangle.P2.Y * Scale;
  RESULT.P2.Z := Triangle.P2.Z * Scale;
  RESULT.P3.X := Triangle.P3.X * Scale;
  RESULT.P3.Y := Triangle.P3.Y * Scale;
  RESULT.P3.Z := Triangle.P3.Z * Scale;
end;

//------------------------------------------------------------------------------
// AddPointToVertex()
// adds a point to a vertex
//------------------------------------------------------------------------------
function TForm1.AddPointToTriangle(Triangle: Triangle3D; Point: Vector3D): Triangle3D;
begin
  RESULT.P1.X := Point.X + Triangle.P1.X;
  RESULT.P1.Y := Point.Y + Triangle.P1.Y;
  RESULT.P1.Z := Point.Z + Triangle.P1.Z;
  RESULT.P2.X := Point.X + Triangle.P2.X;
  RESULT.P2.Y := Point.Y + Triangle.P2.Y;
  RESULT.P2.Z := Point.Z + Triangle.P2.Z;
  RESULT.P3.X := Point.X + Triangle.P3.X;
  RESULT.P3.Y := Point.Y + Triangle.P3.Y;
  RESULT.P3.Z := Point.Z + Triangle.P3.Z;
end;

//------------------------------------------------------------------------------
// VertexYawPitchRoll()
// roll a triangle
//------------------------------------------------------------------------------
function TForm1.TriangleYawPitchRoll(Triangle: Triangle3D; Yaw: Single; Pitch: Single; Roll: Single): Triangle3D;
begin
  RESULT.P1 := Vector3DYawPitchRoll(Triangle.P1, Yaw, Pitch, Roll);
  RESULT.P2 := Vector3DYawPitchRoll(Triangle.P2, Yaw, Pitch, Roll);
  RESULT.P3 := Vector3DYawPitchRoll(Triangle.P3, Yaw, Pitch, Roll);
end;

//------------------------------------------------------------------------------
// VectorYawPitchRoll()
// roll a vector
//------------------------------------------------------------------------------
function TForm1.Vector3DYawPitchRoll(Vertex: Vector3D; Yaw: Single; Pitch: Single; Roll: Single): Vector3D;
  var RotMatrix: TSingle3X3;
  var SinYaw, CosYaw,
      SinPitch, CosPitch,
      SinRoll, CosRoll: Single;
begin
  //3d-rotation solved over 3d-matrices ;)
  Yaw := Yaw * Pi180;
  Pitch := Pitch * Pi180;
  Roll := Roll * Pi180;

  SinYaw := Sin(Yaw);
  CosYaw := Cos(Yaw);
  SinPitch := Sin(Pitch);
  CosPitch := Cos(Pitch);
  SinRoll := Sin(Roll);
  CosRoll := Cos(Roll);

  RotMatrix[0][0] := (SinYaw * SinRoll * SinPitch) + (CosYaw * CosPitch);
  RotMatrix[0][1] := (SinYaw * SinRoll * CosPitch) - (CosYaw * SinPitch);
  RotMatrix[0][2] := cos(Roll) * SinYaw;

  RotMatrix[1][0] := SinPitch * CosRoll;
  RotMatrix[1][1] := CosRoll * CosPitch;
  RotMatrix[1][2] := -SinRoll;

  RotMatrix[2][0] := (CosYaw * SinRoll * SinPitch) - (SinYaw * CosPitch);
  RotMatrix[2][1] := (CosYaw * SinRoll * CosPitch) + (SinYaw * SinPitch);
  RotMatrix[2][2] := CosYaw * CosRoll;


  Result.X := Vertex.X * RotMatrix[0][0] + Vertex.Y * RotMatrix[0][1] + Vertex.Z * RotMatrix[0][2];
  Result.Y := Vertex.X * RotMatrix[1][0] + Vertex.Y * RotMatrix[1][1] + Vertex.Z * RotMatrix[1][2];
  Result.Z := Vertex.X * RotMatrix[2][0] + Vertex.Y * RotMatrix[2][1] + Vertex.Z * RotMatrix[2][2];
end;

function Vector3DSubtract(VectorA: Vector3D; VectorB: Vector3D): Vector3D;
begin
  Result.X := VectorA.X - VectorB.X;
  Result.Y := VectorA.Y - VectorB.Y;
  Result.Z := VectorA.Z - VectorB.Z;
end;

//------------------------------------------------------------------------------
// StrToFloatEx()
// converts a point str to a float
//------------------------------------------------------------------------------
function TForm1.StrToFloatEx(vString: String): Real;
  var vNewString: String;
begin
  vNewString := StringReplace(vString, '.', ',', [rfReplaceAll, rfIgnoreCase]);
  Result := StrToFloat (vNewString);
end;

//------------------------------------------------------------------------------
// StrToColor()
// converts a str to a colorvalue
//------------------------------------------------------------------------------
function TForm1.StrToColor(vStr: String): TColor;
  var Position: Integer;
  var R:        Integer;
  var G:        Integer;
  var B:        Integer;
  var Value:    String;
begin
  Position := Pos(',', vStr);
  B := StrToInt(Copy(vStr, 0, Position -1));
  Value := Copy(vStr, Position + 1, 999);

  Position := Pos(',', Value);
  G := StrToInt(Copy(Value, 0, Position -1));
  R := StrToInt(Copy(Value, Position + 1, 999));

  RESULT := RGB (R, G, B);
end;

//------------------------------------------------------------------------------
// SphereCollision()
// collision within 2 spheres
//------------------------------------------------------------------------------
function TForm1.SphereCollision(P1: Vector3D; P2: Vector3D; SP1: Single; SP2: Single): Boolean;
  var vDist: Vector3D;
  var vDistLength: Single;
begin
  vDist.X := P1.X - P2.X;
  vDist.Y := P1.Y - P2.Y;
  vDist.Z := P1.Z - P2.Z;

  //Strecke zwischen den beiden Punkten herausfinden
  //Ihre Länge minus die beiden Radien ergibt einen Wert:
  //wenn dieser weniger oder gleich als 0 ist, gibt es eine Kollision, wenn er größer ist, nicht.
  vDistLength := sqrt((vDist.X*vDist.X) + (vDist.Y*vDist.Y) + (vDist.Z*vDist.Z));
  vDistLength := Betrag(vDistLength) - (SP1 + SP2);

  If vDistLength <= 0.0001 then
  begin
    RESULT := True;
  end
  else
  begin
    RESULT := False;
  end;
end;

//------------------------------------------------------------------------------
// BerechneKollision()
// checks col within 2 triangles
//------------------------------------------------------------------------------
function TForm1.BerechneKollision(Tri1A: Vector3D; Tri1B: Vector3D; Tri1C: Vector3D; Tri2A: Vector3D; Tri2B: Vector3D; Tri2C: Vector3D): Boolean;
  var Ebene2: Plane3D;
  var Point1A: Single;
  var Point1B: Single;
  var Point1C: Single;
  var Ebene1: Plane3D;
  var Point2A: Single;
  var Point2B: Single;
  var Point2C: Single;
  var ToEbene1: Integer;
  var Top2: Integer;
  var L1A: Vector3D; // Startpunkt von Tri1
  var L1B: Vector3D; // Endpunkt von Tri1
  var L2A: Vector3D; // Startpunkt von Tri2
  var L2B: Vector3D; // Endpunkt von Tri2
  var Dir: Vector3D;
  var Max: Integer;
  var ReducedL1B: Single;
  var ReducedL2A: Single;
  var ReducedL2B: Single;
  var vBuffer: Single;
  var vBuffer1: Single;
  var vBuffer2: Single;
  var vBuffer3: Single;
begin
  //Die Brechnung läuft zur Einsparung an Rechenleistung in mehreren Schritten ab.
  //Man muss sich vorstellen, dass eine 3D-Welt aus mehreren Millionen Dreiecken
  //besteht, die alle mehr als 40 mal in der Sekunde geprüft werden sollen.

  //Die erste Überprüfung ist, ob die Punkte alle jeseits einer Dreiecksebene
  //liegen. Wenn dies der Fall ist, kann man die Funktion bereits gleich abbrechen.
  Ebene2 := PlaneFromPoints(Tri2A, Tri2B, Tri2C);
  //Um die Berechnung wirklich narrensicher zu machen, sollte der Vektor N nicht
  //in der PlaneFromPoints-Funktion normalisiert werden, da die FLOAT-breite
  //aufgrund der Dual-System-Architektur nicht 100% genau funktioniert.
  //Alternativ könnte man die Normalisierung weglassen und stattdessen hier durch
  //die Vektorlänge teilen.
  //Update: Die Normalisierung des (orthogonalen) Vektors wurde nun getrost ignoriert ;D
  //Stattdessen können wir nun durch die Vektorlänge teilen.

  //Überprüfung für alle drei Punkte durchführen, indem man deren Abstand zur Ebene herasufindet.
  Point1A := ((Tri1A.X * Ebene2.N.X) + (Tri1A.Y * Ebene2.N.Y) + (Tri1A.Z * Ebene2.N.Z) - Ebene2.D);
  Point1B := ((Tri1B.X * Ebene2.N.X) + (Tri1B.Y * Ebene2.N.Y) + (Tri1B.Z * Ebene2.N.Z) - Ebene2.D);
  Point1C := ((Tri1C.X * Ebene2.N.X) + (Tri1C.Y * Ebene2.N.Y) + (Tri1C.Z * Ebene2.N.Z) - Ebene2.D);

  //Wenn alle Punkte auf einer Seite liegen, kann sofort abgebrochen werden.
  If ((Point1A > 0) and (Point1B > 0) and (Point1C > 0)) then
  begin
    RESULT := False;
    Exit;
  end;
  If ((Point1A < -0) and (Point1B < -0) and (Point1C < -0)) then
  begin
    RESULT := False;
    Exit;
  end;

  //Denselben Test wie oben mit dem anderen Dreieck.
  Ebene1 := PlaneFromPoints(Tri1A, Tri1B, Tri1C);
  Point2A := ((Tri2A.X * Ebene1.N.X) + (Tri2A.Y * Ebene1.N.Y) + (Tri2A.Z * Ebene1.N.Z) - Ebene1.D);
  Point2B := ((Tri2B.X * Ebene1.N.X) + (Tri2B.Y * Ebene1.N.Y) + (Tri2B.Z * Ebene1.N.Z) - Ebene1.D);
  Point2C := ((Tri2C.X * Ebene1.N.X) + (Tri2C.Y * Ebene1.N.Y) + (Tri2C.Z * Ebene1.N.Z) - Ebene1.D);

  If ((Point2A > 0) and (Point2B > 0) and (Point2C > 0)) then
  begin
    RESULT := False;
    Exit;
  end;
  If ((Point2A < -0) and (Point2B < -0) and (Point2C < -0)) then
  begin
    RESULT := False;
    Exit;
  end;

  //Wenn die Funktion bis hierher noch nicht abgebrochen wurde,
  //dann ist eine Kollision möglich. Als nächstes suchen wir bei
  //beiden Dreiecken den Punkt, der alleine auf seiner Ebenenseite
  //liegt - dessen Vorzeichen bezüglich der Ebene also anders als
  //das der beiden anderen Punkte ist.
  //Von diesem werden wir daraufhin einen Vektor zu den Schnittpunkten der
  //Aussenlinien der Gerade ziehen und deren exakte Position auf der Schnitt-
  //geraden berechnen.
  //Durch die Werte dieser Punkte lässt sich bestimmen, ob die Dreiecke mitteinander
  //kollidieren.
  If (Point2B <= -vMin) and (Point2C <= -vMin) then ToEbene1 := 1
  else if (Point2B >= vMin) and (Point2C >= vMin) then ToEbene1 := 1
  else if (Point2A >= vMin) and (Point2B >= vMin) then ToEbene1 := 3
  else if (Point2A <= -vMin) and (Point2B <= -vMin) then ToEbene1 := 3
  else ToEbene1 := 2;

  If (Point1B <= -vMin) and (Point1C <= -vMin) then Top2 := 1
  else if (Point1B >= vMin) and (Point1C >= vMin) then Top2 := 1
  else if (Point1A >= vMin) and (Point1B >= vMin) then Top2 := 3
  else if (Point1A <= -vMin) and (Point1B <= -vMin) then Top2 := 3
  else Top2 := 2;

  // L1 berechnen
  // Nun kommt es darauf an, welcher Punkt alleine liegt!
  If Top2 = 1 then
  begin
   //Die Funktion aufrufen, die eine Kollision zwischen einer Gerade und einer Ebene berechet.
   //Dadurch wissen wir die Position der äusseren Schnittpunkte der Dreiecke auf der Schnittgeraden.
   //the two VECTOR3D-arguments are identifing the lane by two points.
   L1A := LineHitsPlaneFast(Tri1A, Tri1B, Ebene2);
   L1B := LineHitsPlaneFast(Tri1A, Tri1C, Ebene2);
  end
  else if Top2 = 2 then
  begin
   L1A := LineHitsPlaneFast(Tri1B, Tri1A, Ebene2);
   L1B := LineHitsPlaneFast(Tri1B, Tri1C, Ebene2);
  end
  else if Top2 = 3 then
  begin
   L1A := LineHitsPlaneFast(Tri1C, Tri1A, Ebene2);
   L1B := LineHitsPlaneFast(Tri1C, Tri1B, Ebene2);
  end;

  If ToEbene1 = 1 then
  begin
   L2A := LineHitsPlaneFast(Tri2A, Tri2B, Ebene1);
   L2B := LineHitsPlaneFast(Tri2A, Tri2C, Ebene1);
  end
  else if ToEbene1 = 2 then
  begin
   L2A := LineHitsPlaneFast(Tri2B, Tri2A, Ebene1);
   L2B := LineHitsPlaneFast(Tri2B, Tri2C, Ebene1);
  end
  else if ToEbene1 = 3 then
  begin
   L2A := LineHitsPlaneFast(Tri2C, Tri2A, Ebene1);
   L2B := LineHitsPlaneFast(Tri2C, Tri2B, Ebene1);
  end;

  //Richtungsvektor der Schnittgerade berechnen:
  vBuffer1 := L1B.X - L1A.X;
  vBuffer2 := L2A.X - L1A.X;
  vBuffer3 := L2B.X - L1A.X;

  Max := GetMax(vBuffer1, vBuffer2, vBuffer3);
  If Max = 1 then
  begin
    Dir.X := vBuffer1;
    Dir.Y := L1B.Y - L1A.Y;
    Dir.Z := L1B.Z - L1A.Z;
  end
  else if Max = 2 then
  begin
    Dir.X := vBuffer2;
    Dir.Y := L2A.Y - L1A.Y;
    Dir.Z := L2A.Z - L1A.Z;
  end
  else if Max = 3 then
  begin
    Dir.X := vBuffer3;
    Dir.Y := L2B.Y - L1A.Y;
    Dir.Z := L2B.Z - L1A.Z;
  end
  else
  begin
  //diesselbe Überprüfung durchführen für die y-Ebene
    //Richtungsvektor der Schnittgerade berechnen:
    vBuffer1 := L1B.Y - L1A.Y;
    vBuffer2 := L2A.Y - L1A.Y;
    vBuffer3 := L2B.Y - L1A.Y;

    Max := GetMax(vBuffer1, vBuffer2, vBuffer3);
    If Max = 1 then
    begin
      Dir.X := L1B.X - L1A.X;
      Dir.Y := vBuffer1;
      Dir.Z := L1B.Z - L1A.Z;
    end
    else if Max = 2 then
    begin
      Dir.X := L2A.X - L1A.X;
      Dir.Y := vBuffer2;
      Dir.Z := L2A.Z - L1A.Z;
    end
    else if Max = 3 then
    begin
      Dir.X := L2B.X - L1A.X;
      Dir.Y := vBuffer3;
      Dir.Z := L2B.Z - L1A.Z;
    end
    else
    begin
      //diesselbe Überprüfung durchführen für die z-Ebene
      //Richtungsvektor der Schnittgerade berechnen:
      vBuffer1 := L1B.Z - L1A.Z;
      vBuffer2 := L2A.Z - L1A.Z;
      vBuffer3 := L2B.Z - L1A.Z;

      Max := GetMax(vBuffer1, vBuffer2, vBuffer3);
      If Max = 1 then
      begin
        Dir.X := L1B.X - L1A.X;
        Dir.Y := L1B.Y - L1A.Y;
        Dir.Z := vBuffer1;
      end
      else if Max = 2 then
      begin
        Dir.X := L2A.X - L1A.X;
        Dir.Y := L2A.Y - L1A.Y;
        Dir.Z := vBuffer2;
      end
      else if Max = 3 then
      begin
        Dir.X := L2B.X - L1A.X;
        Dir.Y := L2B.Y - L1A.Y;
        Dir.Z := vBuffer3;
      end
      else
      begin
        //es gibt kein ergebnis für den Vektor...
        RESULT := False;
        Exit;
      end;
    end;
  end;

  //Nun wollen wir S, also den Multiplikator der Punkte mit dem Richtungs-
  //vektor bestimmen ;D. Also P = s*Vektor.
  //Verstanden? ^^
  //Wenn ihr aufpasst habt, wisst ihr dass der PC sich mit Kommazahlen schwer
  //tut. Also nehmen wir den höchsten Wert, um ein möglichst genaues s
  //zu finden. Dieses s erhalten wir durch Division des Punktes mit dem größten
  //Wert des Vektors.
  Max := GetMax(Betrag(Dir.X), Betrag(Dir.Y), Betrag(Dir.Z));

  //s berechnen:
  //s von ReducedL1A = 0 ! -> Der äussere Dreieckspunkt ist der Aufpunkt!
  If Max = 1 then
  begin
    ReducedL1B := (L1B.x - L1A.x);
    ReducedL2A := (L2A.x - L1A.x);
    ReducedL2B := (L2B.x - L1A.x);
  end
  else if Max = 2 then
  begin
    ReducedL1B := (L1B.y - L1A.y);
    ReducedL2A := (L2A.y - L1A.y);
    ReducedL2B := (L2B.y - L1A.y);
  end
  else if Max = 3 then
  begin
    ReducedL1B := (L1B.z - L1A.z);
    ReducedL2A := (L2A.z - L1A.z);
    ReducedL2B := (L2B.z - L1A.z);
  end
  else
  begin
    RESULT := False;
    Exit;
  end;

  //Endlich die wete überprüfen (es wird zeit ^^)
  //Erklärung der Werte:
  //ReducedL1A = 0, Anfang Dreieck 1
  //ReducedL1B = Ende Dreieck 1
  //ReducedL2A = Anfang Dreieck 2
  //ReducedL2B = Ende Dreieck 2

  //Werte nach Größe sortieren:
  If (ReducedL1B < 0) then
  begin
    //Werte vertauschen:
    ReducedL1B := Betrag(ReducedL1B);
    ReducedL2A := ReducedL2A + ReducedL1B;
    ReducedL2B := ReducedL2B + ReducedL1B;
  end;
  If (ReducedL2B < ReducedL2A) then
  begin
    //denselben Test für Dreieck 2:
    vBuffer := ReducedL2A;
    ReducedL2A := ReducedL2B;
    ReducedL2B := vBuffer;
  end;
  //Die Werte sind nun nach Größe sortiert!
  //Wir müssen nun folgende Fälle betrachten:
  //a)Dreieck 1 komplett in Dreieck 2
  //b)Dreieck 2 komplett in Dreieeck 1
  //c)Dreieck 2 am rechten Rand von Dreieck 1
  //d)Dreieck 2 am linken Rand von Dreieck 1

  //Auf Kollision überprüfen:
  If (0 >= ReducedL2A) and (ReducedL1B <= ReducedL2B) then
  begin
    RESULT := True;
  end
  else if (ReducedL2A <= ReducedL1B) and (ReducedL2A >= 0) then
  begin
    RESULT := True;
  end
  else if (ReducedL2B  >= 0) and (ReducedL2B <= ReducedL1B) then
  begin
    RESULT := True;
  end
  else
  begin
    RESULT := False;
  end;
end;

//------------------------------------------------------------------------------
// Vector3D_cross()
// vector cross product
//------------------------------------------------------------------------------
function Vector3DCross(VectorB: Vector3D; VectorC: Vector3D): Vector3D;
  var RectVector: Vector3D;
begin
  //berechnet den orthogonalen Vektor zu einer Ebene:
  RectVector.X := VectorB.Y * VectorC.Z - VectorB.Z * VectorC.Y;
  RectVector.Y := VectorB.Z * VectorC.X - VectorB.X * VectorC.Z;
  RectVector.Z := VectorB.X * VectorC.Y - VectorB.Y * VectorC.X;
  RESULT := RectVector;
end;

//------------------------------------------------------------------------------
// Vector3DDot()
// dot product of 2 vectors
//------------------------------------------------------------------------------
function Vector3DDot(VectorA: Vector3D; VectorB: Vector3D): Single;
  var VLenA: Single;
  var VLenB: Single;
  var VecMultiply: Single;
  var vSub: Single;
begin
  VecMultiply := VectorA.X * VectorB.X + VectorA.Y * VectorB.Y + VectorA.Z * VectorB.Z;
  vLenA := sqrt((VectorA.X*VectorA.X)+(VectorA.Y*VectorA.Y)+(VectorA.Z*VectorA.Z));
  vLenB := sqrt((VectorB.X*VectorB.X)+(VectorB.Y*VectorB.Y)+(VectorB.Z*VectorB.Z));
  vSub := vLenA * vLenB;

  If vSub = 0 then
  begin
    Result := -655232;
  end
  else
  begin
    Result := VecMultiply / vSub;
  end;
end;

//------------------------------------------------------------------------------
// LineHitsPlaneFast()
// checks col within a plane and a lane
//------------------------------------------------------------------------------
function TForm1.LineHitsPlaneFast(LineA: Vector3D; LineB: Vector3D; Plane: Plane3D): Vector3D;
  var LineDir:     Vector3D;  //Richtungsvektor der Geraden
  var vSkalarProdukt: Single; //Skalarprodukt des Richtungsvektors der Gerade mit dem der Ebene, um zu checken ob die
  //Gerade in der Ebene liegen könnte.
  var s: Single;
  var SP: Vector3D;
begin
  LineDir.X := LineB.X - LineA.X;
  LineDir.Y := LineB.Y - LineA.Y;
  LineDir.Z := LineB.Z - LineA.Z;
  //Skalarprodukt berechnen:
  vSkalarProdukt := Plane.N.X * LineDir.X + Plane.N.Y * LineDir.Y + Plane.N.Z * LineDir.Z;
  if Betrag(vSkalarProdukt) <= vMin then
  begin
    //Den Aufpunkt als Schnittpunkt zurückgeben, um wenigstens einen Anfang zu machen, sollten die Dreiecksebenen
    //ineinander liegen. Dieser Aufpunkt ist notwendig, um wenigstens eine Schnittgerade definieren zu können.
    //Da es ja unendlich viele Schnittgeraden gibt, nehmen wir die aus den beiden Eckpunkten der Dreiecke.
    Result := LineB;
    //Möglich wäre eine Überprüfung, ob die Gerade oder die Ebene parallel wären, indem man den Abstand zwischen dem Aufpunkt und
    //der Ebene berechnet. Dies ist aber unnötig, da wir wissen, dass sie sich schneiden!
    //if Betrag(LineA.X * Plane.N.X + LineA.Y * Plane.N.Y + LineA.Z * Plane.N.Z - Plane.D) < vMin then
    //begin

    //end;
  end;
  //Abstand der Ebene zu dem Schnittpunkt bestimmen. Dazu setzen wir die Gerade in die Ebenengleichung ein und berechnen
  //s.
  if vSkalarprodukt <> 0 then
  begin
    s := (Plane.D - Plane.N.X*LineA.X - Plane.N.Y*LineA.Y - Plane.N.Z*LineA.Z)/ vSkalarprodukt;
    if (s < 0.0) or (s > 1.0) then
    begin
      s := 0;
    end;
  end
  else
  begin
    S := 0;
  end;
  //Anhand diesen Abstandes den Schnittpunkt herausfinden:
  SP.X := LineA.X + s * LineDir.X;
  SP.Y := LineA.Y + s * LineDir.Y;
  SP.Z := LineA.Z + s * LineDir.Z;

  //Den Schnittpunkt zurückgeben
  RESULT := SP;
end;

//------------------------------------------------------------------------------
// Betrag()
// !!!
//------------------------------------------------------------------------------
function TForm1.Betrag (vZahl: Single): Single;
begin
  //Betrag einer Zahl
  If vZahl < 0 then
  begin
    RESULT := -vZahl;
  end
  else
  begin
    RESULT := vZahl;
  end;
end;

//------------------------------------------------------------------------------
// NormalizeVector()
// returns a vector with length=1
//------------------------------------------------------------------------------
function NormalizeVector(V: Vector3D): Vector3D;
  var vResult: Vector3D;
  var Length: Single;
begin
  //Vektor normalisieren, indem man ihn durch seine Länge teilt!
  Length := sqrt((V.X*V.X)+(V.Y*V.Y)+(V.Z*V.Z));

  If ((Length > 1) or (Length < 1)) and (Length <> 0) then
  begin
    vResult.X := V.X/Length;
    vResult.Y := V.Y/Length;
    vResult.Z := V.Z/Length;
  end;
  RESULT := vResult;
end;

//------------------------------------------------------------------------------
// PlaneFromPoints()
// transforms 3 points in a plane
//------------------------------------------------------------------------------
function TForm1.PlaneFromPoints(P1: Vector3D; P2: Vector3D; P3: Vector3D): Plane3D;
  var vPlane: Plane3D;
  var vDif1: Vector3D;
  var vDif2: Vector3D;
begin
  //orthogonalen Vektor bestimmen:
  vDif1.X := P3.X - P2.X;
  vDif1.Y := P3.Y - P2.Y;
  vDif1.Z := P3.Z - P2.Z;

  vDif2.X := P1.X - P2.X;
  vDif2.Y := P1.Y - P2.Y;
  vDif2.Z := P1.Z - P2.Z;

  vPlane.N := Vector3DCross(vDif1, vDif2);
  //P1 wird als Aufpunkt genommen.
  vPlane.D := (P1.X * vPlane.N.X) + (P1.Y * vPlane.N.Y) + (P1.Z * vPlane.N.Z);
  RESULT := vPlane;
end;


//------------------------------------------------------------------------------
// GetMax()
// returns the greatest value out of 3
//------------------------------------------------------------------------------
function TForm1.GetMax(Z1: Single; Z2: Single; Z3: Single): Integer;
  var Max: Single;
  var ResID: Integer;
begin
  //Das Maximum aus 3 Zahlen herausfinden:
  If Z1 = 0 then
  begin
    ResID := 0;
    Max := 0;
  end
  else
  begin
    Max := Betrag(Z1);
    ResID := 1;
  end;
  If Betrag(Z2) > Max then begin Max := Betrag(Z2); ResID := 2; end;
  If Betrag(Z3) > Max then begin ResID := 3; end;
  RESULT := ResID;
end;

//------------------------------------------------------------------------------
// RestorePlaneTimer()
// makes a plane immune for several secs
//------------------------------------------------------------------------------
procedure TForm1.t_RestorePlaneTimer(Sender: TObject);
begin
  //this timer controls the collision handle of the aircraft. If enabled,
  //the plane will be immune for several seconds.
    Players[ActivePlane].vRedSplash := False;
    Players[ActivePlane].vCrashImmune := False;
    t_RestorePlane.Enabled := False;
end;

//------------------------------------------------------------------------------
// Timer_FPSTimer()
// saves fps
//------------------------------------------------------------------------------
procedure TForm1.Timer_FPSTimer(Sender: TObject);
begin
  vCurrentFPS := vFPS;
  vFPS := 0;
end;                                                  

//------------------------------------------------------------------------------
// ResetShadowVolume()
// deletes old shadow volume
//------------------------------------------------------------------------------
procedure TShadowVolume.ResetShadowVolume;
begin
  r_SetVertexBufferLengthEx(VertexBufferID, 0);
end;

//------------------------------------------------------------------------------
// Render()
// render a shadow vol
//------------------------------------------------------------------------------
procedure TShadowVolume.ShadowRender;
begin
  r_RenderVertexBufferEx(VertexBufferID);
end;

//-----------------------------------------------------------------------------
// Name: AddEdge()
// Desc: Adds an edge to a list of silohuette edges of a shadow volume.
//-----------------------------------------------------------------------------
procedure AddEdge(var pEdges: array of Word; var dwNumEdges: DWord; VectorA, VectorB: Word);
var
  i: Integer;
begin
  // Remove interior edges (which appear in the list twice)
  for i:= 0 to (dwNumEdges - 1) do
  begin
    if ((pEdges[2*i+0] = VectorA) and (pEdges[2*i+1] = VectorB)) or
       ((pEdges[2*i+0] = VectorB) and (pEdges[2*i+1] = VectorA)) then
    begin
      if (dwNumEdges > 1) then
      begin
        pEdges[2*i+0] := pEdges[2*(dwNumEdges-1)+0];
        pEdges[2*i+1] := pEdges[2*(dwNumEdges-1)+1];
        Dec(dwNumEdges);
        Exit;
      end;
    end;
  end;

  pEdges[2*dwNumEdges+0] := VectorA;
  pEdges[2*dwNumEdges+1] := VectorB;
  Inc(dwNumEdges);
end;

function TForm1.FtoDW(f: Single): DWORD;
begin
  Result:= PDWord(@f)^;
end;

//------------------------------------------------------------------------------
// BuildFromCollisionMesh()
// builds a shadow volume out of a mbdak 3 col model :D
//------------------------------------------------------------------------------
procedure TShadowVolume.BuildFromCollisionMesh(vCOLID: COLMODELS; vLight: Vector3D);
type
  //Tempörärer Vertextyp
  TMeshVertex = PACKED RECORD
    P: Vector3D;
    N: Vector3D;
  end;
var
  //Die Vertices der Model-Triangles
  pVertices:  Array of TMeshVertex;
  pEdges:     Array of Word;
  dwNumEdges: DWord;
  wFace0:     Word;
  wFace1:     Word;
  wFace2:     Word;
  VectorA, VectorB, VectorC, VectorD, VectorE, VectorF: Vector3D;
  vNormal:  Vector3D;
  I: Integer;
  K: Integer;
  FaceCount: Integer;
  VC: Vector3D;
  vDirection: Vector3D;
  vCOffset: Vector3D;
begin
    //At first, we have to go through all spheres and collect the containing triangles.
    FaceCount := 0;
    pVertices := nil;

    vDirection.X := vLight.x;
    vDirection.Y := vLight.y;
    vDirection.Z := vLight.Z;
    vDirection := NormalizeVector(vDirection);

    VC.x := vDirection.x * 6;
    VC.y := vDirection.y * 6;
    VC.z := vDirection.z * 6;

    VCOffset.x := 0.003 * vDirection.X;
    VCOffset.y := 0.003 * vDirection.Y;
    VCOffset.z := 0.003 * vDirection.Z;
                

    For I := 1 To vCOLID.SPHCount do
    begin
      //Now get all triangles together..
      For K := 1 To vCOLID.Spheres[I].TRICount do
      begin
        //Vertex-Buffer erstellen:
        SetLength (pVertices, (FaceCount * 3) + 3);
        VectorA := vCOLID.Spheres[I].Triangles[K].P1;
        VectorB := vCOLID.Spheres[I].Triangles[K].P2;
        VectorC := vCOLID.Spheres[I].Triangles[K].P3;

        VectorA := Vector3DSubtract(VectorA, VCOffset);
        VectorB := Vector3DSubtract(VectorB, VCOffset);
        VectorC := Vector3DSubtract(VectorC, VCOffset);

        pVertices[(FaceCount * 3) + 0].p := VectorA;
        pVertices[(FaceCount * 3) + 1].p := VectorB;
        pVertices[(FaceCount * 3) + 2].p := VectorC;
        FaceCount := FaceCount + 1;
      end;
    end;

    //create a temporary list of edges
    SetLength(pEdges, FaceCount*6);
    dwNumEdges:= 0;

    // For each face
    for i:= 0 to (FaceCount - 1) do
    begin
      wFace0 := 3*i+0;
      wFace1 := 3*i+1;
      wFace2 := 3*i+2;

      VectorA := pVertices[wFace0].p;
      VectorB := pVertices[wFace1].p;
      VectorC := pVertices[wFace2].p;

      // Check if some vertices are blittet together... in this case, we can add those vectors -> saves many ressources!
      //search orthogonal vector
      vNormal := Vector3DCross(Vector3DSubtract(VectorC, VectorB), Vector3DSubtract(VectorB, VectorA));

      if Vector3DDot(vNormal, vLight) >= 0.00 then
      begin
        //Die dem Licht zugewandeten Seiten bilden die Front-Cap
        AddEdge(pEdges, dwNumEdges, wFace0, wFace1);
        AddEdge(pEdges, dwNumEdges, wFace1, wFace2);
        AddEdge(pEdges, dwNumEdges, wFace2, wFace0);

        //Front-Cap hinzufügen (nur notwendig für depth-fail-method):
        r_AddVertexToBufferEx(VertexBufferID, VectorC);
        r_AddVertexToBufferEx(VertexBufferID, VectorB);
        r_AddVertexToBufferEx(VertexBufferID, VectorA);

        VectorD := Vector3DSubtract(VectorA, VC);
        VectorE := Vector3DSubtract(VectorB, VC);
        VectorF := Vector3DSubtract(VectorC, VC);

        //Back-Cap (die Punkte ins unendliche verlängern:
        r_AddVertexToBufferEx(VertexBufferID, VectorD);
        r_AddVertexToBufferEx(VertexBufferID, VectorE);
        r_AddVertexToBufferEx(VertexBufferID, VectorF);
     (*
     end
     else
     begin
        VectorD := Vector3DSubtract(VectorA, VC);
        VectorE := Vector3DSubtract(VectorB, VC);
        VectorF := Vector3DSubtract(VectorC, VC);

        //Back-Cap (die Punkte ins unendliche verlängern:
        r_AddVertexToBufferEx(VertexBufferID, VectorF);
        r_AddVertexToBufferEx(VertexBufferID, VectorE);
        r_AddVertexToBufferEx(VertexBufferID, VectorD);
     *)
     end;
    end;

    for I := 0 to (dwNumEdges - 1) do
    begin
      //Die Fläche in einen Raum erweitern: (den Shadow-Volume)
      //V1 = B
      //V2 = C
      //V3 = D
      //V4 = E
      VectorD := Vector3DSubtract(pVertices[pEdges[2*I+0]].p, VC);
      VectorE := Vector3DSubtract(pVertices[pEdges[2*I+1]].p, VC);

      VectorB := pVertices[pEdges[2*I+0]].p;
      VectorC := pVertices[pEdges[2*I+1]].p;

      r_AddVertexToBufferEx(VertexBufferID, VectorB);
      r_AddVertexToBufferEx(VertexBufferID, VectorC);
      r_AddVertexToBufferEx(VertexBufferID, VectorD);

      r_AddVertexToBufferEx(VertexBufferID, VectorC);
      r_AddVertexToBufferEx(VertexBufferID, VectorE);
      r_AddVertexToBufferEx(VertexBufferID, VectorD);
    end;
    SetLength(pEdges, 0);
end;

//------------------------------------------------------------------------------
// RenderShadow()
// render all shadow models
//------------------------------------------------------------------------------
function TForm1.RenderShadow: HResult;
 var I: Integer;
 var P1, P2: Vector3D;
begin
  //Z-Buffer-Schreiben deaktivieren und den Stencil-Buffer einschalten:
  r_SetRenderState(RS_ZWRITEENABLE,  0);
  r_SetRenderState(RS_STENCILENABLE, 1);

  //Ressourcen sparen, indem man den SHADE-Modus auf FLAT-Shading umschaltet:
  r_SetRenderState(RS_SHADEMODE,     SHADE_FLAT);

  //Den Stencil-Buffer so umstellen, dass der Vektor des "Auges" nur noch durch den z-Buffer blockiert werden kann:
  r_SetRenderState(RS_STENCILFUNC,  CMP_ALWAYS);
  r_SetRenderState(RS_STENCILPASS, STENCILOP_KEEP);
  r_SetRenderState(RS_STENCILFAIL,  STENCILOP_KEEP);

  //Bei Front- und Backfaces den Stencil-Buffer umschreiben:
  r_SetRenderState(RS_STENCILREF,       $1);
  r_SetRenderState(RS_STENCILMASK,      $ffffffff);
  r_SetRenderState(RS_STENCILWRITEMASK, $ffffffff);

  //Das ganze Schattenzeug darf nicht in den Frame-Buffer geschrieben werden!
  r_SetRenderState(RS_ALPHABLENDENABLE, 1);
  r_SetRenderState(RS_SRCBLEND,  BLEND_ZERO);
  r_SetRenderState(RS_DESTBLEND, BLEND_ONE);


  //use this line for depth-fail-shadow-variant
  r_SetRenderState(RS_STENCILZFAIL, STENCILOP_DECR);

  //Die Vorderseiten der Dreiecke rendern (dabei den Stencil-Buffer für jede Fläche erhöhen):
  If RenderTRShadows = True then
  begin
    For I := 1 To IPLCount do
    begin
      If (vIPL[I].vShowShadow = True) and (vIPL[I].vVisible = True) then
      begin
        P1.X := vIPL[I].vXPOS;
        P1.Y := vIPL[I].vYPOS;
        P1.Z := vIPL[I].vZPOS;

        vIPL[I].vShadowVlms.ShadowRender();
      end;
    end;
  end;
  If RenderACShadows = True then
  begin
    For I := 1 To PlayerCount do
    begin
      Players[I].vShadowVolume.ShadowRender();
    end;
  end;

  //Rückseiten rendern (Verdrehen des Vertex-Orders)
  r_SetRenderState(RS_CULLMODE,   CULL_CW);

  //use this line for delpth-fail-shadow-variant
  r_SetRenderState(RS_STENCILZFAIL, STENCILOP_INCR);

  //Rendern:
  P2.X := CameraPos.X;
  P2.Y := CameraPos.Y;
  P2.Z := CameraPos.Z;
  If RenderTRShadows = True then
  begin
    For I := 1 To IPLCount do
    begin
        If (vIPL[I].vShowShadow = True) and (vIPL[I].vVisible = True) then
        begin
          P1.X := vIPL[I].vXPOS;
          P1.Y := vIPL[I].vYPOS;
          P1.Z := vIPL[I].vZPOS;

          vIPL[I].vShadowVlms.ShadowRender();
        end;
    end;
  end;
  If RenderACShadows = True then
  begin
    For I := 1 To PlayerCount do
    begin
      Players[I].vShadowVolume.ShadowRender();
    end;
  end;

  r_SetRenderState(RS_CULLMODE,  CULL_CCW);

  //Den Renderstate zurücksetzen:
  r_SetRenderState(RS_SHADEMODE, SHADE_GOURAUD);
  r_SetRenderState(RS_ZWRITEENABLE,     1);
  r_SetRenderState(RS_STENCILENABLE,    0);
  r_SetRenderState(RS_ALPHABLENDENABLE, 0);

  Result := S_OK;
end;

//------------------------------------------------------------------------------
// DrawShadow()
// draw a grey shape over the stencil mask
//------------------------------------------------------------------------------
function TForm1.DrawShadow: HResult;
  var vDrawPosition: Vector3D;
begin
  //Renderstatus setzen:
    r_SetRenderState(RS_ZENABLE,          0);
    r_SetRenderState(RS_STENCILENABLE,    1);
    r_SetRenderState(RS_FOGENABLE,        0);

    //Halbtransparenz des Schatten aktivieren:

    r_SetRenderState(RS_ALPHABLENDENABLE, 1);
    r_SetRenderState(RS_SRCBLEND,  BLEND_SRCALPHA);
    r_SetRenderState(RS_DESTBLEND, BLEND_INVSRCALPHA);
    //Select Alpha-Channel from Texture
    r_SetTextureStageState(0, TSS_ALPHAARG2, TA_TEXTURE);

    //Schreibzugriffe auf Stencil-maskierte Bereiche setzen:
    r_SetRenderState(RS_STENCILREF,  $1);
    r_SetRenderState(RS_STENCILFUNC, CMP_LESSEQUAL);
    r_SetRenderState(RS_STENCILPASS, STENCILOP_KEEP);

    //Set up the Position of the grey wall:
    vDrawPosition.X := Players[ActivePlane].XPOS - Players[ActivePlane].HDistanceToCam  * 0.1  * sin(Players[ActivePlane].HWinkel * Pi180);
    vDrawPosition.Y := Players[ActivePlane].YPOS + Players[ActivePlane].VDistanceToCam;
    vDrawPosition.Z := Players[ActivePlane].ZPOS - Players[ActivePlane].HDistanceToCam * 0.1 * cos(Players[ActivePlane].HWinkel * Pi180);

    //use for the SkyBox-Object
    r_MatrixTranslation(vDrawPosition.X, vDrawPosition.Y, vDrawPosition.Z);
    r_MatrixRotation (Players[ActivePlane].HWinkel + 180, 0, 0);
    r_MatrixScaling(10, 10, 10);

    //set semi-transparent texture
    r_SetTexture(ShadowTexture);

    //Render a x-File with a semi-transparent-texture
    RenderModel3DEx(Skybox.vSkyBox3DModel);

    //Restore render states
    r_SetRenderState(RS_ZENABLE,          1 );
    r_SetRenderState(RS_STENCILENABLE,    0 );
    r_SetRenderState(RS_ALPHABLENDENABLE, 0 );

    r_SetTextureStageState(0, TSS_ALPHAARG2, TA_DIFFUSE);
  Result := S_OK;
end;

//------------------------------------------------------------------------------
// DrawRedHit()
// draw a red shape
//------------------------------------------------------------------------------
procedure TForm1.DrawRedHit;
  var vDrawPosition: Vector3D;
begin
  //Renderstatus setzen:
    r_SetRenderState(RS_ZENABLE,          0);
    r_SetRenderState(RS_FOGENABLE,        0);

    //Halbtransparenz des Schatten aktivieren:
    r_SetRenderState(RS_ALPHABLENDENABLE, 1);
    r_SetRenderState(RS_SRCBLEND,  BLEND_SRCALPHA);
    r_SetRenderState(RS_DESTBLEND, BLEND_INVSRCALPHA);
    //Select Alpha-Channel from Texture
    r_SetTextureStageState(0, TSS_ALPHAARG2, TA_TEXTURE);

    //Set up the Position of the grey wall:
    vDrawPosition.X := Players[ActivePlane].XPOS - Players[ActivePlane].HDistanceToCam  * 0.1  * sin(Players[ActivePlane].HWinkel * Pi180);
    vDrawPosition.Y := Players[ActivePlane].YPOS + Players[ActivePlane].VDistanceToCam;
    vDrawPosition.Z := Players[ActivePlane].ZPOS - Players[ActivePlane].HDistanceToCam * 0.1 * cos(Players[ActivePlane].HWinkel * Pi180);

    //use for the SkyBox-Object
    r_MatrixTranslation(vDrawPosition.X, vDrawPosition.Y, vDrawPosition.Z);
    r_MatrixRotation (Players[ActivePlane].HWinkel + 180, 0, 0);
    r_MatrixScaling(10, 10, 10);

    //set semi-transparent texture
    r_SetTexture(HitTexture);

    //Render a x-File with a semi-transparent-texture
    RenderModel3DEx(Skybox.vSkyBox3DModel);

    //Restore render states
    r_SetRenderState(RS_ZENABLE,          1 );
    r_SetRenderState(RS_FOGENABLE,        1 );
    r_SetRenderState(RS_ALPHABLENDENABLE, 0 );
    r_SetTextureStageState(0, TSS_ALPHAARG2, TA_DIFFUSE);
end;


//------------------------------------------------------------------------------
// BuildGenericCollisionSystem()
// builds a generic usable col model to save some transformations later
//------------------------------------------------------------------------------
procedure TForm1.BuildGenericCollisionSystem;
  var I: Integer;
  var K: Integer;
  var L: Integer;
  var vColID: Integer;
  var TempTriangle: Triangle3D;
  var TempVector: Vector3D;
  var Position: Vector3D;
begin
  //Wir erstellen hier praktisch ein generelles Kollisionsmodell.
  //Dieses hat u.a. den Vorteil, das die Yaw/Pitch/Roll nicht erst
  IF IPLCount > 0 then
  begin
    For I := 1 To IPLCount do
    begin
      If (vIPL[I].vCollision = True) or (vIPL[I].vColExcl = True) then 
      begin
        vColID := vIDE[vIPL[I].vIDE].vColID;
        If (COLMeshes[vColID].SPHCount > 0) and (vColID > 0) then
        begin
          vIPL[I].vColMDL.SPHCount := COLMeshes[vColID].SPHCount;
          SetLength ( vIPL[I].vColMDL.Spheres, vIPL[I].vColMDL.SPHCount + 1);
          For K := 1 To COLMeshes[vColID].SPHCount do
          begin
            //Koordinaten der Sphere übernehmen:
            TempVector := COLMeshes[vColID].Spheres[K].Point;
            //Yaw-Pitch-Roll miteinbeziehen:
            TempVector := Vector3DYawPitchRoll(TempVector, vIPL[I].vYaw, vIPL[I].vRoll, vIPL[I].vPitch);

            vIPL[I].vColMDL.Spheres[K].Point.X := vIPL[I].vXPOS + Trunc(TempVector.X * vIPL[I].vModelScale);
            vIPL[I].vColMDL.Spheres[K].Point.Y := vIPL[I].vYPOS + Trunc(TempVector.Y * vIPL[I].vModelScale);
            vIPL[I].vColMDL.Spheres[K].Point.Z := vIPL[I].vZPOS + Trunc(TempVector.Z * vIPL[I].vModelScale);

            //Radius:
            vIPL[I].vColMDL.Spheres[K].Radius := Trunc(COLMeshes[vColID].Spheres[K].Radius * vIPL[I].vModelScale);
            //Nun müssen alle Dreiecke überprüft werden:
            If COLMeshes[vColID].Spheres[K].TRICount > 0 then
            begin
              //Es gibt demnach Dreiecke...
              //Array erstellen:
              vIPL[I].vColMDL.Spheres[K].TRICount := COLMeshes[vColID].Spheres[K].TRICount;
              SetLength(vIPL[I].vColMDL.Spheres[K].Triangles, vIPL[I].vColMDL.Spheres[K].TRICount + 1);
              //Nun jedes Dreieck hinzufügen:
              //Wir übernehmen zuerst die
              For L := 1 To COLMeshes[vColID].Spheres[K].TRICount do
              begin
                TempTriangle := COLMeshes[vColID].Spheres[K].Triangles[L];
                TempTriangle := TriangleYawPitchRoll(TempTriangle, vIPL[I].vYaw, vIPL[I].vRoll, vIPL[I].vPitch);
                TempTriangle := ScaleTriangle(TempTriangle, vIPL[I].vModelScale);
                Position.X := vIPL[I].vXPOS;
                Position.Y := vIPL[I].vYPOS;
                Position.Z := vIPL[I].vZPOS;
                vIPL[I].vColMDL.Spheres[K].Triangles[L] := AddPointToTriangle(TempTriangle, Position);
                //Damit wäre alle Dreiecke kopiert...
              end; //Ende Dreiecksliste
            end; //Ende Anzahl-der-Dreiecke-Check

          end; //Ende SphereListe
        end; //Ende Anzahl-der-Sphere-Check

      end; //Ende des Objekt-Collision-Checks
    end; //Ende der IPL-Liste
  end;  //Ende der IPL-Count-Checkliste

  //Gut, die Prozedur wäre hiermit beendet. Wir können nun mithilfe dieses Collisionsmeshes das Schattenbild bauen.
end;

//------------------------------------------------------------------------------
// DrawFireSprite()
// renders a engine fire
//------------------------------------------------------------------------------
procedure TForm1.DrawFireSprite(vPlane: Integer; I: Integer);
begin
          r_SetTexture(FireTexture);
          r_MatrixTranslation(Players[vPlane].vSmogParticle[i].X, Players[vPlane].vSmogParticle[i].Y, Players[vPlane].vSmogParticle[i].Z);
          r_MatrixRotation (Players[vPlane].HWinkel +180, 0, 0);
          r_MatrixScaling(0.07, 0.07, 0.07);
          RenderModel3DEx (SkyBox.vSkyBox3DModel);
end;

//------------------------------------------------------------------------------
// Shoot_Timer()
// timer to control shoots
//------------------------------------------------------------------------------
procedure TForm1.Shoot_Timer1Timer(Sender: TObject);
begin
  Shoot_Timer1.Enabled := False;
end;

//------------------------------------------------------------------------------
// CreateShootByPlayer()
// creates a shoot by player
//------------------------------------------------------------------------------
procedure TForm1.CreateShootByPlayer(vPlane: Integer; vPosition: Vector3D; vBULRef: Integer);
  var vTurnedVec: Vector3D;
  var vShootVec:  Vector3D;
begin
    //Create a new Bullet
    LASCount := LASCount + 1;
    If LASCount > MAX_SHOTS then
    begin
      LASCount := 1;
    end;
    vLAS[LASCount].vBULID := vBULRef;
    vTurnedVec := Vector3DYawPitchRoll(vPosition, Players[vPlane].HWinkel, Players[vPlane].HAcceleration, Players[vPlane].VAcceleration);
    vLAS[LASCount].vXPOS := Players[vPlane].XPOS + vTurnedVec.X;
    vLAS[LASCount].vYPOS := Players[vPlane].YPOS + vTurnedVec.Y;
    vLAS[LASCount].vZPOS := Players[vPlane].ZPOS + vTurnedVec.Z;
    vShootVec.X := 0;
    vShootVec.Y := 0;
    vShootVec.Z := vBUL[vBULRef].vSpeed * -1;
    vShootVec := Vector3DYawPitchRoll(vShootVec, Players[vPlane].HWinkel, Players[vPlane].HAcceleration, Players[vPlane].VAcceleration);
    vLAS[LASCount].vDirection := vShootVec;
    vLAS[LASCount].vYaw := Players[vPlane].HWinkel;
    vLAS[LASCount].vPitch := Players[ActivePlane].VAcceleration;
    vLAS[LASCount].vActive := True;

end;

//------------------------------------------------------------------------------
// Timer_LightTimer()
// position lights
//------------------------------------------------------------------------------
procedure TForm1.Timer_LightTimer(Sender: TObject);
begin
  if Players[ActivePlane].vLightEnabled = True then
  begin
    Players[ActivePlane].vLightEnabled := False;
    r_EnableLight(Players[ActivePlane].vLight_Left_ID, FALSE);
    r_EnableLight (Players[ActivePlane].vLight_Right_ID, FALSE);
    Timer_Light.Interval := 1000;
  end
  else
  begin
    Players[ActivePlane].vLightEnabled := True;
    r_EnableLight (Players[ActivePlane].vLight_Left_ID, TRUE);
    r_EnableLight (Players[ActivePlane].vLight_Right_ID, TRUE);
    Timer_Light.Interval := 100;
  end;
end;

//------------------------------------------------------------------------------
// Timer_SpeedTimer()
// uuuuuuuuuuuuultra speed
//------------------------------------------------------------------------------
procedure TForm1.Timer_SpeedTimer(Sender: TObject);
begin
  If Timer_Speed.Tag = 1 then
  begin
    Timer_Speed.Tag := 0;
    Timer_Speed.Enabled := False;
    Timer_Speed.Interval := 2000;
    Exit;
  end;
  If Timer_Speed.Tag <> 1 then
  begin
    Timer_Speed.Tag := 1;
    Timer_Speed.Interval := 5000;
  end;
end;

//------------------------------------------------------------------------------
// IsFileInUse()
// hate write comments
//------------------------------------------------------------------------------
function TForm1.IsFileInUse(vName: String): Boolean;
var
  HFileRes: HFILE;
begin
  HFileRes := CreateFile(PChar(vName),
                         GENERIC_READ or GENERIC_WRITE,
                         0,
                         nil,
                         OPEN_EXISTING,
                         FILE_ATTRIBUTE_NORMAL,
                         0);
  RESULT := (HFileRes = INVALID_HANDLE_VALUE);
  If RESULT = False then CloseHandle(HFileRes);
end;


//------------------------------------------------------------------------------
// PlaySound()
// plays a sound
//------------------------------------------------------------------------------
procedure TForm1.PlaySound(SoundBuffer: Integer; Looped: Boolean);
begin
    If UseAudio = False then exit;
    If UseSounds = False then exit;

    //play sound
    a_PlayAudio(SoundBuffer, Looped);
    a_SetVolume(SoundBuffer, SoundVolume);
end;

//------------------------------------------------------------------------------
// CreateSoundBufferFromFile()
// loads a sound from file
//------------------------------------------------------------------------------
function TForm1.CreateSoundBufferFromFile(vFile: String): TAudio;
begin
      RESULT.Buffer := -1;
      RESULT.Default_Freq := 0;
      RESULT.Current_Freq := 0;
      If UseAudio = False then Exit;
      If UseSounds = False then Exit;
      //load sound
      RESULT.Buffer := a_CreateAudioBufferFromFile(vFile);
      RESULT.Default_Freq := a_GetFrequency(RESULT.Buffer);
      RESULT.Current_Freq := RESULT.Default_Freq;
end;

//------------------------------------------------------------------------------
// PlayMusic()
// plays a music buffer
//------------------------------------------------------------------------------
procedure TForm1.PlayMusic(SoundBuffer: Integer; Looped: Boolean);
begin
    If UseAudio = False then exit;
    If UseMusic = False then exit;

    //play sound
    a_PlayAudio(SoundBuffer, Looped);
    a_SetVolume(SoundBuffer, MusicVolume);
end;

//------------------------------------------------------------------------------
// CreateMusicBufferFromFile()
// loads a music file
//------------------------------------------------------------------------------
function TForm1.CreateMusicBufferFromFile(vFile: String): TAudio;
begin
      RESULT.Buffer := -1;
      RESULT.Default_Freq := 0;
      RESULT.Current_Freq := 0;
      If UseAudio = False then Exit;
      If UseMusic = False then Exit;
      //load sound
      RESULT.Buffer := a_CreateAudioBufferFromFile(vFile);
      RESULT.Default_Freq := a_GetFrequency(RESULT.Buffer);
      RESULT.Current_Freq := RESULT.Default_Freq;
end;


//------------------------------------------------------------------------------
// FlowMusic()
// mutes/increased a music slowly
//------------------------------------------------------------------------------
procedure TForm1.FlowMusic(SoundBuffer: Integer; Time: Integer; Down: Boolean; IsMusic: Boolean);
  var DeltaVol:   Integer;
  var TimeBuffer: Integer;
begin
  //set init volume
  if IsMusic = True then
  begin
    DeltaVol := MusicVolume;
  end
  else
  begin
    DeltaVol := SoundVolume;
  end;

  if Down = True then
  begin
    vTimerCurrentVol := DeltaVol;
    vTimerFinVol := 0;
  end
  else
  begin
    vTimerCurrentVol := 0;
    vTimerFinVol := DeltaVol;
  end;
  TimeBuffer := Timer_Audio_Flow.Interval;
  vTimerDown := Down;
  vTimerVolStep := DeltaVol * TimeBuffer / Time;
  vTimerValue := 0;
  vTimerMaxValue := Trunc(Time / TimeBuffer);
  vTimerChannel := SoundBuffer;
  Timer_Audio_Flow.Enabled := True;
end;

//------------------------------------------------------------------------------
// Timer_Audio_FlowTimer()
// help timer for audio flow
//------------------------------------------------------------------------------
procedure TForm1.Timer_Audio_FlowTimer(Sender: TObject);
begin
  //flow music
  vTimerValue := vTimerValue + 1;
  If vTimerDown = True then
  begin
    vTimerCurrentVol := vTimerCurrentVol - vTimerVolStep;
    if vTimerCurrentVol < 0 then
    begin
      vTimerCurrentVol := 0;
    end;
  end
  else
  begin
    vTimerCurrentVol := vTimerCurrentVol - vTimerVolStep;
  end;

  if vTimerValue >= vTimerMaxValue then
  begin
    //stop audio buffer,
    //disable timer
    If vTimerDown = True then
    begin
      vTimerCurrentVol := vTimerFinVol;
      //can be changed if needed
      if vTimerFinVol = 0 then
      begin
        a_StopAudioBuffer(vTimerChannel);
      end;
    end
    else
    begin
      vTimerCurrentVol := vTimerFinVol;
    end;
    Timer_Audio_Flow.Enabled := False;
  end;
  //save audio volume
  a_SetVolume(vTimerChannel, Trunc(vTimerCurrentVol));
end;


//------------------------------------------------------------------------------
// GetIP()
// returns ip addr of current machine - required to have an specific filename
//------------------------------------------------------------------------------
function TForm1.GetIP: String;
type
  TaPInAddr = array[0..10] of PInAddr;
  PaPInAddr = ^TaPInAddr;
var
  PHE: PHostEnt;
  PPTR: PaPInAddr;
  Buffer: array[0..63] of Char;
  I: Integer;
  GInitData: TWSAData;
begin
  WSAStartup($101, GInitData);
  Result := '';
  GetHostName(Buffer, SizeOf(Buffer));
  PHE := GetHostByName(buffer);

  if PHE = nil then Exit;

  PPTR := PaPInAddr(PHE^.h_addr_list);
  I    := 0;

  while PPTR^[I] <> nil do
  begin
    Result := Result + Inet_Ntoa(PPTR^[I]^) + '.';
    Inc(I);
  end;


  WSACleanup;
end;

//------------------------------------------------------------------------------
// Timer_ExplodeTimer()
// timer witch manages to explode the aircraft
//------------------------------------------------------------------------------
procedure TForm1.Timer_ExplodeTimer(Sender: TObject);
begin
  Timer_Explode.Enabled := False;
  ExplodeAirCraft(ActivePlane);
end;

end.
