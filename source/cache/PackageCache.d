module cache.PackageCache;

struct PackageCache {
    import core.RepositoryManager : RepositoryType;
    import std.stdio : writeln;
    public static: 

    void buildCaches() {
        import std.file;
        import std.traits;
        foreach(rep; EnumMembers!RepositoryType) {
            import std.algorithm.iteration : filter;
            import std.array : array;
            import std.conv : to;
            import core.EnvironmentManager : EnvironmentManager;
            auto repository = to!string(cast(OriginalType!RepositoryType)rep);
            auto repoPath = std.string.format("%s%s%s", EnvironmentManager.repositoryDirectory, repository, std.path.dirSeparator);
            if(std.file.exists(repoPath)){
                auto pacs = filter!(ent => ent.isFile)(dirEntries(repoPath, "{*.tar*,*.pacD}", SpanMode.shallow)).array;
                foreach(p; pacs) {
                    repositoryCache[rep] ~= p;
                }
            }
        }
    }

    void writeCaches() {
        import std.file;
        import std.traits;
        foreach(rep; EnumMembers!RepositoryType) {
            import std.conv : to;
            import core.EnvironmentManager : EnvironmentManager;
            auto repository = to!string(cast(OriginalType!RepositoryType)rep);
            auto cacheFile = std.string.format("%s%s%scache.json", EnvironmentManager.repositoryDirectory, repository, std.path.dirSeparator);
            
            import std.json : JSONValue, toJSON;
            JSONValue jValue;
            jValue["packages"] = repositoryCache[rep];
            if(exists(cacheFile)) remove(cacheFile);
            write(cacheFile, toJSON(jValue));
        }
                import std.json : toJSON;
        import std.stdio : writeln;
    }

    bool cacheContains(RepositoryType type, string pac) {
        import std.algorithm.searching : canFind;
        import std.stdio : writeln;
        import std.string : format;
        import std.array : split;
        foreach(p; getCacheForRepositoryType(type)){
            writeln(p);
            if(canFind(p, pac)){
                return true;
            }
        }
        return false;
    }

    void addToCache(RepositoryType type, string pac) {
        repositoryCache[type] ~= pac;
    }

    string[] getCacheForRepositoryType(RepositoryType type) {
        return repositoryCache[type];
    }

    private:
    string[] cacheFiles;
    string[][RepositoryType] repositoryCache;
}