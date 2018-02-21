OUTPUT=battletoad

build:
	ocamlbuild \
		-use-ocamlfind \
		-pkg core \
		-pkg re2 \
		-pkg ISO8601 \
		-pkg omd \
		-pkg jingoo \
		-pkg fileutils \
		-pkg inifiles \
		-tag "ppx(ppx-jane -as-ppx)" \
		-tag thread \
		-tag debug \
		-tag bin_annot \
		-tag short_paths \
		-cflags "-w A-4-33-40-41-42-43-34-44" \
		-cflags -strict-sequence \
		src/main.byte
	rm -f ./main.byte
	mv _build/src/main.byte $(OUTPUT)

prod:
	ocamlbuild \
		-use-ocamlfind \
		-pkg core \
		-pkg re2 \
		-pkg ISO8601 \
		-pkg omd \
		-pkg jingoo \
		-pkg fileutils \
		-pkg inifiles \
		-tag "ppx(ppx-jane -as-ppx)" \
		-tag thread \
		-tag debug \
		-tag bin_annot \
		-tag short_paths \
		-cflags "-w A-4-33-40-41-42-43-34-44" \
		-cflags -strict-sequence \
		src/main.native
	rm -f ./main.native
	mv _build/src/main.native $(OUTPUT)


clean:
	rm -rf $(OUTPUT) _build bt_build
