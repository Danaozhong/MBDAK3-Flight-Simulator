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
library Render_Direct3D;
uses
  SysUtils,
  Classes,
  D3DX8,
  Direct3D8,
  Windows,
  Messages,
  Variants,
  Graphics,
  Controls;

type
  //============================================================================
  // predefined structures
  //============================================================================
  Vector3D= RECORD
    X: Single;
    Y: Single;
    Z: Single;
  end;

  Vertex3D = RECORD
    X,Y,Z:    Single;
    NX,NY,NZ: Single;
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
    vVertices: Array[0..32000-1] of TD3DXVector3;
    m_dwNumVertices: WORD;
  end;

  //the directx vertex buffers
  VertexBuffer3D = RECORD
    DXVertexBuffer: IDirect3DVertexBuffer8;
    TriangleCount:  WORD;
  end;

  //the texture-buffer
  TextureBuffer3D = RECORD
    Buffer: IDIRECT3DTEXTURE8;
    FilePath: String;
  end;


const
  Pi180 = Pi/180.0;
  //VertexTyp:         Position      Normalenvektoren Texturiert
  D3D8T_CUSTOMVERTEX = D3DFVF_XYZ or D3DFVF_NORMAL or D3DFVF_TEX1;


  //all renderstates:
  //=================
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

var
  //DirectX-Variablen:
  //==================
  D3D8:               IDIRECT3D8;
  D3dDevCaps:         TD3DCaps8;
  D3DDevice8:         IDirect3DDevice8;
  D3DPP:              TD3DPRESENTPARAMETERS;
  D3DDM:              D3DDisplayMode;
  Sprite:             ID3DXSprite;

  vMat:               D3DMATERIAL8;

  WorldMatrix:        TD3DXMATRIX;
  TempMatrix:         TD3DXMATRIX;
  ViewMatrix:         TD3DXMATRIX;

  SceneConfig:        SceneArguments;

  Textures:           Array of TextureBuffer3D;
  TextureCount:       Integer;

  Lights:             Array of D3DLIGHT8;
  LightCount:         Integer;

  PRIMeshes:          Array of VerticesList;
  PRICount:           Integer;

  VertexBuffers:      Array of VertexBuffer3D;
  VertexBufferCount:  Integer;

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

//------------------------------------------------------------------------------
// D3GetValidDisplayMode()
// returns an optimal 3d format by the color depth
//------------------------------------------------------------------------------
function D3GetValidDisplayMode(ColorDepth: Integer):TD3DFORMAT; stdcall;
var
  hr: HRESULT;
begin
  If ColorDepth = 8 then
  begin
    //test format 8 bit :D :D
    hr := D3D8.CheckDeviceType (D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, D3DFMT_R3G3B2, D3DFMT_R3G3B2, False);
    if (SUCCEEDED(hr)) then begin
      RESULT := D3DFMT_R3G3B2;
      Exit;
    end;
  end
  else if ColorDepth = 16 then
  begin
    //test format 1
    hr := D3D8.CheckDeviceType (D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, D3DFMT_R5G6B5, D3DFMT_R5G6B5, False);
    if (SUCCEEDED(hr)) then begin
      RESULT := D3DFMT_R5G6B5;
      Exit;
    end;

    //if failed, test format 2
    hr := D3D8.CheckDeviceType (D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, D3DFMT_X1R5G5B5, D3DFMT_X1R5G5B5, False);
    if (SUCCEEDED(hr)) then begin
      RESULT := D3DFMT_X1R5G5B5;
      Exit;
    end;

    //if failed, test format 3
    hr := D3D8.CheckDeviceType (D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, D3DFMT_X1R5G5B5, D3DFMT_A1R5G5B5, False);
    if (SUCCEEDED(hr)) then begin
      RESULT := D3DFMT_A1R5G5B5;
      Exit;
    end;
  end
  else if ColorDepth = 24 then
  begin
    //test format 24bt
    hr := D3D8.CheckDeviceType (D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, D3DFMT_R8G8B8, D3DFMT_R8G8B8, False);
    if (SUCCEEDED(hr)) then begin
      RESULT := D3DFMT_R8G8B8;
      Exit;
    end;
  end
  else if ColorDepth = 32 then
  begin
    //test 32 bit format
    hr := D3D8.CheckDeviceType (D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, D3DFMT_X8R8G8B8, D3DFMT_X8R8G8B8, False);
    if (SUCCEEDED(hr)) then begin
      RESULT := D3DFMT_X8R8G8B8;
      Exit;
    end;
  end;
  
  //well, try, even if not supported
  Result := D3DFMT_R5G6B5;
end;

