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

-= dedicated 2 =-

3dfx...
worlds fastest pc accelerators.

-= coded by =-
[3dfx] IceFire
*)

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, D3DX8, Direct3D8, D3DFile, D3DUtil, ExtCtrls, StdCtrls, Math,
  FMOD, FMODTypes, FMODErrors, ComCtrls, WinSock, ShellAPI;

  //predefined structures:
  //=======================
type
  //structures for the menu:
  MenuButton = RECORD
    ID:             Integer;
    XPOS:           Integer;
    YPOS:           Integer;
    Caption:        TLabel;
    Image_Normal:   TImage;
    Image_Down:     TImage;
    ClickArea:      TImage;
  end;

  //frames
  MenuScreen = RECORD
    Caption:        String;
    ID:             Integer;
    BGScreen:       TImage;
    Buttons:        Array of Integer;
    ButtonCount:    Integer;
  end;

  //sound struct
  TSound = RECORD
    Channel: Integer;
    Buffer: PFMusicModule;
  end;

  //vector struct
  Vector3D= RECORD
    X: Double;
    Y: Double;
    Z: Double;
  end;

  //3d models
  D3DMODELS = PACKED RECORD
        //Die allgemeinen 3D-Models, die über X-Files geladen werden:
        vModelDatas: CD3DMesh;
        //ist atm noch als RECORD verpackt, um später ggf. weitere Infos dazupacken zu können!
  end;

  //used for the starfield simulator
  Star = RECORD
        X, Y, Z, X2, Y2: Real;
        Speed: Real;
  end;

  TForm1 = class(TForm)
    Render_Timer: TTimer;
    lbl_Fonttype: TLabel;
    Shoot_Timer1: TTimer;
    Timer_Audio_Flow: TTimer;
    OptionScreen: TPanel;
    Box_ScreenRes: TComboBox;
    Chk_enable_shadows: TCheckBox;
    Chk_aircraft_shadows: TCheckBox;
    Chk_terrain_shadows: TCheckBox;
    Chk_enable_audio: TCheckBox;
    Chk_enable_music: TCheckBox;
    Chk_enable_sound: TCheckBox;
    Sld_music_volume: TTrackBar;
    Sld_sound_volume: TTrackBar;
    Label1: TLabel;
    Label2: TLabel;
    Shape1: TShape;
    Shape2: TShape;
    lbl_Title: TLabel;
    Chk_enable_particle: TCheckBox;
    Chk_enable_fog: TCheckBox;
    Timer_Speed: TTimer;
    lbl_Error: TLabel;
    Sld_TextureDetail: TTrackBar;
    Label3: TLabel;
    Label4: TLabel;
    Chk_FullScreen: TCheckBox;
    //form functions
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
    Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
    Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

    //gfx functions
    function InitDirectX: Integer;
    procedure InitScene;
    procedure RenderScene;
    procedure ReleaseScene;
    procedure Render3DModel (vModelID: Integer);
    procedure Render3DModelEx (vModelID: Integer);
    function FindDepthStencilFormat(vMinDepthBits: Integer; vMinStencilBits: Integer; TargetFormat: _D3DFORMAT): TD3DFormat;
    function ConfirmDevice(var pCaps: TD3DCaps8; dwBehavior: DWORD; Format: TD3DFormat): HResult;
    procedure DrawFireSprite(I: Integer);
    procedure CreateShootByPlayer(vPosition: Vector3D; vBULRef: Integer);
    function ChangeResolution(SizeX, SizeY, BPP: DWORD): Boolean;

    //file functions
    procedure LoadMap(FileName: String);
    procedure LoadConfig;
    function Load3DModel(vFileName: String): Integer;
    function IsFileInUse(vName: String): Boolean;

    //math funct
    function VectorYawPitchRoll(Vertex: Vector3D; Yaw: Double; Pitch: Double; Roll: Double): Vector3D;

    //timers
    procedure Render_TimerTimer(Sender: TObject);
    procedure Shoot_Timer1Timer(Sender: TObject);
    procedure Timer_SpeedTimer(Sender: TObject);

    //misc functions
    function StrToFloatEx(vString: String): Real;
    function StrToColor(vStr: String): TColor;
    function BoolToStrEx(const vVar: Boolean): String;
    function Betrag (vZahl: Double): Double;
    function GetIP: String;

    //frame functions
    function CreateButton(XPOS: Integer; YPOS: Integer; Caption: String): Integer;
    procedure ShowButton(ID: Integer; vVisible: Boolean);
    procedure ButtonMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);
    procedure ButtonMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);
    procedure ShowForm(ID: Integer; vVisible: Boolean);
    procedure SwitchIntroAway(Sender: TObject);
    procedure HideOptionScreen(SaveSettings: Boolean);
    procedure LoadOptionScreen;
    procedure DebugError (ErrorStr: String);

    //audio funct
    function PlayMusic(SoundBuffer: PFMusicModule; Looped: Boolean): Integer;
    function PlaySound(SoundBuffer: PFMusicModule; Looped: Boolean): Integer;
    function CreateSoundBufferFromFile(vFile: String): PFMusicModule;
    function CreateMusicBufferFromFile(vFile: String): PFMusicModule;
    procedure StopAudioBuffer(Channel: Integer);
    procedure SetVolume(Channel: Integer; Volume: Integer);
    function CheckIfAudioBufferIsPlayed(Channel: Integer): Boolean;
    procedure FlowMusic(Channel: Integer; Time: Integer; Down: Boolean; IsMusic: Boolean);
    procedure Timer_Audio_FlowTimer(Sender: TObject);

    //configuration funct
    procedure Sld_music_volumeChange(Sender: TObject);
    procedure Sld_sound_volumeChange(Sender: TObject);
    procedure Chk_enable_audioClick(Sender: TObject);
    procedure Chk_enable_musicClick(Sender: TObject);
    procedure Chk_enable_soundClick(Sender: TObject);
    procedure Chk_enable_shadowsClick(Sender: TObject);
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

  //Konstanten:
  //===========
const
  Pi180 = Pi/180.0; //Ein Winkel mit dieser Konstante multipliziert ergibt diesen Winkel im Bogenmaß
  D3D8T_CUSTOMVERTEX =D3DFVF_XYZ or D3DFVF_DIFFUSE or D3DFVF_NORMAL or D3DFVF_TEX1; //Die Art des Vertexes
  MAX_SHOTS = 100; //how many shots are allowed in the scene
  MAX_SMOKE_SPRITES = 70;
var

  //Systemvariablen:
  //============================================================================

  Form1:           TForm1;
  ApplicationPath: String;  //Pfad der Anwendung
  ConfigFilePath:  String;  //path to the configuration file
  M_CFG_FilePath:  String;  //path to the menu config file
  Minimized:       Boolean;

  //Spiele-Variablen
  //============================================================================
  Show_Renderframe:     Boolean; //if the preview wnd is displayed

  //parameter config
  DisableIntro:         Boolean; //dissable intro splash screen
  Disable3DStuff:       Boolean; //can be used to disable everything

  //steer vars
  GoLeft:               Boolean;
  GoRight:              Boolean;
  GoTop:                Boolean;
  GoDown:               Boolean;
  Descent:              Boolean;
  Climb:                Boolean;
  Shooting:             Boolean;

  //vars for the starfied
  var StarCount:        Integer;
  var MaxSpeed:         Integer;
  var MaxZ:             Integer;
  var Stars:            Array of Star;

  //vars that are saved in config files
  ScreenWidth:     Integer;
  ScreenHeight:    Integer;
  ColorDepth:      Integer;
  AudioLoaded:     Boolean;
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
  TextureDetail:   Integer;
  UseFullscreen:   Boolean;
  b_UseAudio:      Boolean;
  b_UseMusic:      Boolean;
  b_UseSounds:     Boolean;
  b_MusicVolume:   Integer;
  b_SoundVolume:   Integer;
  m_ScreenWidth:   Integer;
  m_ScreenHeight:  Integer;
  m_ColorDepth:    Integer;

  DEFAULT_BUTTON_COLOR:  TColor;
  SELECTED_BUTTON_COLOR: TColor;
  DEFAULT_BG_COLOR:      TColor;
  
  //help vars required to flow the audio buffers
  vTimerCurrentVol:Single;
  vTimerFinVol:    Integer;
  vTimerDown:      Boolean;
  vTimerVolStep:   Single;
  vTimerValue:     Integer;
  vTimerMaxValue:  Integer;
  vTimerChannel:   Integer;

  //music buffer ids
  vIntroMusic:     TSound;
  vMainMusic:      TSound;

  //sound buffer
  vIntroClkSound:  TSound;
  vClickSound:     TSound;

  //menu frame vars
  MenuForms:       Array of MenuScreen;
  Buttons:         Array of MenuButton;
  ButtonCount:     Integer;
  FormCount:       Integer;

  //form ids
  frm_Intro:       Integer;
  frm_Main:        Integer;
  frm_Option:      Integer;

  vInIntro:        Boolean;

  //button ids
  btn_NewGame:     Integer;
  btn_Option:      Integer;
  btn_Close:       Integer;
  btn_SaveConfig:  Integer;
  btn_IgnoreConfig:Integer;

  OptionScreen: RECORD
    vScreenResBox:   TComboBox;
    vUseShadows:     TCheckBox;
    vUsePlaneShad:   TCheckBox;
    vUseTerrainShad: TCheckBox;
    vUseAudio:       TCheckBox;
    vEnableMusic:    TCheckBox;
    vEnableSound:    TCheckBox;
    vMusicVolume:    TTrackBar;
    vSoundVolume:    TTrackBar;
  end;


  //DirectX-Variablen:
  //============================================================================

  //Main-Initialisierungsvariablen von Direct3D
  D3D8:               IDIRECT3D8;
  D3dDevCaps:         TD3DCaps8;

  //Die Direct3D-Device ermöglicht uns Zugriff auf das System
  D3DDevice8:         IDirect3DDevice8;
  D3DPP:              TD3DPRESENTPARAMETERS;  //D3D-Parameter
  D3DDM:              D3DDisplayMode;         //Der Displaymodus

  //Die 3D-Matrizen:
  WorldMatrix:    TD3DXMATRIX;
  TempMatrix:     TD3DXMATRIX;
  ViewMatrix:     TD3DXMATRIX;

  //Kameraposition
  Camera: RECORD
        X:  Real;
        Y:  Real;
        Z:  Real;
        AX: Real;
        AY: Real;
        AZ: Real;
  END;

  vRenderTexture:     IDIRECT3DTEXTURE8;
  vRenderSurface:     IDIRECT3DSURFACE8;
  vBackBuffer:        IDIRECT3DSURFACE8;

  //Sprites (fürs HUD, etc)
  Sprite:             ID3DXSprite;

  //Das Starfield im Vorschaufenster
  StarField:        IDIRECT3DTEXTURE8;
  StarA:            IDIRECT3DTEXTURE8;
  FireTexture:      IDIRECT3DTEXTURE8;

  //Blit-Daten:
  vPosition:          TD3DXVector2;
  Scaling:            TD3DXVector2;
  RCenter:            TD3DXVector2;

  //Render-Fenster
  vRECT:              TRECT;
  SRECT:              TRECT;

  //Die allg. 3D-Models (ohne jedgliche Transformation):
  MODMeshes: Array of D3DMODELS;
  MODCount: LongInt;

  //Skybox
  SkyBox: RECORD
        vSkyBox3DModel: Integer;            //Verweis auf ein MODMesh
        vDistanceToPlane: Real;             //Abstand zur Cam
        SkyTexture   : IDIRECT3DTEXTURE8;   //Textur
  end;

  //Spiele-Daten
  //============================================================================

  //Player-Array
  Player: RECORD
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
    HDistanceToCam:     Real;
    VDistanceToCam:     Real;
    vSmogParticle:      Array of Vector3D;
    vCurrentSmogParticle:Integer;
    vPoints:            Array of RECORD
      vPosition:        Vector3D;
      vName:            String;
    END;
    vEnginePoints:      Array of Vector3D;
    vPointCount:        Integer;
    vEnginePointCount:  Integer;
    vShoot_1_Source:    Vector3D;
    vShoot_2a_Source:   Vector3D;
    vShoot_2b_Source:   Vector3D;
    vShootMode:         Integer;
  end;

  //----------------------------------------------------------------------------
  // IDE-Bausteine
  //----------------------------------------------------------------------------
  vIDE: Array of RECORD
    vName:    String;
    vModelID: Integer;
  end;
  IDECount: Integer;

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
// DebugError()
// Shows an error
//------------------------------------------------------------------------------
procedure TForm1.DebugError (ErrorStr: String);
begin
  lbl_Error.Caption := ErrorStr;
  lbl_Error.BringToFront;
