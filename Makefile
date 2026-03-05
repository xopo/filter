odin=odin
src=.
out=filter
FLAGS=-o:size -vet -strict-style

.PHONY: all run clean test

all:
	@mkdir -p $(out)
	$(odin) build $(src) $(FLAGS)

run: all 
	./$(out)/app

test:
	$(odin) test $(src) $(FLAGS)

clean:
	rm -rf $(out)