//------------------------------------------------------------------------------
// FindDepthStencilFormat()
// finds a hw supported gpu format
//------------------------------------------------------------------------------
function FindDepthStencilFormat(vMinDepthBits: Integer; vMinStencilBits: Integer; TargetFormat: _D3DFORMAT): TD3DFormat; stdcall;
begin
  //Die verschiedenen Displaymodes für den Stencil-Buffer testen:
  if (vMinDepthBits <= 16) and (vMinStencilBits = 0) then
  begin
    if SUCCEEDED(D3D8.CheckDeviceFormat(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, TargetFormat, D3DUSAGE_DEPTHSTENCIL, D3DRTYPE_SURFACE, D3DFMT_D16)) then
    begin
      if SUCCEEDED(D3D8.CheckDepthStencilMatch(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, TargetFormat, TargetFormat, D3DFMT_D16)) then
      begin
        Result := D3DFMT_D16;
        Exit;
      end;
    end;
  end;

  if (vMinDepthBits <= 15) and (vMinStencilBits <= 1) then
  begin
    if SUCCEEDED(D3D8.CheckDeviceFormat(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, TargetFormat, D3DUSAGE_DEPTHSTENCIL, D3DRTYPE_SURFACE, D3DFMT_D15S1)) then
    begin
      if SUCCEEDED(D3D8.CheckDepthStencilMatch(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, TargetFormat, TargetFormat, D3DFMT_D15S1)) then
      begin
        Result := D3DFMT_D15S1;
        Exit;
      end;
    end;
  end;

  if (vMinDepthBits <= 24) and (vMinStencilBits = 0) then
  begin
    if SUCCEEDED(D3D8.CheckDeviceFormat(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, TargetFormat, D3DUSAGE_DEPTHSTENCIL, D3DRTYPE_SURFACE, D3DFMT_D24X8)) then
    begin
      if SUCCEEDED(D3D8.CheckDepthStencilMatch(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, TargetFormat, TargetFormat, D3DFMT_D24X8)) then
      begin
        Result := D3DFMT_D24X8;
        Exit;
      end;
    end;
  end;

  if (vMinDepthBits <= 24) and (vMinStencilBits <= 8) then
  begin
    if SUCCEEDED(D3D8.CheckDeviceFormat(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, TargetFormat, D3DUSAGE_DEPTHSTENCIL, D3DRTYPE_SURFACE, D3DFMT_D24S8)) then
    begin
      if SUCCEEDED(D3D8.CheckDepthStencilMatch(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, TargetFormat, TargetFormat, D3DFMT_D24S8)) then
      begin
        Result := D3DFMT_D24S8;
        Exit;
      end;
    end;
  end;

  if (vMinDepthBits <= 24) and (vMinStencilBits <= 4) then
  begin
    if SUCCEEDED(D3D8.CheckDeviceFormat(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, TargetFormat, D3DUSAGE_DEPTHSTENCIL, D3DRTYPE_SURFACE, D3DFMT_D24X4S4)) then
    begin
      if SUCCEEDED(D3D8.CheckDepthStencilMatch(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, TargetFormat, TargetFormat, D3DFMT_D24X4S4)) then
      begin
        Result := D3DFMT_D24X4S4;
        Exit;
      end;
    end;
  end;

  if (vMinDepthBits <= 32) and (vMinStencilBits = 0) then
  begin
    if SUCCEEDED(D3D8.CheckDeviceFormat(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, TargetFormat, D3DUSAGE_DEPTHSTENCIL, D3DRTYPE_SURFACE, D3DFMT_D32)) then
    begin
      if SUCCEEDED(D3D8.CheckDepthStencilMatch(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, TargetFormat, TargetFormat, D3DFMT_D32)) then
      begin
        Result := D3DFMT_D32;
        Exit;
      end;
    end;
  end;

  //das kompatibleste Format zurückgeben:
  Result := D3DFMT_D16;
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
    Diffuse.r := Mode.Diffuse.R;
    Diffuse.g := Mode.Diffuse.G;
    Diffuse.b := Mode.Diffuse.B;
    Diffuse.a := Mode.Diffuse.A;
    Ambient.r := Mode.Ambient.R;
    Ambient.g := Mode.Ambient.G;
    Ambient.b := Mode.Ambient.B;
    Ambient.a := Mode.Ambient.A;
    Specular.r := Mode.Specular.R;
    Specular.g := Mode.Specular.G;
    Specular.b := Mode.Specular.B;
    Specular.a := Mode.Specular.A;
    Range := Mode.Range;
    Attenuation0 := Mode.Attenuation0;
    Attenuation1 := Mode.Attenuation1;
    Attenuation2 := Mode.Attenuation2;
    If Mode.LightMode = 101 then _Type := D3DLIGHT_POINT
    else if Mode.LightMode = 102 then _Type := D3DLIGHT_DIRECTIONAL;

    Direction.x := Mode.Direction.x;
    Direction.y := Mode.Direction.y;
    Direction.z := Mode.Direction.z;
    Position.x := Mode.Position.x;
    Position.y := Mode.Position.y;
    Position.z := Mode.Position.z;
  end;

  RESULT := LightCount;