end;

//------------------------------------------------------------------------------
// ButtonMouseUp()
// manages the actions when clicking on a button
//------------------------------------------------------------------------------
procedure TForm1.ButtonMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);
  var ButtonID: Integer;
  var F1: TextFile;
  var FilePath: String;
begin
  ButtonID := TLabel(Sender).Tag;

  //restore button
  if Buttons[ButtonID].Caption.Visible = False then
  begin
    exit;
  end;

  Buttons[ButtonID].Caption.Font.Color := DEFAULT_BUTTON_COLOR;
  Buttons[ButtonID].Image_Normal.Visible := True;
  Buttons[ButtonID].Image_Down.Visible := False;

  If ButtonID = btn_NewGame then
  begin
    Show_RenderFrame := False;
    ReleaseScene;

    //start a new game
    FilePath := ApplicationPath + '\mbdak3' + GetIP + '.ini';
    If FileExists(FilePath) = False then
    begin
      try
      //write new config
      AssignFile(F1, FilePath);
      Rewrite(F1);

      Writeln (F1, 'MAP_NAME=' + ApplicationPath + '\maps\level1.map');

      CloseFile(F1);
      except
        ShowMessage ('ERROR: No write access to hard drive.');
      end;
    end;

    //just run game
    ShellExecute (Application.Handle, 'open',  PChar (ApplicationPath + '\engine.bat'), nil, nil, SW_SHOWNORMAL);
    Close;
  end
  else if ButtonID = btn_Option then
  begin
    Show_RenderFrame := False;
    LoadOptionScreen();
    ShowForm(frm_Main, False);
    ShowForm(frm_Option, True);
  end
  else If ButtonID = btn_Close then
  begin
    Show_RenderFrame := False;
    ReleaseScene;
    Close;
  end
  else if ButtonID = btn_IgnoreConfig then
  begin
    //go back to the menu
    HideOptionScreen(False);
    Show_RenderFrame := True;
    Render_Timer.Enabled := True;
    ShowForm(frm_Main, True);
    ShowForm(frm_Option, False);
  end
  else if ButtonId = btn_SaveConfig then
  begin
    //go back to the menu, but save settings n0w
    HideOptionScreen(True);
    Show_RenderFrame := True;
    Render_Timer.Enabled := True;
    ShowForm(frm_Main, True);
    ShowForm(frm_Option, False);
  end;
end;

//------------------------------------------------------------------------------
// ButtonMouseDown()
// manages a hover fx
//------------------------------------------------------------------------------
procedure TForm1.ButtonMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);
  var ButtonID: Integer;
begin
    ButtonID := TLabel(Sender).Tag;

    //restore button
    if Buttons[ButtonID].Caption.Visible = False then
    begin
      exit;
    end;
    //play sound
    vClickSound.Channel := PlaySound(vClickSound.Buffer, False);

    Buttons[ButtonID].Caption.Font.Color := SELECTED_BUTTON_COLOR;
    Buttons[ButtonID].Image_Normal.Visible := False;
    Buttons[ButtonID].Image_Down.Visible := True;
end;


//------------------------------------------------------------------------------
// CreateButton()
// creates a new button:
//------------------------------------------------------------------------------
function TForm1.CreateButton(XPOS: Integer; YPOS: Integer; Caption: String): Integer;
begin
  ButtonCount := ButtonCount + 1;
  SetLength (Buttons, ButtonCount + 1);

  Buttons[ButtonCount].Image_Normal := TImage.Create(Self);
  Buttons[ButtonCount].Image_Normal.Parent := Form1;
  Buttons[ButtonCount].Image_Normal.Picture.LoadFromFile('data\menu\gfx\button\up.bmp');
  Buttons[ButtonCount].Image_Normal.Left := XPOS;
  Buttons[ButtonCount].Image_Normal.Top := YPOS;
  Buttons[ButtonCount].Image_Normal.Width := 260;
  Buttons[ButtonCount].Image_Normal.Height := 30;
  Buttons[ButtonCount].Image_Normal.Visible := False;
  Buttons[ButtonCount].Image_Down := TImage.Create(Self);
  Buttons[ButtonCount].Image_Down.Parent := Form1;
  Buttons[ButtonCount].Image_Down.Picture.LoadFromFile('data\menu\gfx\button\down.bmp');
  Buttons[ButtonCount].Image_Down.Left := XPOS;
  Buttons[ButtonCount].Image_Down.Top := YPOS;
  Buttons[ButtonCount].Image_Down.Width := 260;
  Buttons[ButtonCount].Image_Down.Height := 30;
  Buttons[ButtonCount].Image_Down.Visible := False;

  Buttons[ButtonCount].Caption := TLabel.Create(Self);
  Buttons[ButtonCount].Caption.Parent := Form1;

  Buttons[ButtonCount].Caption.Left := XPOS;
  Buttons[ButtonCount].Caption.Top := YPOS;
  Buttons[ButtonCount].Caption.Caption := Caption;

  //set font
  Buttons[ButtonCount].Caption.Transparent := True;
  Buttons[ButtonCount].Caption.Font.Name := 'Tahoma';
  Buttons[ButtonCount].Caption.Font.Size := 16;
  Buttons[ButtonCount].Caption.Font.Color := DEFAULT_BUTTON_COLOR;

  //Set font to center of the button
  Buttons[ButtonCount].Caption.AutoSize := False;
  Buttons[ButtonCount].Caption.Width := 260;
  Buttons[ButtonCount].Caption.Height := 30;
  Buttons[ButtonCount].Caption.Alignment := taCenter;
  Buttons[ButtonCount].Caption.Layout := tlCenter;
  Buttons[ButtonCount].Caption.Visible := True;
  Buttons[ButtonCount].Caption.Tag := ButtonCount;
  Buttons[ButtonCount].Caption.Visible := False;

  //Ereignisse festlegen:
  Buttons[ButtonCount].Caption.OnMouseUp := ButtonMouseUp;
  Buttons[ButtonCount].Caption.OnMouseDown := ButtonMouseDown;
  RESULT := ButtonCount;
end;

//------------------------------------------------------------------------------
// ShowButton()
// hides/shows a button
//------------------------------------------------------------------------------
procedure TForm1.ShowButton(ID: Integer; vVisible: Boolean);
begin
  Buttons[ID].Caption.Visible := vVisible;
  Buttons[ID].Image_Normal.Visible := vVisible;
  If vVisible = False then Buttons[ID].Image_Down.Visible := vVisible;
  Buttons[ID].Caption.Font.Color := DEFAULT_BUTTON_COLOR;
end;

//------------------------------------------------------------------------------
// ShowForm()
// hides/shows a form
//------------------------------------------------------------------------------
procedure TForm1.ShowForm(ID: Integer; vVisible: Boolean);
  var I: Integer;
begin

  MenuForms[ID].BGScreen.Visible := vVisible;
  if vVisible = True then
  begin
    if MenuForms[ID].Caption <> '' then
    begin
      //use title
      lbl_Title.Caption := MenuForms[ID].Caption;
      lbl_Title.Visible := True;
      lbl_Title.BringToFront;
    end;
  end
  else
  begin
    lbl_Title.Visible := False;
  end;

  If MenuForms[ID].ButtonCount > 0 then
  begin
    For I := 1 To MenuForms[ID].ButtonCount do
    begin
      ShowButton(MenuForms[ID].Buttons[I], vVisible);
    end;
  end;

  lbl_Error.BringToFront;
end;

//------------------------------------------------------------------------------
// FormCreate()
// call on programm init
//------------------------------------------------------------------------------
procedure TForm1.FormCreate(Sender: TObject);
  var I          : Integer;
  var Parameters : String;
  var Position   : Integer;
  var vParamArray: Array Of String;
  var vParamCount: Integer;
