# compile nasm into binary
hello: hello.asm
	nasm -f macho64 -o hello.o hello.asm
	ld -l System -L /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib -o hello hello.o

# clean files
.PHONY: clean
clean:
	rm hello.o hello
