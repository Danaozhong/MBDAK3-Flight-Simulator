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

MBDAK3 // Structures

*)
unit Structures;

interface

//============================================================================
// predefined structures
//============================================================================
type
  // math
  Vector3D= RECORD
    X: Single;
    Y: Single;
    Z: Single;
  end;

  Vector3DInt= RECORD
    X: Integer;
    Y: Integer;
    Z: Integer;
  end;

  Vector2D= RECORD
    X: Single;
    Y: Single;
  end;

  Plane3D= RECORD
    N: Vector3D;
    D: Single;
  end;

  Triangle3D= RECORD
    P1: Vector3D;
    P2: Vector3D;
    P3: Vector3D;
  end;

  Vertex3D = RECORD
    X,Y,Z:    Single;
    NX,NY,NZ: Single;
    TU, TV:   Single;
  END;

  TSingle3X3 = Array[0..2] of Array[0..2] of Single;
  TSingle3   = Array[0..2] of Single;
  TSingle4   = Array[0..3] of Single;
  TWord3     = Array[0..2] of Word;

  TriangleEx3D = RECORD
    VertexIndices:  TWord3;
  END;

  Group3D = RECORD
    //render references
    VertexBuffer:     Integer;
    Material:         Integer;

    //internal structure references (can be manipulated)
    MaterialIndex        : Byte;
    nTriangles           : Word;
    TriangleIndices      : Array of Word;
  END;

  Materials3D = RECORD
    Texture: Integer;
    //space for other datas
  end;

  Sphere3DRef = RECORD
      vIPLRef:    Integer;
      vSphereRef: Integer;
  end;

  TreeBox = RECORD
    Spheres: Array of Sphere3DRef;
    SphereCount: Integer;
  end;

  Octree3D = RECORD
    XCount, YCount, ZCount: Integer;
    XDiff, YDiff,  ZDiff: Single;
    SubTrees: Array Of Array Of Array Of TreeBox;
    GlobalSpheres: Array of Sphere3DRef;
    GlobalSphereCount: Integer;
  end;

  //collision sphere/triangle combos
  Sphere3D= RECORD
    Point: Vector3D;
    Radius: Single;
    TRICount: LongInt;
    Triangles: Array of Triangle3D;
  end;

  //all col models
  COLMODELS =  RECORD
    SPHCount: LongInt;
    Spheres: Array of Sphere3D;
  end;

  TAudio = PACKED RECORD
    Buffer: Integer;
    Default_Freq, Current_Freq: Integer;
  END;
  //render mode when initialising the render device
  RenderMode = RECORD
    vWindowed:    Boolean;
    vUseTnL:      Boolean;
    ScreenWidth:  Integer;
    ScreenHeight: Integer;
    ColorDepth:   Integer;
    StencilBits:  Integer;
    WindowHWND:   Integer;
  end;

  //scene data informations
  SceneArguments = RECORD
    vRad:               Single;
    vFormat:            Single;
    vNearClippingPlane: Single;
    vFarClippingPlane:  Single;
    vFogEnabled:        Boolean;
    vFogBegin:          Single;
    vFogColor:          Cardinal;
  end;

  Camera = RECORD
        X:  Real;
        Y:  Real;
        Z:  Real;
        AX: Real;
        AY: Real;
        AZ: Real;
        RX: Real;
        RY: Real;
        RZ: Real;
  END;

  //sprite render mode
  SpriteMode = RECORD
    Texture:  Integer;
    Left:     Integer;
    Top:      Integer;
    Width:    Integer;
    Height:   Integer;
    Right:    Integer;
    Bottom:   Integer;
    Color:    Cardinal;
    Rotation: Single;
    ScaleX, ScaleY: Single;
  end;

  T3DColor = RECORD
    R: Single;
    G: Single;
    B: Single;
    A: Single;
  end;

  //light mode information
  LightMode = RECORD
    Diffuse:  T3DColor;
    Ambient:  T3DColor;
    Specular: T3DColor;
    Range:    Single;
    Attenuation0, Attenuation1, Attenuation2: Single;
    LightMode: Integer;
    Direction: Vector3D;
  end;


  //============================================================================
  //3d device subs - external load (allows changing the 3d api (Glide, OpenGL, Direct3D)
  //============================================================================

  //order functions of the 3d device
  function r_Init(Mode: RenderMode): Integer; stdcall; external '3ddrv.dll';
  procedure r_DeviceCleanUp(); stdcall; external '3ddrv.dll';
  procedure r_BeginScene(ViewPosition: Camera); stdcall; external '3ddrv.dll';
  procedure r_EndScene(); stdcall; external '3ddrv.dll';
  procedure r_SetRenderState(State: Cardinal; Mode: Cardinal); stdcall; external '3ddrv.dll';
  procedure r_SetTextureStageState(Stage: Cardinal; State: Cardinal; Mode: Cardinal); stdcall; external '3ddrv.dll';
  procedure r_ClearBackBuffer(Stencil: Boolean); stdcall; external '3ddrv.dll';
  procedure r_RestoreScene(); stdcall; external '3ddrv.dll';
  procedure r_InitScene(Mode: SceneArguments); stdcall; external '3ddrv.dll';

  //simple, primitive vertex buffer functions
  function r_CreateVertexBufferEx: Integer; stdcall; external '3ddrv.dll';
  procedure r_AddVertexToBufferEx(Buffer: Integer; Vertex: Vector3D); stdcall; external '3ddrv.dll';
  procedure r_SetVertexBufferLengthEx(Buffer: Integer; NewLength: Integer); stdcall; external '3ddrv.dll';
  procedure r_RenderVertexBufferEx(ID: Integer); stdcall; external '3ddrv.dll';

  //hardware stored vertex buffers (supports textures & is hw stored)
  function r_CreateVertexBuffer(Size: Word): Integer; stdcall; external '3ddrv.dll';
  procedure r_AddVerticesToBuffer(ID: Integer; Vertices: Array Of Vertex3D); stdcall; external '3ddrv.dll';
  procedure r_RenderVertexBuffer(ID: Integer); stdcall; external '3ddrv.dll';

  //light functions
  function r_CreateLight(Mode: LightMode): Integer; stdcall; external '3ddrv.dll';
  procedure r_EnableLight(Light: Integer; Enabled: Boolean); stdcall; external '3ddrv.dll';
  procedure r_UpdateLightPosition(ID: Integer; Position: Vector3D); stdcall; external '3ddrv.dll';
  procedure r_SetLight(Light: Integer); stdcall; external '3ddrv.dll';

  //texture and sprite functions
  function r_CreateTextureFromFileEx(Path: PChar; vWidth: Integer; vHeight: Integer; vColorKey: Cardinal): Integer; stdcall; external '3ddrv.dll';
  function r_CreateTextureFromFile(Path: PChar): Integer; stdcall; external '3ddrv.dll';
  procedure r_SetTexture(TextureID: Integer); stdcall; external '3ddrv.dll';
  procedure r_DrawSprite(Mode: SpriteMode); stdcall; external '3ddrv.dll';
  procedure r_StartSprites(); stdcall;  external '3ddrv.dll';
  procedure r_EndSprites(); stdcall; external '3ddrv.dll';

  //matrix move orders
  procedure r_MatrixTranslation(X: Single; Y: Single; Z: Single); stdcall; external '3ddrv.dll';
  procedure r_MatrixScaling(X: Single; Y: Single; Z: Single); stdcall; external '3ddrv.dll';
  procedure r_MatrixRotation(Yaw: Single; Pitch: Single; Roll: Single); stdcall; external '3ddrv.dll';

  //audio subs - external load (allows changing of the audio device)
  procedure a_InitAudio(); stdcall; external 'sub_audio.dll';
  procedure a_AudioCleanUp(); stdcall; external 'sub_audio.dll';
  procedure a_PlayAudio(SoundBuffer: Integer; Looped: Boolean); stdcall; external 'sub_audio.dll';
  function a_CreateAudioBufferFromFile(vFile: String): Integer; stdcall; external 'sub_audio.dll';
  procedure a_StopAudioBuffer(SoundBuffer: Integer); stdcall; external 'sub_audio.dll';
  procedure a_SetFrequency(SoundBuffer: Integer; Freq: Integer); stdcall; external 'sub_audio.dll';
  function a_GetFrequency(SoundBuffer: Integer): Integer; stdcall; external 'sub_audio.dll';
  procedure a_SetVolume(SoundBuffer: Integer; Volume: Integer); stdcall; external 'sub_audio.dll';
  function a_CheckIfAudioBufferIsPlayed(SoundBuffer: Integer): Boolean; stdcall; external 'sub_audio.dll';

implementation

end.
