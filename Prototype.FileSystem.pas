unit Prototype.FileSystem;

interface

uses
  System.Classes,
  System.SysUtils,
  WinAPI.Windows,
  WinApi.OpenGL;

type
  TDataFileSystem = class
  private
    procedure WriteGlFloatArrayToFile(const FileName: string; const A: TArray<glFloat>);
    procedure WriteGluIntArrayToFile(const FileName: string; const B: TArray<gluInt>);
    function StaticToDynamicUIntArray(const Source: array of gluInt): TArray<gluInt>;
    function LoadPAnsiCharFromFile(const FileName: string):PAnsiChar;
    function ReadGlFloatArrayFromFile(const FileName: string):TArray<glFloat>;
    function ReadGluIntArrayFromFile(const FileName: string):TArray<gluInt>;
  public
    constructor Create;
    destructor Destroy; reintroduce;
  end;

implementation

{ TFileSystem }

constructor TDataFileSystem.Create;
  begin
    //
  end;

destructor TDataFileSystem.Destroy;
  begin
    //
  end;

procedure TDataFileSystem.WriteGlFloatArrayToFile(const FileName: string; const A: TArray<glFloat>);
  var
    Stream: TBufferedFileStream;
    Count: Integer;
  begin
    Stream := TBufferedFileStream.Create(FileName, fmCreate or fmShareDenyWrite);
    try
      Count := Length(A);
      Stream.WriteBuffer(Count, SizeOf(Count));
      if Count > 0 then
        Stream.WriteBuffer(A[0], Count * SizeOf(glFloat));
    finally
      Stream.Free;
    end;
  end;

procedure TDataFileSystem.WriteGluIntArrayToFile(const FileName: string; const B: TArray<gluInt>);
  var
    Stream: TBufferedFileStream;
    Count: Integer;
  begin
    Stream := TBufferedFileStream.Create(FileName, fmCreate or fmShareDenyWrite);
    try
      Count := Length(B);
      Stream.WriteBuffer(Count, SizeOf(Count));
      if Count > 0 then
        Stream.WriteBuffer(B[0], Count * SizeOf(gluInt));
    finally
      Stream.Free;
    end;
  end;

function TDataFileSystem.LoadPAnsiCharFromFile(const FileName: string): PAnsiChar;
  var
    FileStream: TBufferedFileStream;
    FileSize: Int64;
    V:PANSICHAR;
  begin
    if not FileExists(FileName) then Exit;

    FileStream := TBufferedFileStream.Create(FileName, fmOpenRead);
    try
      FileSize := FileStream.Size;
      if FileSize = 0 then Exit;

      GetMem(V, FileSize + 1);
      FileStream.ReadBuffer(V^, FileSize);
      V[FileSize] := #0;
    finally
      FileStream.Free;
    end;
    Result := V;
  end;

function TDataFileSystem.ReadGlFloatArrayFromFile(const FileName: string): TArray<glFloat>;
  var
    Stream: TBufferedFileStream;
    Count: Integer;
    A:TArray<glFloat>;
  begin
    Stream := TBufferedFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
    try
      Stream.ReadBuffer(Count, SizeOf(Count));

      SetLength(A, Count);
      Stream.ReadBuffer(A[0], Count * SizeOf(glFloat));
    finally
      Stream.Free;
    end;
    Result := A;
  end;

function TDataFileSystem.ReadGluIntArrayFromFile(const FileName: string): TArray<gluInt>;
  var
    Stream: TBufferedFileStream;
    Count: Integer;
    B: TArray<gluInt>;
  begin
    Stream := TBufferedFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
    try
      Stream.ReadBuffer(Count, SizeOf(Count));

      SetLength(B, Count);
      Stream.ReadBuffer(B[0], Count * SizeOf(gluInt));
    finally
      Stream.Free;
    end;
    Result := B;
  end;

function TDataFileSystem.StaticToDynamicUIntArray(const Source: array of gluInt): TArray<gluInt>;
  var
    Dest:TArray<gluInt>;
  begin
    SetLength(Dest, Length(Source));
    if Length(Source) > 0 then
      Move(Source[0], Dest[0], Length(Source) * SizeOf(gluInt));
    Result := Dest;
  end;

end.
