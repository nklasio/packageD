module core.RepositoryManager;

enum RepositoryType {
    AUR = 0,
    pacD
}
import std.json;
import core.EnvironmentManager;

class RepositoryManager {
    public:
    void Info(RepositoryType type, JSONValue pac) {
        import std.string : format;
        import std.stdio : writeln;

        writeln(format("Found 1 package! %s", pac["Name"].str));
        writeln(format("Description: %s", pac["Description"].str));
        import std.array : array, join;
        string[] dependencies;
        if("Depends" in pac) {
            auto s = pac["Depends"].array;
            foreach(p; s) {
                dependencies ~= p.str;
            }
            writeln(format("Requiered dependencies[%s]: %s", dependencies.length, join(dependencies, ", ")));
        }
        bool failed = false;
        foreach(d; dependencies) {
            if(!Request(type, d, true)) {
                writeln(format("Abort! Could not resolve dependencies for %s! \nUnresolvable dependency: %s", pac["Name"].str, d));
                failed = true;
                break;
            }
        }
        if (failed)
            return;
        
        if(true) {

        }
        //TODO: CHECK FOR USER
        GatheringPackage(type, pac);
        foreach(d; dependencies) { 
            GatheringPackage(type, pac);
        }

    }

    bool GatheringPackage(RepositoryType type, JSONValue pac) {
        import std.net.curl : download, CurlException;
        import std.stdio : writeln;
        import std.string : format;
        import std.algorithm.iteration : filter;
        import std.algorithm.searching : canFind;
        
        import std.array: array;


        final switch(type) {
            case RepositoryType.AUR: 
                auto p = filter!(rep => canFind(rep, "aur"))(mirrors);
                import std.file : exists, getSize;
                foreach(r; p) {
                    try {
                        import cache.PackageCache : PackageCache;
                        string pacFile = format("%s%s.tar.gz", EnvironmentManager.setupSubFolder(EnvironmentManager.repositoryDirectory, "aur"), pac["Name"].str);
                        if(PackageCache.cacheContains(type, pac["Name"].str)) {
                            writeln(format("Package already in cache. Skipping download! | %s", getSize(pacFile)));
                            return true;
                        }
                        writeln("Downloading package...");
                        download(format("%s%s",r, pac["URLPath"].str), pacFile);
                        if(exists(pacFile)) {
                            writeln(format("Successfully downloaded! %s.tar.gz | %s", pac["Name"].str, getSize(pacFile)));
                            PackageCache.rebuildCache(RepositoryType.AUR);
                            return true;
                        }
                    }
                    catch(CurlException exc) {
                        writeln(format("%s | %s", exc.message, r));
                        EnvironmentManager.sharedLogger.error(format("%s | %s", exc.message, r));
                    }
                }

                break;
            case RepositoryType.pacD: 
                break;
        }

        //cgit/aur.git/snapshot/spotify.tar.gz"
        return false;
    }

    bool Request(RepositoryType RepositoryType, string pac, bool dependency = false) {
        import std.stdio : writeln;
        import std.string : format;
        import std.algorithm.iteration : filter;
        import std.algorithm.searching : canFind;
        
        import std.array: array;
        
        import std.net.curl : get, CurlException;
        import std.json : parseJSON, JSONValue;

        JSONValue packet = null; 
        

        final switch(RepositoryType) {
            case RepositoryType.AUR: 
                auto p = filter!(rep => canFind(rep, "aur"))(mirrors);

                foreach(r; p) {
                    if(!packet.isNull)
                        break;

                    try {
                        auto request = parseJSON(get(format("%srpc/?v=5&type=info&arg[]=%s", r, pac))).object;
                        if(request["resultcount"].integer > 0){
                            foreach(result; request["results"].array) {
                                if(result["Name"].str == pac) {
                                    packet = result;
                                    break;
                                }
                            }
                        }
                    }
                    catch(CurlException exc) {
                        if(!dependency) writeln(format("%s | %s", exc.message, r));
                        EnvironmentManager.sharedLogger.error(format("%s | %s", exc.message, r));
                    }
                }
                break;
            case RepositoryType.pacD:
                    break;
        }
        import std.file : write;
        if(!packet.isNull) {
            write("debug.request", packet.toString());
            Info(RepositoryType, packet);
            return true;
        } else {
            if(!dependency) writeln(format("Could not find package: %s", pac));
            return false;
        }
    }



    void addMirror(string repository) {
        this.mirrors ~= repository;
    }
    void addMirrors(string[] mirrors) {
        this.mirrors ~= mirrors;
    }

    this() {
        this.mirrors = [];
    }

    ~this() {
        
    }
    private:
    string[] mirrors;
}