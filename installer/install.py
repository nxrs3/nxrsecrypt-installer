import subprocess
import sys
from os import path

path = path.join(path.expanduser("~"), "nxrsecrypt-installer", "installer")

print("\033[2J\033[H", end="")

while True:
    print(" |  nxrseCrypt Installer  ")
    print(" --------------------------")
    print(" | Which OS are you using?")
    print(" |- (1) windows")
    print(" |- (2) linux")
    print(" |- (3) macos")
    print(" |")
    print(" |> ", end="")
    OS = input()
    print()

    if OS == "1":
        subprocess.run(["cmd", "/c", "windows-install.cmd"], check=True, cwd=path)
        sys.exit()
    elif OS == "2":
        subprocess.run(["chmod", "+x", "linux-install.sh"], check=True, cwd=path)
        subprocess.run(["./linux-install.sh"], check=True, cwd=path)
        sys.exit()
    elif OS == "3":
        subprocess.run(["chmod", "+x", "macos-install.sh"], check=True, cwd=path)
        subprocess.run(["./macos-install.sh"], check=True, cwd=path)
        sys.exit()

    else:
        print("\033[2J\033[H", end="")
        print(f" '{OS}' invalid: Please enter either '1' for Windows, '2' for Linux, or '3' for macos")
