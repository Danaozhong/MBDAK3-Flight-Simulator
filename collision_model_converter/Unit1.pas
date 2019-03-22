unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Math;

type
  Vector3D= RECORD
    X: Double;
    Y: Double;
    Z: Double;
  END;

  Triangles3D= RECORD
    Dot1: Vector3D;
    Dot2: Vector3D;
    Dot3: Vector3D;
    Used: Boolean;
  END;

  Box3D= RECORD
    X1, X2: Double;
    Y1, Y2: Double;
    Z1, Z2: Double;
  END;

  TForm1 = class(TForm)
    Shape1: TShape;
    Bevel1: TBevel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Button1: TButton;
    Label5: TLabel;
    Label6: TLabel;
    GroupBox1: TGroupBox;
    Label7: TLabel;
    x: TEdit;
    y: TEdit;
    Label8: TLabel;
    z: TEdit;
    Label9: TLabel;
    Button2: TButton;
    Button3: TButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    function ConvertMSHFile (vOriginal: String; vDestination: String): Boolean;
    function CheckPointBoxCollision(vPoint: Vector3D; vBox: Box3D): Boolean;
    function CheckTriangleBoxCollision(Triangle: Triangles3D; vBox: Box3D): Boolean;
    function Betrag(vWert: Double): Double;
    procedure Button2Click(Sender: TObject);
    function StrToFloatEx(vString: String): Real;
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

function TForm1.ConvertMSHFile (vOriginal: String; vDestination: String): Boolean;
  var F1:               TextFile;
  var vSuccess:         Boolean;
  var Line:             String;
  var Position:         Integer;
  var SubString1:       String;
  var SubString2:       String;

  var vVerticesCount:   Integer;
  var vAllVertices:     Integer;
  var vVerticesCountID: Integer;
  var vTriangleCount:   Integer;
  var vTriangleCountID: Integer;
  var vVertices:  Array of Vector3D;
  var vTriangles: Array of Triangles3D;
  var CurrentMode:      Integer;
  var vTrashCount:      Integer;
  var vTrashCountID:    Integer;

  var I, K, L, M:       Integer;
  var XMin, XMax,
      YMin, YMax,
      ZMin, ZMax:       Double;
  var CXMin, CXMax,
      CYMin, CYMax,
      CZMin, CZMax:     Double;
  var XDiv,
      YDiv,
      ZDiv:             Integer;
  var DeltaX,
      DeltaY,
      DeltaZ:           Double;
  var WidthX,
      WidthY,
      WidthZ:           Double;

  var TempBox:          Box3D;
  var TriangleList:     Array of Triangles3D;
  var TriangleCount:    Integer;
  var SpherePos:        Vector3D;
  var SphereRad:        Double;
