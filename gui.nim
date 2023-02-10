import std/strutils
import spplib
import nimgl/imgui, nimgl/imgui/[impl_opengl, impl_glfw]
import nimgl/[opengl, glfw]

proc loadStyles() = 
  case Settings.style:
    of "Cherry":
      igStyleColorsCherry()
    of "Light":
      igStyleColorsLight()
    of "Dark":
      igStyleColorsDark()
    of "Classic":
      igStyleColorsClassic()

proc main() =
  doAssert glfwInit()

  glfwWindowHint(GLFWContextVersionMajor, 3)
  glfwWindowHint(GLFWContextVersionMinor, 3)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE)
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(GLFWResizable, GLFW_FALSE)

  var w: GLFWWindow = glfwCreateWindow(800, 340, "Portal Pulse Mod Loader")
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
  var doSettings: bool = false
  while not w.windowShouldClose:
    loadStyles()
    glfwPollEvents()

    igOpenGL3NewFrame()
    igGlfwNewFrame()
    igNewFrame()
    igGetIO().iniFilename = nil
    igSetNextWindowSizeConstraints(ImVec2(x:800,y:340), ImVec2(x:1920, y:340))
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

    if igButton("Settings"):
      doSettings = true

    igEnd()
    if doSettings:
      igSetNextWindowSize(ImVec2(x: 200, y: 100))
      igBegin("Settings")


      if(igBeginCombo("Style", Settings.style)):
        if igSelectable("Dark"):
          Settings.style = "Dark"
        if igSelectable("Light"):
          Settings.style = "Light"
        if igSelectable("Cherry"):
          Settings.style = "Cherry"
        if igSelectable("Classic"):
          Settings.style = "Classic"
        igEndCombo()
      
      igCheckbox("Launch Game After Install", Settings.doLaunch.addr)

      if igButton("Save"):
        Settings.save()
      igSameLine()
      if igButton("Close"):
        load(Settings.addr)
        doSettings = false
      igEnd()

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