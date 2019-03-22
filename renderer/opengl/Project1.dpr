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
*)
library Render_OpenGL;
uses
  SysUtils,
  Classes,
  Windows,
  Messages,
  Variants,
  Graphics,
  Controls,
  dglOpenGL,
  glBitmap;

type
  //============================================================================
  // predefined structures
  //============================================================================
  Vector3D= RECORD
    X: Single;
    Y: Single;
    Z: Single;
  end;

  Vector4D= RECORD
    X: Single;
    Y: Single;
    Z: Single;
    W: Single;
  end;

  Vertex3D = RECORD
    Position: Vector3D;
    Normals:  Vector3D;
    TU, TV:   Single;
  END;

  T3DColor = RECORD
    R: Single;
    G: Single;
    B: Single;
    A: Single;
  end;

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
    vFogDensity:        Single;
  end;

  //Kameraposition
  Camera = RECORD
    X:  Single;
    Y:  Single;
    Z:  Single;
    AX: Single;
    AY: Single;
    AZ: Single;
    RX, RY, RZ: Single;
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

  //light mode information
  LightMode = RECORD
    Diffuse:  T3DColor;
    Ambient:  T3DColor;
    Specular: T3DColor;
    Range:    Single;
    Attenuation0, Attenuation1, Attenuation2: Single;
    LightMode: Integer;
    Direction: Vector3D;
    Position:  Vector3D;
  end;

  //basic primitive mesh list
  VerticesList = RECORD
    vVertices: Array of Vector3D;
    m_dwNumVertices: DWORD;
  end;

  //the directx vertex buffers
  VertexBuffer3D = RECORD
    Vertices: Array of RECORD
      Position: Vector3D;
      Normals:  Vector3D;
      TU, TV:   Single;
    end;
    TriangleCount:  Word;
  end;

  Light3D = RECORD
    Position: Vector4D;
    Ambient : T3DColor;
    Diffuse : T3DColor;
    Emissive: T3DColor;
    Specular: T3DColor;
    Range: Single;
    Attenuation0,
    Attenuation1,
    Attenuation2: Single;
  end;
const
  Pi180 = Pi/180.0;

  //all renderstates:
  //=================
  RS_ZENABLE                   = 7;    (* D3DZBUFFERTYPE (or TRUE/FALSE for legacy) *)
  RS_FILLMODE                  = 8;    (* D3DFILLMODE *)
  RS_SHADEMODE                 = 9;    (* D3DSHADEMODE *)
  RS_LINEPATTERN               = 10;   (* D3DLINEPATTERN *)
  RS_ZWRITEENABLE              = 14;   (* TRUE to enable z writes *)
  RS_ALPHATESTENABLE           = 15;   (* TRUE to enable alpha tests *)
  RS_LASTPIXEL                 = 16;   (* TRUE for last-pixel on lines *)
  RS_CULLMODE                  = 22;   (* D3DCULL *)
  RS_SRCBLEND                  = 19;   (* D3DBLEND *)
  RS_DESTBLEND                 = 20;   (* D3DBLEND *)
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

  //procedure glBindTexture(target: GLenum; texture: GLuint); stdcall; external opengl32;

  var

  //OpenGL-Variablen:
  //==================

  h_DC   : HDC;                      // Device Context
  h_RC   : HGLRC;                    // OpenGL Rendering Context

  InitConfig:         RenderMode;
  SceneConfig:        SceneArguments;
  

  vTextures:           Array of TglBitmap2D;
  TextureCount:       LongInt;

  Lights:             Array of Light3D;
  LightCount:         LongInt;

  PRIMeshes:          Array of VerticesList;
  PRICount:           LongInt;

  VertexBuffers:      Array of VertexBuffer3D;
  VertexBufferCount:  LongInt;

  vHande: Integer;
  //helper vars for the Renderstates:
  vSRCBlend: Cardinal;
  vDSTBlend: Cardinal;
  vAlphaRef: Single;
  vAlphaFunc: Cardinal;
  vStencilPass: Cardinal;
  vStencilFail: Cardinal;
  vStencilZFail: Cardinal;

  vStencilRef:  Cardinal;
  vStencilMask: Cardinal;
  vStencilFunc: Cardinal;
  
  LightAmbient : array[0..3] of Single = (0.2, 0.2, 0.2, 1);
  LightDiffuse : array[0..3] of Single = (1.0, 0.6, 0.5, 1);
  LightSpecular: array[0..3] of Single = (1.0, 1.0, 1.0, 1);
  LightDirection:array[0..3] of Single = (1.0, 2.0, 1.0, 0);
  //LightPosition: array[0..3] of Single = (0.0, 10.0, 0.0,1);


//==============================================================================
// Non-public-functions
//==============================================================================

//------------------------------------------------------------------------------
// FtoDW()
// Converts a Float to a DWord
//------------------------------------------------------------------------------
function FtoDW(f: Single): DWORD; stdcall;
begin
  Result:= PDWord(@f)^;
end;

//==============================================================================
// Public-functions
//==============================================================================

//------------------------------------------------------------------------------
// r_SetTexture()
// sets a texture
//------------------------------------------------------------------------------
procedure r_SetTexture(TextureID: Integer); stdcall;
begin
  If TextureID > 0 then
    vTextures[TextureID].Bind();
end;

//------------------------------------------------------------------------------
// r_CreateTextureFromFileEx()
// Creates a texture buffer
//------------------------------------------------------------------------------
function r_CreateTextureFromFileEx(Path: PChar; vWidth: Integer; vHeight: Integer; vColorKey: Cardinal): Integer; stdcall;
var
  Color: LongInt;
  R, G, B: Byte;