begin
  //We will load the MSH-file.
  //1. Step: read the vertices
  //2. Step: read the triangles and connect them to the vertices
  //3. Step: write the informations into a file
  CurrentMode := 0;
  vVerticesCountID := 0;
  vTriangleCountID := 0;
  vTrashCountID := 0;
  vTrashCount := 0;
  vVerticesCount := 0;
  vTriangleCount := 0;
  vAllVertices := 0;
  AssignFile(F1, vOriginal);
  Reset(F1);

  try
  while not EOF(F1) do
  begin
    Readln(F1, Line);
    if Line <> '' then
    begin
      If CurrentMode = 3 then
      begin
        //read the triangle information
        //Dot1
        Position := Pos(' ', Line);
        Line := Copy(Line, Position + 1, 999);
        Position := Pos(' ', Line);
        SubString1 := Copy(Line, 1, Position -1);
        Line := Copy(Line, Position + 1, 999);
        //Dot2
        Position := Pos(' ', Line);
        SubString2 := Copy(Line, 1, Position -1);
        Line := Copy(Line, Position + 1, 999);
        //Dot3
        Position := Pos(' ', Line);
        Line := Copy(Line, 1, Position -1);

        //fill the triangle with the tree vertices
        vTriangles[vTriangleCountID].Dot1 := vVertices[vAllVertices + StrToInt(SubString1)];
        vTriangles[vTriangleCountID].Dot2 := vVertices[vAllVertices + StrToInt(SubString2)];
        vTriangles[vTriangleCountID].Dot3 := vVertices[vAllVertices + StrToInt(Line)];
        vTriangles[vTriangleCountID].Used := False;
        vTriangleCountID := vTriangleCountID + 1;
        If vTriangleCountID = vTriangleCount then
        begin
          vAllVertices := vAllVertices + vVerticesCount;
          CurrentMode := -10;
        end;
      end;
      if CurrentMode = 5 then
      begin
        vTriangleCount := vTriangleCount + StrToInt(Line);
        SetLength(vTriangles, vTriangleCount + 1);
        CurrentMode := 3;
      end;
      if CurrentMode = 9 then
      begin
        vTrashCountID := vTrashCountID + 1;
        If vTrashCountID = vTrashCount then
        begin
          CurrentMode := 5;
        end;
      end;
      if CurrentMode = 7 then
      begin
        vTrashCount := StrToInt(line);
        vTrashCountID := 0;
        CurrentMode := 9;
      end;
      If CurrentMode = 2 then
      begin
        //read the vertices
        Position := Pos(' ', Line);
        Line := Copy(Line, Position + 1, 999);
        //x
        Position := Pos(' ', Line);
        SubString1 := Copy(Line, 1, Position -1);
        Line := Copy(Line, Position + 1, 999);
        //y
        Position := Pos(' ', Line);
        SubString2 := Copy(Line, 1, Position -1);
        Line := Copy(Line, Position + 1, 999);
        //z
        Position := Pos(' ', Line);
        Line := Copy(Line, 1, Position -1);

        //Fill the values into the vVertices array
        vVertices[vAllVertices + vVerticesCountID].X := StrToFloatEx(SubString1) * 0.1;
        vVertices[vAllVertices + vVerticesCountID].Y := StrToFloatEx(SubString2) * 0.1;
        //for some reasons, the z-axis is inverted in some x-files...
        vVertices[vAllVertices + vVerticesCountID].Z := StrToFloatEx(Line) * -0.1;

        //Check for vertices
        vVerticesCountID := vVerticesCountID + 1;
        If vVerticesCountID = vVerticesCount then
        begin
          CurrentMode := 7;
        end;
      end;
      if CurrentMode = 4 then
      begin
        vVerticesCount := StrToInt(Line);
        SetLength (vVertices, vAllVertices + vVerticesCount);
        vVerticesCountID := 0;
        CurrentMode := 2;
      end;
      if (Copy (Line, 1, 1) = '"') and (CurrentMode <> -22) then
      begin
        CurrentMode := 4;
      end;
      if Copy (Line, 1, 9) = 'Materials' then
      begin
        CurrentMode := -22;
      end;

    end;
  end;
  CloseFile (F1);

  XMax := -1000;
  YMax := -1000;
  ZMax := -1000;
  XMin := 1000;
  YMin := 1000;
  ZMin := 1000;
  
  //now find the min/max
  For I := 0 To vTriangleCount - 1 do
  begin
    //x-extremes
    If vTriangles[I].Dot1.X > XMax then XMax := vTriangles[I].Dot1.X;
    If vTriangles[I].Dot2.X > XMax then XMax := vTriangles[I].Dot2.X;
    If vTriangles[I].Dot3.X > XMax then XMax := vTriangles[I].Dot3.X;

    If vTriangles[I].Dot1.X < XMin then XMin := vTriangles[I].Dot1.X;
    If vTriangles[I].Dot2.X < XMin then XMin := vTriangles[I].Dot2.X;
    If vTriangles[I].Dot3.X < XMin then XMin := vTriangles[I].Dot3.X;

    //y-extremes
    If vTriangles[I].Dot1.Y > YMax then YMax := vTriangles[I].Dot1.Y;
    If vTriangles[I].Dot2.Y > YMax then YMax := vTriangles[I].Dot2.Y;
    If vTriangles[I].Dot3.Y > YMax then YMax := vTriangles[I].Dot3.Y;

    If vTriangles[I].Dot1.Y < YMin then YMin := vTriangles[I].Dot1.Y;
    If vTriangles[I].Dot2.Y < YMin then YMin := vTriangles[I].Dot2.Y;
    If vTriangles[I].Dot3.Y < YMin then yMin := vTriangles[I].Dot3.Y;

    //z-extremes
    If vTriangles[I].Dot1.Z > ZMax then ZMax := vTriangles[I].Dot1.Z;
    If vTriangles[I].Dot2.Z > ZMax then ZMax := vTriangles[I].Dot2.Z;
    If vTriangles[I].Dot3.Z > ZMax then ZMax := vTriangles[I].Dot3.Z;

    If vTriangles[I].Dot1.Z < ZMin then ZMin := vTriangles[I].Dot1.Z;
    If vTriangles[I].Dot2.Z < ZMin then ZMin := vTriangles[I].Dot2.Z;
    If vTriangles[I].Dot3.Z < ZMin then ZMin := vTriangles[I].Dot3.Z;
  end;

  //if one of the points is in the current range
  XDiv := StrToInt(x.Text);
  YDiv := StrToInt(y.Text);
  ZDiv := StrToInt(z.Text);

  If XDiv < 1 then XDiv := 1;
  If YDiv < 1 then YDiv := 1;
  If ZDiv < 1 then ZDiv := 1;

  DeltaX := (XMax - XMin) / XDiv;
  DeltaY := (YMax - YMin) / YDiv;
  DeltaZ := (ZMax - ZMin) / ZDiv;

  //now, we'll have to write the file down.
  AssignFile(F1, vDestination);
  Rewrite(F1);

  //comment header
  Writeln (F1, '###########################################');
  Writeln (F1, '###########################################');
  Writeln (F1, '###### MBDAK III collision model ##########');
  Writeln (F1, '###########################################');
  Writeln (F1, '###########################################');

  For I := 1 to XDiv do
  begin
    //alle x-bereiche checken
    For K := 1 to YDiv do
    begin
      //alle y-bereiche checken
      For L := 1 to ZDiv do
      begin
        //alle z-bereiche checken
        TempBox.X1 := XMin + (I - 1) * DeltaX;
        TempBox.X2 := XMin + I * DeltaX;
        TempBox.Y1 := YMin + (K - 1) * DeltaY;
        TempBox.Y2 := YMin + K * DeltaY;
        TempBox.Z1 := ZMin + (L - 1) * DeltaZ;
        TempBox.Z2 := ZMin + L * DeltaZ;
        CXMax := -1000;
        CYMax := -1000;
        CZMax := -1000;
        CXMin := 1000;
        CYMin := 1000;
        CZMin := 1000;
        TriangleCount := 0;
        SetLength(TriangleList, 0);

        For M := 0 To vTriangleCount - 1 do
        begin
          if vTriangles[M].Used = False then
          begin
            //check if one of the points is in the current dev
            If CheckTriangleBoxCollision(vTriangles[M], TempBox) = True then
            begin
              vTriangles[M].Used := True;
              //get maximal dimensions...
              //trip1:
              if vTriangles[M].Dot1.X > CXMax then CXMax := vTriangles[M].Dot1.X;
              if vTriangles[M].Dot1.X < CXMin then CXMin := vTriangles[M].Dot1.X;
              if vTriangles[M].Dot1.Y > CYMax then CYMax := vTriangles[M].Dot1.Y;
              if vTriangles[M].Dot1.Y < CYMin then CYMin := vTriangles[M].Dot1.Y;
              if vTriangles[M].Dot1.Z > CZMax then CZMax := vTriangles[M].Dot1.Z;
              if vTriangles[M].Dot1.Z < CZMin then CZMin := vTriangles[M].Dot1.Z;
              //trip2:
              if vTriangles[M].Dot2.X > CXMax then CXMax := vTriangles[M].Dot2.X;
              if vTriangles[M].Dot2.X < CXMin then CXMin := vTriangles[M].Dot2.X;
              if vTriangles[M].Dot2.Y > CYMax then CYMax := vTriangles[M].Dot2.Y;
              if vTriangles[M].Dot2.Y < CYMin then CYMin := vTriangles[M].Dot2.Y;
              if vTriangles[M].Dot2.Z > CZMax then CZMax := vTriangles[M].Dot2.Z;
              if vTriangles[M].Dot2.Z < CZMin then CZMin := vTriangles[M].Dot2.Z;
              //trip3:
              if vTriangles[M].Dot3.X > CXMax then CXMax := vTriangles[M].Dot3.X;
              if vTriangles[M].Dot3.X < CXMin then CXMin := vTriangles[M].Dot3.X;
              if vTriangles[M].Dot3.Y > CYMax then CYMax := vTriangles[M].Dot3.Y;
              if vTriangles[M].Dot3.Y < CYMin then CYMin := vTriangles[M].Dot3.Y;
              if vTriangles[M].Dot3.Z > CZMax then CZMax := vTriangles[M].Dot3.Z;
              if vTriangles[M].Dot3.Z < CZMin then CZMin := vTriangles[M].Dot3.Z;

              //create the current triangle list
              Inc(TriangleCount);
              SetLength(TriangleList, TriangleCount + 1);
              TriangleList[TriangleCount] := vTriangles[M];
            end;
          end;
        end;

        //now, create the sphere....
        WidthX := CXMax - CXMin;
        WidthY := CYMax - CYMin;
        WidthZ := CZMax - CZMin;

        //the middlepoint
        SpherePos.X := CXMin + 0.5 * WidthX;
        SpherePos.Y := CYMin + 0.5 * WidthY;
        SpherePos.Z := CZMin + 0.5 * WidthZ;

        SphereRad := SQRT(Power(0.5 * WidthX, 2) + Power(0.5 * WidthY, 2) + Power(0.5 * WidthZ,2));

        if TriangleCount > 0 then
        begin
          //create the sphere
          Writeln (F1, 'CREATE=SPHERE');
          Writeln (F1, 'X=' + FloatToStr(SpherePos.X));
          Writeln (F1, 'Y=' + FloatToStr(SpherePos.Y));
          Writeln (F1, 'Z=' + FloatToStr(SpherePos.Z));
          Writeln (F1, 'RADIUS=' + FloatToStr(SphereRad));

          //write all triangles
          For M := 1 To TriangleCount do
          begin
            Writeln (F1, 'CREATE=TRIANGLE');
            Writeln (F1, 'P1X=' + FloatToStr(TriangleList[M].Dot1.X));
            Writeln (F1, 'P1Y=' + FloatToStr(TriangleList[M].Dot1.Y));
            Writeln (F1, 'P1Z=' + FloatToStr(TriangleList[M].Dot1.Z));
            Writeln (F1, 'P2X=' + FloatToStr(TriangleList[M].Dot2.X));
            Writeln (F1, 'P2Y=' + FloatToStr(TriangleList[M].Dot2.Y));
            Writeln (F1, 'P2Z=' + FloatToStr(TriangleList[M].Dot2.Z));
            Writeln (F1, 'P3X=' + FloatToStr(TriangleList[M].Dot3.X));
            Writeln (F1, 'P3Y=' + FloatToStr(TriangleList[M].Dot3.Y));
            Writeln (F1, 'P3Z=' + FloatToStr(TriangleList[M].Dot3.Z));
          end;
        end;
        //print the current box.
      end;
    end;
  end;

  //closefile and save
  CloseFile(F1);
  vSuccess := True;
  except
    vSuccess := False;
  end;

   RESULT := vSuccess;
