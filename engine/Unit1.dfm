object Form1: TForm1
  Left = 351
  Top = 338
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'MBDAK 3 render window'
  ClientHeight = 453
  ClientWidth = 632
  Color = clBlack
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  Visible = True
  WindowState = wsMaximized
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  PixelsPerInch = 96
  TextHeight = 13
  object lbl_Fonttype: TLabel
    Left = 112
    Top = 40
    Width = 3
    Height = 13
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 169
    Height = 57
    Caption = 'management stuff'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    Visible = False
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 72
    Width = 169
    Height = 97
    Caption = 'game stuff'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    Visible = False
  end
  object t_RestorePlane: TTimer
    Enabled = False
    Interval = 500
    OnTimer = t_RestorePlaneTimer
    Left = 80
    Top = 88
  end
  object Shoot_Timer1: TTimer
    Enabled = False
    Interval = 200
    OnTimer = Shoot_Timer1Timer
    Left = 16
    Top = 88
  end
  object Timer_Light: TTimer
    Enabled = False
    Interval = 100
    OnTimer = Timer_LightTimer
    Left = 112
    Top = 88
  end
  object Timer_Speed: TTimer
    Enabled = False
    Interval = 2000
    OnTimer = Timer_SpeedTimer
    Left = 48
    Top = 88
  end
  object Timer_FPS: TTimer
    Enabled = False
    OnTimer = Timer_FPSTimer
    Left = 16
    Top = 24
  end
  object Render_Timer: TTimer
    Tag = 1
    Enabled = False
    Interval = 400
    OnTimer = Render_TimerTimer
    Left = 48
    Top = 24
  end
  object Timer_Audio_Flow: TTimer
    Enabled = False
    Interval = 100
    OnTimer = Timer_Audio_FlowTimer
    Left = 80
    Top = 24
  end
  object Timer_Explode: TTimer
    Enabled = False
    Interval = 6000
    OnTimer = Timer_ExplodeTimer
    Left = 144
    Top = 88
  end
end