begin
    If FileExists(Path) = True then
    begin
      Inc(TextureCount);
      SetLength(vTextures, TextureCount + 1);

      vTextures[TextureCount] := TGLBitmap2D.Create;
      
      Color := ColorToRGB(vColorKey);
      R := Color;
      G := Color SHR 8;
      B := Color SHR 16;
      vTextures[TextureCount].LoadFromFile(Path);

      if vTextures[TextureCount] = nil then
      begin
        RESULT := -1;
        Exit;
      end;

      vTextures[TextureCount].AddAlphaFromColorKey(R, G, B);

      //assign default texture filters
      vTextures[TextureCount].SetFilter(GL_LINEAR, GL_LINEAR);
      vTextures[TextureCount].SetWrap(GL_REPEAT, GL_REPEAT, GL_REPEAT);
      vTextures[TextureCount].GenTexture(False);

      RESULT := TextureCount;
    end
    else
    begin
      RESULT := -1;
    end;
end;

//------------------------------------------------------------------------------
// r_CreateTextureFromFile()
// Creates a texture buffer
//------------------------------------------------------------------------------
function r_CreateTextureFromFile(Path: PChar): Integer; stdcall;
begin
    If FileExists(Path) = True then
    begin
      Inc(TextureCount);
      SetLength(vTextures, TextureCount + 1);
      vTextures[TextureCount] := TglBitmap2D.Create();
      vTextures[TextureCount].LoadFromFile(Path);

      if vTextures[TextureCount] = nil then
      begin
        RESULT := -1;
        Exit;
      end;
      vTextures[TextureCount].SetFilter(GL_NEAREST_MIPMAP_NEAREST, GL_LINEAR); //GL_LINEAR, GL_LINEAR);
      vTextures[TextureCount].SetWrap(GL_REPEAT, GL_REPEAT, GL_REPEAT);
      vTextures[TextureCount].GenTexture(False);
      RESULT := TextureCount;
    end
    else
    begin
      RESULT := -1;
    end;

end;

//------------------------------------------------------------------------------
// r_MatrixTranslation()
// set up position of the matrix
//------------------------------------------------------------------------------
procedure r_MatrixTranslation(X: Single; Y: Single; Z: Single); stdcall;
begin
  glPopMatrix;
  glPushMatrix;
  glTranslatef(Z, Y, X);
end;

//------------------------------------------------------------------------------
// r_MatrixRotation()
// rotates a matrix
//------------------------------------------------------------------------------
procedure r_MatrixRotation(Yaw: Single; Pitch: Single; Roll: Single); stdcall;
begin
  glRotatef(Yaw, 0.0, -1.0, 0.0);
  glRotatef(Pitch, 0.0, 0.0, -1.0);
  glRotatef(Roll, -1.0, 0.0, 0.0);
end;

//------------------------------------------------------------------------------
// r_MatrixScaling()
// scales a matrix
//------------------------------------------------------------------------------
procedure r_MatrixScaling(X: Single; Y: Single; Z: Single); stdcall;
begin
  glScalef(Z, Y, X);
end;


//------------------------------------------------------------------------------
// r_CreateVertexBufferEx()
// creates a facile vertex buffer
//------------------------------------------------------------------------------
function r_CreateVertexBufferEx: Integer; stdcall;
begin
  Inc(PRICount);
  SetLength(PRIMeshes, PRICount+1);
  RESULT := PRICount;
end;

//------------------------------------------------------------------------------
// r_SetVertexBufferLengthEx()
// sets the size of the easy vertex-buffer
//------------------------------------------------------------------------------
procedure r_SetVertexBufferLengthEx(Buffer: Integer; NewLength: Integer); stdcall;
begin
  PRIMeshes[Buffer].m_dwNumVertices := NewLength;
  SetLength(PRIMeshes[Buffer].vVertices, NewLength);
end;

//------------------------------------------------------------------------------
// r_AddVertexToBufferEx()
// adds a vertex to the buffer
//------------------------------------------------------------------------------
procedure r_AddVertexToBufferEx(Buffer: Integer; Vertex: Vector3D); stdcall;
begin
  SetLength(PRIMeshes[Buffer].vVertices, PRIMeshes[Buffer].m_dwNumVertices + 1);
  PRIMeshes[Buffer].vVertices[PRIMeshes[Buffer].m_dwNumVertices].X := Vertex.Z;
  PRIMeshes[Buffer].vVertices[PRIMeshes[Buffer].m_dwNumVertices].Y := Vertex.Y;
  PRIMeshes[Buffer].vVertices[PRIMeshes[Buffer].m_dwNumVertices].Z := Vertex.X;
  Inc(PRIMeshes[Buffer].m_dwNumVertices);
end;

//------------------------------------------------------------------------------
// r_RenderVertexBufferEx()
// renders the primitive vertices
//------------------------------------------------------------------------------
procedure r_RenderVertexBufferEx(ID: Integer); stdcall;
  var I: Integer;
begin
  glBegin(GL_TRIANGLES);
  for I := 0 to PRIMeshes[ID].m_dwNumVertices - 1 do
  begin
    glVertex3fv(@PRIMeshes[ID].vVertices[I]);
  end;
  glEnd();
end;

//------------------------------------------------------------------------------
// r_CreateVertexBuffer()
// creates an advanced vertex-buffer (support of textures)
//------------------------------------------------------------------------------
function r_CreateVertexBuffer(Size: Word): Integer; stdcall;
begin
  Inc(VertexBufferCount);
  SetLength(VertexBuffers, VertexBufferCount + 1);
  VertexBuffers[VertexBufferCount].TriangleCount := Size;
  SetLength(VertexBuffers[VertexBufferCount].Vertices, Size + 1);
  RESULT := VertexBufferCount;
end;

//------------------------------------------------------------------------------
// r_AddVerticesToBuffer()
// adds vertices to the extended buffer
//------------------------------------------------------------------------------
procedure r_AddVerticesToBuffer(ID: Integer; tVertices: Array Of Vertex3D); stdcall;
  var I: Integer;
