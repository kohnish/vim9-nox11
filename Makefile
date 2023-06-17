vim9-nox11:
	gcc $(CFLAGS) $(LDFLAGS) native/app/*.c -Os -luv -o bin/vim9-nox11

macports-vim9-nox11:
	LDFLAGS=-L/opt/local/lib CFLAGS=-I/opt/local/include $(MAKE) vim9-nox11

online-build:
	rm -rf build
	cmake -Bbuild -DBUILD_STATIC=ON
	cmake --build build --target install/strip

linux-download:
	mkdir -p bin
	curl -L https://github.com/kohnish/vim9-nox11/releases/download/v0.1/vim9-nox11-linux-x86-64 -o bin/vim9-nox11
	chmod +x bin/vim9-nox11

win-download:
	mkdir -p bin
	curl -L https://github.com/kohnish/vim9-nox11/releases/download/v0.1/vim9-nox11-win-x86-64 -o bin/vim9-nox11.exe
	chmod +x bin/vim9-nox11.exe

clean:
	rm bin/vim9-nox11
