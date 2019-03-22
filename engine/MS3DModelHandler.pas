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

MBDAK3 // Milkshape3D-Mesh-Loader

Parts made by Lithander (lithander@gmx.de)

*)
unit MS3DModelHandler;
interface

uses Structures, SysUtils, Messages, Variants, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Math, WinSock, Models3D;

function LoadMS3DModel(aPath : String; TexturePath: String): Model3D;

implementation

uses Windows, Classes;
type
//Lets start with setting up some data structures that we want to read
//from the Milkshape file...

MS3D_Header = Packed RECORD
    ID               : Array[0..9] of Char;
    Version          : Integer;
end;

MS3D_Vertex = Packed RECORD
    Flags            : Byte;
    Position         : TSingle3;
    BoneID           : ShortInt;
    refCount         : Byte;
end;

MS3D_Triangle = Packed RECORD
    Flags             : Word;
    VertexIndices     : TWord3;
    VertexNormals     : TSingle3X3;
    S,T               : TSingle3;
    SmoothingGroup    : Byte;
    GroupIndex        : Byte;
end;

MS3D_Group = Packed RECORD
    Flags             : Byte;
    Name              : array[0..31] of Char;
    nTriangles        : Word;
    TriangleIndices   : array of Word;
    MaterialIndex     : Byte;
end;

MS3D_Material = Packed RECORD
    Name              : array[0..31] of char;
    Ambient           : TSingle4;
    Diffuse           : TSingle4;
    Specular          : TSingle4;
    Emissive          : TSingle4;
    Shininess         : Single;
    Transparency      : Single;
    Mode              : Byte;
    Texture           : array[0..127] of Char;
    Alphamap          : array[0..127] of Char;
end;


var Path: String;
var DefaultPath: String; //alternative path if main math is inexistant

//------------------------------------------------------------------------------
// LoadHeader()
// skips the ms3d-header over
//------------------------------------------------------------------------------
procedure LoadHeader(aModel: Model3D; aStream: TStream);
var MS3dHeader: MS3D_Header;
begin
  with aModel do
  begin
    //informations are not used, just skip them
    aStream.Read(MS3dHeader, SizeOf(MS3dHeader));
  end;
end;

//------------------------------------------------------------------------------
// LoadVertices()
// loads vertex buffer
//------------------------------------------------------------------------------
procedure LoadVertices(aModel: Model3D; aStream: TStream);
var MS3dVertex: MS3D_Vertex;
    I: Integer;
begin
  with aModel do
  begin
    aStream.Read(numVertices, SizeOf(NumVertices));
    SetLength(Vertices, numVertices);
    for I := 0 to numVertices - 1 do
    begin
      aStream.Read(MS3dVertex, SizeOf(ms3dVertex));
      //multiply the vertices with 0.1 to fit it into the default matrices
      //invert z axis!
      Vertices[I].X := MS3dVertex.Position[0] * 0.1;
      Vertices[I].Y := MS3dVertex.Position[1] * 0.1;
      Vertices[I].Z := -MS3dVertex.Position[2] * 0.1;
    end;
  end;
end;

//------------------------------------------------------------------------------
// LoadTriangles()
// load index buffer
//------------------------------------------------------------------------------
procedure LoadTriangles(aModel: Model3D; aStream: TStream);
var MS3dTriangle: MS3D_Triangle;
    I:            Integer;
