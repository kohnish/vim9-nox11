Vim9-nox11
=========

Temporary workaround for supporting remote command without X11 dependency.
Emulate --remote option with environment variable using vim channel API and shell hacks

ToDo
----
 - Add tests

Runtime requirements
--------------------
 - Vim with vim9 script support

Usage
-----
Installation
```sh
mkdir -p ~/.vim/pack/plugins/opt
git clone https://github.com/kohnish/vim9-nox11 ~/.vim/pack/plugins/opt/vim9-nox11
cd ~/.vim/pack/plugins/opt/vim9-nox11
# For Linux 
curl -L https://github.com/kohnish/vim9-nox11/releases/download/v0.1/vim9-nox11-linux-x86-64 -o ~/.vim/pack/plugins/opt/vim9-nox11/bin/vim9-nox11 ~/.vim/pack/plugins/opt/vim9-nox11/bin/vim9-nox11
chmod +x ~/.vim/pack/plugins/opt/vim9-nox11/bin/vim9-nox11
# For Windows
curl -L https://github.com/kohnish/vim9-nox11/releases/download/v0.1/vim9-nox11-win-x86-64 -o ~/.vim/pack/plugins/opt/vim9-nox11/bin/vim9-nox11.exe
chmod +x ~/.vim/pack/plugins/opt/vim9-nox11/bin/vim9-nox11.exe
# Or see the build section for compiling locally
```

Vim configuration
```vim
# Enable vim9-nox11
packadd! vim9-nox11
```
Shell configuration
```
Check example_zshrc.sh
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
