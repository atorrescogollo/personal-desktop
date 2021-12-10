## Terminal Config
```bash
# Save
dconf dump /org/gnome/terminal/ > ~/git/atorrescogollo/personal-desktop/gnome/gnome-terminal.conf
# Load
cat ~/git/atorrescogollo/personal-desktop/gnome/gnome-terminal.conf | dconf load /org/gnome/terminal/
```

## WM Config
```bash
# Save
dconf dump /org/gnome/mutter/ > ~/git/atorrescogollo/personal-desktop/gnome/mutter.conf
# Load
cat ~/git/atorrescogollo/personal-desktop/gnome/mutter.conf | dconf load /org/gnome/mutter/
```