begin
        //Systemvariabeln:
        ApplicationPath := ExtractFilePath (Application.ExeName);
        //Load parameters
        DisableIntro    := False;
        Disable3DStuff  := False;

        if ParamCount > 0 then
        begin
          //Mit Parameter gestartet
          for I := 1 to ParamCount do Parameters := Parameters +  ParamStr(I);

          vParamCount := 1;
          SetLength(vParamArray, vParamCount + 1);

          //filter begin str
          Position := Pos('-', Parameters);
          Parameters := Copy(Parameters, Position + 1, 999);

          //find all arguments
          Position := Pos('-', Parameters);
          While Position <> 0 do
          begin
            //get all parameters
            vParamArray[vParamCount] := Trim(Copy(Parameters, 1, Position - 1));
            Parameters := Copy(Parameters, Position + 1, 999);
            Inc(vParamCount);
            SetLength(vParamArray, vParamCount + 1);
            Position := Pos('-', Parameters);
          end;
          vParamArray[vParamCount] := Parameters;
          For I := 1 to vParamCount do
          begin
            If vParamArray[I] = 'nointro' then
            begin
              DisableIntro := True;
            end
            else If vParamArray[I] = 'no3d' then
            begin
              Disable3DStuff := True;
            end;
          end;
        end;

        ConfigFilePath := ApplicationPath + 'config\config.ini';
        M_CFG_FilePath := ApplicationPath + 'config\menu.ini';

        //initialize audio system
        FMOD_Load (nil);
        FSOUND_SetOutput (FSOUND_OUTPUT_DSOUND);
        FSOUND_SetDriver (0);
        FSOUND_SetMixer (FSOUND_MIXER_AUTODETECT);
        FSOUND_SetBufferSize (100);

        FSOUND_Init (44100, 128, FSOUND_INIT_GLOBALFOCUS or FSOUND_INIT_ENABLESYSTEMCHANNELFX or FSOUND_INIT_ACCURATEVULEVELS);

        //load conf
        LoadConfig;

        //DirectX starten:
        If InitDirectX <> 0 then
        begin
          ShowMessage ('Initialisation of DirectX failed.');
          Close;
        end;

        InitScene;
        LoadMap ('maps\menu.map');

        //Es gibt 0 Lichter in der Szene
        AudioLoaded := False;
        SetLength(vLAS, MAX_SHOTS + 1);
        SetLength(Player.vSmogParticle, MAX_SMOKE_SPRITES * Player.vEnginePointCount);

        //Die Position setzen für das Vorschaufenster:
        vRECT.Left := 35;
        vRECT.Top := 128;
        vRECT.Right := 235;
        vRECT.Bottom := 278;

        //Die Anzahl der 3d-Modelle festlegen (=0)
        MODCount := 0;

        //Ladepause:
        Application.ProcessMessages;
        Player.Speed := 0.1;

        //Load stars
        StarCount := 500;
        MaxZ := 500;
        MaxSpeed := 8;
        SetLength (Stars, StarCount + 1);
        Randomize;

        //die globale Spiel
        Show_Renderframe := False;
        Render_Timer.Enabled := False;

        FormCount := 1;
        ButtonCount := 0;

        //Load intro form
        SetLength(MenuForms, FormCount+1);
        MenuForms[FormCount].BGScreen := TImage.Create(Self);
        MenuForms[FormCount].BGScreen.Parent := Form1;
        MenuForms[FormCount].BGScreen.Picture.LoadFromFile('data\menu\gfx\intro.bmp');
        MenuForms[FormCount].BGScreen.Left := 0;
        MenuForms[FormCount].BGScreen.Top := 0;
        MenuForms[FormCount].BGScreen.Width := m_ScreenWidth;
        MenuForms[FormCount].BGScreen.Height := m_ScreenHeight;
        MenuForms[FormCount].BGScreen.Visible := True;
        MenuForms[FormCount].BGScreen.OnClick := SwitchIntroAway;
        MenuForms[FormCount].ButtonCount := 0;

        frm_Intro := FormCount;
        ShowForm(frm_Intro, False);

        //load main form
        FormCount := FormCount + 1;
        SetLength(MenuForms, FormCount+1);
        MenuForms[FormCount].BGScreen := TImage.Create(Self);
        MenuForms[FormCount].BGScreen.Parent := Form1;
        MenuForms[FormCount].BGScreen.Picture.LoadFromFile('data\menu\gfx\bg_rw.bmp');
        MenuForms[FormCount].BGScreen.Left := 0;
        MenuForms[FormCount].BGScreen.Top := 0;
        MenuForms[FormCount].BGScreen.Width := m_ScreenWidth;
        MenuForms[FormCount].BGScreen.Height := m_ScreenHeight;
        MenuForms[FormCount].BGScreen.Visible := True;
        MenuForms[FormCount].ButtonCount := 5;
        SetLength(MenuForms[FormCount].Buttons, MenuForms[FormCount].ButtonCount +1);

        MenuForms[FormCount].Buttons[1] := CreateButton(330, 140, 'New Game');
        MenuForms[FormCount].Buttons[2] := CreateButton(330, 200, 'Load Game');
        MenuForms[FormCount].Buttons[3] := CreateButton(330, 260, 'Options');
        MenuForms[FormCount].Buttons[4] := CreateButton(330, 320, 'Credits');
        MenuForms[FormCount].Buttons[5] := CreateButton(330, 380, 'Quit');

        //save button ids
        btn_NewGame := MenuForms[FormCount].Buttons[1];
        btn_Option := MenuForms[FormCount].Buttons[3];
        btn_Close := MenuForms[FormCount].Buttons[5];

        frm_Main := FormCount;
        ShowForm(frm_Main, False);

        //load option form
        FormCount := FormCount + 1;
        SetLength(MenuForms, FormCount+1);
        MenuForms[FormCount].BGScreen := TImage.Create(Self);
        MenuForms[FormCount].BGScreen.Parent := Form1;
        MenuForms[FormCount].BGScreen.Picture.LoadFromFile('data\menu\gfx\config.bmp');
        MenuForms[FormCount].BGScreen.Left := 0;
        MenuForms[FormCount].BGScreen.Top := 0;
        MenuForms[FormCount].BGScreen.Width := m_ScreenWidth;
        MenuForms[FormCount].BGScreen.Height := m_ScreenHeight;
        MenuForms[FormCount].BGScreen.Visible := True;
        MenuForms[FormCount].ButtonCount := 2;
        MenuForms[FormCount].Caption := 'Configuration';
        SetLength(MenuForms[FormCount].Buttons, MenuForms[FormCount].ButtonCount +1);

        MenuForms[FormCount].Buttons[1] := CreateButton(45, 380, 'back');
        MenuForms[FormCount].Buttons[2] := CreateButton(330, 380, 'save changes');

        //save config
        btn_IgnoreConfig := MenuForms[FormCount].Buttons[1];
        btn_SaveConfig := MenuForms[FormCount].Buttons[2];

        frm_Option := FormCount;
        ShowForm(frm_Option, False);

        If DisableIntro = False then
        begin
          ShowForm(frm_Intro, True);
          vIntroMusic.Channel := PlayMusic(vIntroMusic.Buffer, True);
          vInIntro := True;
        end
        else
        begin
          ShowForm(frm_Main, True);
          Show_Renderframe := True;
          ShowForm(frm_Intro, False);
          Render_Timer.Enabled := True;
          vMainMusic.Channel := PlayMusic(vMainMusic.Buffer, True);
          vInIntro := False;
        end;
end;


//------------------------------------------------------------------------------
// LoadConfig()
// loads all config files
//------------------------------------------------------------------------------
procedure TForm1.LoadConfig;
  var F1: TextFile;
  var Line, Command, Value: String;
  var Position: Integer;
begin
  //read config file

  //load default config
  UseShadows := False;
  RenderACShadows := False;
  RenderTRShadows := False;
  ScreenWidth := 640;
  ScreenHeight:= 480;
  ColorDepth := 32;
  m_ScreenWidth := 640;
  m_ScreenHeight := 480;
  m_ColorDepth := 32;
  UseAudio := False;
  UseMusic := False;
  UseSounds := False;
  MusicVolume := 0;
  SoundVolume := 0;
  EnableParticle := False;
  EnableFog := False;
  FarClippingPlane := 25;
  UseFullScreen := True;
  TextureDetail := 0;

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
                          else if Command = 'M_SCREENWIDTH' then
                          begin
                            m_ScreenWidth := StrToInt(Value);
                          end
                          else if Command = 'M_SCREENHEIGHT' then
                          begin
                            m_ScreenHeight := StrToInt(Value);
                          end
                          else if Command = 'M_COLOR_DEPTH' then
                          begin
                            m_ColorDepth := StrToInt(Value);
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
                          else if Command = 'USE_FULLSCREEN' then
                          begin
                            If Value='0' then UseFullScreen := False else UseFullScreen := True;
                          end
                          else if Command = 'TEXTURE_DETAIL' then
                          begin
                            TextureDetail := StrToInt(Value);
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

  //load settings for menu
  if AudioLoaded = False then
  begin
    DEFAULT_BUTTON_COLOR  := RGB(255,255,255);
    SELECTED_BUTTON_COLOR := RGB(255,100,0);
    DEFAULT_BG_COLOR      := RGB(255, 0, 0);

    If FileExists(M_CFG_FilePath) = True then
    begin
        If IsFileInUse (M_CFG_FilePath) = False then
        begin
            AssignFile(F1, M_CFG_FilePath);
            Reset(F1);
              while not EOF(F1) do
              begin
                    Readln(F1, Line);
                    If Line <> '' then
                    begin
                            Position := Pos ('=', Line);
                            Command := Copy (Line, 0, Position -1);
                            Value := Copy (Line, Position +1, 999);
                            if Command = 'BGCOLOR' then
                            begin
                              DEFAULT_BG_COLOR := StrToColor(Value);
                            end
                            else if Command = 'BUTTON_DEFAULT_COLOR' then
                            begin
                              DEFAULT_BUTTON_COLOR := StrToColor(Value);
                            end
                            else if Command = 'BUTTON_SELECT_COLOR' then
                            begin
                              SELECTED_BUTTON_COLOR := StrToColor(Value);
                            end
                            else if Command = 'INTRO_MUSIC' then
                            begin
                              If FileExists(Value) = True then
                                vIntroMusic.Buffer := CreateMusicBufferFromFile(Value)
                              else
                                vIntroMusic.Buffer := CreateMusicBufferFromFile('data\menu\audio\music\intro_music.mp3');
                            end
                            else if Command = 'MAIN_MUSIC' then
                            begin
                              If FileExists(Value) = True then
                                  vMainMusic.Buffer := CreateMusicBufferFromFile(Value)
                              else
                                vMainMusic.Buffer := CreateMusicBufferFromFile('data\menu\audio\music\main_music.mp3');
                            end
                            else if Command = 'INTRO_CLICK' then
                            begin
                              If FileExists(Value) = True then
                                  vIntroClkSound.Buffer := CreateSoundBufferFromFile(Value)
                              else
                                vIntroClkSound.Buffer := CreateSoundBufferFromFile('data\menu\audio\sounds\intro_click.mp3');
                            end
                            else if Command = 'DEFAULT_CLICK' then
                            begin
                              If FileExists(Value) = True then
                                  vClickSound.Buffer := CreateSoundBufferFromFile(Value)
                              else
                                  vClickSound.Buffer := CreateSoundBufferFromFile('data\menu\audio\sounds\click.mp3');
                            end
                            else if Command = 'CURSOR' then
                            begin
                                //Cursor ändern:
                                Screen.Cursors[10] := LoadCursorFromFile (PChar (Value));
                                Screen.Cursor := 10;
                            end;
                    end;
              end;
             CloseFile(F1);
        end;
    end;
    AudioLoaded := True;
  end;
end;

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
// FindDepthStencilFormat()
// Searchs an optimal Stencil and Z-Buffer format
//------------------------------------------------------------------------------
function TForm1.FindDepthStencilFormat(vMinDepthBits: Integer; vMinStencilBits: Integer; TargetFormat: _D3DFORMAT): TD3DFormat;
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
// ConfirmDevice()
// Checks capabilitys of the Video card
//------------------------------------------------------------------------------
function TForm1.ConfirmDevice(var pCaps: TD3DCaps8; dwBehavior: DWORD; Format: TD3DFormat): HResult;
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

//------------------------------------------------------------------------------
// InitDirectX()
// Initializes the Direct3D interface and sets up resolution
//------------------------------------------------------------------------------
function TForm1.InitDirectX: Integer;
var
        vResult:         HRESULT;                //Fehlerabfrage
        TnL:            Boolean;                //TnL-Unterstützung
        RenderMode:     Integer;                //Rendermode mit TnL oder ohne