end;

//------------------------------------------------------------------------------
// EnableLight()
// Switches a light on/off
//------------------------------------------------------------------------------
procedure r_EnableLight(Light: Integer; Enabled: Boolean); stdcall;
begin
  D3DDevice8.LightEnable (Light, Enabled);
end;

//------------------------------------------------------------------------------
// r_UpdateLightPosition()
// updates the position of a light
//------------------------------------------------------------------------------
procedure r_UpdateLightPosition(ID: Integer; Position: Vector3D); stdcall;
begin
  Lights[ID].Position.x := Position.X;
  Lights[ID].Position.y := Position.Y;
  Lights[ID].Position.z := Position.Z;
end;

//------------------------------------------------------------------------------
// EnableLight()
// Switches a light on/off
//------------------------------------------------------------------------------
procedure r_SetLight(Light: Integer); stdcall;
begin
  D3DDevice8.SetLight (Light, Lights[Light]);
end;

//------------------------------------------------------------------------------
// ConfirmDevice()
// check if mode is supported
//------------------------------------------------------------------------------
function ConfirmDevice(var pCaps: TD3DCaps8; dwBehavior: DWORD; Format: TD3DFormat): HResult; stdcall;
begin
  // Make sure device supports point lights
  if ((dwBehavior and D3DCREATE_HARDWARE_VERTEXPROCESSING) or
      (dwBehavior and D3DCREATE_MIXED_VERTEXPROCESSING)) <> 0 then
  begin
    if (0 = (pCaps.VertexProcessingCaps and D3DVTXPCAPS_POSITIONALLIGHTS)) then
    begin
      Result := E_FAIL;
      Exit;
    end;
  end;

  Result := S_OK;
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
  D3DDevice8.SetTexture(0, Textures[TextureID].Buffer);
end;

//------------------------------------------------------------------------------
// r_CreateTextureFromFileEx()
// Creates a texture buffer
//------------------------------------------------------------------------------
function r_CreateTextureFromFileEx(Path: PChar; vWidth: Integer; vHeight: Integer; vColorKey: Cardinal): Integer; stdcall;
begin
    vColorKey := vColorKey + $FF000000;
    Inc(TextureCount);
    SetLength(Textures, TextureCount + 1);
    D3DXCreateTextureFromFileEx(D3DDevice8,
      Path,
      vWidth, vHeight,
      1, 0,
      D3DFMT_A8R8G8B8,
      D3DPOOL_MANAGED,
      D3DX_FILTER_NONE,
      D3DX_FILTER_NONE,
      vColorKey,
      nil,
      nil,
      Textures[TextureCount].Buffer);

    RESULT := TextureCount;
end;

//------------------------------------------------------------------------------
// r_CreateTextureFromFile()
// Creates a texture buffer
//------------------------------------------------------------------------------
function r_CreateTextureFromFile(Path: PChar): Integer; stdcall;
  var I: Integer;
begin
    //check if texture is already loaded
    If TextureCount > 0 then
    begin
      For I := 1 to TextureCount do
      begin
        If Textures[I].FilePath = Path then
        begin
          Result := I;
          Exit;
        end;
      end;
    end;
    Inc(TextureCount);
    SetLength(Textures, TextureCount + 1);
    Textures[TextureCount].FilePath := Path;

    D3DXCreateTextureFromFileEx(D3DDevice8,
      Path,
      D3DX_DEFAULT, D3DX_DEFAULT,
      5, 0,
      D3DFMT_A8R8G8B8,
      D3DPOOL_MANAGED,
      D3DX_FILTER_NONE,
      D3DX_FILTER_LINEAR,
      0,
      nil,
      nil,
      Textures[TextureCount].Buffer);

    RESULT := TextureCount;
end;

//------------------------------------------------------------------------------
// r_MatrixTranslation()
// set up position of the matrix
//------------------------------------------------------------------------------
procedure r_MatrixTranslation(X: Single; Y: Single; Z: Single); stdcall;
begin
  D3DXMatrixTranslation(WorldMatrix, X, Y, Z);
end;

//------------------------------------------------------------------------------
// r_MatrixRotation()
// rotates a matrix
//------------------------------------------------------------------------------
procedure r_MatrixRotation(Yaw: Single; Pitch: Single; Roll: Single); stdcall;
begin
  D3DXMatrixRotationYawPitchRoll (TempMatrix, Yaw*Pi180, Pitch*Pi180, Roll*Pi180);
  D3DXMatrixMultiply(WorldMatrix, TempMatrix, WorldMatrix);
end;

//------------------------------------------------------------------------------
// r_MatrixScaling()
// scales a matrix
//------------------------------------------------------------------------------
procedure r_MatrixScaling(X: Single; Y: Single; Z: Single); stdcall;
begin
  D3DXMatrixScaling(TempMatrix, X, Y, Z);
  D3DXMatrixMultiply(WorldMatrix,TempMatrix,WorldMatrix);
