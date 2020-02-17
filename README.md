# Fleaswallow

![](/fleaswallow.png)

A static site generator in OCaml 🐸 🐫

I used to generate my site with [Frog][1], decided to try my hand at a
static-site generator more to my own needs, and now we have this froggy-themed
derivation. Powers [morepablo.com][2].

Note that it's got some hard-coded assumptions, both in its implementation
(using `Filename.concat` for the hostname to post path probably breaks URLs in
Windows, for example) and its use case (some `morepablo.com` assumptions are
hard-coded until I comb through them more carefully).

Maybe, maybe one day this becomes a proper command-line app that's generalizable
to more sites, we'll see! This was mostly me taking a shot at OCaml, "building
my own lightsaber" kind of thing.

## Building/hacking

With `dune` and `opam` installed, create a local switch (`opam switch create .`).
I _think_ this should create an environment where the rest of the Make commands
work.

   [1]: https://github.com/greghendershott/frog
   [2]: https://morepablo.com
