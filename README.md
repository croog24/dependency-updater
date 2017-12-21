# Dependency-Updater
A simple Crystal script (mostly a learning exercise) to scan a given base directory
for Gradle build files and perform various update options.

_Note that this is quite simple in its regex scan and made only for my application(s). It will look for the following format:_
```
def versionVariable = 'version'
...
compile group: 'group', name: 'name', version: versionVariable
...
tsetCompile group: 'group', name: 'name', version: versionVariable
```

# TODO
- Parse files for dependency keywords and values
- Connect to appropriate central repositories to compare versions