end;


//------------------------------------------------------------------------------
// r_CreateVertexBufferEx()
// creates a facile vertex buffer
//------------------------------------------------------------------------------
function r_CreateVertexBufferEx: Integer; stdcall;
begin
  Inc(PRICount);
  SetLength(PRIMeshes, PRICount+1);
  PRIMeshes[PRICount].m_dwNumVertices := 0;
  RESULT := PRICount;
end;

//------------------------------------------------------------------------------
// r_SetVertexBufferLengthEx()
// sets the size of the easy vertex-buffer
//------------------------------------------------------------------------------
procedure r_SetVertexBufferLengthEx(Buffer: Integer; NewLength: Integer); stdcall;
begin
  PRIMeshes[Buffer].m_dwNumVertices := NewLength;
end;

//------------------------------------------------------------------------------
// r_AddVertexToBufferEx()
// adds a vertex to the buffer
//------------------------------------------------------------------------------
procedure r_AddVertexToBufferEx(Buffer: Integer; Vertex: Vector3D); stdcall;
  var DXVertex: TD3DXVector3;
begin

  DXVertex.x := Vertex.X;
  DXVertex.y := Vertex.Y;
  DXVertex.z := Vertex.Z;

  if (PRIMeshes[Buffer].m_dwNumVertices < 32000) then
  begin
    PRIMeshes[Buffer].vVertices[PRIMeshes[Buffer].m_dwNumVertices] := DXVertex;
    PRIMeshes[Buffer].m_dwNumVertices := PRIMeshes[Buffer].m_dwNumVertices + 1;
  end;

end;

//------------------------------------------------------------------------------
// r_RenderVertexBufferEx()
// renders the primitive vertices
//------------------------------------------------------------------------------
procedure r_RenderVertexBufferEx(ID: Integer); stdcall;
begin
  D3DDevice8.SetTransform(D3DTS_WORLD,WorldMatrix);
  D3DDevice8.SetVertexShader(D3DFVF_XYZ);
{$IFDEF DXG_COMPAT}
  D3DDevice8.DrawPrimitiveUP(D3DPT_TRIANGLELIST, PRIMeshes[ID].m_dwNumVertices div 3,
                                      @PRIMeshes[ID].vVertices, SizeOf(TD3DXVector3));
{$ELSE}
  D3DDevice8.DrawPrimitiveUP(D3DPT_TRIANGLELIST, PRIMeshes[ID].m_dwNumVertices div 3,
                                      PRIMeshes[ID].vVertices, SizeOf(TD3DXVector3));
{$ENDIF}
end;

//------------------------------------------------------------------------------
// r_CreateVertexBuffer()
// creates an advanced vertex-buffer (support of textures)
//------------------------------------------------------------------------------
function r_CreateVertexBuffer(Size: Word): Integer; stdcall;
begin
  Inc(VertexBufferCount);
  SetLength(VertexBuffers, VertexBufferCount + 1);
  VertexBuffers[VertexBufferCount].TriangleCount := Trunc(Size / 3);
  D3DDevice8.CreateVertexBuffer(Size*SizeOf(Vertex3D), D3DUSAGE_WRITEONLY, D3D8T_CUSTOMVERTEX, D3DPOOL_MANAGED, VertexBuffers[VertexBufferCount].DXVertexBuffer);

  RESULT := VertexBufferCount;
end;

//------------------------------------------------------------------------------
// r_AddVerticesToBuffer()
// adds vertices to the extended buffer
//------------------------------------------------------------------------------
procedure r_AddVerticesToBuffer(ID: Integer; tVertices: Array Of Vertex3D); stdcall;
  var vbVertices : pByte;
begin
  //lock
  tVertices[0].NX := 1.0;
  VertexBuffers[ID].DXVertexBuffer.Lock (0, 0, vbVertices, 0);
  //fill with new datas
  Move(tVertices, vbVertices^, SizeOf(tVertices));
  VertexBuffers[ID].DXVertexBuffer.Unlock();
end;

//------------------------------------------------------------------------------
// r_RenderVertexBuffer()
// renders an extended vertex buffer
//------------------------------------------------------------------------------
procedure r_RenderVertexBuffer(ID: Integer); stdcall;
begin
  D3DDevice8.SetTransform(D3DTS_WORLD,WorldMatrix);
  D3DDevice8.SetVertexShader(D3D8T_CUSTOMVERTEX);
  D3DDevice8.SetStreamSource(0, VertexBuffers[ID].DXVertexBuffer, SizeOf(Vertex3D));
  D3DDevice8.DrawPrimitive(D3DPT_TRIANGLELIST, 0, VertexBuffers[ID].TriangleCount);
end;

