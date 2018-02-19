module core.RepositoryManager;

enum RepositoryType {
    AUR = "aur",
    pacD = "pacD"
}
import std.json;
import core.EnvironmentManager;
import std.stdio : writeln;


class RepositoryManager {
    public:
    void Info(RepositoryType type, JSONValue pac) {
        import std.string : format;

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
                            PackageCache.addToCache(RepositoryType.AUR, pac["Name"].str);
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

    bool RequestPacD(JSONValue pacDObject) {
        import std.string;
        import std.file;

        //writeln(pacDObject["package"]);
        auto pack = pacDObject["package"];
        writeln("_____________________________________________");
        writeln(format("Name: %s", pack["name"].str));
        string ver = format("%s.%s.%s",pack["major"], pack["minor"], pack["patch"]);
        writeln(format("Version: %s", ver));
        writeln(format("Author: %s", pack["author"].str));
        writeln("_____________________________________________");
        writeln(format("You are about to install \"%s\" : v.%s by %s. Continue installing? [Y|n]", pack["name"].str, ver, pack["author"].str));
        import std.stdio : stdin;
        import std.algorithm.searching : canFind;
        auto read = stdin.readln();
        if(read.canFind("n")){
            writeln("Installation abort by user!");
            return false;
        } else {
            import std.process;
            import std.file : chdir;
            import std.array : replace, split;
            import std.conv : to;

            import core.EnvironmentManager : EnvironmentManager;
            writeln("Installing...");
            chdir(EnvironmentManager.tmpDirectory);

            writeln("#Cloning package");
            auto proc = executeShell("git clone " ~ pack["git"].str.replace("\\", "") ~ " --depth 1");
            if(proc.status != 0) {
                writeln("ERROR! : Program returned " ~ to!string(proc.status));
                writeln(proc.output);
                return false;
            } else {
                writeln(proc.output);
            }

            auto packageDir = format("%s%s", EnvironmentManager.tmpDirectory, pack["name"].str);
            if(exists(packageDir)) {
                writeln("Successfully cloned package!");
                chdir(packageDir);
                import std.path : dirSeparator;
                string packaged = format("%s%s%s%s", EnvironmentManager.tmpDirectory, pack["name"].str, dirSeparator, "packaged.json");
               
                if(exists(packaged)){
                    auto build = parseJSON(readText(packaged));

                    if(build["build"]["test"].str.length > 0) {
                        writeln("#Running Tests! THIS MAY TAKE A WHILE!");
                        proc = executeShell(build["build"]["test"].str);
                       if(proc.status != 0) {
                            writeln("ERROR! : Program returned " ~ to!string(proc.status));
                            writeln(proc.output);
                            return false;
                        } else {
                            writeln(proc.output);
                        }
                    }

                    if(build["build"]["build"].str.length > 0){
                       writeln("#Building Package! THIS MAY TAKE A WHILE!");
                        proc = executeShell(build["build"]["build"].str);
                       if(proc.status != 0) {
                            writeln("ERROR! : Program returned " ~ to!string(proc.status));
                            writeln(proc.output);
                            return false;
                        } else {
                            writeln(proc.output);
                        }
                        writeln("Successfully build: " ~ pack["name"].str);
                    }

                    switch(build["type"].str) {
                        case "library":
                            auto lib = EnvironmentManager.setupSubFolder(EnvironmentManager.dataDirectory, "libraries");
                            foreach(output; build["output"].array) {
                                copy(output.str, lib ~ output.str);
                            }
                            break;
                        case "application":
                            auto bin = EnvironmentManager.setupSubFolder(EnvironmentManager.dataDirectory, "bin");
                            auto app = EnvironmentManager.setupSubFolder(bin, build["name"].str);
                            foreach(output; build["output"].array) {
                                copy(output.str, bin ~ output.str);
                            }
                            
                            break;
                        default: 
                            writeln("packageD does not support this project type! " ~ build["type"].str);
                            return false;
                            
                    }

                    writeln(format("SUCCESS! Successfully installed %s : %s by %s", pack["name"].str, ver, pack["author"].str));
                } else {
                    writeln("Package is not a valid packageD package... Please report this to the author!");
                    return false;
                }
            }
        }
        return true;
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