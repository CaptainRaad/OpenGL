unit Prototype.OGLBaseInit;

interface

uses
  System.Classes,
  System.SysUtils,
  System.AnsiStrings,
  WinAPI.Windows,
  WinAPI.OpenGL,
  WinAPI.OpenGLext;

type
  TWDRS = record
    HWND  : HWND;
    HRC   : HGLRC;
    DC    : HDC;
    PFD   : TPIXELFORMATDESCRIPTOR;
    PF    : Int32;
  end;

  TOpenGLLimits = record
    MaxElementIndex: GLuint;           // Maximum vertex index value
    MaxElementsVertices: GLint;        // Maximum number of vertices in a draw call
    MaxElementsIndices: GLint;         // Maximum number of indices in a draw call
    MaxTextureSize: GLint;             // Maximum size of a 2D texture
    Max3DTextureSize: GLint;           // Maximum size of a 3D texture
    MaxCubeMapTextureSize: GLint;      // Maximum size of a cube map texture
    MaxTextureImageUnits: GLint;       // Maximum number of texture image units (fragment shader)
    MaxCombinedTextureImageUnits: GLint; // Maximum number of combined texture image units
    MaxArrayTextureLayers: GLint;      // Maximum number of layers in a texture array
    MaxVertexAttribs: GLint;           // Maximum number of vertex attributes
    MaxUniformBlockSize: GLint64;      // Maximum size of a uniform buffer object (UBO)
    MaxShaderStorageBlockSize: GLint64;// Maximum size of a shader storage buffer object (SSBO)
    MaxVertexUniformComponents: GLint; // Maximum number of uniform components (vertex shader)
    MaxFragmentUniformComponents: GLint; // Maximum number of uniform components (fragment shader)
    MaxGeometryTotalOutputComponents: GLint; // Maximum number of output components (geometry shader)
    MaxGeometryOutputVertices: GLint;  // Maximum number of output vertices (geometry shader)
    MaxPatchVertices: GLint;           // Maximum number of vertices in a patch (tessellation)
    MaxTessGenLevel: GLint;            // Maximum tessellation generation level
    MaxFramebufferWidth: GLint;        // Maximum framebuffer width
    MaxFramebufferHeight: GLint;       // Maximum framebuffer height
    MaxColorAttachments: GLint;        // Maximum number of color attachments
    MaxFramebufferSamples: GLint;      // Maximum number of samples for multisampling
    MaxComputeWorkGroupCountX: GLint;  // Maximum compute work group count (X dimension)
    MaxComputeWorkGroupCountY: GLint;  // Maximum compute work group count (Y dimension)
    MaxComputeWorkGroupCountZ: GLint;  // Maximum compute work group count (Z dimension)
    MaxComputeWorkGroupSizeX: GLint;   // Maximum compute work group size (X dimension)
    MaxComputeWorkGroupSizeY: GLint;   // Maximum compute work group size (Y dimension)
    MaxComputeWorkGroupSizeZ: GLint;   // Maximum compute work group size (Z dimension)
    MaxComputeWorkGroupInvocations: GLint; // Maximum number of compute work group invocations
    UniformBufferOffsetAlignment: GLint; // Alignment requirement for UBO offsets
    ShaderStorageBufferOffsetAlignment: GLint; // Alignment requirement for SSBO offsets
  end;

TOGLInit = class
  private
    Limits:TOpenGLLimits;
    WDRS:TWDRS;
    function SetGLS_DC  : Boolean;
    function SetGLS_PFD : Boolean;
    function SetGLS_RC  : Boolean;
    procedure FillOpenGLLimits(var aLimits: TOpenGLLimits);
  public
  constructor Create;
    function SetHWND(aHWND:HWND):Boolean;
    function InitGLS:Boolean;
    function GetLimits:TOpenGLLimits;
    function GetSwapDC: HDC;
  destructor Destroy; reintroduce;
end;

implementation

{ TOGLInit }

//    BaseInit.SetHWND(aHWND);
//    if not BaseInit.InitGLS then
//      begin
//        Result := False;
//        Exit;
//      end;

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
  end;

function TOGLInit.GetLimits: TOpenGLLimits;
  begin
    Result := Limits;
  end;

function TOGLInit.GetSwapDC: HDC;
  begin
    Result := WDRS.DC;
  end;

function TOGLInit.InitGLS: Boolean;
  begin
    Result := SetGLS_DC and SetGLS_PFD and SetGLS_RC;
    InitOpenGLext;
    FillOpenGLLimits(Limits);
  end;

function TOGLInit.SetGLS_DC: Boolean;
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

function TOGLInit.SetGLS_PFD: Boolean;
  begin
    with WDRS.PFD do
      begin
        nSize           := SizeOf(TPIXELFORMATDESCRIPTOR);
        nVersion        := 1;
        dwFlags         := PFD_DRAW_TO_WINDOW
                           or PFD_SUPPORT_OPENGL
                           or PFD_DOUBLEBUFFER;
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
        cDepthBits      := 24;
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

