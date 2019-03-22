object Form1: TForm1
  Left = 409
  Top = 299
  BorderIcons = [biSystemMenu]
  BorderStyle = bsNone
  Caption = 'MBDAK 3 menu render window'
  ClientHeight = 668
  ClientWidth = 863
  Color = clBlack
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Visible = True
  WindowState = wsMaximized
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  PixelsPerInch = 96
  TextHeight = 13
  object lbl_Fonttype: TLabel
    Left = 104
    Top = 64
    Width = 3
    Height = 13
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object lbl_Title: TLabel
    Left = 40
    Top = 128
    Width = 553
    Height = 49
    Alignment = taCenter
    AutoSize = False
    Caption = 'Configuration'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWhite
    Font.Height = -24
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
    Layout = tlCenter
    Visible = False
  end
  object lbl_Error: TLabel
    Left = 8
    Top = 8
    Width = 529
    Height = 16
    AutoSize = False
    Color = clBlack
    Font.Charset = ANSI_CHARSET
    Font.Color = clWhite
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    Transparent = True
  end
  object OptionScreen: TPanel
    Left = 24
    Top = 184
    Width = 585
    Height = 193
    BevelOuter = bvNone
    Color = 3223876
    TabOrder = 0
    Visible = False
    object Shape2: TShape
      Left = 320
      Top = 24
      Width = 257
      Height = 161
      Brush.Style = bsClear
      Pen.Color = clWhite
    end
    object Label1: TLabel
      Left = 352
      Top = 88
      Width = 67
      Height = 13
      Caption = 'music volume:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      Transparent = True
    end
    object Label2: TLabel
      Left = 352
      Top = 136
      Width = 69
      Height = 13
      Caption = 'sound volume:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      Transparent = True
    end
    object Shape1: TShape
      Left = 16
      Top = 24
      Width = 297
      Height = 161
      Brush.Style = bsClear
      Pen.Color = clWhite
    end
    object Label3: TLabel
      Left = 216
      Top = 40
      Width = 63
      Height = 13
      Caption = 'texture detail:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      Transparent = True
    end
    object Label4: TLabel
      Left = 200
      Top = 104
      Width = 108
      Height = 13
      Caption = 'low                        high'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      Transparent = True
    end
    object Sld_music_volume: TTrackBar
      Left = 440
      Top = 80
      Width = 129
      Height = 33
      Ctl3D = False
      Max = 255
      ParentCtl3D = False
      PageSize = 20
      Frequency = 25
      TabOrder = 7
      TabStop = False
      ThumbLength = 25
      OnChange = Sld_music_volumeChange
    end
    object Box_ScreenRes: TComboBox
      Left = 24
      Top = 32
      Width = 161
      Height = 21
      AutoComplete = False
      AutoCloseUp = True
      BevelInner = bvNone
      BevelKind = bkFlat
      Style = csDropDownList
      Color = clBlack
      Ctl3D = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ItemHeight = 13
      ItemIndex = 0
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 0
      TabStop = False
      Text = '1024x768'
      Items.Strings = (
        '1024x768'
        '640x480'
        '800x600')
    end
    object Chk_enable_shadows: TCheckBox
      Left = 24
      Top = 64
      Width = 145
      Height = 17
      TabStop = False
      Caption = 'enable Shadows'
      Ctl3D = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 1
      OnClick = Chk_enable_shadowsClick
    end
    object Chk_aircraft_shadows: TCheckBox
      Left = 40
      Top = 88
      Width = 145
      Height = 17
      TabStop = False
      Caption = 'render aircraft shadow'
      Ctl3D = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 2
    end
    object Chk_terrain_shadows: TCheckBox
      Left = 40
      Top = 112
      Width = 145
      Height = 17
      TabStop = False
      Caption = 'render terrain shadows'
      Ctl3D = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 3
    end
    object Chk_enable_audio: TCheckBox
      Left = 328
      Top = 40
      Width = 145
      Height = 17
      TabStop = False
      Caption = 'enable audio'
      Ctl3D = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 4
      OnClick = Chk_enable_audioClick
    end
    object Chk_enable_music: TCheckBox
      Left = 336
      Top = 64
      Width = 81
      Height = 17
      TabStop = False
      Caption = 'enable music'
      Ctl3D = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 5
      OnClick = Chk_enable_musicClick
    end
    object Chk_enable_sound: TCheckBox
      Left = 336
      Top = 112
      Width = 97
      Height = 17
      TabStop = False
      Caption = 'enable sound fx'
      Ctl3D = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 6
      OnClick = Chk_enable_soundClick
    end
    object Sld_sound_volume: TTrackBar
      Left = 440
      Top = 136
      Width = 129
      Height = 33
      Ctl3D = False
      Max = 255
      ParentCtl3D = False
      PageSize = 20
      Frequency = 25
      TabOrder = 8
      TabStop = False
      ThumbLength = 25
      OnChange = Sld_sound_volumeChange
    end
    object Chk_enable_particle: TCheckBox
      Left = 24
      Top = 136
      Width = 145
      Height = 17
      TabStop = False
      Caption = 'enable particle fx'
      Ctl3D = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 9
    end
    object Chk_enable_fog: TCheckBox
      Left = 24
      Top = 160
      Width = 145
      Height = 17
      TabStop = False
      Caption = 'enable fog'
      Ctl3D = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 10
    end
    object Sld_TextureDetail: TTrackBar
      Left = 200
      Top = 64
      Width = 105
      Height = 33
      Ctl3D = False
      Max = 2
      Min = -2
      ParentCtl3D = False
      PageSize = 20
      Frequency = 25
      TabOrder = 11
      TabStop = False
      ThumbLength = 25
      OnChange = Sld_music_volumeChange
    end
    object Chk_FullScreen: TCheckBox
      Left = 184
      Top = 136
      Width = 121
      Height = 17
      TabStop = False
      Caption = 'use fullscreen mode'
      Ctl3D = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 12
    end
  end
  object Render_Timer: TTimer
    Tag = 1
    Enabled = False
    Interval = 100
    OnTimer = Render_TimerTimer
    Left = 8
    Top = 40
  end
  object Shoot_Timer1: TTimer
    Enabled = False
    Interval = 200
    OnTimer = Shoot_Timer1Timer
    Left = 40
    Top = 40
  end
  object Timer_Audio_Flow: TTimer
    Enabled = False
    Interval = 50
    OnTimer = Timer_Audio_FlowTimer
    Left = 72
    Top = 40
  end
  object Timer_Speed: TTimer
    Enabled = False
    Interval = 2000
    OnTimer = Timer_SpeedTimer
    Left = 104
    Top = 40
  end
end
