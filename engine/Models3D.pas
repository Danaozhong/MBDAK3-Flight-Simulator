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

MBDAK3 // Model-Handler


*)
unit Models3D;
interface

uses Structures;

type
  Model3D = class
  public
    numGroups            : Word;
    numMaterials         : Word;
    numTriangles         : Word;
    numVertices          : Word;
    Vertices             : Array of Vertex3D;
    Triangles            : Array of TriangleEx3D;
    Groups               : Array of Group3D;
    Materials            : Array of Materials3D;
    procedure Render;
    procedure RenderEx;
    procedure BuildModelBuffer;
  end;

implementation

//------------------------------------------------------------------------------
// BuildModelBuffer()
// creates a hardware stored vertex buffer
//------------------------------------------------------------------------------
procedure Model3D.BuildModelBuffer();
  var I, K, L: Integer;
  var VertexBufferList: Array Of Vertex3D;
  var vCounter: LongInt;
begin
  //we'll now create a vertex and a index buffer.
  For I := 0 to numGroups - 1 do
  begin
    vCounter := 0;
    //create the vertex&index buffer for each group (3 vertices for each triangle)
    For K := 0 to Groups[I].nTriangles - 1 do
    begin
      For L := 0 to 2 do
      begin
        SetLength (VertexBufferList, vCounter + 1);
        VertexBufferList[vCounter] := Vertices[Triangles[Groups[I].TriangleIndices[K]].VertexIndices[L]];
        Inc(vCounter);
      end;
    end;
    Groups[I].VertexBuffer := r_CreateVertexBuffer(vCounter);
    r_AddVerticesToBuffer(Groups[I].VertexBuffer, VertexBufferList);
  end;
end;

//------------------------------------------------------------------------------
// Render()
// renders the model with textures
//------------------------------------------------------------------------------
procedure Model3D.Render();
  var I: Integer;
begin
  for I := 0 to numGroups - 1 do
  begin
    //Set Texture
    r_SetTexture(Materials[Groups[I].Material].Texture);
    //render Vertex Buffer
    r_RenderVertexBuffer(Groups[I].VertexBuffer);
  end;
end;

//------------------------------------------------------------------------------
// RenderEx()
// renders the model without textures
//------------------------------------------------------------------------------
procedure Model3D.RenderEx();
  var I: Integer;
begin
  for I := 0 to numGroups - 1 do
  begin
    //render Vertex Buffer
    r_RenderVertexBuffer(Groups[I].VertexBuffer);
  end;
end;

end.

