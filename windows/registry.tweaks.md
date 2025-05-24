# Registry Tweaks For Windows


## Change Deafult Drag-and-Drop Behavior

[Change Default Drag and Drop Action in Windows 11](https://www.elevenforum.com/t/change-default-drag-and-drop-action-in-windows-11.2924/)

### Set Default Drag and Drop Action to Always Move
```regedit
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\*]
"DefaultDropEffect"=dword:00000002

[HKEY_CLASSES_ROOT\AllFilesystemObjects]
"DefaultDropEffect"=dword:00000002
```

### Set Default Drag and Drop Action to Always Copy
```regedit
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\*]
"DefaultDropEffect"=dword:00000001

[HKEY_CLASSES_ROOT\AllFilesystemObjects]
"DefaultDropEffect"=dword:00000001
```

### Restore Default Drag and Drop Action
```regedit
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\*]
"DefaultDropEffect"=-

[HKEY_CLASSES_ROOT\AllFilesystemObjects]
"DefaultDropEffect"=-
```