begin
  For I := 0 to VertexBuffers[ID].TriangleCount - 1 do
  begin
      //we need to reverse mirror by the x and the z pos cause opengl is
      //a left-handed coordinate system
      VertexBuffers[ID].Vertices[I].Position.X := tVertices[I].Position.Z;
      VertexBuffers[ID].Vertices[I].Position.Y := tVertices[I].Position.Y;
      VertexBuffers[ID].Vertices[I].Position.Z := tVertices[I].Position.X;
      VertexBuffers[ID].Vertices[I].Normals.X := tVertices[I].Normals.Z;
      VertexBuffers[ID].Vertices[I].Normals.Y := tVertices[I].Normals.Y;
      VertexBuffers[ID].Vertices[I].Normals.Z := tVertices[I].Normals.X;
      VertexBuffers[ID].Vertices[I].TU := tVertices[I].TU;
      VertexBuffers[ID].Vertices[I].TV := tVertices[I].TV;
  end;
end;

//------------------------------------------------------------------------------
// r_RenderVertexBuffer()
// renders an extended vertex buffer
//------------------------------------------------------------------------------
procedure r_RenderVertexBuffer(ID: Integer); stdcall;
  var I:              Integer;
begin
  glBegin(GL_TRIANGLES);
  For I := 0 To VertexBuffers[ID].TriangleCount - 1 do
  begin
      glNormal3fv(@VertexBuffers[ID].Vertices[I].Normals);
      glTexCoord2f(VertexBuffers[ID].Vertices[I].TU, VertexBuffers[ID].Vertices[I].TV);
      glVertex3fv(@VertexBuffers[ID].Vertices[I].Position);
  end;
  glEnd();
end;

//------------------------------------------------------------------------------
// r_ClearBackBuffer()
// cleans the backbuffer
//------------------------------------------------------------------------------
procedure r_ClearBackBuffer(Stencil: Boolean); stdcall;
begin
  glClearColor(0,0,0,0);
  If Stencil = True then
  begin
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);
  end
  else
  begin
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  end;
  glLoadIdentity;
end;

//------------------------------------------------------------------------------
// r_RestoreScene()
// called when the window lost focus
//------------------------------------------------------------------------------
procedure r_RestoreScene(); stdcall;
begin
      //D3DDevice8.Reset(D3DPP);
      //r_InitScene(SceneConfig);

end;

//------------------------------------------------------------------------------
// r_EndScene()
// scene is complete, flip!
//------------------------------------------------------------------------------
procedure r_EndScene(); stdcall;
begin
  glPopMatrix;
  //Blitten
  SwapBuffers(h_DC);
end;

//------------------------------------------------------------------------------
// r_CreateLight()
// Creates a new light
//------------------------------------------------------------------------------
function r_CreateLight(Mode: LightMode): Integer; stdcall;
begin
  Inc(LightCount);
  SetLength(Lights, LightCount + 1);

  with Lights[LightCount] do
  begin
    Specular := Mode.Specular;
    Ambient := Mode.Ambient;
    Diffuse := Mode.Diffuse;
    Range := Mode.Range;
    Attenuation0 := Mode.Attenuation0;
    Attenuation1 := Mode.Attenuation1;
    Attenuation2 := Mode.Attenuation2;
    Position.X := Mode.Position.X;
    Position.Y := Mode.Position.Y;
    Position.Z := Mode.Position.Z;
    If Mode.LightMode = 101 then Position.W := 1       //POINT Light
    else if Mode.LightMode = 102 then Position.W := 0; //DIRECTIONAL Light
  end;
  RESULT := LightCount;
end;

//------------------------------------------------------------------------------
// ReturnLightCardinal()
// Returns an ID of a light
//------------------------------------------------------------------------------
function ReturnLightCardinal(Light: Integer): Integer; stdcall;
begin
  If Light = 1 then RESULT := GL_LIGHT0
  else if Light = 2 then RESULT := GL_LIGHT1
  else if Light = 3 then RESULT := GL_LIGHT2
  else if Light = 4 then RESULT := GL_LIGHT3
  else if Light = 5 then RESULT := GL_LIGHT4
  else if Light = 6 then RESULT := GL_LIGHT5
  else if Light = 7 then RESULT := GL_LIGHT6
  else if Light = 8 then RESULT := GL_LIGHT7
  else RESULT := -1;
end;

//------------------------------------------------------------------------------
// EnableLight()
// Switches a light on/off
//------------------------------------------------------------------------------
procedure r_EnableLight(Light: Integer; Enabled: Boolean); stdcall;
  var CardLightID: Integer;
begin
  CardLightID := ReturnLightCardinal(Light);
  If CardLightID = -1 then Exit;

  If Enabled = True then
  begin
    glEnable(CardLightID);
  end
  else
  begin
    glDisable(CardLightID);
  end;
end;

//------------------------------------------------------------------------------
// r_UpdateLightPosition()
// updates the position of a light
//------------------------------------------------------------------------------
procedure r_UpdateLightPosition(ID: Integer; Position: Vector3D); stdcall;
begin
  Lights[ID].Position.X := Position.Z;
  Lights[ID].Position.Y := Position.Y;
  Lights[ID].Position.Z := Position.X;
end;

//------------------------------------------------------------------------------
// r_SetLightPosition()
// updates the light position of a scene
//------------------------------------------------------------------------------
procedure r_SetLightPosition(Light: Integer); stdcall;
  var CardLightID: Integer;
begin
  CardLightID := ReturnLightCardinal(Light);
  If CardLightID = -1 then Exit;
  glLightfv(CardLightID, GL_POSITION, @Lights[Light].Position);
end;

//------------------------------------------------------------------------------
// r_SetLight()
// installs a light in the scene
//------------------------------------------------------------------------------
procedure r_SetLight(Light: Integer); stdcall;
  var CardLightID: Integer;