//------------------------------------------------------------------------------
// r_ClearBackBuffer()
// cleans the backbuffer
//------------------------------------------------------------------------------
procedure r_ClearBackBuffer(Stencil: Boolean); stdcall;
begin
      If Stencil = True then
      begin
        D3DDevice8.Clear(0, nil, D3DCLEAR_TARGET or D3DCLEAR_ZBUFFER or D3DCLEAR_STENCIL, $00000000, 1, 0);
      end
      else
      begin
        D3DDevice8.Clear(0, nil, D3DCLEAR_TARGET or D3DCLEAR_ZBUFFER, $00000000, 1, 0);
      end;
end;

//------------------------------------------------------------------------------
// r_BeginScene()
// scene's beginning!
//------------------------------------------------------------------------------
procedure r_BeginScene(ViewPosition: Camera); stdcall;
begin
  D3DDevice8.BeginScene();
  
  //reset matrices
  D3DXMatrixIdentity(WorldMatrix);
  D3DXMatrixIdentity(TempMatrix);
  D3DXMatrixIdentity(ViewMatrix);

  D3DXMatrixLookAtLH (ViewMatrix,
      D3DXVECTOR3(ViewPosition.X, ViewPosition.Y, ViewPosition.Z),
      D3DXVECTOR3(ViewPosition.AX, ViewPosition.AY, ViewPosition.AZ),
      D3DXVECTOR3(ViewPosition.RX, ViewPosition.RY, ViewPosition.RZ));

  D3DDevice8.SetTransform(D3DTS_VIEW,ViewMatrix);
end;

//------------------------------------------------------------------------------
// r_EndScene()
// scene is complete, flip!
//------------------------------------------------------------------------------
procedure r_EndScene(); stdcall;
begin
  //Szene ist fertig
  D3DDevice8.EndScene;

  //Blitten
  D3DDevice8.Present(nil,nil,0,nil);
end;

//------------------------------------------------------------------------------
// r_SetRenderState()
// sets up a renderstate
//------------------------------------------------------------------------------
procedure r_SetRenderState(State: Cardinal; Mode: Cardinal); stdcall;
  var RenderState: TD3DRenderStateType;
begin
  //transform the most important renderstates
  case State of
    RS_ZENABLE:           RenderState := D3DRS_ZENABLE;
    RS_FILLMODE:          RenderState := D3DRS_FILLMODE;
    RS_SHADEMODE:         RenderState := D3DRS_SHADEMODE;
    RS_LINEPATTERN:       RenderState := D3DRS_LINEPATTERN;
    RS_ZWRITEENABLE:      RenderState := D3DRS_ZWRITEENABLE;
    RS_ALPHATESTENABLE:   RenderState := D3DRS_ALPHATESTENABLE;
    RS_LASTPIXEL:         RenderState := D3DRS_LASTPIXEL;
    RS_SRCBLEND:          RenderState := D3DRS_SRCBLEND;
    RS_DESTBLEND:         RenderState := D3DRS_DESTBLEND;
    RS_CULLMODE:          RenderState := D3DRS_CULLMODE;
    RS_ZFUNC:             RenderState := D3DRS_ZFUNC;
    RS_ALPHAREF:          RenderState := D3DRS_ALPHAREF;
    RS_ALPHAFUNC:         RenderState := D3DRS_ALPHAFUNC;
    RS_DITHERENABLE:      RenderState := D3DRS_DITHERENABLE;
    RS_ALPHABLENDENABLE:  RenderState := D3DRS_ALPHABLENDENABLE;
    RS_FOGENABLE:         RenderState := D3DRS_FOGENABLE;
    RS_SPECULARENABLE:    RenderState := D3DRS_SPECULARENABLE;
    RS_ZVISIBLE:          RenderState := D3DRS_ZVISIBLE;
    RS_FOGCOLOR:          RenderState := D3DRS_FOGCOLOR;
    RS_FOGTABLEMODE:      RenderState := D3DRS_FOGTABLEMODE;
    RS_FOGSTART:          RenderState := D3DRS_FOGSTART;
    RS_FOGEND:            RenderState := D3DRS_FOGEND;
    RS_FOGDENSITY:        RenderState := D3DRS_FOGDENSITY;
    RS_ZBIAS:             RenderState := D3DRS_ZBIAS;
    RS_RANGEFOGENABLE:    RenderState := D3DRS_RANGEFOGENABLE;
    RS_STENCILENABLE:     RenderState := D3DRS_STENCILENABLE;
    RS_STENCILFAIL:       RenderState := D3DRS_STENCILFAIL;
    RS_STENCILZFAIL:      RenderState := D3DRS_STENCILZFAIL;
    RS_STENCILPASS:       RenderState := D3DRS_STENCILPASS;
    RS_STENCILFUNC:       RenderState := D3DRS_STENCILFUNC;
    RS_STENCILREF:        RenderState := D3DRS_STENCILREF;
    RS_STENCILMASK:       RenderState := D3DRS_STENCILMASK;
    RS_STENCILWRITEMASK:  RenderState := D3DRS_STENCILWRITEMASK;
    RS_LIGHTING:          RenderState := D3DRS_LIGHTING;
  else
    Exit;
  end;

  D3DDevice8.SetRenderState(RenderState, Mode);