begin
        //Auflösung einstellen:
        ChangeResolution(m_ScreenWidth, m_ScreenHeight, m_ColorDepth);
        Form1.Left := 0;
        Form1.Top := 0;
        Form1.Width := m_ScreenWidth;
        Form1.Height := m_ScreenHeight;

        If Disable3DStuff = True then
        begin
          Result := 0;
          Exit;
        end;

        //Initialisiern des DirectX-Interfaces:
        D3D8:=Direct3DCreate8(D3D_SDK_VERSION);
        if(D3D8=nil) then
        begin
              //Das Erstellen von DirectX ist fehlgeschlagen!
              Result := -1;
              Exit;
        end;

        D3D8.GetAdapterDisplayMode(D3DADAPTER_DEFAULT, D3DDM);
        ZeroMemory(@D3DPP,sizeof(D3DPP));

        //Windowed
        D3DPP.Windowed := True;
        D3DPP.SwapEffect:=D3DSWAPEFFECT_COPY_VSYNC;

        //Setzen des Handles:
        D3DPP.hDeviceWindow:=Form1.Handle;

        If D3DPP.Windowed = False then
        begin
          //Das sind die Einstellungen für Fullscreen
          D3DPP.BackBufferFormat := D3DDM.Format;
          D3DPP.BackBufferWidth   := m_ScreenWidth;
          D3DPP.BackBufferHeight  := m_ScreenHeight;
          D3DPP.BackBufferCount:= 1;
        end
        else
        begin
          //Im Window-Mode rendern:
          vResult := D3D8.GetAdapterDisplayMode(D3DADAPTER_DEFAULT, D3DDM);
          If FAILED(vResult) then
          begin
              Result := -2;
              Exit;
          end;
          D3DPP.BackBufferFormat := D3DDM.Format;
        end;
        
        // Unterstützung von Hardware T&L?
        D3D8.GetDeviceCaps(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL,D3dDevCaps);
        TnL := False;

        RenderMode := D3DCREATE_SOFTWARE_VERTEXPROCESSING;

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

        //Z-Buffer initialisieren:
        D3DPP.EnableAutoDepthStencil := TRUE;

        D3DPP.AutoDepthStencilFormat := FindDepthStencilFormat (16, 0, D3DDM.Format);

        //Erstellen der D3D-Device:
        vResult := D3D8.CreateDevice(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL,  Form1.Handle, RenderMode, D3DPP, D3DDevice8);
        if FAILED(vResult) then
        begin
              Result := -3;
              Exit;
        end;

        Result := 0;
end;

//------------------------------------------------------------------------------
// InitScene()
// Initializes the render scene
//------------------------------------------------------------------------------
procedure TForm1.InitScene;
var
  ViewMatrix:  TD3DXMATRIX;
  matProj:     TD3DXMATRIX;
  Farbe:       D3DCOLORVALUE;
  vMat:        D3DMATERIAL8;
begin
  If Disable3DStuff = True then Exit;
  
  If Assigned(D3DDevice8) = True then with D3DDevice8 do begin
    //create sprites
    D3DXCreateSprite(D3DDevice8, Sprite);

    //Erstellen der Kamera:
    SetTransform(D3DTS_PROJECTION, ViewMatrix);

    D3DXMatrixPerspectiveFovLH(matProj,                  //Resultierende Matrix
                               D3DX_PI/4,                //Radius der Ansicht
                               m_ScreenWidth/m_ScreenHeight, //Auflösung
                               0.1,                      // Mindeste Nähe
                               FarClippingPlane);        // Maximal sichtbare Entfernung

    SetTransform(D3DTS_PROJECTION, matProj );

    //Cullcomde disablen, d.h. die Rückseite von Polys nicht zeichnen. Ist schneller,
    //und  da unsere Models auch gut sind, brauchen wir es auch nicht.
    //Im abgesichterten Modus anzeigen:
    SetRenderState(D3DRS_CULLMODE, 0);

    //Lighting einschalten:
    SetRenderState(D3DRS_LIGHTING, 1);
    D3DDevice8.SetRenderState (D3DRS_SPECULARENABLE, 1);
    D3DDevice8.SetRenderState (D3DRS_DITHERENABLE, 1);

    Farbe.r := 1.0;
    Farbe.g := 1.0;
    Farbe.b := 1.0;
    Farbe.a := 0.0;
    vMat.Diffuse := Farbe;
    vMat.Ambient := Farbe;
    vMat.Specular := Farbe;


    Farbe.r := 0.0;
    Farbe.g := 0.0;
    Farbe.b := 0.0;
    Farbe.a := 0.0;

    vMat.Emissive := Farbe;
    vMat.Power := 0.0;

    D3DDevice8.SetMaterial(vMat);

    //Texturfilter gegen LEGO-Steine
    SetTextureStageState(0,D3DTSS_MAGFILTER, D3DTEXF_LINEAR);
    SetTextureStageState(0,D3DTSS_MINFILTER, D3DTEXF_LINEAR);

    //Weitere Renderstates:
    //Nebel:
    SetRenderState(D3DRS_FOGENABLE,      0);
    SetRenderState(D3DRS_FOGCOLOR,       $ffC8C4C4);
    SetRenderState(D3DRS_FOGTABLEMODE,   D3DFOG_NONE);
    SetRenderState(D3DRS_FOGVERTEXMODE,  D3DFOG_LINEAR);
    SetRenderState(D3DRS_RANGEFOGENABLE, 0);

    SetRenderState(D3DRS_ZENABLE, 1);

    //Configs fürs Alpha-Blending
    SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
    SetTextureStageState(0, D3DTSS_COLORARG2, D3DTA_DIFFUSE);
    SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_MODULATE);
    SetTextureStageState(0, D3DTSS_ALPHAARG1, D3DTA_TEXTURE);
    SetTextureStageState(0, D3DTSS_ALPHAARG2, D3DTA_DIFFUSE);

    //Sprites erstellen:
    D3DDevice8.CreateTexture(256, 256, 0, D3DUSAGE_RENDERTARGET, D3DFMT_R5G6B5, D3DPOOL_DEFAULT, vRenderTexture);
    vRenderTexture.GetSurfaceLevel(0, vRenderSurface);
    GetRenderTarget(vBackBuffer);
    end;
end;

//------------------------------------------------------------------------------
// RenderScene()
// Is doing all the stuff of rendering, etc.
//------------------------------------------------------------------------------
procedure TForm1.RenderScene;
        //Die Szene rendern:
var
  I: Integer;
  K: Integer;
  TempVector: Vector3D;
  L: Integer;
  vStencilBuffer: IDirect3DSurface8;
  vecDirection: Vector3D;