end;

procedure TForm1.Button2Click(Sender: TObject);
  var Result: Boolean;
  var DestinationFile: String;
begin

  SaveDialog1.Execute;
  DestinationFile := SaveDialog1.FileName;
  If DestinationFile = '' then Exit;

  //call the convert function
  Result := ConvertMSHFile (Label4.Caption, DestinationFile);
  If Result = False then
  begin
    MessageDlg ('Error while converting.', mtError, [mbOk], 0);
  end
  else
  begin
    MessageDlg ('3D Model successfully converted.', mtInformation, [mbOk], 0);
  end;
end;

//FloatToStringEx (benutzt Punkte anstelle von Kommas)
function TForm1.StrToFloatEx(vString: String): Real;
  var vNewString: String;
begin
  vNewString := StringReplace(vString, '.', ',', [rfReplaceAll, rfIgnoreCase]);
  Result := StrToFloat (vNewString);
end;

function TForm1.Betrag(vWert: Double): Double;
begin
  if vWert < 0 then vWert := -vWert;
  RESULT := vWert;
end;

function TForm1.CheckTriangleBoxCollision(Triangle: Triangles3D; vBox: Box3D): Boolean;
begin
  if (CheckPointBoxCollision(Triangle.Dot1, vBox) = True) or
     (CheckPointBoxCollision(Triangle.Dot2, vBox) = True) or
     (CheckPointBoxCollision(Triangle.Dot3, vBox) = True) then
  begin
    RESULT := True;
  end
  else
  begin
    RESULT := False;
  end;