begin
  CardLightID := ReturnLightCardinal(Light);
  If CardLightID = -1 then Exit;
  glLightfv(CardLightID, GL_AMBIENT, @Lights[Light].Ambient);
  glLightfv(CardLightID, GL_DIFFUSE, @Lights[Light].Diffuse);
  glLightfv(CardLightID, GL_SPECULAR, @Lights[Light].Specular);
  glLightfv(CardLightID, GL_CONSTANT_ATTENUATION, @Lights[Light].Attenuation0);
  glLightfv(CardLightID, GL_LINEAR_ATTENUATION, @Lights[Light].Attenuation1);
  glLightfv(CardLightID, GL_QUADRATIC_ATTENUATION, @Lights[Light].Attenuation2);
  r_SetLightPosition(Light);
end;

//------------------------------------------------------------------------------
// r_BeginScene()
// scene's beginning!
//------------------------------------------------------------------------------
procedure r_BeginScene(ViewPosition: Camera); stdcall;
  var I: Integer;
begin
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  gluLookAt(ViewPosition.Z, ViewPosition.Y, ViewPosition.X,
      ViewPosition.AZ, ViewPosition.AY, ViewPosition.AX,
      ViewPosition.RZ, ViewPosition.RY, ViewPosition.RX);

  For I := 1 To LightCount - 1 do
  begin
    r_SetLightPosition(I);
  end;
  glPushMatrix;
  glEnable(GL_TEXTURE_2D);
  
end;

