module core.Package;

import std.net.curl;
import std.json;
import std.array;
import std.container.array;
import std.conv;

import std.stdio;
import std.string;
import core.Version;

struct Package {
    string id;
    //timestamp created_at
    //timestamp updated_at
    string author;
    string git;
    string name;
    string description;
    string imageUrl;
    Version ver;

    bool install() {
        writeln("TODO: Install <", name, ">");
        return false;
    }

    void info() {
        import std.format : format;
        writeln(format("Name: %s", name));
        writeln(format("Version: %s", ver.toString()));
        writeln(format("Description: %s", description));
        writeln(format("Author: %s", author));
    }

    static:
    Package choose(Package[string] packages) {
        if(packages.length > 1) {
            writeln("Found more than one possible package for your query [", packages.length,"]");
            req:
            write(format("Please choose one package: (%s)(Default: %s)", packages.keys.join(","), packages.keys[0]));
            auto read = stdin.readln().chop;
            if(read in packages || read == "") {
                if(read == "")
                    read = packages.keys[0];
                return packages[read];
            } else  {
                writeln("Packages do not contain '", read, "'");
                goto req;
            }
        } else {
            return packages[packages.keys[0]];
        }
        
    }

    bool searchAndInstall(string requestedPackage) {
        writeln("Searching for package: ", requestedPackage, "...");
        return choose(fetch(requestedPackage)).install();
    }

    void info(string pack) {
        auto p = choose(fetch(pack));
        import std.format : format;
        writeln(format("Name: %s", p.name));
        writeln(format("Version: %s", p.ver.toString()));
        writeln(format("Description: %s", p.description));
        writeln(format("Author: %s", p.author));
    }

    Package[string] fetch(string requestedPackage) {
        import std.format : format;
        auto res = get(format("%s%s", "http://reposited.test/api/s/", requestedPackage));
        JSONValue jRes = parseJSON(res);
        auto queryPackages = jRes["packages"].array;
        if(queryPackages.length < 1) {
            writeln("No package found < ", requestedPackage);
            return null;
        }
        else {
            Package[string] packages;
            foreach(pack; queryPackages) {
                try {
                packages[pack["name"].str] = 
                        Package(
                            pack["id"].str, pack["author"].str, pack["git"].str, 
                            pack["name"].str, pack["description"].str ,pack["imageUrl"].str, 
                            Version(to!uint(pack["major"].integer), to!uint(pack["minor"].integer),to!uint(pack["patch"].integer)));
                } catch(JSONException ex) {
                    writeln(ex.message);
                }
            }
            return packages;
        }
    }
}