To build a Windows .exe:

Do this in Windows:
* One-time:
    * install pywin32
    * download https://bootstrap.pypa.io/get-pip.py
    * python get-pip.py
    * As admin
        * pip install pyinstaller
* Whenever you want to build:
    * pyinstaller --onefile helper.py
    * It builds chrome_extensions\autoupdate_disabler_0.0.x\helper\dist\helper.exe
