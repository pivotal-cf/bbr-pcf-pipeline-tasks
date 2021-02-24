# Introduction
If you are running a [Cryogenics Icebox containerised development environment](https://github.com/pivotal-cf/cryogenics-icebox)
all these variables will be available and prepopulated.

Otherwise, make sure you initialise them with the right values.
Running these scripts without them can have unpredictable results.

<br /><br />
# Variables

## ```$PROJECT_ROOT```

Should point to ```your project's``` root folder.

This is useful to avoid:
- Complex and fragile relative paths that break after moving things around.
- Absolute paths that break when run in a different environment.

```In Icebox```: It is populated using ```git-root``` command, which

> When run inside any folder contained within a git repository even within
> deeply nested submodules, git-root will return the path of the topmost repository.

---

## ```$CONCOURSE_URL```

Should point to some pre-existing Concourse instance.

This is useful to:
- Deploy to different environments running the same scripts.
- Reuse variables and reduce duplication across scripts.

```In Icebox```: It defaults to http://concourse:8080/. A containerised Concourse instance _intended for **local development only**_.
**BEWARE!** you can't just navigate to http://concourse:8080/ in your favorite browser.<br/>
The _"real"_ url for this Concourse instance which you can visit is http://localhost:9001/

---

## ```$CONCOURSE_TEAM```

The name of the Concourse team to which you want to deploy the pipelines.

This is useful to:
- Deploy to different environments running the same scripts.
- Reuse variables and reduce duplication across scripts.

```In Icebox```: It defaults to "main".

<br /><br />

# How to run literate scripts
By convention, literate (```lit```) scripts will have the extension ```".sh.md"``` although this is not mandatory.<br />
```lit``` scripts are written in [Markdown](https://www.markdownguide.org) following some conventions that allow them to be run with [this lit cli tool](https://github.com/vijithassar/lit).

Test it now by running:
```bash
lit-run ${PROJECT_ROOT}/.icebox/hi.sh.md --run
```

You can also target multiple ```lit``` scripts using wildcards.<br /><br />
**ADVICE!** when using wildcards **DON'T** include the ```--run``` flag.<br />
This will display a list of all the files that would be executed.<br />
Only after you have reviewed it, run the command again with the flag to actually run the scripts.

```bash
lit-run ${PROJECT_ROOT}/.icebox/**/*.sh.md
```