begin

  //----------------------------------------------------------------------------
  //Spiel-Resultate berechnen:  ------------------------------------------------
  //----------------------------------------------------------------------------
  Application.ProcessMessages;
  Sleep(0);
  If Disable3DStuff = True then Exit;
  
  With Player do
  begin
    If GoLeft = True then
    begin
      If HAcceleration > 0 then
      begin
        HAcceleration := HAcceleration - 12 * (0.1 + Player.Speed);
      end
      else if HAcceleration > -60 then
      begin
        HAcceleration := HAcceleration - 12 * (0.1 + Player.Speed);
      end;
    end
    else if GoRight
     = True then
    begin
      If HAcceleration < 0 then
      begin
        HAcceleration := HAcceleration + 12 * (0.1 + Player.Speed);
      end
      else if HAcceleration < 60 then
      begin
        HAcceleration := HAcceleration + 12 * (0.1 + Player.Speed);
      end;
    end
    else
    begin
      If Betrag(HAcceleration) > 0 then
      begin
        If Betrag(HAcceleration) < 8 then HAcceleration := 0;
        If HAcceleration > 0 then
        begin
          HAcceleration := HAcceleration -6;
        end
        else if HAcceleration < 0 then
        begin
          HAcceleration := HAcceleration +6;
        end;
      end;
    end;

    HWinkel := HWinkel + HAcceleration * 0.08;

    If GoTop = True then
    begin
      //Full Speed:
      If Timer_Speed.Enabled = False then
      begin
        Player.Speed := 0.2;
        Timer_Speed.Enabled := True;
      end;
    end;
    If GoDown = True then
    begin
      //Slow down:
      If Timer_Speed.Enabled = False then
      begin
        Player.Speed := 0.05;
        Timer_Speed.Enabled := True;
      end;
    end;

    If (Timer_Speed.Tag = 1) or (Timer_Speed.Enabled = False) then
    begin
      If Speed > 0.1 then Speed := Speed  - 0.005;
      If Speed < 0.1 then Speed := Speed  + 0.005;
    end;

    If Climb = True then
    begin
      If VAcceleration < 0 then
      begin
        VAcceleration := VAcceleration + 2;
      end
      else if VAcceleration < 45 then
      begin
        VAcceleration := VAcceleration + 1;
      end;
    end
    else if Descent = True then
    begin
      If VAcceleration > 0 then
      begin
        VAcceleration := VAcceleration - 2;
      end
      else if VAcceleration > -45 then
      begin
        VAcceleration := VAcceleration - 1;
      end;
    end
    else
    begin
      If Betrag(VAcceleration) > 0 then
      begin
        If Betrag(VAcceleration) < 2 then VAcceleration := 0;
        If VAcceleration > 0 then
        begin
          VAcceleration := VAcceleration -2;
        end
        else if VAcceleration < 0 then
        begin
          VAcceleration := VAcceleration +2;
        end;
      end;
    end;

    //get the direction vector
    vecDirection.X := 0;
    vecDirection.Y := 0;
    vecDirection.Z := -Speed;
    vecDirection := VectorYawPitchRoll(vecDirection, HWinkel, HAcceleration * 0.5, VAcceleration);

    //set up the direction vector
    XPOS := XPOS + vecDirection.X;
    YPOS := YPOS + vecDirection.Y;
    ZPOS := ZPOS + vecDirection.Z;


    //create a bullet while shooting
    if Shooting = True then
    begin
      if Shoot_Timer1.Enabled = False then
      begin
        Shoot_Timer1.Enabled := True;
        If vShootMode = 1 then
        begin
          //only use single shot
          CreateShootByPlayer(vShoot_1_Source, 1);
        end
        else if vShootMode = 2 then
        begin
          //create a double shot
          CreateShootByPlayer (vShoot_2a_Source, 1);
          CreateShootByPlayer(vShoot_2b_Source, 1);
        end;
      end;
    end;
  end;

  If assigned(D3DDevice8) then With D3DDevice8 Do begin
   GetDepthStencilSurface(vStencilBuffer);
    //render-to-texture
    SetRenderTarget(vRenderSurface,  vStencilBuffer);
    Clear(0, nil, D3DCLEAR_TARGET, $FF000000, 1.0, 0);
    BeginScene();
        //restore render & texture states
        SetRenderState( D3DRS_DITHERENABLE, 1 );
        SetRenderState( D3DRS_SPECULARENABLE, 1 );
        SetRenderState( D3DRS_LIGHTING, 0 );
        SetTextureStageState(0, D3DTSS_COLOROP, D3DTA_TEXTURE);
        SetTextureStageState(0, D3DTSS_COLORARG1,D3DTA_TEXTURE);

        Sprite._Begin();
        //set render RECT
        SRECT.Left := 0;
        SRECT.Top := 0;
        SRECT.Bottom := 256;
        SRECT.Right := 256;

        //draw bg texture
        Sprite.Draw(SkyBox.SkyTexture, @SRECT, nil, nil, 0, nil, D3DCOLOR_RGBA(255,255,255,255));

        //now, draw stars
        SRECT.Right := 1;
        SRECT.Bottom := 1;
        //render the Stars of the Starfield
        For i := 1 To StarCount do
        begin
          If Stars[i].Z < 10 then
          begin
            //set to a random position
            Stars[i].X := Random(256);
            Stars[i].Y := Random(256);
            Stars[i].Z := Random(MaxZ) + 100;
            Stars[I].Speed := Random(MaxSpeed) + 1;
          end;

          //update position
          Stars[I].X2 := Stars[I].X;
          Stars[I].Y2 := Stars[I].Y;
          Stars[I].X := Stars[I].X + (Stars[I].X2 - (128 + Player.HAcceleration * 2))/Stars[I].Z * 0.5 * Stars[I].Speed;
          Stars[I].Y := Stars[I].Y + (Stars[I].Y2 - (128 - Player.VAcceleration * 2))/Stars[I].Z * 0.5 * Stars[I].Speed;
          Stars[I].Z := Stars[I].Z - Stars[I].Speed;

          //render star
          vPosition.x := Trunc(Stars[I].X);
          vPosition.y := Trunc(Stars[I].Y);
          Scaling.x := 100/Stars[I].Z + 1;
          Scaling.y := 100/Stars[I].Z + 1;
          Sprite.Draw(StarA, @SRECT, @Scaling, nil, 0, @vPosition, D3DCOLOR_RGBA(255, 255, 255, 255));
        end;
        Sprite._End;
    EndScene();
    
    //set default render Target
    SetRenderTarget(vBackBuffer, vStencilBuffer);
    Clear(0, nil, D3DCLEAR_TARGET or D3DCLEAR_ZBUFFER, $FF000000, 1, 0);
    BeginScene();
        //----------------------------------------------------------------------
        //Kameraposition deklarieren: ------------------------------------------
        //----------------------------------------------------------------------
        Camera.X := Player.XPOS + Player.HDistanceToCam  * sin(Player.HWinkel * Pi180);
        Camera.Y := Player.YPOS + Player.VDistanceToCam;
        Camera.Z := Player.ZPOS + Player.HDistanceToCam  * cos(Player.HWinkel * Pi180);
        Camera.AX := Player.XPOS - SkyBox.vDistanceToPlane * sin(Player.HWinkel * Pi180);
        Camera.AY := Player.YPOS;
        Camera.AZ := Player.ZPOS - SkyBox.vDistanceToPlane * cos(Player.HWinkel * Pi180);

        //Kameraposition
        D3DXMatrixLookAtLH (ViewMatrix, D3DXVECTOR3(Camera.X, Camera.Y, Camera.Z),
                                     D3DXVECTOR3(Camera.AX, Camera.AY, Camera.AZ),
                                     D3DXVECTOR3(0, 1, 0));
                                     //D3DXVECTOR3(-Player.HAcceleration * 0.4 * Pi180 * cos(Player.HWinkel * Pi180), 1.0, Player.HAcceleration * 0.4 * Pi180 * sin(Player.HWinkel * Pi180)));
        SetTransform(D3DTS_VIEW,ViewMatrix);
        SetRenderState( D3DRS_DITHERENABLE, 1 );
        SetRenderState( D3DRS_SPECULARENABLE, 1 );
        SetRenderState( D3DRS_LIGHTING, 0 );

        //----------------------------------------------------------------------
        //SkyBox rendern: ------------------------------------------------------
        //----------------------------------------------------------------------
        SetRenderState(D3DRS_ZENABLE, 0);
        SetTexture(0, vRenderTexture);
        D3DXMatrixTranslation(WorldMatrix, Camera.AX + Player.HAcceleration * 0.01 * cos(Player.HWinkel * Pi180), Camera.AY - 0.7 * sin(Player.VAcceleration * Pi180), Camera.AZ - Player.HAcceleration * 0.01 * sin(Player.HWinkel * Pi180));
        D3DXMatrixRotationYawPitchRoll (TempMatrix, (Player.HWinkel+180) * Pi180, 0, 0);
        D3DXMatrixMultiply(WorldMatrix, TempMatrix, WorldMatrix);
        D3DXMatrixScaling(TempMatrix, SkyBox.vDistanceToPlane * 1.5, SkyBox.vDistanceToPlane * 1.5, SkyBox.vDistanceToPlane * 1.5);
        D3DXMatrixMultiply(WorldMatrix,TempMatrix,WorldMatrix);
        SetTransform(D3DTS_WORLD,WorldMatrix);
        Render3DModelEx (SkyBox.vSkyBox3DModel);
        SetRenderState(D3DRS_ZENABLE, 1);

        SetRenderState( D3DRS_LIGHTING, 1);

        //----------------------------------------------------------------------
        //Player rendern:  -----------------------------------------------------
        //----------------------------------------------------------------------
        //Position des Flugzeugs setzen:
        D3DXMatrixTranslation(WorldMatrix, Player.XPOS, Player.YPOS, Player.ZPOS);
        D3DXMatrixRotationYawPitchRoll(TempMatrix, Player.HWinkel * Pi180, Player.VAcceleration * Pi180, Player.HAcceleration * Pi180);
        D3DXMatrixMultiply(WorldMatrix,TempMatrix,WorldMatrix);
        D3DXMatrixScaling(TempMatrix, Player.vModelScale, Player.vModelScale, Player.vModelScale);
        D3DXMatrixMultiply(WorldMatrix,TempMatrix,WorldMatrix);
        SetTransform(D3DTS_WORLD,WorldMatrix);
        Render3DModel(Player.v3DModel);

        //----------------------------------------------------------------------
        //Schüsse rendern:  ----------------------------------------------------
        //----------------------------------------------------------------------
        for I := 1 to MAX_SHOTS do
        begin
            if vLAS[I].vActive = True then
            begin
              vLAS[I].vXPOS := vLAS[I].vXPOS + vLAS[I].vDirection.X;
              vLAS[I].vYPOS := vLAS[I].vYPOS + vLAS[I].vDirection.Y;
              vLAS[I].vZPOS := vLAS[I].vZPOS + vLAS[I].vDirection.Z;
              D3DXMatrixTranslation(WorldMatrix, vLAS[I].vXPOS, vLAS[I].vYPOS, vLAS[I].vZPOS);
              D3DXMatrixRotationYawPitchRoll(TempMatrix, vLAS[I].vYaw * Pi180, vLAS[I].vPitch * Pi180, 0);
              D3DXMatrixMultiply(WorldMatrix,TempMatrix,WorldMatrix);
              D3DXMatrixScaling(TempMatrix, vBUL[vLAS[I].vBULID].vScale, vBUL[vLAS[I].vBULID].vScale, vBUL[vLAS[I].vBULID].vScale);
              D3DXMatrixMultiply(WorldMatrix,TempMatrix,WorldMatrix);
              SetTransform(D3DTS_WORLD,WorldMatrix);
              Render3DModel(VIDE[vBUL[vLAS[I].vBULID].vIDE].vModelID);
            end;
        end;


        //----------------------------------------------------------------------
        //Partikel rendern:  ---------------------------------------------------
        //----------------------------------------------------------------------
        //enabling alpha
        If EnableParticle = True then
        begin
          SetRenderState(D3DRS_ALPHABLENDENABLE, 1);
          SetRenderState( D3DRS_ALPHATESTENABLE, 1);
          SetRenderState( D3DRS_ALPHAREF, 1);
          SetRenderState( D3DRS_ALPHAFUNC, D3DCMP_GREATEREQUAL );
          SetRenderState( D3DRS_SRCBLEND,  D3DBLEND_SRCALPHA );
          SetRenderState( D3DRS_DESTBLEND, D3DBLEND_ONE );
          SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_MODULATE);
          SetTextureStageState(0, D3DTSS_ALPHAARG1, D3DTA_TEXTURE);
          SetTextureStageState(0, D3DTSS_ALPHAARG2, D3DTA_TEXTURE);

          //Player-Smoke----------------------------------------------------------
            if Player.vEnginePointCount > 0 then
            begin
              For K := 1 To Player.vEnginePointCount do
              begin
                Player.vCurrentSmogParticle := Player.vCurrentSmogParticle + 2;
                If Player.vCurrentSmogParticle > MAX_SMOKE_SPRITES * Player.vEnginePointCount then
                begin
                  Player.vCurrentSmogParticle := 2;
                end;

                //Pitch miteinbeiehen:
                TempVector := Player.vEnginePoints[K];
                //we'll have to reverse the pitch and the roll due the rotated model
                TempVector := VectorYawPitchRoll(TempVector,Player.HWinkel, Player.HAcceleration, Player.VAcceleration);
                Player.vSmogParticle[Player.vCurrentSmogParticle].X := Player.XPOS + TempVector.X;
                Player.vSmogParticle[Player.vCurrentSmogParticle].Y := Player.YPOS + TempVector.Y;
                Player.vSmogParticle[Player.vCurrentSmogParticle].Z := Player.ZPOS + TempVector.Z;

                Player.vSmogParticle[Player.vCurrentSmogParticle - 1].X := Player.XPOS + TempVector.X - (vecDirection.X / 2);
                Player.vSmogParticle[Player.vCurrentSmogParticle - 1].Y := Player.YPOS + TempVector.Y - (vecDirection.Y / 2);
                Player.vSmogParticle[Player.vCurrentSmogParticle - 1].Z := Player.ZPOS + TempVector.Z - (vecDirection.Z / 2);

                //render the fire particels - we have to sort them by their z position in order to get a usable result.
                //for-next-loops do not support reverse countings (i--), so we'll go another way over the while.
                L := Player.vCurrentSmogParticle;
                while L > 1 do
                begin
                  L := L -1;
                  DrawFireSprite(L);
                end;

                L := MAX_SMOKE_SPRITES * Player.vEnginePointCount + 1;
                while L > Player.vCurrentSmogParticle + 1 do
                begin
                  L := L -1;
                  DrawFireSprite(L);
                end;
              end;
              //restore alpha states
            SetRenderState(D3DRS_ALPHABLENDENABLE, 0);
            SetRenderState( D3DRS_ALPHATESTENABLE, 0);
            SetRenderState( D3DRS_SRCBLEND,  D3DBLEND_ONE );
            SetRenderState( D3DRS_DESTBLEND, D3DBLEND_ZERO );
            SetTextureStageState(0, D3DTSS_ALPHAARG1, D3DTA_TEXTURE);
            SetTextureStageState(0, D3DTSS_ALPHAARG2, D3DTA_DIFFUSE);
        end;
      end;
      //restore render states
      SetTextureStageState(0, D3DTSS_COLOROP, D3DTA_TEXTURE);
      SetRenderState(D3DRS_FOGENABLE, 0 );

      //Szene ist fertig
      EndScene();

      //Blitten
      Present(nil, @vRECT, 0,nil);
      end;
    Application.ProcessMessages;
end;

