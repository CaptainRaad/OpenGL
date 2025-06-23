unit Prototype.OGLShaderSystem;

interface

uses
  System.Classes,
  System.SysUtils,
  System.AnsiStrings,
  Generics.Collections,
  WinAPI.Windows,
  WinAPI.OpenGL,
  WinAPI.OpenGLext;

type
  TGluIntList = TList<gluInt>;

  TShaderSystem = class
	  private
      ProgramList: TgluIntList;
		  procedure CompileShader(const SRC: PAnsiChar; var ID: GLuint);
		  procedure LinkProgram(ID: GLuint);
	  public
      constructor Create;
      destructor Destroy; reintroduce;
		  procedure NewShaderProgram(const VSRC,FSRC: PAnsiChar; var ID:gluInt);
	  end;

implementation

{ TShaderSystem }

constructor TShaderSystem.Create;
  begin
    ProgramList := TgluIntList.Create;
  end;

destructor TShaderSystem.Destroy;
  var
    ID:gluInt;
  begin
    for ID in ProgramList do glDeleteProgram(ID);
  end;

procedure TShaderSystem.CompileShader(const SRC: PAnsiChar; var ID: GLuint);
  var
    Success: GLint;
    InfoLog: array[0..511] of AnsiChar;
    c:ANSIchar;
    s:ANSIString;
  begin
    glShaderSource(ID, 1, @SRC, nil);
    glCompileShader(ID);
    glGetShaderiv(ID, GL_COMPILE_STATUS, @Success);
    if Success = 0 then
      begin
        glGetShaderInfoLog(ID, 512, nil, InfoLog);
        for c in InfoLog do
          s:= s + c;
        MessageBox(0, 'Error Compile GLSL', 'Error', MB_OK or MB_ICONERROR);
      end;
  end;

procedure TShaderSystem.LinkProgram(ID: GLuint);
  var
    Success: GLint;
    InfoLog: array[0..511] of AnsiChar;
    c:ANSIchar;
    s:ANSIString;
  begin
    glLinkProgram(ID);
    glGetProgramiv(ID, GL_LINK_STATUS, @Success);
    if Success = 0 then
      begin
        glGetProgramInfoLog(ID, 512, nil, InfoLog);
        for c in InfoLog do
          s:= s + c;
        MessageBox(0, 'Error Link GLSL', 'Error', MB_OK or MB_ICONERROR);
      end;
  end;

procedure TShaderSystem.NewShaderProgram(const VSRC, FSRC: PAnsiChar; var ID: gluInt);
  var
    FS,VS:gluInt;
  begin
		VS := glCreateShader(GL_VERTEX_SHADER);
		CompileShader(VSRC,VS);

		FS := glCreateShader(GL_FRAGMENT_SHADER);
		CompileShader(FSRC,FS);

		ID := glCreateProgram;
		glAttachShader(ID, VS);
		glAttachShader(ID, FS);
		LinkProgram(ID);

		glDeleteShader(VS);
		glDeleteShader(FS);
    ProgramList.Add(ID);
  end;

end.
