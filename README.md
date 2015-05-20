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

### maven
the root is determined by traversing upward to the first directory containing a `pom.xml`. this results in commands being run on submodules in multi module projects.

dependencies are output using the following command. 
`mvn dependency:build-classpath -Dmdep.outputFile={{outputfile}} -DincludeScope={{scope}}`

### sbt
the root is determined first by the presence of `build.sbt`. if none, fallback to `sbt` for those using an sbt wrapper script and `.scala` build definitions.

dependencies are output using the following command.
`sbt "export {{scope}}:full-classpath"`

output is:
```
	{{modulename}}/{{scope}}:fullClasspath
	{{classpath}}

```
module name is parsed and a best effort search for a directory of that name is performed. the first, if any, gets `.vimcp` written in that directory. _it is crucial that module names reflect the name of the directory they are found in._
