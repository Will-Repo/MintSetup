sudo apt install fprintd -y
sudo apt install libpam-fprintd -y
sudo pam-auth-update
sudo fprintd-enroll will -f right-index-finger
sudo fprintd-list will
