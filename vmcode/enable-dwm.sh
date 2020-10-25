#!/bin/ksh

# https://dwm.suckless.org/
# https://dwm.suckless.org/tutorial/

echo "installing dwm"

pkg_add -I dwm dmenu st

cat << EOF > /home/puffy/.xinitrc
st &
exec dwm
EOF

cat > /home/puffy/.xsession << EOF
#!/bin/ksh
st &
exec dwm
EOF

chown puffy /home/puffy/.xinitrc /home/puffy/.xsession

echo "finished installing dwm"