end;

//------------------------------------------------------------------------------
// r_SetTextureStageState()
// sets up a texture stage
//------------------------------------------------------------------------------
procedure r_SetTextureStageState(Stage: Cardinal; State: Cardinal; Mode: Cardinal); stdcall;
  var TextureState: TD3DTEXTURESTAGESTATETYPE;
begin
  case State of
    TSS_COLOROP:                TextureState := D3DTSS_COLOROP;
    TSS_COLORARG1:              TextureState := D3DTSS_COLORARG1;
    TSS_COLORARG2:              TextureState := D3DTSS_COLORARG2;
    TSS_ALPHAOP:                TextureState := D3DTSS_ALPHAOP;
    TSS_ALPHAARG1:              TextureState := D3DTSS_ALPHAARG1;
    TSS_ALPHAARG2:              TextureState := D3DTSS_ALPHAARG2;
    TSS_BUMPENVMAT00:           TextureState := D3DTSS_BUMPENVMAT00;
    TSS_BUMPENVMAT01:           TextureState := D3DTSS_BUMPENVMAT01;
    TSS_BUMPENVMAT10:           TextureState := D3DTSS_BUMPENVMAT10;
    TSS_BUMPENVMAT11:           TextureState := D3DTSS_BUMPENVMAT11;
    TSS_TEXCOORDINDEX:          TextureState := D3DTSS_TEXCOORDINDEX;
    TSS_ADDRESSU:               TextureState := D3DTSS_ADDRESSU;
    TSS_ADDRESSV:               TextureState := D3DTSS_ADDRESSV;
    TSS_BORDERCOLOR:            TextureState := D3DTSS_BORDERCOLOR;
    TSS_MAGFILTER:              TextureState := D3DTSS_MAGFILTER;
    TSS_MINFILTER:              TextureState := D3DTSS_MINFILTER;
    TSS_MIPFILTER:              TextureState := D3DTSS_MIPFILTER;
    TSS_MIPMAPLODBIAS:          TextureState := D3DTSS_MIPMAPLODBIAS;
    TSS_MAXMIPLEVEL:            TextureState := D3DTSS_MAXMIPLEVEL;
    TSS_MAXANISOTROPY:          TextureState := D3DTSS_MAXANISOTROPY;
    TSS_BUMPENVLSCALE:          TextureState := D3DTSS_BUMPENVLSCALE;
    TSS_BUMPENVLOFFSET:         TextureState := D3DTSS_BUMPENVLOFFSET;
    TSS_TEXTURETRANSFORMFLAGS:  TextureState := D3DTSS_TEXTURETRANSFORMFLAGS;
    TSS_ADDRESSW:               TextureState := D3DTSS_ADDRESSW;
    TSS_COLORARG0:              TextureState := D3DTSS_COLORARG0;
    TSS_ALPHAARG0:              TextureState := D3DTSS_ALPHAARG0;
    TSS_RESULTARG:              TextureState := D3DTSS_RESULTARG;
  else
    Exit;
  end;
  D3DDevice8.SetTextureStageState(Stage, TextureState, Mode);
end;

//------------------------------------------------------------------------------
// r_StartSprites()
// starts 2d-rendering
//------------------------------------------------------------------------------
procedure r_StartSprites(); stdcall;
begin
  Sprite._Begin;
end;

//------------------------------------------------------------------------------
// r_EndSprites()
// ends 2d rendering
//------------------------------------------------------------------------------
procedure r_EndSprites(); stdcall;
begin
  Sprite._End;
end;

//------------------------------------------------------------------------------
// r_DrawSprite()
// renders a 2d sprite
//------------------------------------------------------------------------------
procedure r_DrawSprite(Mode: SpriteMode); stdcall;
  var RECT: TRECT;
  var Position: TD3DXVector2;
  var Scaling: TD3DXVector2;
begin
    RECT.Left := Mode.Right;
    RECT.Top := Mode.Bottom;
    RECT.Right := Mode.Right + Mode.Width;
    RECT.Bottom := Mode.Bottom + Mode.Height;
    Position.x := Mode.Left;
    Position.y := Mode.Top;
    Scaling.x := Mode.ScaleX;
    Scaling.y := Mode.ScaleY;
    Sprite.Draw(Textures[Mode.Texture].Buffer, @RECT, @Scaling, nil, Mode.Rotation, @Position, Mode.Color);
end;

