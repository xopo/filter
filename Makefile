odin=odin
src=.
out=dist
bin=filter
FLAGS=-o:size -vet -strict-style -out:${out}/${bin}

.PHONY: all run clean test

all:
	@mkdir -p $(out)
	$(odin) build $(src) $(FLAGS)

run: all 
	./$(out)/${bin}

test:
	$(odin) test $(src) $(FLAGS)

clean:
	rm -rf $(out)
