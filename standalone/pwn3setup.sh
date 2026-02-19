sudo apt --fix-broken install -y
sudo apt install -y postgresql

cd ~/Games/pwnieisland/PwnAdventure3Servers/MasterServer/
sudo -u postgres bash <<EOF
psql template1 <<SQL
CREATE DATABASE master;
GRANT ALL PRIVILEGES ON DATABASE master TO postgres;
SQL

# Execute the initdb.sql file on the master database
psql -f initdb.sql -d master -U postgres
export LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH
./MasterServer --create-server-account
EOF

wget https://security.ubuntu.com/ubuntu/pool/main/o/openssl1.0/libssl1.0.0_1.0.2n-1ubuntu5.13_amd64.deb
dpkg-deb -xv libssl1.0.0_1.0.2n-1ubuntu5.13_amd64.deb test
cp test/usr/lib/x86_64-linux-gnu/lib* ~/Games/pwnieisland/PwnAdventure3Servers/MasterServer/
mv test/usr/lib/x86_64-linux-gnu/lib* ~/Games/pwnieisland/PwnAdventure3/PwnAdventure3/Binaries/Linux/
rm -rf test
rm libssl1.0.0_1.0.2n-1ubuntu5.13_amd64.deb
openssl req -new -key ~/Games/pwnieisland/PwnAdventure3Servers/MasterServer/server.key -out ~/Games/pwnieisland/PwnAdventure3Servers/MasterServer/server.csr -subj "/C=US/ST=DC/L=Washington/O=Ghost in the Shellcode/CN=master"
openssl x509 -req -days 3650 -in ~/Games/pwnieisland/PwnAdventure3Servers/MasterServer/server.csr -signkey ~/Games/pwnieisland/PwnAdventure3Servers/MasterServer/server.key -out ~/Games/pwnieisland/PwnAdventure3Servers/MasterServer/server.crt
cp ~/Games/pwnieisland/PwnAdventure3Servers/MasterServer/server.crt ~/Games/pwnieisland/PwnAdventure3/PwnAdventure3/Content/Server/