begin
  with aModel do
  begin
    aStream.Read(numTriangles, SizeOf(NumTriangles));
    SetLength(Triangles, numTriangles);
    for I := 0 to NumTriangles - 1 do
    begin
      aStream.Read(MS3dTriangle, SizeOf(MS3dTriangle));
      //reverse vertex order (to have the 3d models fit in the directX-API)
      Triangles[I].VertexIndices[2]    := MS3dTriangle.VertexIndices[0];
      Triangles[I].VertexIndices[1]    := MS3dTriangle.VertexIndices[1];
      Triangles[I].VertexIndices[0]    := MS3dTriangle.VertexIndices[2];
      Vertices[Triangles[I].VertexIndices[2]].TU := MS3dTriangle.S[0];
      Vertices[Triangles[I].VertexIndices[1]].TU := MS3dTriangle.S[1];
      Vertices[Triangles[I].VertexIndices[0]].TU := MS3dTriangle.S[2];
      Vertices[Triangles[I].VertexIndices[2]].TV := MS3dTriangle.T[0];
      Vertices[Triangles[I].VertexIndices[1]].TV := MS3dTriangle.T[1];
      Vertices[Triangles[I].VertexIndices[0]].TV := MS3dTriangle.T[2];
      Vertices[Triangles[I].VertexIndices[2]].NX := MS3dTriangle.VertexNormals[0][0];
      Vertices[Triangles[I].VertexIndices[2]].NY := MS3dTriangle.VertexNormals[0][1];
      Vertices[Triangles[I].VertexIndices[2]].NZ := MS3dTriangle.VertexNormals[0][2];
      Vertices[Triangles[I].VertexIndices[1]].NX := MS3dTriangle.VertexNormals[1][0];
      Vertices[Triangles[I].VertexIndices[1]].NY := MS3dTriangle.VertexNormals[1][1];
      Vertices[Triangles[I].VertexIndices[1]].NZ := MS3dTriangle.VertexNormals[1][2];
      Vertices[Triangles[I].VertexIndices[0]].NX := MS3dTriangle.VertexNormals[2][0];
      Vertices[Triangles[I].VertexIndices[0]].NY := MS3dTriangle.VertexNormals[2][1];
      Vertices[Triangles[I].VertexIndices[0]].NZ := MS3dTriangle.VertexNormals[2][2];
    end;
  end;
end;

//------------------------------------------------------------------------------
// LoadGroups()
// Loads the Group infos out of the file
//------------------------------------------------------------------------------
procedure LoadGroups(aModel: Model3D; aStream: TStream);
var MS3dGroup: MS3D_Group;
    I, K: Integer;
begin
  with aModel do
  begin
    aStream.Read(numGroups, SizeOf(NumGroups));
    SetLength(Groups, numGroups);
    for I := 0 to NumGroups - 1 do
    with Groups[I] do
    begin
      aStream.Read(MS3dGroup.Flags, SizeOf(ms3dgroup.Flags));
      aStream.Read(MS3dGroup.Name, SizeOf(ms3dgroup.Name));
      aStream.Read(nTriangles, SizeOf(nTriangles));

      SetLength(TriangleIndices, nTriangles);
      for K := 0 to nTriangles - 1 do
      begin
        aStream.Read(TriangleIndices[K], SizeOf(TriangleIndices[K]));
      end;
      aStream.Read(Material, SizeOf(MaterialIndex));
    end;
  end;
end;

//------------------------------------------------------------------------------
// LoadMaterials()
// Loads the Materials out of the File
//------------------------------------------------------------------------------
procedure LoadMaterials(aModel: Model3D; aStream: TStream);
var MS3dMaterial     : MS3D_Material;
    I                : Integer;
    TexPath          : String;
begin
  with aModel do
  begin
    aStream.Read(numMaterials, SizeOf(numMaterials));
    SetLength(Materials, numMaterials);
    for I := 0 to numMaterials - 1 do
    begin
      aStream.Read(MS3dMaterial,SizeOf(MS3dMaterial));
      if MS3dMaterial.Texture <> '' then
      begin
        TexPath := Path + MS3dMaterial.Texture;
        If FileExists(TexPath) = False then
        begin
          TexPath := DefaultPath + MS3dMaterial.Texture;
        end;
        Materials[I].Texture := r_CreateTextureFromFile(PChar(TexPath));
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
// LoadMS3DModel()
// Loads a MS3D-File and puts the geometry datas in a MBDAK 3 Model-System
//------------------------------------------------------------------------------
function LoadMS3DModel(aPath : String; TexturePath: String): Model3D;
var Model          : Model3D;
    Stream         : TFileStream;
begin
  //extract file path
  DefaultPath := ExtractFilePath(Application.ExeName) + 'data\3d\textures_medium\';
  Path := TexturePath;

  //create file stram
  Stream:=TFileStream.Create(aPath, 0);
  Model := Model3D.Create;

  //load filedata into Model:
  LoadHeader(Model,Stream);
  LoadVertices(Model,Stream);
  LoadTriangles(Model, Stream);
  LoadGroups(Model, Stream);
  LoadMaterials(Model, Stream);
  Stream.Free;
  //build the vertex buffers
  Model.BuildModelBuffer();
  //return model
  RESULT := Model;
end;

end.

