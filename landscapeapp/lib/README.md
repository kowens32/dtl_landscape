# RHEL 7 dependancy library
# Update via the following:

```shell
# ensure in correct directory 
cd dtl_landscape/landscapeapp/lib/
gunzip zlib-1.2.9.tar.gz
tar xf zlib-1.2.9.tar
cd zlib-1.2.9 
./configure; make; sudo make install
cd /lib64
sudo ln -s -f /usr/local/lib/libz.so.1.2.9 libz.so.1

```


