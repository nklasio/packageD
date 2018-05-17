module packaged.Version;

struct Version {
    uint major;
    uint minor;
    uint patch;

    public string toString() const {
        import std.format : format;
        return format("%s.%s.%s", major, minor, patch);
    }
}