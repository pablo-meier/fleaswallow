# Fleaswallow

![](/fleaswallow.png)

A static site generator using OCaml.

## What else?

I'm using it to build off my former [Frog][1] project but to adapt to my own
needs. It's not quite a port but neither is it completely divorced from it.

## y tho?

Frog is an _amazing_ project, but a number of features are harder to implement
without full-on forking. Submitting PRs are an option, but it relies on the
author a) agreeing with the scope of my changes, and b) on their schedule.
I'd rather not put that pressure on them or that dependency on me. I could
XEmacs-style fork, but I don't think I like that either.

Furthermore, I view building tools for my site to be something like how Jedi
have to make their own lightsabers. It's a just-right sized project to get me
off the ground in OCaml.

## Things I'd want different

These were inspiration features for the project, I might update this README to
include which I have and haven't implemented later.

The assumption on using Bootstrap is a bit hard on me. Generating more/less
links is done in Racket and not in the templates.

CSS/JS pipeline for inlining when applicable.

I'd like to have more support for what metadata I can add/remove from posts,
like og:image/og:description per-post.

Medium-style "X minute read."

Actions on publishing new posts, like sharing to social media, or making a
weekly newsletter.

Linkable paragraphs.

Versioned posts.

### TODO

See `TODO`.

   [1]: https://github.com/greghendershott/frog