//------------------------------------------------------------------------------
// Init()
// inits a 3d interface
//------------------------------------------------------------------------------
function r_Init(Mode: RenderMode): Integer; stdcall;
var
        TnL:            Boolean;                //TnL-Unterstützung
        RenderMode:     Integer;                //Rendermode mit TnL oder ohne
begin

        //Initialisiern des DirectX-Interfaces:
        D3D8:=Direct3DCreate8(D3D_SDK_VERSION);
        if(D3D8=nil) then
        begin
              //Das Erstellen von DirectX ist fehlgeschlagen!
              RESULT := -1;
              Exit;
        end;

        D3D8.GetAdapterDisplayMode(D3DADAPTER_DEFAULT, D3DDM);
        ZeroMemory(@D3DPP, SizeOf(D3DPP));

        //Windowed
        D3DPP.Windowed := Mode.vWindowed;
        D3DPP.SwapEffect:=D3DSWAPEFFECT_DISCARD;

        //Setzen des Handles:
        D3DPP.hDeviceWindow := Mode.WindowHWND;

        If D3DPP.Windowed = False then
        begin
          //Das sind die Einstellungen für Fullscreen
          D3DPP.BackBufferWidth   := Mode.ScreenWidth;
          D3DPP.BackBufferHeight  := Mode.ScreenHeight;
          D3DPP.BackBufferFormat := D3GetValidDisplayMode(Mode.ColorDepth);
          D3DPP.BackBufferCount:= 1;
        end
        else
        begin
          //Im Window-Mode rendern:
          Result := D3D8.GetAdapterDisplayMode(D3DADAPTER_DEFAULT, D3DDM);
          If FAILED(Result) then
          begin
                  //displaymodus not get
                  RESULT := -2;
                  Exit;
          end;
          D3DPP.BackBufferFormat := D3DDM.Format;
        end;

        // Unterstützung von Hardware T&L?
        D3D8.GetDeviceCaps(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL,D3dDevCaps);

        TnL := False;
        RenderMode := D3DCREATE_SOFTWARE_VERTEXPROCESSING;

        If Mode.vUseTnL = True then
        begin
          // Confirm the device/format for HW vertex processing
          If (D3dDevCaps.DevCaps and D3DDEVCAPS_HWTRANSFORMANDLIGHT) = D3DDEVCAPS_HWTRANSFORMANDLIGHT then
          begin
            If (D3dDevCaps.DevCaps and D3DDEVCAPS_PUREDEVICE) = D3DDEVCAPS_PUREDEVICE then
            begin
              RenderMode := D3DCREATE_HARDWARE_VERTEXPROCESSING or D3DCREATE_PUREDEVICE;
              If SUCCEEDED(ConfirmDevice(D3dDevCaps, RenderMode, D3DDM.Format)) then TnL := True;
            end;

            if (TnL = False) then
            begin
              RenderMode := D3DCREATE_HARDWARE_VERTEXPROCESSING;
              If SUCCEEDED(ConfirmDevice(D3dDevCaps, RenderMode, D3DDM.Format)) then TnL := True;
            end;

            if (TnL = False) then
            begin
              RenderMode := D3DCREATE_MIXED_VERTEXPROCESSING;
              If SUCCEEDED(ConfirmDevice(D3dDevCaps, RenderMode, D3DDM.Format)) then TnL := True;
            end;
          end;
          If TnL = False then
          begin
            RenderMode := D3DCREATE_SOFTWARE_VERTEXPROCESSING;
          end;
        end;

        //Z-Buffer initialisieren:
        D3DPP.EnableAutoDepthStencil := True;

        //optimalen Stencil-Buffer finden:
        D3DPP.AutoDepthStencilFormat := FindDepthStencilFormat (16, Mode.StencilBits, D3DDM.Format);


        //Erstellen der D3D-Device:
        Result := D3D8.CreateDevice(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, Mode.WindowHWND, RenderMode, D3DPP, D3DDevice8);
        if FAILED(Result) then
        begin
                //Die D3D-Device konnte leider nicht erstellt werden.
                RESULT := 0;
                Exit;
        end;

    RESULT := 1;
end;


//------------------------------------------------------------------------------
// r_DeviceCleanUp()
// deletes all devices
//------------------------------------------------------------------------------
procedure r_DeviceCleanUp(); stdcall;
  var I: Integer;
begin
  D3DDevice8.SetStreamSource(0, nil, 0);

  //release textures
  if TextureCount > 0 then
  begin
    For I := 1 To TextureCount do
    begin
      if Textures[I].Buffer <> nil then
      begin
        Textures[I].Buffer := nil;
      end;
    end;
  end;

  For I := 1 To VertexBufferCount do
  begin
      if VertexBuffers[I].DXVertexBuffer <> nil then
      begin
        VertexBuffers[I].DXVertexBuffer := nil;
      end;
  end;
  
  //Zuallerletzt die DirectX-Variablen entfernen:
  if D3DDevice8 <> nil then
  begin
    D3DDevice8 := nil;
  end;
  if D3D8 <> nil then
  begin
    D3D8 := nil;
  end;