//------------------------------------------------------------------------------
// r_SetRenderState()
// sets up a renderstate
//------------------------------------------------------------------------------
procedure r_SetRenderState(State: Cardinal; Mode: Cardinal); stdcall;
begin
  //transform the most important renderstates
  case State of
    RS_ZENABLE:
      If Mode = 1 then glEnable(GL_DEPTH_TEST) else glDisable(GL_DEPTH_TEST);
    RS_LIGHTING:
      If Mode = 1 then glEnable(GL_LIGHTING) else glDisable(GL_LIGHTING);
    RS_ZFUNC:
      If Mode = CMP_LESSEQUAL then
        glDepthFunc(GL_LEQUAL)
      else if Mode = CMP_LESS then
        glDepthFunc(GL_LESS)
      else if Mode = CMP_EQUAL then
        glDepthFunc(GL_EQUAL)
      else if Mode = CMP_GREATER then
        glDepthFunc(GL_GREATER)
      else if Mode = CMP_NOTEQUAL then
        glDepthFunc(GL_NOTEQUAL)
      else if Mode = CMP_GREATEREQUAL then
        glDepthFunc(GL_GEQUAL)
      else if Mode = CMP_NEVER then
        glDepthFunc(GL_NEVER)
      else if Mode = CMP_ALWAYS then
        glDepthFunc(GL_ALWAYS);
    RS_STENCILENABLE:
      If Mode = 1 then glEnable(GL_STENCIL_TEST) else glDisable(GL_STENCIL_TEST);
    RS_CULLMODE:
      If Mode = CULL_CCW then
        glFrontFace(GL_CCW)
      else if Mode = CULL_CW then
        glFrontFace(GL_CW)
      else if Mode = CULL_NONE then
         glEnable(GL_CULL_FACE);
    RS_ALPHABLENDENABLE:
      If Mode = 1 then glEnable(GL_BLEND) else glDisable(GL_BLEND);
    RS_ALPHATESTENABLE:
       If Mode = 1 then glEnable(GL_ALPHA_TEST) else glDisable(GL_ALPHA_TEST);
    RS_SHADEMODE:
      If Mode = SHADE_FLAT then
        glShadeModel(GL_FLAT)
      else If Mode = SHADE_GOURAUD then
        glShadeModel(GL_SMOOTH);
    RS_SRCBLEND:
      begin
        if Mode = BLEND_ZERO then
          vSRCBlend := GL_ZERO
        else if Mode = BLEND_ONE then
          vSRCBlend := GL_ONE
        else if Mode = BLEND_SRCCOLOR then
          vSRCBlend := GL_SRC_COLOR
        else if Mode = BLEND_INVSRCCOLOR then
          vSRCBlend := GL_ONE_MINUS_SRC_COLOR
        else if Mode = BLEND_SRCALPHA then
          vSRCBlend := GL_SRC_ALPHA
        else if Mode = BLEND_INVSRCALPHA then
          vSRCBlend := GL_ONE_MINUS_SRC_ALPHA
        else if Mode = BLEND_DESTALPHA then
          vSRCBlend := GL_DST_ALPHA
        else if Mode = BLEND_INVDESTALPHA then
          vSRCBlend := GL_ONE_MINUS_DST_ALPHA
        else if Mode = BLEND_DESTCOLOR then
          vSRCBlend := GL_DST_COLOR
        else if Mode = BLEND_INVDESTCOLOR then
          vSRCBlend := GL_ONE_MINUS_DST_COLOR
        else if Mode = BLEND_SRCALPHASAT then
          vSRCBlend := GL_SRC_ALPHA_SATURATE;
        glBlendFunc(vSRCBlend, vDSTBlend);
      end;
    RS_DESTBLEND:
      begin
        if Mode = BLEND_ZERO then
          vDSTBlend := GL_ZERO
        else if Mode = BLEND_ONE then
          vDSTBlend := GL_ONE
        else if Mode = BLEND_SRCCOLOR then
          vDSTBlend := GL_SRC_COLOR
        else if Mode = BLEND_INVSRCCOLOR then
          vDSTBlend := GL_ONE_MINUS_SRC_COLOR
        else if Mode = BLEND_SRCALPHA then
          vDSTBlend := GL_SRC_ALPHA
        else if Mode = BLEND_INVSRCALPHA then
          vDSTBlend := GL_ONE_MINUS_SRC_ALPHA
        else if Mode = BLEND_DESTALPHA then
          vDSTBlend := GL_DST_ALPHA
        else if Mode = BLEND_INVDESTALPHA then
          vDSTBlend := GL_ONE_MINUS_DST_ALPHA
        else if Mode = BLEND_DESTCOLOR then
          vDSTBlend := GL_DST_COLOR
        else if Mode = BLEND_INVDESTCOLOR then
          vDSTBlend := GL_ONE_MINUS_DST_COLOR
        else if Mode = BLEND_SRCALPHASAT then
          vDSTBlend := GL_SRC_ALPHA_SATURATE;
        glBlendFunc(vSRCBlend, vDSTBlend);
      end;
    RS_ALPHAREF:
      begin
        vAlphaRef := Mode * 0.01;
        glAlphaFunc (vAlphaFunc, vAlphaRef);
      end;
    RS_ALPHAFUNC:
    begin
      If Mode = CMP_LESSEQUAL then
        vAlphaFunc := GL_LEQUAL
      else if Mode = CMP_LESS then
        vAlphaFunc := GL_LESS
      else if Mode = CMP_EQUAL then
        vAlphaFunc := GL_EQUAL
      else if Mode = CMP_GREATER then
        vAlphaFunc := GL_GREATER
      else if Mode = CMP_NOTEQUAL then
        vAlphaFunc := GL_NOTEQUAL
      else if Mode = CMP_GREATEREQUAL then
        vAlphaFunc := GL_GEQUAL
      else if Mode = CMP_NEVER then
        vAlphaFunc := GL_NEVER
      else if Mode = CMP_ALWAYS then
        vAlphaFunc := GL_ALWAYS;
      glAlphaFunc (vAlphaFunc, vAlphaRef);
    end;
    RS_DITHERENABLE:
      if Mode = 1 then glEnable(GL_DITHER) else glDisable(GL_DITHER);
    RS_FOGCOLOR:
      glFogf(GL_FOG_COLOR, Mode);
    RS_FOGENABLE:
      //2do
      Exit;
    RS_ZWRITEENABLE:
      If Mode = 1 then glDepthMask(True) else glDepthMask(False);
    RS_FOGTABLEMODE:
    begin
      If Mode = 1 then
        glFogf(GL_FOG_MODE, GL_EXP) //exp
      else if Mode = 2 then
        glFogf(GL_FOG_MODE, GL_EXP2) //exp2
      else if Mode = 3 then
        glFogf(GL_FOG_MODE, GL_LINEAR) //linear
    end;
    RS_FOGSTART:
      glFogf(GL_FOG_START, Mode);
    RS_FOGEND:
      glFogf(GL_FOG_END, Mode);
    RS_FOGDENSITY:
      glFogf(GL_FOG_DENSITY, Mode);
    RS_STENCILPASS:
    begin
      If Mode = STENCILOP_KEEP then
        vStencilPass := GL_KEEP
      else if Mode = STENCILOP_ZERO then
        vStencilPass := GL_ZERO
      else if Mode = STENCILOP_INCR then
        vStencilPass := GL_INCR
      else if Mode = STENCILOP_DECR then
        vStencilPass := GL_DECR
      else if Mode = STENCILOP_INVERT then
        vStencilPass := GL_INVERT;
      glStencilOp(vStencilFail,vStencilZFail,vStencilPass);
    end;
    RS_STENCILFAIL:
    begin
      If Mode = STENCILOP_KEEP then
        vStencilFail := GL_KEEP
      else if Mode = STENCILOP_ZERO then
        vStencilFail := GL_ZERO
      else if Mode = STENCILOP_INCR then
        vStencilFail := GL_INCR
      else if Mode = STENCILOP_DECR then
        vStencilFail := GL_DECR
      else if Mode = STENCILOP_INVERT then
        vStencilFail := GL_INVERT;
        glStencilOp(vStencilFail,vStencilZFail,vStencilPass);
    end;
    RS_STENCILZFAIL:
    begin
      If Mode = STENCILOP_KEEP then
        vStencilZFail := GL_KEEP
      else if Mode = STENCILOP_ZERO then
        vStencilZFail := GL_ZERO
      else if Mode = STENCILOP_INCR then
        vStencilZFail := GL_INCR
      else if Mode = STENCILOP_DECR then
        vStencilZFail := GL_DECR
      else if Mode = STENCILOP_INVERT then
        vStencilZFail := GL_INVERT;
      glStencilOp(vStencilFail,vStencilZFail,vStencilPass);
    end;
    RS_STENCILREF:
    begin
      vStencilRef := Mode;
      glStencilFunc(vStencilFunc, vStencilRef, vStencilMask);
    end;
    RS_STENCILMASK:
    begin
      vStencilMask := Mode;
      glStencilFunc(vStencilFunc, vStencilRef, vStencilMask);
    end;
    RS_STENCILWRITEMASK:
    begin
      vStencilMask := Mode;
      glStencilFunc(vStencilFunc, vStencilRef, vStencilMask);
    end;
    RS_STENCILFUNC:
    begin
      If Mode = CMP_LESSEQUAL then
        vStencilFunc := GL_LEQUAL
      else if Mode = CMP_LESS then
        vStencilFunc := GL_LESS
      else if Mode = CMP_EQUAL then
        vStencilFunc := GL_EQUAL
      else if Mode = CMP_GREATER then
        vStencilFunc := GL_GREATER
      else if Mode = CMP_NOTEQUAL then
        vStencilFunc := GL_NOTEQUAL
      else if Mode = CMP_GREATEREQUAL then
        vStencilFunc := GL_GEQUAL
      else if Mode = CMP_NEVER then
        vStencilFunc := GL_NEVER
      else if Mode = CMP_ALWAYS then
        vStencilFunc := GL_ALWAYS;
      glStencilFunc(vStencilFunc, vStencilRef, vStencilMask);
    end;
    RS_SPECULARENABLE:
    begin
      Exit;
    end;
    RS_ZBIAS:
    begin
      Exit;
    end;
    RS_RANGEFOGENABLE:
    begin
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
// r_SetTextureStageState()
// sets up a texture stage
//------------------------------------------------------------------------------
procedure r_SetTextureStageState(Stage: Cardinal; State: Cardinal; Mode: Cardinal); stdcall;
begin

  case State of
    (*
    TSS_COLOROP:
    TSS_COLORARG1:
    TSS_COLORARG2:
    TSS_ALPHAOP:
    TSS_ALPHAARG1:
    TSS_ALPHAARG2:
    TSS_BUMPENVMAT00:
    TSS_BUMPENVMAT01:
    TSS_BUMPENVMAT10:
    TSS_BUMPENVMAT11:
    TSS_TEXCOORDINDEX:
    *)
    TSS_ADDRESSU:
    begin
      if Mode = TADDRESS_WRAP then
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_R_EXT, GL_REPEAT)
      else if Mode = TADDRESS_MIRROR then
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_R_EXT, GL_REPEAT)
      else if Mode = TADDRESS_CLAMP then
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)
      else if Mode = TADDRESS_BORDER then
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_R_EXT, GL_CLAMP_TO_BORDER)
      else if Mode = TADDRESS_MIRRORONCE then
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_R_EXT, GL_REPEAT);
    end;
    TSS_ADDRESSV:
    begin
      if Mode = TADDRESS_WRAP then
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_R_EXT, GL_REPEAT)
      else if Mode = TADDRESS_MIRROR then
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_R_EXT, GL_REPEAT)
      else if Mode = TADDRESS_CLAMP then
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
      else if Mode = TADDRESS_BORDER then
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_R_EXT, GL_CLAMP_TO_BORDER)
      else if Mode = TADDRESS_MIRRORONCE then
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_R_EXT, GL_REPEAT);
    end;
    (*
    TSS_BORDERCOLOR:
    TSS_MAGFILTER:
    TSS_MINFILTER:
    TSS_MIPFILTER:
    TSS_MIPMAPLODBIAS:
    TSS_MAXMIPLEVEL:
    TSS_MAXANISOTROPY:
    TSS_BUMPENVLSCALE:
    TSS_BUMPENVLOFFSET:
    TSS_TEXTURETRANSFORMFLAGS:
    TSS_ADDRESSW:
    TSS_COLORARG0:
    TSS_ALPHAARG0:
    TSS_RESULTARG:
    *)
  else
    Exit;
  end;
