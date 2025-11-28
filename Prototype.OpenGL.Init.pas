unit Prototype.OpenGL.Init;

interface

uses
  System.Classes, WinAPI.Windows, WinAPI.OpenGL, WinAPI.OpenGLext;

type

  TWDRS = record
    HWND  : HWND;
    HRC   : HGLRC;
    DC    : HDC;
    PFD   : TPIXELFORMATDESCRIPTOR;
    PF    : Int32;
  end;

  TOpenGLLimits = record
    MaxElementIndex: GLuint;
    MaxElementsVertices,
    MaxElementsIndices,
    MaxTextureSize,
    Max3DTextureSize,
    MaxCubeMapTextureSize,
    MaxTextureImageUnits,
    MaxCombinedTextureImageUnits,
    MaxArrayTextureLayers,
    MaxVertexAttribs: GLint;
    MaxUniformBlockSize: GLint64;
    MaxShaderStorageBlockSize: GLint64;
    MaxVertexUniformComponents,
    MaxFragmentUniformComponents,
    MaxGeometryTotalOutputComponents,
    MaxGeometryOutputVertices,
    MaxPatchVertices,
    MaxTessGenLevel,
    MaxFramebufferWidth,
    MaxFramebufferHeight,
    MaxColorAttachments,
    MaxFramebufferSamples,
    MaxComputeWorkGroupCountX,
    MaxComputeWorkGroupCountY,
    MaxComputeWorkGroupCountZ,
    MaxComputeWorkGroupSizeX,
    MaxComputeWorkGroupSizeY,
    MaxComputeWorkGroupSizeZ,
    MaxComputeWorkGroupInvocations,
    UniformBufferOffsetAlignment,
    ShaderStorageBufferOffsetAlignment: GLint;
  end;

  TOGLInit = class
    private
      Limits:TOpenGLLimits;
      WDRS:TWDRS;
      Initialized:Boolean;
      function SetGL_DC  : Boolean;
      function SetGL_PFD : Boolean;
      function SetGL_RC  : Boolean;
      procedure FillOpenGLLimits(var aLimits: TOpenGLLimits);
    public
      constructor Create;
      function SetHWND(aHWND: HWND):Boolean;
      function InitGL:Boolean;
      function GetLimits:TOpenGLLimits;
      function GetSwapDC:HDC;
      function GetRenderRC:HGLRC;
      function GetInitialized:boolean;
      destructor Destroy; reintroduce;
    end;

implementation

{$REGION 'TOGLInit'}

{ TOGLInit }

constructor TOGLInit.Create;
  begin
    //
  end;

destructor TOGLInit.Destroy;
  begin
    if (not wglMakeCurrent(WDRS.DC, 0)) then
      MessageBox(0, 'Release of GLS_DC and RC failed!', 'Error', MB_OK or MB_ICONERROR);

    if (not wglDeleteContext(WDRS.HRC)) then
      begin
        MessageBox(0, 'Release of rendering context failed!', 'Error', MB_OK or MB_ICONERROR);
        WDRS.HRC := 0;
      end;

    if ((WDRS.DC > 0) and (ReleaseDC(WDRS.HWND, WDRS.DC) = 0)) then
      begin
        MessageBox(0, 'Release of device context failed!', 'Error', MB_OK or MB_ICONERROR);
        WDRS.DC := 0;
      end;
    inherited;
  end;

function TOGLInit.GetInitialized: boolean;
  begin
    Result := Initialized;
  end;

function TOGLInit.GetLimits: TOpenGLLimits;
  begin
    Result := Limits;
  end;

function TOGLInit.GetRenderRC: HGLRC;
  begin
    Result := WDRS.HRC;
  end;

function TOGLInit.GetSwapDC: HDC;
  begin
    Result := WDRS.DC;
  end;

function TOGLInit.InitGL: Boolean;
  begin
    Result := SetGL_DC and SetGL_PFD and SetGL_RC;
    InitOpenGLext;
    FillOpenGLLimits(Limits);
    Initialized := True;
  end;

function TOGLInit.SetGL_DC: Boolean;
  begin
    WDRS.DC := GetDC(WDRS.HWND);
    if (WDRS.DC = 0) then
      begin
        MessageBox(0, 'Unable to get a device context!', 'Error', MB_OK or MB_ICONERROR);
        Result := False;
        Exit;
      end;
    Result := True;
  end;

function TOGLInit.SetGL_PFD: Boolean;
  begin
    with WDRS.PFD do
      begin
        nSize           := SizeOf(TPIXELFORMATDESCRIPTOR);
        nVersion        := 1;
        dwFlags         := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
        iPixelType      := PFD_TYPE_RGBA;
        cColorBits      := 32;
        cRedBits        := 0;
        cRedShift       := 0;
        cGreenBits      := 0;
        cGreenShift     := 0;
        cBlueBits       := 0;
        cBlueShift      := 0;
        cAlphaBits      := 0;
        cAlphaShift     := 0;
        cAccumBits      := 0;
        cAccumRedBits   := 0;
        cAccumGreenBits := 0;
        cAccumBlueBits  := 0;
        cAccumAlphaBits := 0;
        cDepthBits      := 32;
        cStencilBits    := 0;
        cAuxBuffers     := 0;
        iLayerType      := PFD_MAIN_PLANE;
        bReserved       := 0;
        dwLayerMask     := 0;
        dwVisibleMask   := 0;
        dwDamageMask    := 0;
      end;

    WDRS.PF := ChoosePixelFormat(WDRS.DC, @WDRS.PFD);
    if (WDRS.PF = 0) then
      begin
        MessageBox(0, 'Unable to find a suitable pixel format', 'Error', MB_OK or MB_ICONERROR);
        Result := False;
        Exit;
      end;

    if (not SetPixelFormat(WDRS.DC, WDRS.PF, @WDRS.PFD)) then
      begin
        MessageBox(0, 'Unable to set the pixel format', 'Error', MB_OK or MB_ICONERROR);
        Result := False;
        Exit;
      end;
    Result := True;
  end;

