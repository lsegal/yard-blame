= yard-blame

Adds git blame info to your method source views.

== Install

    $ rake install

== How to Use

Generate your docs with `yardoc` and click a method's "view source" link to
see the git blame info.

To link your blame info to github, set the `YARD_USER` and `YARD_PROJECT` 
environment variables

    $ YARD_USER=lsegal YARD_PROJECT=yard-blame yardoc

== Notes

  - Github links don't yet work.
  - Blame info is not always accurate

== License

MIT License