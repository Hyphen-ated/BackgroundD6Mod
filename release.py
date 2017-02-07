import shutil
moddir = "../builtind6_855995373/"
shutil.copy("main.lua", moddir)
shutil.copy("metadata.xml", moddir)
shutil.copy("README.md", moddir)
shutil.copytree("content", moddir + "content")
shutil.copytree("resources", moddir + "resources")