end;

function TForm1.CheckPointBoxCollision(vPoint: Vector3D; vBox: Box3D): Boolean;
  var Buffer: Double;
begin
   //prearrange box
   if vBox.X1 > vBox.X2 then
   begin
    Buffer := vBox.X2;
    vBox.X2 := vBox.X1;
    vBox.X1 := Buffer;
   end;
   if vBox.Y1 > vBox.Y2 then
   begin
    Buffer := vBox.Y2;
    vBox.Y2 := vBox.Y1;
    vBox.Y1 := Buffer;
   end;
   if vBox.Z1 > vBox.Z2 then
   begin
    Buffer := vBox.Z2;
    vBox.Z2 := vBox.Z1;
    vBox.Z1 := Buffer;
   end;

   //now, check coll
   if  (vPoint.X >= vBox.X1) and (vPoint.X <= vBox.X2)
   and (vPoint.Y >= vBox.Y1) and (vPoint.Y <= vBox.Y2)
   and (vPoint.Z >= vBox.Z1) and (vPoint.Z <= vBox.Z2) then
   begin
    RESULT := True;
   end
   else
   begin
    RESULT := False;
   end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  Close;
end;

procedure TForm1.Button1Click(Sender: TObject);
  var SourceFile: String;
begin
  OpenDialog1.Execute;
  SourceFile := OpenDialog1.FileName;
  If SourceFile = '' then
  begin
    Label4.Caption := 'none selected.';
    Exit;
  end;
  Label4.Caption := SourceFile;
end;

end.