end;

//------------------------------------------------------------------------------
// DrawQuad()
// drasw a 3d quad for the sprites
//------------------------------------------------------------------------------
procedure DrawQuad(X1, Y1, X2, Y2, Left, Right, lEnd, rEnd: Single); stdcall;
begin
  glBegin(GL_QUADS);
   glTexCoord2f(Left,Right); glVertex3f(X1, Y1, -1);
   glTexCoord2f(lEnd,Right); glVertex3f(X2, Y1, -1);
   glTexCoord2f(lEnd,rEnd); glVertex3f(X2, Y2, -1);
   glTexCoord2f(Left,rEnd); glVertex3f(X1, Y2, -1);
  glEnd;
end;

//------------------------------------------------------------------------------
// r_StartSprites()
// starts 2d-rendering
//------------------------------------------------------------------------------
procedure r_StartSprites(); stdcall;
begin
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  // enable 2d-projection
  glOrtho(0, InitConfig.ScreenWidth, InitConfig.ScreenHeight, 0, 0, 128);
  glEnable(GL_TEXTURE_2D);
    glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
  glTranslatef(0, 0, 0);
  glDisable(GL_DEPTH_TEST);

  //enable alpha testing
  glEnable(GL_ALPHA_TEST);
  glAlphaFunc(GL_GREATER, 0.1);
  glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
end;

//------------------------------------------------------------------------------
// r_EndSprites()
// ends 2d rendering
//------------------------------------------------------------------------------
procedure r_EndSprites(); stdcall;
begin
  //reset view and projection matrix
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  gluPerspective(SceneConfig.vRad / (Pi180), SceneConfig.vFormat, SceneConfig.vNearClippingPlane, SceneConfig.vFarClippingPlane * 2);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
  glEnable(GL_DEPTH_TEST);
  glDisable(GL_ALPHA_TEST);
end;

//------------------------------------------------------------------------------
// r_DrawSprite()
// renders a 2d sprite
//------------------------------------------------------------------------------
procedure r_DrawSprite(Mode: SpriteMode); stdcall;
  var vWidth, vHeight: Integer;
  var X1, Y1, X2, Y2, Left, Top, lEnd, rEnd: Single;
begin
  If Mode.Texture > 0 then
    vTextures[Mode.Texture].Bind()
  else
    Exit;

    vWidth := vTextures[Mode.Texture].Width;
    vHeight := vTextures[Mode.Texture].Height;

    X1 := Mode.Left;
    Y1 := Mode.Top;
    X2 := Mode.Left + Mode.Width * Mode.ScaleX;
    Y2 := Mode.Top + Mode.Height * Mode.ScaleY;
    Left := (Mode.Right / vWidth) * Mode.ScaleX;
    Top  := (Mode.Bottom / vHeight) * Mode.ScaleY;
    lEnd := ((Mode.Right + Mode.Width) / vWidth) * Mode.ScaleX;
    rEnd := ((Mode.Bottom + Mode.Height) / vHeight) * Mode.ScaleY;

    DrawQuad (X1, Y1, X2, Y2, Left, Top, lEnd, rEnd);
end;