//------------------------------------------------------------------------------
// FormKeyDown/FormKeyUp()
// Handles the keyboard input
//------------------------------------------------------------------------------
procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Show_RenderFrame = True then
  begin
    //left/right
    if Key = VK_LEFT then GoLeft := True;
    if Key = VK_RIGHT then GoRight := True;
    //descent/climg
    if Key = VK_UP then Descent := True;
    if Key = VK_DOWN then Climb := True;
    //brake
    if Key = VK_CONTROL then GoDown := True;
    //accelerate
    if Key = VK_SHIFT then GoTop := True;
    if Key = VK_SPACE then Shooting := True;
  end;

  //disable splash screen
  If vInIntro = True then
  begin
    SwitchIntroAway(Sender);
  end;
end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Show_RenderFrame = True then
  begin
  //Steuerung
    if Key = VK_LEFT then GoLeft := False;
    if Key = VK_RIGHT then GoRight := False;
    if Key = VK_UP then Descent := False;
    if Key = VK_DOWN then Climb := False;
    if Key = VK_CONTROL then GoDown := False;
    if Key = VK_SHIFT then GoTop := False;
    if Key = VK_SPACE then
    begin
      Shooting := False;
      Shoot_Timer1.Enabled := False;
    end;
  end;
end;

//------------------------------------------------------------------------------
// FormClose()
// Exit the application
//------------------------------------------------------------------------------
procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
        //Alle Daten wieder aufräumen:
        Show_Renderframe := False;
        Application.ProcessMessages;
        Action := caFree;
        Application.Terminate;
        ExitProcess(PROCESS_TERMINATE);
end;

//------------------------------------------------------------------------------
// ReleaseScene()
// Clean up all ressources
//------------------------------------------------------------------------------
procedure TForm1.ReleaseScene;
begin
  If Disable3DStuff = False then
  begin
    //Zuallerletzt die DirectX-Variablen entfernen:
    if assigned(D3DDevice8) then D3DDevice8 := nil;
    if assigned(D3D8) then D3D8 := nil;
  end;
  ShowCursor (True);
end;

//------------------------------------------------------------------------------
// Render_TimerTimer()
// manages all the render procedures
//------------------------------------------------------------------------------
procedure TForm1.Render_TimerTimer(Sender: TObject);
begin
  //Die Render-Prozedur wird mit einem Timer gestartet.
  //So stellt man sicher, dass das Formular bereits geladen ist.
  //Ist zwar etwas unüblich, funktioniert aber...
  Render_Timer.Enabled := False;
  While Show_RenderFrame = True do
  begin
    //Rendern
    Application.ProcessMessages;

    //check if the form has lost focus
    If Form1.Focused = False then
    begin
      Minimized := True;
      Application.ProcessMessages;
      Continue;
    end
    else
    begin
      RenderScene;
    end;
  end;

  Form1.Refresh;
end;

//------------------------------------------------------------------------------
// LoadMap()
// loads all map informations
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
begin
    AssignFile(F1, ApplicationPath + FileName);
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
                //Es sind die XPos / Ypos-Parameter
                if Command = 'PLAYERMODEL' then
                begin
                  //Vereinfachte Funktion zum Laden. Die Funktion gibt die 3D-Model-ID zurück.
                  Player.v3DModel := Load3DModel(Value);
                end
                else if Command = 'PLAYERMODELSCALE' then
                begin
                  //Skalierungsfaktor des 3D-Models:
                  Player.vModelScale := StrToFloatEx(Value);
                end
                else if Command = 'PLAYERMODELYDIFF' then
                begin
                  //Y-Differenz zur Kamera
                  Player.VDistanceToCam := StrToFloatEx(Value);
                end
                else if Command = 'PLAYERMODELCAMDIST' then
                begin
                  //Abstand des Flugzeuges zur Kamera
                  Player.HDistanceToCam := StrToFloatEx(Value);
                end
                else if Command = 'SKYBOX_STAR' then
                begin
                  D3DXCreateTextureFromFile(D3DDevice8, PChar(ApplicationPath + Value), StarA);
                end
                else if Command = 'SKYBOX_BACK' then
                begin
                  D3DXCreateTextureFromFile(D3DDevice8, PChar(ApplicationPath + Value), SkyBox.SkyTexture);
                end
                else if Command = 'SKYBOX_3DMODEL' then
                begin
                  SkyBox.vSkyBox3DModel := Load3DModel(ApplicationPath + Value);
                end
                else if Command = 'SKYBOX_DISTANCE' then
                begin
                  SkyBox.vDistanceToPlane := StrToInt(Value);
                end
                else if Command = 'ENGINE_FIRE_TEXTURE' then
                begin
                  D3DXCreateTextureFromFile(D3DDevice8, PChar(ApplicationPath + Value), FireTexture);
                end
                else if Command = 'PLAYER_SHOOT_MODE' then
                begin
                  //weapon mode
                  if Value = 'SINGLE' then
                  begin
                    Player.vShootMode := 1;
                  end
                  else if Value = 'DOUBLE' then
                  begin
                    Player.vShootMode := 2;
                  end
                  else
                  begin
                    Player.vShootMode := 0;
                  end;
                end
                else if Command = 'SINGLE_SHOT' then
                begin
                  For I := 1 To Player.vPointCount do
                  begin
                    If Player.vPoints[I].vName = Value then
                    begin
                      //Fireposition besetzen:            
                      Player.vShoot_1_Source := Player.vPoints[I].vPosition;
                      Break;
                    end;
                  end;
                end
                else if Command = 'DOUBLE_SHOT_1' then
                begin
                  For I := 1 To Player.vPointCount do
                  begin
                    If Player.vPoints[I].vName = Value then
                    begin
                      //double shot #2
                      Player.vShoot_2a_Source := Player.vPoints[I].vPosition;
                      Break;
                    end;
                  end;
                end
                else if Command = 'DOUBLE_SHOT_2' then
                begin
                  For I := 1 To Player.vPointCount do
                  begin
                    If Player.vPoints[I].vName = Value then
                    begin
                      //double shot #2a
                      Player.vShoot_2b_Source := Player.vPoints[I].vPosition;
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
                vIDE[IDECount].vModelID := Load3DModel(Command);
              end
              else if Command = 'BUL' then
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
                Player.vPointCount := Player.vPointCount + 1;
                SetLength(Player.vPoints, Player.vPointCount +1);
                Line := Copy (Line, 4, 999);
                //Den Namen auslesen:
                Position := Pos(',', Line);
                Player.vPoints[Player.vPointCount].vName := Trim(Copy(Line, 1, Position -1));
                Line := Trim (Copy(Line, Position + 2, 999));
                //load coords:
                Position := Pos(',', Line);
                Command := Trim(Copy(Line, 1, Position -1));
                Line := Trim (Copy(Line, Position + 2, 999));
                Player.vPoints[Player.vPointCount].vPosition.X := StrToFloatEx(Command);
                Position := Pos(',', Line);
                Command := Trim(Copy(Line, 1, Position -1));
                Value := Trim (Copy(Line, Position + 2, 999));
                Player.vPoints[Player.vPointCount].vPosition.Y := StrToFloatEx(Command);
                Player.vPoints[Player.vPointCount].vPosition.Z := StrToFloatEx(Value);
                if Player.vPoints[Player.vPointCount].vName = 'ENGINE' then
                begin
                  //Es handelt sich um die Deklaration einer neuen Turbine:
                  Player.vEnginePointCount := Player.vEnginePointCount + 1;
                  SetLength(Player.vEnginePoints, Player.vEnginePointCount + 1);
                  Player.vEnginePoints[Player.vEnginePointCount] := Player.vPoints[Player.vPointCount].vPosition;
                end;
              end;
            end;
          end;
          //Nächste Zeile auslesen
        end;
      CloseFile(F1);
end;

//------------------------------------------------------------------------------
// Render3DModel()
// renders a mesh with texture
//------------------------------------------------------------------------------
procedure TForm1.Render3DModel (vModelID: Integer);
var
  I:    Integer;
  vMesh: ID3DXMesh;
begin
      vMesh := MODMeshes[vModelID].vModelDatas.GetSysMemMesh;
      for I := 0 To MODMeshes[vModelID].vModelDatas.m_dwNumMaterials - 1 do
      begin

                //Do not use model materials - they disable any kind of lightning
                //D3DDevice8.SetMaterial(MODMeshes[vModelID].vModelDatas.m_pMaterials[I]);
                D3DDevice8.SetTexture(0, IDirect3DBaseTexture8(MODMeshes[vModelID].vModelDatas.m_pTextures^[I]));

                vMesh.DrawSubset(I);
      end;
end;

//------------------------------------------------------------------------------
// Render3DModelEx()
// renders a mesh without texture
//------------------------------------------------------------------------------
procedure TForm1.Render3DModelEx (vModelID: Integer);
var
  I:    Integer;
  vMesh: ID3DXMesh;
begin
      vMesh := MODMeshes[vModelID].vModelDatas.GetSysMemMesh;
      for I := 0 To MODMeshes[vModelID].vModelDatas.m_dwNumMaterials - 1 do
      begin
                vMesh.DrawSubset(I);
      end;
end;

//------------------------------------------------------------------------------
// Load3DModel()
// loads an x-File
//------------------------------------------------------------------------------
function TForm1.Load3DModel(vFileName: String): Integer;
  //Diese Funktion läd ein X-File in ein 3D-Modell-Mesh
var
  FileFolder: String;
begin
    FileFolder := ExtractFilePath (vFileName);
    MODCount := MODCount + 1;
    SetLength (MODMeshes, MODCount + 1);

    MODMeshes[MODCount].vModelDatas := CD3DMesh.Create;
    MODMeshes[MODCount].vModelDatas.Create_(D3DDevice8, PChar(vFileName), FileFolder);
    MODMeshes[MODCount].vModelDatas.SetFVF(D3DDevice8, D3D8T_CUSTOMVERTEX);
    Result := MODCount;
end;

//------------------------------------------------------------------------------
// VectorYawPitchRoll()
// rotates a vector
//------------------------------------------------------------------------------
function TForm1.VectorYawPitchRoll(Vertex: Vector3D; Yaw: Double; Pitch: Double; Roll: Double): Vector3D;
  var TempVertex: Vector3D;
  var RotateMatrix: D3DMATRIX;
  var V1: TD3DXVECTOR3;
  var V2: TD3DXVECTOR4;
begin
  //New rotation version over the D3DXMatrix.. the other one made some serious mistakes...
  D3DXMatrixRotationYawPitchRoll(RotateMatrix, Yaw * Pi180, Roll * Pi180, Pitch * Pi180);
  V1.x := Vertex.X;
  V1.y := Vertex.Y;
  V1.z := Vertex.Z;

  D3DXVec3Transform(V2, V1, RotateMatrix);
  TempVertex.X := V2.x;
  TempVertex.y := V2.y;
  TempVertex.z := V2.z;
  RESULT := TempVertex;
end;

//------------------------------------------------------------------------------
// StrToFloatEx()
// special functions to read floats out of the map file
//------------------------------------------------------------------------------
function TForm1.StrToFloatEx(vString: String): Real;
  var vNewString: String;
begin
  vNewString := StringReplace(vString, '.', ',', [rfReplaceAll, rfIgnoreCase]);
  Result := StrToFloat (vNewString);
end;

//------------------------------------------------------------------------------
// StrToColor()
// converts a color string into TCOLOR format
//------------------------------------------------------------------------------
function TForm1.StrToColor(vStr: String): TColor;
  var Position: Integer;
  var R:        Integer;
  var G:        Integer;
  var B:        Integer;
  var Value:    String;
