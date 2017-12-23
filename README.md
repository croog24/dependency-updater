# Dependency-Updater
A simple Crystal script (mostly a learning exercise) to scan a given base directory
for Gradle build files and perform a check to see if there are any updates available
for each dependency.

_Note that this is quite simple in its regex scan and made only for my application(s). It will look for the following format:_
```
def versionVariable = 'version'
...
compile group: 'group', name: 'name', version: versionVariable
...
tsetCompile group: 'group', name: 'name', version: versionVariable
```

# TODO
- Clean up variable scans (Might not be doable because version vars are defined _before_ dependency definitions, so have to reparse from the top)
- Add major and minor flags for version scans