//------------------------------------------------------------------------------
// Init()
// inits a 3d interface
//------------------------------------------------------------------------------
function r_Init(Mode: RenderMode): Integer; stdcall;
var
  dmScreenSettings : DEVMODE;   // Bildschirm Einstellungen (fullscreen, etc...)
  ZDepth: Integer;
begin
  InitConfig := Mode;
  vHande := Mode.WindowHWND;
  //Initialisiern des OpenGL-Interfaces:

  if Mode.vWindowed = False then
  begin
    ZeroMemory(@dmScreenSettings, SizeOf(dmScreenSettings));
    with dmScreenSettings do begin              // Bildschirm Einstellungen werden festgelegt
      dmSize       := SizeOf(dmScreenSettings);
      dmPelsWidth  := Mode.ScreenWidth;  // Fenster Breite
      dmPelsHeight := Mode.ScreenHeight; // Fenster Höhe
      dmBitsPerPel := Mode.ColorDepth;   // Farbtiefe (32bit etc)
      dmFields     := DM_PELSWIDTH or DM_PELSHEIGHT or DM_BITSPERPEL;
    end;

    if (ChangeDisplaySettings(dmScreenSettings, CDS_FULLSCREEN) = DISP_CHANGE_FAILED) then
    begin
      //unable to set the display mode
      RESULT := -1;
      Exit;
    end;
  end;
    
  // Den Device Kontext unseres Fensters besorgen
  h_DC := GetDC(Mode.WindowHWND);
  if (h_DC = 0) then
  begin
    //unnable to get the display mode
    Result := -2;
    Exit;
  end;
    (*
  // Das Pixelformat einstellen
  with pfd do
  begin
    nSize           := SizeOf(TPIXELFORMATDESCRIPTOR); // Größe des Pixel Format Descriptor
    nVersion        := 1;                    // Version des Daten Structs
    dwFlags         := PFD_DRAW_TO_WINDOW    // Buffer erlaubt zeichenen auf Fenster
                       or PFD_SUPPORT_OPENGL // Buffer unterstützt OpenGL drawing
                       or PFD_DOUBLEBUFFER;  // Double Buffering benutzen
    iPixelType      := PFD_TYPE_RGBA;        // RGBA Farbformat
    cColorBits      := Mode.ColorDepth;      // OpenGL Farbtiefe
    cRedBits        := 0;
    cRedShift       := 0;
    cGreenBits      := 0;
    cGreenShift     := 0;
    cBlueBits       := 0;
    cBlueShift      := 0;
    cAlphaBits      := 0;                    // Not supported
    cAlphaShift     := 0;                    // Not supported
    cAccumBits      := 0;                    // Kein Accumulation Buffer
    cAccumRedBits   := 0;
    cAccumGreenBits := 0;
    cAccumBlueBits  := 0;
    cAccumAlphaBits := 0;
    cDepthBits      := 16;                   // Genauigkeit des Depth-Buffers
    cStencilBits    := Mode.StencilBits;     // Stencil Buffer
    cAuxBuffers     := 0;                    // Not supported
    iLayerType      := PFD_MAIN_PLANE;       // Wird Ignoriert!
    bReserved       := 0;                    // Anzahl der Overlay und Underlay Planes
    dwLayerMask     := 0;                    // Wird Ignoriert!
    dwVisibleMask   := 0;                    // Transparente Farbe der Underlay Plane
    dwDamageMask    := 0;                    // Wird Ignoriert!
  end;
  PixelFormat := ChoosePixelFormat(h_DC, @pfd);
  SetPixelFormat(h_DC, PixelFormat, @pfd);


  // OpenGL Rendering Context wird erstellt
  h_RC := wglCreateContext(h_DC);
  // Der OpenGL Rendering Context wird aktiviert
  wglMakeCurrent(h_DC, h_RC);
      *)
      
  // use this for dglOpenGL.pas
  initOpenGl();
  If Mode.ColorDepth = 32 then
  begin
    ZDepth := 24;
  end
  else
  begin
    ZDepth := 16;
  end;

  h_RC := CreateRenderingContext(h_DC, [opDoubleBuffered], Mode.ColorDepth, ZDepth, Mode.StencilBits,0,0,0);
  ActivateRenderingContext(h_DC, h_RC);

  ShowWindow(Mode.WindowHWND, SW_SHOW);
  SetForegroundWindow(Mode.WindowHWND);
  SetFocus(Mode.WindowHWND);


  glViewport(0, 0, Mode.ScreenWidth, Mode.ScreenHeight);    // Setzt den Viewport für das OpenGL Fenster
  RESULT := 1;
end;


//------------------------------------------------------------------------------
// r_DeviceCleanUp()
// deletes all devices
//------------------------------------------------------------------------------
procedure r_DeviceCleanUp(); stdcall;
  var I: Integer;
begin
  For I := 1 To VertexBufferCount do
  begin
    //VertexBuffers[I].VertexBuffer := nil;
  end;
  
  //release textures
  if TextureCount > 0 then
  begin
    For I := 1 To TextureCount do
    begin
      vTextures[I].Free;
    end;
  end;

  ChangeDisplaySettings(devmode(nil^), 0);

  // Freigabe des Device und Rendering Contexts.
  wglMakeCurrent(0, 0);
  // Löscht Rendering Context
  wglDeleteContext(h_RC);
  // Gibt Device Context fre

  ReleaseDC(vHande, h_DC);

end;


//------------------------------------------------------------------------------
// r_SplitColorToRGB()
// divides a color value into the r,g,b values
//------------------------------------------------------------------------------
function SplitColorToRGB(const Color: Cardinal): T3DColor;
begin
  RESULT.B := (ColorToRGB(Color) and $0000FF) / 255;
  RESULT.G := ((ColorToRGB(Color) and $00FF00) shr  8) / 255;
  RESULT.R := ((ColorToRGB(Color) and $FF0000) shr 16) / 255;
  RESULT.A := 1.0;
