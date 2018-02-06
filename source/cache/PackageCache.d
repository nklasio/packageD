module cache.PackageCache;

struct PackageCache {
    public static: 
    void buildCaches() {
        import core.EnvironmentManager : EnvironmentManager;
        import std.string : format;
        import std.file;
        import std.path : dirSeparator;
        import std.algorithm.iteration : filter;
        import std.json : toJSON;
        import std.stdio : writeln;
        auto reps = filter!(ent => ent.isDir)(dirEntries(EnvironmentManager.repositoryDirectory, SpanMode.shallow));
        foreach(rep; reps) {
            import std.array : array, join;
            auto pacs = filter!(ent => ent.isFile)(dirEntries(rep, "*.tar*", SpanMode.shallow)).array;
            string[] packages;
            foreach(pac; pacs){
                packages ~=pac;
            }
            import std.json : JSONValue;
            JSONValue jValue;
            jValue["packages"] = packages;
            auto cacheFile = format("%s%scache.json", rep, dirSeparator);
            if(exists(cacheFile)) remove(cacheFile);
            write(cacheFile, toJSON(jValue));
            cacheFiles ~= cacheFile;
        }
    }
    import core.RepositoryManager : RequestType;

    bool cacheContains(RequestType type, string pac) {
        import std.algorithm.searching : canFind;
        import std.stdio : writeln;
        import std.string : format;
        import std.array : split;
        foreach(p; getCacheForRequestType(type)){
            writeln(p);
            if(canFind(p, pac)){
                return true;
            }
        }
        return false;
    }

    void rebuildCache(RequestType type) {
        import core.EnvironmentManager : EnvironmentManager;
        import std.string : format;
        import std.file;
        import std.path : dirSeparator;
        import std.algorithm.iteration : filter;
        import std.json : toJSON;
        import std.stdio : writeln;

        import std.array : array, join;
        auto rep = format("%s%s%s", EnvironmentManager.repositoryDirectory, type, dirSeparator);
        auto pacs = filter!(ent => ent.isFile)(dirEntries(rep, "*.tar*", SpanMode.shallow)).array;
        string[] packages;
        foreach(pac; pacs){
            packages ~=pac;
        }
        import std.json : JSONValue;
        JSONValue jValue;
        jValue["packages"] = packages;
        auto cacheFile = format("%s%scache.json", rep, dirSeparator);
        remove(cacheFile);
        write(cacheFile, toJSON(jValue));
        cacheFiles ~= cacheFile;
    }

    string[] getCacheForRequestType(RequestType type) {
        import std.string : split, format;
        import std.algorithm.searching : canFind;
        import std.stdio : writeln;
        import std.path : dirSeparator;
        import std.algorithm.iteration : filter;
        import std.array: array; 
        import std.file : readText;
        import std.json : parseJSON, JSONValue;
        string[] ret;
        final switch(type) {
            case RequestType.AUR: 
            auto cache = parseJSON(readText(filter!(cFile => canFind(cFile, format("%saur%s", dirSeparator, dirSeparator)))(cacheFiles).array[0]))["packages"].array;
            foreach(c; cache) {
                ret ~= c.str;
            }
            return ret;
            case RequestType.pacD:
            break;
        }        
        return ret;
    }

    private:
    string[] cacheFiles;
}