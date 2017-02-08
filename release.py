import shutil,os
moddir = os.getenv("USERPROFILE")+"/Documents/My Games/Binding of Isaac Afterbirth+ Mods/builtind6_855995373/"
shutil.copy("main.lua", moddir)
shutil.copy("metadata.xml", moddir)
shutil.copy("README.md", moddir)
shutil.rmtree(moddir + "content")
shutil.rmtree(moddir + "resources")
shutil.copytree("content", moddir + "content")
shutil.copytree("resources", moddir + "resources")