function TOGLInit.SetGL_RC: Boolean;
  begin
    WDRS.HRC := wglCreateContext(WDRS.DC);
    if (WDRS.HRC = 0) then
      begin
        MessageBox(0, 'Unable to create an OpenGL rendering context', 'Error', MB_OK or MB_ICONERROR);
        Result := False;
        Exit;
      end;

    if (not wglMakeCurrent(WDRS.DC, WDRS.HRC)) then
      begin
        MessageBox(0, 'Unable to activate OpenGL rendering context', 'Error', MB_OK or MB_ICONERROR);
        Result := False;
        Exit;
      end;
    Result := True;
  end;

procedure TOGLInit.FillOpenGLLimits(var aLimits: TOpenGLLimits);
  begin
    with aLimits do
      begin
        glGetIntegerv(GL_MAX_ELEMENT_INDEX, @MaxElementIndex);
        glGetIntegerv(GL_MAX_ELEMENTS_VERTICES, @MaxElementsVertices);
        glGetIntegerv(GL_MAX_ELEMENTS_INDICES, @MaxElementsIndices);
        glGetIntegerv(GL_MAX_TEXTURE_SIZE, @MaxTextureSize);
        glGetIntegerv(GL_MAX_3D_TEXTURE_SIZE, @Max3DTextureSize);
        glGetIntegerv(GL_MAX_CUBE_MAP_TEXTURE_SIZE, @MaxCubeMapTextureSize);
        glGetIntegerv(GL_MAX_TEXTURE_IMAGE_UNITS, @MaxTextureImageUnits);
        glGetIntegerv(GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS, @MaxCombinedTextureImageUnits);
        glGetIntegerv(GL_MAX_ARRAY_TEXTURE_LAYERS, @MaxArrayTextureLayers);
        glGetIntegerv(GL_MAX_VERTEX_ATTRIBS, @MaxVertexAttribs);
        glGetInteger64v(GL_MAX_UNIFORM_BLOCK_SIZE, @MaxUniformBlockSize);
        glGetInteger64v(GL_MAX_SHADER_STORAGE_BLOCK_SIZE, @MaxShaderStorageBlockSize);
        glGetIntegerv(GL_MAX_VERTEX_UNIFORM_COMPONENTS, @MaxVertexUniformComponents);
        glGetIntegerv(GL_MAX_FRAGMENT_UNIFORM_COMPONENTS, @MaxFragmentUniformComponents);
        glGetIntegerv(GL_MAX_GEOMETRY_TOTAL_OUTPUT_COMPONENTS, @MaxGeometryTotalOutputComponents);
        glGetIntegerv(GL_MAX_GEOMETRY_OUTPUT_VERTICES, @MaxGeometryOutputVertices);
        glGetIntegerv(GL_MAX_PATCH_VERTICES, @MaxPatchVertices);
        glGetIntegerv(GL_MAX_TESS_GEN_LEVEL, @MaxTessGenLevel);
        glGetIntegerv(GL_MAX_FRAMEBUFFER_WIDTH, @MaxFramebufferWidth);
        glGetIntegerv(GL_MAX_FRAMEBUFFER_HEIGHT, @MaxFramebufferHeight);
        glGetIntegerv(GL_MAX_COLOR_ATTACHMENTS, @MaxColorAttachments);
        glGetIntegerv(GL_MAX_FRAMEBUFFER_SAMPLES, @MaxFramebufferSamples);
        glGetIntegerv(GL_MAX_COMPUTE_WORK_GROUP_COUNT, @MaxComputeWorkGroupCountX);
        glGetIntegerv(GL_MAX_COMPUTE_WORK_GROUP_COUNT + 1, @MaxComputeWorkGroupCountY);
        glGetIntegerv(GL_MAX_COMPUTE_WORK_GROUP_COUNT + 2, @MaxComputeWorkGroupCountZ);
        glGetIntegerv(GL_MAX_COMPUTE_WORK_GROUP_SIZE, @MaxComputeWorkGroupSizeX);
        glGetIntegerv(GL_MAX_COMPUTE_WORK_GROUP_SIZE + 1, @MaxComputeWorkGroupSizeY);
        glGetIntegerv(GL_MAX_COMPUTE_WORK_GROUP_SIZE + 2, @MaxComputeWorkGroupSizeZ);
        glGetIntegerv(GL_MAX_COMPUTE_WORK_GROUP_INVOCATIONS, @MaxComputeWorkGroupInvocations);
        glGetIntegerv(GL_UNIFORM_BUFFER_OFFSET_ALIGNMENT, @UniformBufferOffsetAlignment);
        glGetIntegerv(GL_SHADER_STORAGE_BUFFER_OFFSET_ALIGNMENT, @ShaderStorageBufferOffsetAlignment);
      end;
  end;

function TOGLInit.SetHWND(aHWND: HWND): Boolean;
  begin
    WDRS.HWND := aHWND;
    if aHWND = 0 then
      begin
        MessageBox(0, 'Unable to get a HWND', 'Error', MB_OK or MB_ICONERROR);
        Result := False;
        Exit;
      end;
    If not InitGL then
      begin
        MessageBox(0, 'Init Chain Broken', 'Error', MB_OK or MB_ICONERROR);
        Result := False;
        Exit;
      end;
    Result := True;
  end;

{$ENDREGION}

end.
