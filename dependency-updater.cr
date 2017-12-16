GRADLE = "build.gradle"
MVN = "pom.xml"  

# Recursively scan directories for Gradle or Maven build files
# Outputs a Hash of (path, empty[] for dependencies)
def parse_dirs(start, dependencies)
    Dir.foreach(start) do |x|
        path = File.join(start, x)
        if x == "." || x == ".."
            next
        end
        if File.directory?(path)
            parse_dirs(path, dependencies)
        else
            if path.ends_with?(GRADLE) || path.ends_with?(MVN)
                dependencies[path] = [] of String
            end
        end
    end
    return dependencies
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

dependencies.keys.each do |x|
    puts "Found build file: #{x}"
end
