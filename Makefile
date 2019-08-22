OUTPUT=fleaswallow

test:
	dune runtest

build:
	dune build src/$(OUTPUT).exe

fmt:
	dune build @fmt --auto-promote

shell:
	dune utop src/fleaswallow_lib -- -implicit-bindings

clean:
	dune clean
