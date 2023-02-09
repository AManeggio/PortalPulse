import std/strutils
import spplib
import nimgl/imgui, nimgl/imgui/[impl_opengl, impl_glfw]
import nimgl/[opengl, glfw]


proc main() =
  doAssert glfwInit()

  glfwWindowHint(GLFWContextVersionMajor, 3)
  glfwWindowHint(GLFWContextVersionMinor, 3)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE)
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(GLFWResizable, GLFW_FALSE)

  var w: GLFWWindow = glfwCreateWindow(800, 325, "Portal Pulse Mod Loader")
  if w == nil:
    quit(-1)

  fetchPackages()
  w.makeContextCurrent()

  doAssert glInit()

  let context = igCreateContext()
  #let io = igGetIO()

  doAssert igGlfwInitForOpenGL(w, true)
  doAssert igOpenGL3Init()

  igStyleColorsCherry()

  var listptr: int = 1
  var currentlyLoaded: int = 3

  while not w.windowShouldClose:
    glfwPollEvents()

    igOpenGL3NewFrame()
    igGlfwNewFrame()
    igNewFrame()
    igGetIO().iniFilename = nil
    igSetNextWindowSizeConstraints(ImVec2(x:800,y:325), ImVec2(x:1920, y:325))
    igSetNextWindowPos(ImVec2(x:0, y:0));
    #igSetNextWindowSize(igGetIO().displaySize)
    # Simple window
    igSetNextWindowScroll(ImVec2(x:0,y:0))
    igBegin("PortalPulse", nil, ImGuiWindowFlags.NoTitleBar)

    w.setWindowSize(igGetWindowWidth().int32, igGetWindowHeight().int32)
    
    igBeginListBox("", ImVec2(x:500.0, y:200.0))
    var i = 0
    for p in Packages:
      if igSelectable(p.title, listptr == i):
        listptr = i
      i+=1
    igEndListBox()

    igSameLine()

    igTextWrapped("Title: $#\nDescription: $#" % [Packages[listptr].title, Packages[listptr].description])

    if igButton("Launch", ImVec2(x: igGetIO().displaySize.x-10, y:100)):
      currentlyLoaded = listptr
      Packages[listptr].installMod(getSteamDir().getPortalDir())

    if igIsItemHovered():
      igSetTooltip("Download And Install Mod To portal2_tempcontent")

    if currentlyLoaded >= 0:
      igText("Currently Loaded: " & Packages[currentlyLoaded].title)
      igSameLine()
      if igButton("Unload"):
        unloadMod(getSteamDir().getPortalDir())
      if igIsItemHovered():
        igSetTooltip("Unload And Uninstall Mod")

    igEnd()
    # End simple window

    igRender()

    glClearColor(0f, 0f, 0f, 1.00f)
    glClear(GL_COLOR_BUFFER_BIT)

    igOpenGL3RenderDrawData(igGetDrawData())

    w.swapBuffers()

  igOpenGL3Shutdown()
  igGlfwShutdown()
  context.igDestroyContext()

  w.destroyWindow()
  glfwTerminate()

main()