begin
  Position := Pos(',', vStr);
  R := StrToInt(Copy(vStr, 0, Position -1));
  Value := Copy(vStr, Position + 1, 999);

  Position := Pos(',', Value);
  G := StrToInt(Copy(Value, 0, Position -1));
  B := StrToInt(Copy(Value, Position + 1, 999));

  RESULT := RGB (R, G, B);
end;

//------------------------------------------------------------------------------
// BoolToStrEx()
// converts a bool to a '1' or '0' string
//------------------------------------------------------------------------------
function TForm1.BoolToStrEx(const vVar: Boolean): String;
begin
  if vVar = True then RESULT := '1' else RESULT := '0';
end;

//------------------------------------------------------------------------------
// Betrag()
// ...
//------------------------------------------------------------------------------
function TForm1.Betrag (vZahl: Double): Double;
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
// sets the length of an vector to 1.
//------------------------------------------------------------------------------
function NormalizeVector(V: Vector3D): Vector3D;
  var vResult: Vector3D;
  var Length: Double;
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
// DrawFireSprite()
// renders a fire sprite
//------------------------------------------------------------------------------
procedure TForm1.DrawFireSprite(I: Integer);
begin
          D3DDevice8.SetTexture(0,FireTexture);
          D3DXMatrixTranslation(WorldMatrix, Player.vSmogParticle[i].X, Player.vSmogParticle[i].Y, Player.vSmogParticle[i].Z);
          D3DXMatrixRotationYawPitchRoll (TempMatrix, (Player.HWinkel + 180) * Pi180, 0, 0);
          D3DXMatrixMultiply(WorldMatrix, TempMatrix, WorldMatrix);

          D3DXMatrixScaling(TempMatrix, 0.07, 0.07, 0.07);
          D3DXMatrixMultiply(WorldMatrix,TempMatrix,WorldMatrix);
          D3DDevice8.SetTransform(D3DTS_WORLD,WorldMatrix);
          Render3DModelEx (SkyBox.vSkyBox3DModel);
end;

//------------------------------------------------------------------------------
// Shoot_Timer1Timer()
// manages the shoot intervals
//------------------------------------------------------------------------------
procedure TForm1.Shoot_Timer1Timer(Sender: TObject);
begin
  Shoot_Timer1.Enabled := False;
end;

//------------------------------------------------------------------------------
// CreateShootByPlayer()
// creates a shoot by player
//------------------------------------------------------------------------------
procedure TForm1.CreateShootByPlayer(vPosition: Vector3D; vBULRef: Integer);
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
    With Player do
    begin
    vTurnedVec := VectorYawPitchRoll(vPosition, HWinkel, HAcceleration, VAcceleration);
    vLAS[LASCount].vXPOS := XPOS + vTurnedVec.X;
    vLAS[LASCount].vYPOS := YPOS + vTurnedVec.Y;
    vLAS[LASCount].vZPOS := ZPOS + vTurnedVec.Z;
    vShootVec.X := 0;
    vShootVec.Y := 0;
    vShootVec.Z := vBUL[vBULRef].vSpeed * -1;
    vShootVec := VectorYawPitchRoll(vShootVec, HWinkel, HAcceleration, VAcceleration);
    vLAS[LASCount].vDirection := vShootVec;
    vLAS[LASCount].vYaw := HWinkel;
    vLAS[LASCount].vPitch := VAcceleration;
    vLAS[LASCount].vActive := True;
    end;

end;

//------------------------------------------------------------------------------
// ChangeResolution()
// changes screen resolution
//------------------------------------------------------------------------------
function TForm1.ChangeResolution(SizeX, SizeY, BPP: DWORD): Boolean;
var
 DeviceMode: TDeviceModeA;
 i: Integer;
begin
 i := 0;
 Result := False;
 while EnumDisplaySettings(nil, i, DeviceMode) do begin
   //alle devices durchgehen:
   with DeviceMode do
     if (dmPelsWidth = SizeX) and
        (dmPelsHeight = SizeY) and
        (dmBitsPerPel = BPP) then begin
       // Überprüfen, ob der Modus läuft
       if ChangeDisplaySettings(DeviceMode, CDS_TEST) = DISP_CHANGE_SUCCESSFUL then
       begin
           //Der Modus ist verfügbar!
           Result := True;
       end;

       if Result then 
         //Modus aktivieren:
         ChangeDisplaySettings(DeviceMode, CDS_FULLSCREEN)
     end;
   Inc(i);
 end;
end;


//------------------------------------------------------------------------------
// PlaySound()
// plays a sound
//------------------------------------------------------------------------------
function TForm1.PlaySound(SoundBuffer: PFMusicModule; Looped: Boolean): Integer;
  var Channel: Integer;
begin
    RESULT := -1;
    If UseAudio = False then exit;
    If UseSounds = False then exit;

    //play sound
    Channel := FSOUND_PlaySoundEx(FSOUND_FREE, SoundBuffer, nil, True);
    FSOUND_SetVolume(Channel, SoundVolume);

    If Looped = True then
    begin
        //In Endlosschleife spielen
        FSOUND_SetLoopMode(Channel,  FSOUND_LOOP_NORMAL);
    end
    else
    begin
        //Normal Abspielen:
        FSOUND_SetLoopMode(Channel,  FSOUND_LOOP_OFF);
    end;
    FSOUND_SetPaused(Channel, False);

    Result := Channel;
end;

//------------------------------------------------------------------------------
// CreateSoundBufferFromFile()
// loads a sound from file
//------------------------------------------------------------------------------
function TForm1.CreateSoundBufferFromFile(vFile: String): PFMusicModule;
begin
       //load sound
       Result := FSOUND_Sample_Load(FSOUND_FREE, PChar(vFile), FSOUND_2D, 0, 0);

       If Result = nil then
       begin
          DebugError('ERROR: ' + FMOD_ErrorString(FSOUND_GetError()) + ', ' + vFile);
       end;
end;

//------------------------------------------------------------------------------
// PlayMusic()
// plays a music buffer
//------------------------------------------------------------------------------
function TForm1.PlayMusic(SoundBuffer: PFMusicModule; Looped: Boolean): Integer;
  var Channel: Integer;
begin
    RESULT := -1;
    If UseAudio = False then exit;
    If UseMusic = False then exit;

    //the same for music
    Channel := FSOUND_PlaySoundEx(FSOUND_FREE, SoundBuffer, nil, True);
    FSOUND_SetVolume(Channel, MusicVolume);

    If Looped = True then
    begin
        //In Endlosschleife spielen
        FSOUND_SetLoopMode(Channel,  FSOUND_LOOP_NORMAL);
    end
    else
    begin
        //Normal Abspielen:
        FSOUND_SetLoopMode(Channel,  FSOUND_LOOP_OFF);
    end;
    FSOUND_SetPaused(Channel, False);
    Result := Channel;
end;

//------------------------------------------------------------------------------
// CreateMusicBufferFromFile()
// loads a music file
//------------------------------------------------------------------------------
function TForm1.CreateMusicBufferFromFile(vFile: String): PFMusicModule;
begin
       //Das ist  mit FMOS wesentlich leichter ^^
       Result := FSOUND_Sample_Load(FSOUND_FREE, PChar(vFile), FSOUND_2D, 0, 0);
       If Result = nil then
       begin
          DebugError('ERROR: ' + FMOD_ErrorString(FSOUND_GetError()) + ', ' + vFile);
       end;
end;

//------------------------------------------------------------------------------
// StopAudioBuffer()
// stops an audio channel
//------------------------------------------------------------------------------
procedure TForm1.StopAudioBuffer(Channel: Integer);
begin
  FSOUND_StopSound(Channel);
end;

//------------------------------------------------------------------------------
// SetVolume()
// sets a volume of a sound buffer
//------------------------------------------------------------------------------
procedure TForm1.SetVolume(Channel: Integer; Volume: Integer);
begin
   FSOUND_SetVolume(Channel, Volume);
end;

//------------------------------------------------------------------------------
// CheckIfAudioBufferIsPlayed()
// checls if a audio buffer is played
//------------------------------------------------------------------------------
function TForm1.CheckIfAudioBufferIsPlayed(Channel: Integer): Boolean;
begin
   RESULT := FSOUND_IsPlaying(Channel);

end;

//------------------------------------------------------------------------------
// FlowMusic()
// mutes/increased a music slowly
//------------------------------------------------------------------------------
procedure TForm1.FlowMusic(Channel: Integer; Time: Integer; Down: Boolean; IsMusic: Boolean);
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
  vTimerChannel := Channel;
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
        StopAudioBuffer(vTimerChannel);
      end;
    end
    else
    begin
      vTimerCurrentVol := vTimerFinVol;
    end;
    Timer_Audio_Flow.Enabled := False;
  end;
  //save audio volume
  SetVolume(vTimerChannel, Trunc(vTimerCurrentVol));
end;

//------------------------------------------------------------------------------
// SwitchIntroAway()
// hides the intro screen and flows music
//------------------------------------------------------------------------------
procedure TForm1.SwitchIntroAway(Sender:TObject);
begin
    if vInIntro = False then Exit;

    vInIntro := False;
    vClickSound.Channel := PlaySound(vIntroClkSound.Buffer, False);
    FlowMusic(vIntroMusic.Channel, 2000, True, True);

    while Timer_Audio_Flow.Enabled = True do
    begin
      Application.ProcessMessages;
    end;

    ShowForm(frm_Main, True);
    Show_Renderframe := True;
    ShowForm(frm_Intro, False);
    Render_Timer.Enabled := True;
    vMainMusic.Channel := PlayMusic(vMainMusic.Buffer, True);
end;

//------------------------------------------------------------------------------
// LoadOptionScreen()
// creates the option screen
//------------------------------------------------------------------------------
procedure TForm1.LoadOptionScreen();
  var
  Loop    :Integer;
  DevMode :TDevMode;
  ID      :Integer;
  t_SW    :Integer;
  t_SH    :Integer;
  t_CD    :Integer;
  i       :Integer;
  tmpStr  :String;