end;

//------------------------------------------------------------------------------
// r_InitScene()
// Inits the Scene
//------------------------------------------------------------------------------
procedure r_InitScene(Mode: SceneArguments); stdcall;
var
  ViewMatrix:  TD3DXMATRIX;
  matProj:     TD3DXMATRIX;
  Farbe:       D3DCOLORVALUE;
begin
    //save video mode (to restore)
    SceneConfig := Mode;

    If Assigned(D3DDevice8) = True then with D3DDevice8 do begin
    //Sprite-Interface erstellen:
    D3DXCreateSprite(D3DDevice8, Sprite);

    //Erstellen der Kamera:
    SetTransform(D3DTS_PROJECTION,ViewMatrix);

    D3DXMatrixPerspectiveFovLH(matProj,                  //Resultierende Matrix
                               Mode.vRad,                //Radius der Ansicht
                               Mode.vFormat,             //Auflösung
                               Mode.vNearClippingPlane,  // Mindeste Nähe
                               Mode.vFarClippingPlane);  // Maximal sichtbare Entfernung

    // use a far_plane of infinity for projection matrix

    // Limit of far_plane/(far_plane - near_plane)
    // as far_plane approaches infinity is 1.0
    matProj.m[2][2] := 1.0;

    // Limit of -far_plane*near_plane/(far_plane - near_plane)
    // as far_plane approaches infinity is -1.0
    matProj.m[3][2] := -1.0;

    SetTransform(D3DTS_PROJECTION, matProj);

    //set default material
    Farbe.r := 1.0;
    Farbe.g := 1.0;
    Farbe.b := 1.0;
    Farbe.a := 1.0;
    vMat.Diffuse := Farbe;
    vMat.Ambient := Farbe;
    vMat.Specular := Farbe;
    Farbe.r := 0.0;
    Farbe.g := 0.0;
    Farbe.b := 0.0;
    Farbe.a := 0.0;
    vMat.Emissive := Farbe;
    vMat.Power := 1.0;

    //Cullcomde disablen, d.h. die Rückseite von Polys nicht zeichnen. Ist schneller,
    //und  da unsere Models auch gut sind, brauchen wir es auch nicht.
    //Im abgesichterten Modus anzeigen:
    SetRenderState(D3DRS_CULLMODE, D3DCULL_CCW);

    //Texturfilter gegen LEGO-Steine
    SetTextureStageState(0,D3DTSS_MAGFILTER, D3DTEXF_LINEAR);
    SetTextureStageState(0,D3DTSS_MINFILTER, D3DTEXF_LINEAR);
    SetTextureStageState(0,D3DTSS_MIPFILTER, D3DTEXF_LINEAR);

    //für korrekte Lichtberechnungen
    SetRenderState(D3DRS_NORMALIZENORMALS, 1);

    If Mode.vFogEnabled = True then
    begin
      SetRenderState(D3DRS_FOGENABLE,      1);
      SetRenderState(D3DRS_FOGCOLOR,       Mode.vFogColor);

      If Mode.vFogDensity = 1.0  then
      begin
        SetRenderState(D3DRS_FOGTABLEMODE,   D3DFOG_LINEAR);
        SetRenderState(D3DRS_FOGSTART,       FtoDW(Mode.vFogBegin));
        SetRenderState(D3DRS_FOGEND,         FtoDW(Mode.vFarClippingPlane));
      end
      else
      begin
        SetRenderState(D3DRS_FOGTABLEMODE,   D3DFOG_EXP);
        SetRenderState(D3DRS_FOGDENSITY,     FtoDW(Mode.vFogDensity));
      end;
      //SetRenderState(D3DRS_RANGEFOGENABLE, 0);
    end
    else
    begin
      SetRenderState(D3DRS_FOGENABLE,      0);
    end;

    SetMaterial(vMat);
    
    SetRenderState(D3DRS_ZENABLE, 1);
    SetRenderState(D3DRS_LIGHTING, 1);
    //Configs fürs Alpha-Blending
    SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_TEXTURE );
    SetTextureStageState(0, D3DTSS_COLORARG2, D3DTA_DIFFUSE);
    SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_MODULATE);
    SetTextureStageState(0, D3DTSS_ALPHAARG1, D3DTA_TEXTURE);
    SetTextureStageState(0, D3DTSS_ALPHAARG2, D3DTA_CURRENT);
    SetTextureStageState(0, D3DTSS_ALPHAOP,   D3DTOP_SELECTARG1);
    end;
end;

//------------------------------------------------------------------------------
// r_RestoreScene()
// called when the window lost focus
//------------------------------------------------------------------------------
procedure r_RestoreScene(); stdcall;
begin
      D3DDevice8.Reset(D3DPP);
      r_InitScene(SceneConfig);
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