function TOGLInit.SetGLS_RC: Boolean;
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
    // Initialize OpenGL extensions (must call glInit or similar beforehand)
    glGetIntegerv(GL_MAX_ELEMENT_INDEX, @Limits.MaxElementIndex);                    // Get max vertex index
    glGetIntegerv(GL_MAX_ELEMENTS_VERTICES, @Limits.MaxElementsVertices);            // Get max vertices in draw call
    glGetIntegerv(GL_MAX_ELEMENTS_INDICES, @Limits.MaxElementsIndices);              // Get max indices in draw call
    glGetIntegerv(GL_MAX_TEXTURE_SIZE, @Limits.MaxTextureSize);                      // Get max 2D texture size
    glGetIntegerv(GL_MAX_3D_TEXTURE_SIZE, @Limits.Max3DTextureSize);                 // Get max 3D texture size
    glGetIntegerv(GL_MAX_CUBE_MAP_TEXTURE_SIZE, @Limits.MaxCubeMapTextureSize);      // Get max cube map texture size
    glGetIntegerv(GL_MAX_TEXTURE_IMAGE_UNITS, @Limits.MaxTextureImageUnits);         // Get max texture units (fragment shader)
    glGetIntegerv(GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS, @Limits.MaxCombinedTextureImageUnits); // Get max combined texture units
    glGetIntegerv(GL_MAX_ARRAY_TEXTURE_LAYERS, @Limits.MaxArrayTextureLayers);       // Get max texture array layers
    glGetIntegerv(GL_MAX_VERTEX_ATTRIBS, @Limits.MaxVertexAttribs);                  // Get max vertex attributes
    glGetInteger64v(GL_MAX_UNIFORM_BLOCK_SIZE, @Limits.MaxUniformBlockSize);         // Get max UBO size
    glGetInteger64v(GL_MAX_SHADER_STORAGE_BLOCK_SIZE, @Limits.MaxShaderStorageBlockSize); // Get max SSBO size
    glGetIntegerv(GL_MAX_VERTEX_UNIFORM_COMPONENTS, @Limits.MaxVertexUniformComponents); // Get max vertex uniform components
    glGetIntegerv(GL_MAX_FRAGMENT_UNIFORM_COMPONENTS, @Limits.MaxFragmentUniformComponents); // Get max fragment uniform components
    glGetIntegerv(GL_MAX_GEOMETRY_TOTAL_OUTPUT_COMPONENTS, @Limits.MaxGeometryTotalOutputComponents); // Get max geometry output components
    glGetIntegerv(GL_MAX_GEOMETRY_OUTPUT_VERTICES, @Limits.MaxGeometryOutputVertices); // Get max geometry output vertices
    glGetIntegerv(GL_MAX_PATCH_VERTICES, @Limits.MaxPatchVertices);                  // Get max patch vertices (tessellation)
    glGetIntegerv(GL_MAX_TESS_GEN_LEVEL, @Limits.MaxTessGenLevel);                   // Get max tessellation level
    glGetIntegerv(GL_MAX_FRAMEBUFFER_WIDTH, @Limits.MaxFramebufferWidth);            // Get max framebuffer width
    glGetIntegerv(GL_MAX_FRAMEBUFFER_HEIGHT, @Limits.MaxFramebufferHeight);          // Get max framebuffer height
    glGetIntegerv(GL_MAX_COLOR_ATTACHMENTS, @Limits.MaxColorAttachments);           // Get max color attachments
    glGetIntegerv(GL_MAX_FRAMEBUFFER_SAMPLES, @Limits.MaxFramebufferSamples);        // Get max samples for multisampling
    glGetIntegerv(GL_MAX_COMPUTE_WORK_GROUP_COUNT, @Limits.MaxComputeWorkGroupCountX); // Get max compute work group count (X)
    glGetIntegerv(GL_MAX_COMPUTE_WORK_GROUP_COUNT + 1, @Limits.MaxComputeWorkGroupCountY); // Get max compute work group count (Y)
    glGetIntegerv(GL_MAX_COMPUTE_WORK_GROUP_COUNT + 2, @Limits.MaxComputeWorkGroupCountZ); // Get max compute work group count (Z)
    glGetIntegerv(GL_MAX_COMPUTE_WORK_GROUP_SIZE, @Limits.MaxComputeWorkGroupSizeX); // Get max compute work group size (X)
    glGetIntegerv(GL_MAX_COMPUTE_WORK_GROUP_SIZE + 1, @Limits.MaxComputeWorkGroupSizeY); // Get max compute work group size (Y)
    glGetIntegerv(GL_MAX_COMPUTE_WORK_GROUP_SIZE + 2, @Limits.MaxComputeWorkGroupSizeZ); // Get max compute work group size (Z)
    glGetIntegerv(GL_MAX_COMPUTE_WORK_GROUP_INVOCATIONS, @Limits.MaxComputeWorkGroupInvocations); // Get max compute work group invocations
    glGetIntegerv(GL_UNIFORM_BUFFER_OFFSET_ALIGNMENT, @Limits.UniformBufferOffsetAlignment); // Get UBO offset alignment
    glGetIntegerv(GL_SHADER_STORAGE_BUFFER_OFFSET_ALIGNMENT, @Limits.ShaderStorageBufferOffsetAlignment); // Get SSBO offset alignment
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
    If not InitGLS then
      begin
        MessageBox(0, 'Init Chain Broken', 'Error', MB_OK or MB_ICONERROR);
        Result := False;
        Exit;
      end;
    Result := True;
  end;

end.
