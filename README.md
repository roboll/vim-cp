# vim-cp

this plugin sets the classpath for jvm based projects using [http://maven.apache.org](maven), [http://scala-sbt.org](sbt) - and eventually [http://gradle.org](gradle) and [http://lieningen.org](leiningen).

classpaths are exported from the build tool and stored in dotfiles in the codebase - called `.vimcp`. the classpath for a given buffer is discovered by traversing up the filesystem until a `.vimcp` file is found.

## commands
the `:UpdateClasspath` command is provided to update the classpath of the nearest module, found based on conventions of the build tool.

## classpath scopes
support for multiple classpaths (i.e. compile, test, etc.) is provided by writing `.vimcp` files under `src/test/.vimcp, for example - buffers beneath there will give presidence to the test classpath due to it's locality.

## exported data
`b:vimcp` contains the classpath scoped to a given buffer.

## build tool detection
`maven` is detected by the presence of a `pom.xml`.
`sbt` is detected primarily by the presence of `build.sbt`, falling back to `sbt` (for those using a wrapper script).
