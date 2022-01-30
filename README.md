Vim9-nox11
=========

Temporary workaround for supporting remote command without X11 dependency
Emulate --remote-tab option with environment variable using vim channel api and shell hacks

Usage
----
Check example_zshrc.sh

ToDo
----
 - Add tests

Runtime requirements
--------------------
 - Vim with vim9 script support

Usage
-----
Installation:
```sh
mkdir -p ~/.vim/pack/plugins/opt
git clone https://github.com/kohnish/vim9-nox11 ~/.vim/pack/plugins/opt/vim9-nox11
cd ~/.vim/pack/plugins/opt/vim9-nox11
# Not available yet (See Build section)
curl https://github.com/kohnish/vim9-nox11/releases/linux-vim9-nox11 -o vim9-nox11
```
Configuration
```vim
# Enable vim9-nox11
packadd! vim9-nox11
```

Build requirements
------------------
 - CMake
 - pkg-config
 - C compiler (GCC / Clang)
 - C++ compiler (Optional for test)  
  

Build (static build(needs internet access))
```shell
mkdir build
cd build
cmake -DBUILD_STATIC=ON ..
make -j`nproc`
make install/strip
```

Build (dynamic build(Fedora))
```shell
mkdir build
cd build
sudo dnf install -y libuv-devel
cmake ..
make -j`nproc`
make install/strip
```
