module core.RepositoryManager;

enum RequestType {
    AUR = 0,
    pacD
}

class RepositoryManager {
    public:
    void Request(RequestType requestType, string pac) {
        import std.stdio : writeln;
        import std.string : format;
        import std.algorithm.iteration : filter;
        import std.algorithm.searching : canFind;
        
        import std.array: array;
        import std.conv : to;

        final switch(requestType) {
            case RequestType.AUR: 
                auto p = filter!(rep => canFind(rep, "aur"))(repositorys);
                import std.net.curl : get, CurlException;
                foreach(r; p) {
                    try {
                    auto request = get(format("%srpc/?v=5&type=search&arg=%s", r, pac));
                    import std.file : write;
                    write("debug.request", request);
                    }
                    catch(CurlException exc) {
                        import core.EnvironmentManager : EnvironmentManager;
                        writeln(format("%s | %s", exc.message, r));
                        EnvironmentManager.sharedLogger.error(format("%s | %s", exc.message, r));
                    }
                }
                break;
            case RequestType.pacD:
                    break;
        }
        return;
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