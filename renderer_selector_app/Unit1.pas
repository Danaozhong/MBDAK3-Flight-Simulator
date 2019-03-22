unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
  TForm1 = class(TForm)
    Image1: TImage;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    GroupBox1: TGroupBox;
    rad_DX: TRadioButton;
    rad_GL: TRadioButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  //check if file are existant
  if (FileExists('3ddrv/3ddrv.dll.opengl') = False) or
     (FileExists('3ddrv/3ddrv.dll.d3d') = False) then
  begin
    MessageDlg('Unable to open the 3D data configuration!', mtInformation, [mbOk], 0);
    Close;
    Exit;
  end;
  
  If rad_DX.Checked = True then
  begin
    //save dx
    DeleteFile ('3ddrv.dll');
    CopyFile('3ddrv/3ddrv.dll.d3d', '3ddrv.dll', True);
  end
  else
  begin
    //save gl
    DeleteFile ('3ddrv.dll');
    CopyFile('3ddrv/3ddrv.dll.opengl', '3ddrv.dll', True);
  end;
  Close;
end;

end.