begin
    //read file
    LoadConfig;

    //set up colors
    OptionScreen.Color          := DEFAULT_BG_COLOR;
    Chk_enable_shadows.Color    := DEFAULT_BG_COLOR;
    Chk_aircraft_shadows.Color  := DEFAULT_BG_COLOR;
    Chk_terrain_shadows.Color   := DEFAULT_BG_COLOR;
    Chk_enable_particle.Color   := DEFAULT_BG_COLOR;
    Chk_enable_fog.Color        := DEFAULT_BG_COLOR;
    Chk_enable_music.Color      := DEFAULT_BG_COLOR;
    Chk_enable_sound.Color      := DEFAULT_BG_COLOR;
    Chk_enable_audio.Color      := DEFAULT_BG_COLOR;

    Loop := 0;
    Box_ScreenRes.Items.Clear;

    While EnumDisplaySettings (nil, Loop, DevMode) do
    begin
      With Devmode do
      begin
        t_SW := dmPelsWidth;
        t_SH := dmPelsHeight;
        t_CD := dmBitsperPel;
        Inc (Loop);
        if t_CD > 8 then
        begin
          tmpStr := Format ('%d x %d, %d bit', [t_SW, t_SH, t_CD]);
          //check if already exists
          if Box_ScreenRes.Items.Count > 0 then
          begin
            for i := 0 to Box_ScreenRes.Items.Count do
            begin
              if Box_ScreenRes.Items[i] = tmpStr then
              begin
                //already exists
                tmpStr := '';
                Break;
              end;
            end;
          end;

          if tmpStr = '' then
          begin
            //jump to next mode if alrady set
            Continue;
          end;

          //add new mode
          ID := Box_ScreenRes.Items.Add (tmpStr);

          //select active item
          if (t_SW = ScreenWidth) and (t_SH = ScreenHeight) and (t_CD = ColorDepth) then
          begin
            //set active str
            Box_ScreenRes.ItemIndex := ID;
          end;
        end;
      end;
    end;

    //enable settings
    if UseShadows = True then
    begin
      Chk_enable_shadows.Checked := True;
      Chk_aircraft_shadows.Enabled := True;
      Chk_terrain_shadows.Enabled := True;
    end
    else
    begin
      Chk_enable_shadows.Checked := False;
      Chk_aircraft_shadows.Enabled := False;
      Chk_terrain_shadows.Enabled := False;
    end;

    if RenderACShadows = True then Chk_aircraft_shadows.Checked := True else Chk_aircraft_shadows.Checked := False;
    if RenderTRShadows = True then Chk_terrain_shadows.Checked := True else Chk_terrain_shadows.Checked := False;
    if EnableFog = True then Chk_enable_fog.Checked := True else Chk_enable_fog.Checked := False;
    if EnableParticle = True then Chk_enable_particle.Checked := True else Chk_enable_particle.Checked := False;
    if UseFullScreen = True then Chk_FullScreen.Checked := True else Chk_FullScreen.Checked := False;


    //backup original settings
    b_UseAudio :=      UseAudio;
    b_UseMusic :=      UseMusic;
    b_UseSounds :=     UseSounds;
    b_MusicVolume :=   MusicVolume;
    b_SoundVolume :=   SoundVolume;

    Sld_music_volume.Position := MusicVolume;
    Sld_sound_volume.Position := SoundVolume;
    Sld_TextureDetail.Position := TextureDetail;
    
    if UseMusic = True then
    begin
      Chk_enable_music.Checked := True;
      Sld_music_volume.Enabled := True;
    end
    else
    begin
      Chk_enable_music.Checked := False;
      Sld_music_volume.Enabled := False;
    end;

    if UseSounds = True then
    begin
      Chk_enable_sound.Checked := True;
      Sld_sound_volume.Enabled := True;
    end
    else
    begin
      Chk_enable_sound.Checked := False;
      Sld_sound_volume.Enabled := False;
    end;

    if UseAudio = True then
    begin
      Chk_enable_audio.Checked := True;
      Chk_enable_music.Enabled := True;
      Chk_enable_sound.Enabled := True;
      Sld_music_volume.Enabled := True;
      Sld_sound_volume.Enabled := True;
    end
    else
    begin
      Chk_enable_audio.Checked := False;
      Chk_enable_music.Enabled := False;
      Chk_enable_sound.Enabled := False;
      Sld_music_volume.Enabled := False;
      Sld_sound_volume.Enabled := False;
    end;

    OptionScreen.Visible := True;
    StopAudioBuffer(vClickSound.Channel);
end;

//------------------------------------------------------------------------------
// HideOptionScreen()
// hides the option interface
//------------------------------------------------------------------------------
procedure TForm1.HideOptionScreen(SaveSettings: Boolean);
  var F1: TextFile;
  var Position: Integer;
  var TempStr:  String;
begin
  OptionScreen.Visible := False;
  SetVolume(vMainMusic.Channel, MusicVolume);

  if SaveSettings = False then
  begin
    MusicVolume := b_MusicVolume;
    SoundVolume := b_SoundVolume;
    UseSounds := b_UseSounds;
    UseAudio := b_UseAudio;
    UseMusic := b_UseMusic;

    If (UseAudio = True) and (UseMusic = True) then
    begin
      if CheckIfAudioBufferIsPlayed(vMainMusic.Channel) = False then
      begin
        vMainMusic.Channel := PlayMusic(vMainMusic.Buffer, True);
      end;
      SetVolume(vMainMusic.Channel, MusicVolume);
    end
    else
    begin
      //disable audio buffer
      StopAudioBuffer(vMainMusic.Channel);
    end;

  end
  else
  begin
    //update config (ignore audio config - they're already changed)
    UseShadows := Chk_enable_shadows.Checked;
    RenderACShadows := Chk_aircraft_shadows.Checked;
    RenderTRShadows := Chk_terrain_shadows.Checked;
    EnableParticle := Chk_enable_particle.Checked;
    EnableFog := Chk_enable_fog.Checked;
    UseFullScreen := Chk_FullScreen.Checked;
    TextureDetail := Sld_TextureDetail.Position;
    TempStr := Box_ScreenRes.Items[Box_screenRes.ItemIndex];
    Position := Pos(' ', TempStr);
    ScreenWidth := StrToInt(Copy(TempStr, 0, Position -1));
    TempStr := Copy(TempStr, Position + 3, 999);
    Position := Pos(',', TempStr);
    ScreenHeight := StrToInt(Copy(TempStr, 0, Position -1));
    TempStr := Copy(TempStr, Position + 2, 999);
    Position := Pos(' bit', TempStr);
    ColorDepth := StrToInt(Copy(TempStr, 0, Position -1));

    If IsFileInUse(ConfigFilePath) = False then
    begin
      DeleteFile(ConfigFilePath);

      //write new config
      AssignFile(F1, ConfigFilePath);
      Rewrite(F1);

      Writeln (F1, 'ENABLE_AUDIO=' + BoolToStrEx(UseAudio));
      Writeln (F1, 'USE_MUSIC=' + BoolToStrEx(UseMusic));
      Writeln (F1, 'USE_SOUNDS=' + BoolToStrEx(UseSounds));
      Writeln (F1, 'SOUND_VOLUME=' + IntToStr(SoundVolume));
      Writeln (F1, 'MUSIC_VOLUME=' + IntToStr(MusicVolume));
      Writeln (F1, 'SCREENWIDTH=' + IntToStr(ScreenWidth));
      Writeln (F1, 'SCREENHEIGHT=' + IntToStr(ScreenHeight));
      Writeln (F1, 'COLOR_DEPTH=' + IntToStr(ColorDepth));
      Writeln (F1, 'M_SCREENWIDTH=' + IntToStr(m_ScreenWidth));
      Writeln (F1, 'M_SCREENHEIGHT=' + IntToStr(m_ScreenHeight));
      Writeln (F1, 'M_COLOR_DEPTH=' + IntToStr(m_ColorDepth));
      Writeln (F1, 'FAR_CLIPPING_PLANE=' + IntToStr(FarClippingPlane));
      Writeln (F1, 'USE_STENCIL=' + BoolToStrEx(USeShadows));
      Writeln (F1, 'RENDER_AIRCRAFT_SHADOWS=' + BoolToStrEx(RenderACShadows));
      Writeln (F1, 'RENDER_TERRAIN_SHADOWS=' + BoolToStrEx(RenderTRShadows));
      Writeln (F1, 'USE_PARTICLE=' + BoolToStrEx(EnableParticle));
      Writeln (F1, 'TEXTURE_DETAIL=' + IntToStr(TextureDetail));
      Writeln (F1, 'FULLSCREEN=' + BoolToStrEx(UseFullScreen));
      Writeln (F1, 'USE_FOG=' + BoolToStrEx(EnableFog));
      CloseFile(F1);
    end;
  end;
end;

//------------------------------------------------------------------------------
// Sld_music_volumeChange()
// tests new volume
//------------------------------------------------------------------------------
procedure TForm1.Sld_music_volumeChange(Sender: TObject);
begin
  MusicVolume := Sld_music_volume.Position;
  SetVolume(vMainMusic.Channel, MusicVolume);
end;

//------------------------------------------------------------------------------
// Sld_sound_volumeChange()
// tests new volume
//------------------------------------------------------------------------------
procedure TForm1.Sld_sound_volumeChange(Sender: TObject);
begin
  StopAudioBuffer(vClickSound.Channel);
  vClickSound.Channel := PlaySound(vClickSound.Buffer, False);
  SoundVolume := Sld_sound_volume.Position;
  SetVolume(vClickSound.Channel, SoundVolume);
end;

//------------------------------------------------------------------------------
// Sld_sound_volumeChange()
// disable/enable audio buffers complete
//------------------------------------------------------------------------------
procedure TForm1.Chk_enable_audioClick(Sender: TObject);
begin
  If Chk_enable_audio.Checked = True then
  begin
    Chk_enable_music.Enabled := True;
    Chk_enable_sound.Enabled := True;
    UseAudio := True;
  end
  else
  begin
    Chk_enable_music.Enabled := False;
    Chk_enable_sound.Enabled := False;
    UseAudio := False;
  end;
  Chk_enable_musicClick(Sender);
  Chk_enable_soundClick(Sender);
end;

//------------------------------------------------------------------------------
// Chk_enable_musicClick()
// enable/disables other option items
//------------------------------------------------------------------------------
procedure TForm1.Chk_enable_musicClick(Sender: TObject);
begin
  If (Chk_enable_music.Checked = True) and (UseAudio = True) then
  begin
    If CheckIfAudioBufferIsPlayed(vMainMusic.Channel) = False then
    begin
      Sld_music_volume.Enabled := True;
      UseMusic := True;
      vMainMusic.Channel := PlayMusic(vMainMusic.Buffer, True);
    end;
    SetVolume(vMainMusic.Channel, Sld_music_volume.Position);
  end
  else
  begin
    Sld_music_volume.Enabled := False;
    UseMusic := False;
    StopAudioBuffer(vMainMusic.Channel);
  end;
end;

//------------------------------------------------------------------------------
// Chk_enable_soundClick()
// enable/disables other option items
//------------------------------------------------------------------------------
procedure TForm1.Chk_enable_soundClick(Sender: TObject);
begin
  If (Chk_enable_sound.Checked = True) and (UseAudio = True) then
  begin
      Sld_sound_volume.Enabled := True;
      UseSounds := True;
  end
  else
  begin
    Sld_sound_volume.Enabled := False;
    UseSounds := False;
    StopAudioBuffer(vClickSound.Channel);
  end;
end;

//------------------------------------------------------------------------------
// Chk_enable_shadowsClick()
// enable/disables other option items
//------------------------------------------------------------------------------
procedure TForm1.Chk_enable_shadowsClick(Sender: TObject);
begin
  If Chk_enable_shadows.Checked = True then
  begin
    Chk_aircraft_shadows.Enabled := True;
    Chk_terrain_shadows.Enabled := True;
  end
  else
  begin
    Chk_aircraft_shadows.Enabled := False;
    Chk_terrain_shadows.Enabled := False;
  end;
end;

//------------------------------------------------------------------------------
// Timer_SpeedTimer()
// used to have a plane turbo
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
// GetIP()
// returns the sys ip addr (required to have an specific pc name
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

end.