end;

//------------------------------------------------------------------------------
// r_InitScene()
// Inits the Scene
//------------------------------------------------------------------------------
procedure r_InitScene(Mode: SceneArguments); stdcall;
  var vMaterial: RECORD
    vDiffuse:  Array[0..3] Of Single;
    vAmbient:  Array[0..3] Of Single;
    vSpecular: Array[0..3] Of Single;
    vEmissive: Array[0..3] Of Single;
  end;
  FogColor: T3DColor;
begin
  //set default const
  vAlphaFunc := GL_GEQUAL;
  vAlphaRef := 0.001;

  glMatrixMode(GL_PROJECTION);        // Matrix Mode auf Projection setzen
  glLoadIdentity();                   // Reset View
  gluPerspective(Mode.vRad / (Pi180), Mode.vFormat, Mode.vNearClippingPlane, Mode.vFarClippingPlane * 2);  // Perspektive den neuen Maßen anpassen.
  glMatrixMode(GL_MODELVIEW);         // Zurück zur Modelview Matrix
  glLoadIdentity();                   // Reset View

  glEnable(GL_TEXTURE_2D);	       // Aktiviert Texture Mapping
  glShadeModel(GL_SMOOTH);	       // Aktiviert weiches Shading
  glClearColor(0.0, 0.0, 0.0, 0.5);    // Bildschirm löschen (schwarz)
  glClearDepth(1.0);		       // Depth Buffer Setup
  glEnable(GL_DEPTH_TEST);	       // Aktiviert Depth Testing
  glDepthFunc(GL_LEQUAL);	       // Bestimmt den Typ des Depth Testing
  glEnable(GL_CULL_FACE);
  glCullFace (GL_FRONT);
  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_DONT_CARE);  // Qualitativ bessere Koordinaten Interpolation

  //set material
  glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
  glDisable(GL_COLOR_MATERIAL);
  glColorMaterial (GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE);

  //Texturfilter gegen LEGO-Steine
  glEnable(GL_TEXTURE_2D);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,GL_LINEAR);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,GL_LINEAR);


  vMaterial.vDiffuse[0] := 1.0;
  vMaterial.vDiffuse[1] := 1.0;
  vMaterial.vDiffuse[2] := 1.0;
  vMaterial.vDiffuse[3] := 1.0;
  vMaterial.vAmbient[0] := 1.0;
  vMaterial.vAmbient[1] := 1.0;
  vMaterial.vAmbient[2] := 1.0;
  vMaterial.vAmbient[3] := 1.0;
  vMaterial.vSpecular[0] := 1.0;
  vMaterial.vSpecular[1] := 1.0;
  vMaterial.vSpecular[2] := 1.0;
  vMaterial.vSpecular[3] := 1.0;
  vMaterial.vEmissive[0] := 0.0;
  vMaterial.vEmissive[1] := 0.0;
  vMaterial.vEmissive[2] := 0.0;
  vMaterial.vEmissive[3] := 0.0;

  glMaterialfv(GL_FRONT_AND_BACK,  GL_AMBIENT,  @vMaterial.vAmbient);
  glMaterialfv(GL_FRONT_AND_BACK,  GL_DIFFUSE,  @vMaterial.vDiffuse);
  glMaterialfv(GL_FRONT_AND_BACK,  GL_SPECULAR, @vMaterial.vSpecular);
  glMaterialfv(GL_FRONT_AND_BACK,  GL_EMISSION, @vMaterial.vEmissive);

  glEnable(GL_LIGHTING);

  vStencilZFail := GL_KEEP;
  vStencilFail := GL_KEEP;
  vStencilPass := GL_KEEP;
  vStencilRef := 1;
  vStencilMask := $FFFFFFFF;

  glEnable(GL_NORMALIZE);

  If Mode.vFogEnabled = True then
  begin

    FogColor := SplitColorToRGB(Mode.vFogColor);

    If Mode.vFogDensity <> 1.0 then
    begin
      glFogi(GL_FOG_MODE, GL_EXP); // Fog Mode
      glFogf(GL_FOG_DENSITY, Mode.vFogDensity); // How Dense Will The Fog Be
    end
    else
    begin
      glFogi(GL_FOG_MODE, GL_LINEAR); // Fog Mode
    glFogf(GL_FOG_START, Mode.vFogBegin); // Fog Start Depth
    glFogf(GL_FOG_END, Mode.vFarClippingPlane * 2); // Fog End Depth
    end;
    
    glFogfv(GL_FOG_COLOR, @fogcolor); // Set Fog Color
    glHint(GL_FOG_HINT, GL_DONT_CARE); // Fog Hint Value
    glEnable(GL_FOG); // Enables GL_FOG
  end
  else
  begin
    glDisable(GL_FOG); // Enables GL_FOG
  end;

  //save video mode (to restore)
  SceneConfig := Mode;
end;


exports
r_Init,
r_DeviceCleanUp,
r_InitScene,
r_ClearBackBuffer,
r_BeginScene,
r_EndScene,
r_RestoreScene,
r_StartSprites,
r_EndSprites,
r_DrawSprite,

r_CreateTextureFromFileEx,
r_CreateTextureFromFile,
r_SetTexture,

r_MatrixTranslation,
r_MatrixScaling,
r_MatrixRotation,

r_CreateLight,
r_EnableLight,
r_SetLight,
r_UpdateLightPosition,

r_CreateVertexBuffer,
r_AddVerticesToBuffer,
r_RenderVertexBuffer,

r_RenderVertexBufferEx,
r_CreateVertexBufferEx,
r_AddVertexToBufferEx,
r_SetVertexBufferLengthEx,

r_SetRenderState,
r_SetTextureStageState;

begin
end.
