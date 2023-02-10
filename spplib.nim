import os
import std/json
import std/httpclient
import std/strutils
import zip/zipfiles

type Sppackage* = object
    title*: string
    name*: string
    file*: string
    icon*: string
    description*: string

type SettingsObj* = object
  style*: string
  doLaunch*: bool
  repo*: string


proc load*(self: ptr SettingsObj) = 
  if existsFile("./config.json"):
    var json = parseJson(readFile("./config.json"))
    self.style = json["style"].str
    self.doLaunch = json["dolaunch"].getBool()
    self.repo = json["repo"].str
  else:
    writeFile("./config.json", "{\n\t\"style\": \"Cherry\",\n\t\"dolaunch\": true,\n\t\"repo\": \"95.217.182.22\"\n}")
    load(self)

proc save*(self: SettingsObj) = 
  writeFile("./config.json", "{\n\t\"style\": \"$#\",\n\t\"dolaunch\": $#,\n\t\"repo\": \"$#\"\n}" % [self.style, $self.doLaunch, self.repo])
    

var Settings*: SettingsObj = SettingsObj()
load(Settings.addr)
var Client* = newHttpClient()
var Packages* = newSeq[Sppackage]()
var GamePath* = ""
var PackagesJSON* = parseJson(Client.getContent("https://" & Settings.repo & "/spplice/packages"))


proc unloadMod*(path: string) = 
    echo "Uninstalling Mod From: " & path
    var fullPath = path & "/portal2_tempcontent"
    removeDir(fullPath)

proc installMod*(self: Sppackage, path: string) = 
    unloadMod(path)
    Client = newHttpClient()
    echo "Installing Mod: " & self.title & " In: " & path & "/portal2_tempcontent"
    var url = "https://$#/spplice/packages/$#/$#" % [Settings.repo, self.name, self.file]
    echo url
    var fullPath = path & "/portal2_tempcontent"
    if not dirExists(fullPath):
        createDir(fullPath)
    Client.downloadFile(url, fullPath & "/spp.tar.gz")
    echo ("tar -xzf $# -C $#" % [fullPath & "/spp.tar.gz", fullPath])
    discard execShellCmd(("tar -xzf \"$#\" -C \"$#\"" % [fullPath & "/spp.tar.gz", fullPath]))

    discard execShellCmd("steam -applaunch 620 -tempcontent")

proc getSteamDir*(): string = 
  var home = getEnv("HOME")

  const paths = [
    "/.steam/steam",
    "/.local/share/Steam",
    "/Library/Application Support/Steam",
    "/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps"
  ]
  for path in paths:
    if dirExists(home & path):
      echo "Steam Found In: " & home & path
      return home & path
    else:
        echo "Steam not in: " & home & path
    
proc getPortalDir*(path: string): string =
  var libraryfile = readFile(path & "/steamapps/libraryfolders.vdf")
  var paths = libraryfile.split("path")
  var i = -1
  for path in paths:
    if path.find("\"620\"") != -1:
      echo "Portal Found In: " & path.split("\"")[2] & "/steamapps/common/Portal 2"
      return path.split("\"")[2] & "/steamapps/common/Portal 2"
      break
    else:
      echo "Portal NOT Found In: " & path.split("\"")[2] & "/steamapps/common/Portal 2"
    i+=1

proc fetchPackages*() =
    for package in PackagesJSON["packages"]:
        var h = Sppackage()
        h.title = ($package["title"]).replace("\"","").replace("<br>", "\n").replace("\\n", "\n")
        h.name = ($package["name"]).replace("\"","").replace("<br>", "\n").replace("\\n", "\n")
        h.file = ($package["file"]).replace("\"","").replace("<br>", "\n").replace("\\n", "\n")
        h.icon = ($package["icon"]).replace("\"","").replace("<br>", "\n").replace("\\n", "\n")
        h.description = ($package["description"]).replace("\"","").replace("<br>", "\n").replace("\\n", "\n")
        Packages.add(h)
  
  #echo libraryfile.substr(libraryfile.find("\"620\"")+5).replace(" ", "").replace("\t", "").split("\"")[1]