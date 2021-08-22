#!/bin/ksh

# https://dwm.suckless.org/
# https://dwm.suckless.org/tutorial/

# Keys:
#           Mod     Alt
#           S       Shift
#           C       Ctrl

echo "installing dwm"

doas pkg_add -I dwm dmenu st

cat << EOF > ~/.xinitrc
st &
exec dwm
EOF

cat > ~/.xsession << EOF
#!/bin/ksh
st &
exec dwm
EOF

echo "finished installing dwm"