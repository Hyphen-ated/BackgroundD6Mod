import os, sys, shutil, subprocess

# Here is where you can set the name for the release zip file and for the install dir inside it.
# version.txt is the sole source of truth about what version this is. the version string shouldnt be hardcoded anywhere
with open('version.txt', 'r') as f:
    version = f.read()
installName = 'BackgroundD6Server-' + version

# target is where we assemble our final install.
if os.path.isdir('target/'):
    shutil.rmtree('target/')
installDir = 'target/' + installName + '/'
steamDir = 'target/steam/'

# Run the build script. The results are placed in ./dist/
os.chdir("src")
subprocess.call("cxfreeze.py input_server.py --base-name=Win32GUI --target-dir dist ", shell=True, stdout=sys.stdout, stderr=sys.stderr)
os.chdir("..")

shutil.copy('src/d6shard.ico', 'src/dist/d6shard.ico')

shutil.move('src/dist/', installDir + "dist/") # Move the dist files to our target directory

# Then copy over all the data files
shutil.copy('shortcut_for_install_dir.lnk', installDir + "Launch Input Server.lnk")
shutil.copy('options_default.json', installDir + "options.json")
#shutil.copy('LICENSE.txt', installDir)
shutil.copy('README.md', installDir + 'README.txt')
shutil.copy('version.txt', installDir)
shutil.make_archive("target/" + installName, "zip", 'target', installName + "/")

os.mkdir(steamDir)
shutil.copy('main.lua', steamDir)
shutil.copy('metadata.xml', steamDir)
shutil.copy('README.md', steamDir)