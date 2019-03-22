object Form1: TForm1
  Left = 601
  Top = 440
  BorderStyle = bsSingle
  Caption = 'Milkshape 3D ASCII to MBDAK III *.col file converter'
  ClientHeight = 250
  ClientWidth = 513
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Shape1: TShape
    Left = 0
    Top = 0
    Width = 513
    Height = 65
    Pen.Color = clWhite
  end
  object Bevel1: TBevel
    Left = -8
    Top = 64
    Width = 601
    Height = 17
    Shape = bsTopLine
  end
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 342
    Height = 29
    Caption = 'MBDAK III *.col model converter'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -24
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    Transparent = True
  end
  object Label2: TLabel
    Left = 8
    Top = 40
    Width = 462
    Height = 13
    Caption = 
      'This tool will help  you exporting a 3d model file into the MBDA' +
      'K III col file format'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label3: TLabel
    Left = 8
    Top = 128
    Width = 52
    Height = 13
    Caption = 'MS3D-File:'
  end
  object Label4: TLabel
    Left = 64
    Top = 128
    Width = 337
    Height = 13
    AutoSize = False
    Caption = 'none selected'
  end
  object Label5: TLabel
    Left = 16
    Top = 80
    Width = 465
    Height = 17
    AutoSize = False
    Caption = 
      'This small program will help you converting a 3d model file into' +
      ' the MBDAK III col file format by'
  end
  object Label6: TLabel
    Left = 16
    Top = 96
    Width = 459
    Height = 13
    Caption = 
      'reading a Milkshape 3D ASCII file of a 3D model. This tool will ' +
      'generate a new .col-MBDAK III file.'
  end
  object Button1: TButton
    Left = 408
    Top = 120
    Width = 89
    Height = 25
    Caption = 'Browse...'
    TabOrder = 0
    OnClick = Button1Click
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 160
    Width = 489
    Height = 49
    Caption = 'Sphere Infos'
    TabOrder = 1
    object Label7: TLabel
      Left = 8
      Top = 16
      Width = 25
      Height = 13
      Caption = 'div x:'
    end
    object Label8: TLabel
      Left = 168
      Top = 16
      Width = 25
      Height = 13
      Caption = 'div y:'
    end
    object Label9: TLabel
      Left = 360
      Top = 16
      Width = 25
      Height = 13
      Caption = 'div z:'
    end
    object x: TEdit
      Left = 48
      Top = 16
      Width = 89
      Height = 21
      TabOrder = 0
      Text = '1'
    end
    object y: TEdit
      Left = 200
      Top = 16
      Width = 89
      Height = 21
      TabOrder = 1
      Text = '1'
    end
    object z: TEdit
      Left = 392
      Top = 16
      Width = 89
      Height = 21
      TabOrder = 2
      Text = '1'
    end
  end
  object Button2: TButton
    Left = 400
    Top = 216
    Width = 105
    Height = 25
    Caption = 'Convert'
    TabOrder = 2
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 288
    Top = 216
    Width = 105
    Height = 25
    Caption = 'Quit'
    TabOrder = 3
    OnClick = Button3Click
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '|*.txt'
    Filter = 'Milkshape 3D ASCII file|*.txt'
    Left = 64
    Top = 216
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = '|*.col'
    Filter = 'MBDAK III Collision file|*.col'
    Left = 96
    Top = 216
  end
end
