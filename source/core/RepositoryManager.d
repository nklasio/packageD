module core.RepositoryManager;

enum RequestType {
    AUR = 0,
    pacD
}
import std.json;
import core.EnvironmentManager;

class RepositoryManager {
    public:
    void Info(RequestType type, JSONValue pac) {
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
        //TODO: CHECK IF PACKAGE ALLREADY EXISTS LOCALY
        //TODO: CHECK FOR USER
        GatheringPackage(type, pac);
        foreach(d; dependencies) { 
            GatheringPackage(type, pac);
        }

    }

    bool GatheringPackage(RequestType type, JSONValue pac) {
        import std.net.curl : download, CurlException;
        import std.stdio : writeln;
        import std.string : format;
        import std.algorithm.iteration : filter;
        import std.algorithm.searching : canFind;
        
        import std.array: array;

        writeln("Downloading package...");

        final switch(type) {
            case RequestType.AUR: 
                auto p = filter!(rep => canFind(rep, "aur"))(repositorys);
                import std.file : exists, getSize;
                foreach(r; p) {
                    try {
                        version(Windows) {
                            string pacFile = format("%s%s.tar.gz", EnvironmentManager.setupFolder(null, "C:\\.packageD\\data\\repositorys\\aur\\"), pac["Name"].str);
                            download(format("%s%s",r, pac["URLPath"].str), pacFile);
                            if(exists(pacFile)) {
                                writeln(format("Successfully downloaded! %s.tar.gz | %s", pac["Name"].str, getSize(pacFile)));
                                return true;
                            }
                        } else version(linux) {
                            string pacFile = format("%s%s.tar.gz", EnvironmentManager.setupFolder(null, "/var/packageD/repositorys/aur/"), pac["Name"].str);
                            download(format("%s%s", r, pac["URLPath"].str), pacFile);
                            if(exists(pacFile)) {
                                writeln(format("Successfully downloaded! %s.tar.gz | %s", pac["Name"].str, getSize(pacFile)));
                                return true;
                            }
                        }
                    }
                    catch(CurlException exc) {
                        writeln(format("%s | %s", exc.message, r));
                        EnvironmentManager.sharedLogger.error(format("%s | %s", exc.message, r));
                    }
                }

                break;
            case RequestType.pacD: 
                break;
        }

        //cgit/aur.git/snapshot/spotify.tar.gz"
        return false;
    }

    bool Request(RequestType requestType, string pac, bool dependency = false) {
        import std.stdio : writeln;
        import std.string : format;
        import std.algorithm.iteration : filter;
        import std.algorithm.searching : canFind;
        
        import std.array: array;
        
        import std.net.curl : get, CurlException;
        import std.json : parseJSON, JSONValue;

        JSONValue packet = null; 
        

        final switch(requestType) {
            case RequestType.AUR: 
                auto p = filter!(rep => canFind(rep, "aur"))(repositorys);

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
            case RequestType.pacD:
                    break;
        }
        import std.file : write;
        if(!packet.isNull) {
            write("debug.request", packet.toString());
            Info(requestType, packet);
            return true;
        } else {
            if(!dependency) writeln(format("Could not find package: %s", pac));
            return false;
        }
    }



    void addRepository(string repository) {
        this.repositorys ~= repository;
    }
    void addRepositorys(string[] repositorys) {
        this.repositorys ~= repositorys;
    }

    this() {
        this.repositorys = [];
    }

    ~this() {
        
    }
    private:
    string[] repositorys;
}