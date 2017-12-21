GRADLE = "build.gradle"
MVN_REPO_ARTIFACT_URL = "https://mvnrepository.com/artifact/"

GRADLE_DEP_RE = /(test)?compile group: '(?<group>\S*)', name: '(?<artifact>\S*)', version: '?(?<version>\S*)'?/i

# Recursively scan directories for Gradle build files
# Outputs a Hash of (path, empty[])
def parse_dirs(start, dependencies)
    Dir.foreach(start) do |x|
        path = File.join(start, x)
        if x == "." || x == ".."
            next
        end
        if File.directory?(path)
            parse_dirs(path, dependencies)
        else
            if path.ends_with?(GRADLE)
                dependencies[path] = [] of String
            end
        end
    end
    return dependencies
end

def parse_build_file(path)
    File.each_line(path) do |line|
        if dep = line.match(GRADLE_DEP_RE)
            puts "#{dep["group"]?}:#{dep["artifact"]?}:#{dep["version"]?}"
        end
    end
end

begin
    base_dir: Dir = Dir.new(ARGV[0])
rescue
    puts "Must supply 1 directory to recursively scan!"
    exit 1
end    

puts "Scanning for build files in: #{base_dir.path}"
dependencies = {} of String => Array(String)
dependencies = parse_dirs(base_dir.path, dependencies)

puts "\n"

dependencies.keys.each do |k|
    puts "Found build file: #{k}"
    parse_build_file(k)
end
