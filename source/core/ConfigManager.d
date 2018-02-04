module core.ConfigManager;
import core.RepositoryManager;

class ConfigManager {
    this(RepositoryManager repositoryManager) {
        this.repositoryManager = repositoryManager;
       loadConfigurations();
    }

    ~this() {

    }

    private:
    void loadConfigurations() {
        import core.EnvironmentManager : EnvironmentManager;
        import std.file : exists, isFile, dirEntries, DirEntry, SpanMode, readText;
        import std.stdio : writeln;
        foreach(DirEntry f; dirEntries(EnvironmentManager.configDirectory, "*.json", SpanMode.shallow, false)) {
            import std.string : format;
            import std.json : parseJSON, JSONValue;
            auto j = parseJSON(readText(f)).object;
            JSONValue[] rep = j["repositorys"].array;
            foreach(r; rep) {
                repositoryManager.addRepository(r.str);
            }
        }
        
    }

    RepositoryManager repositoryManager;
}