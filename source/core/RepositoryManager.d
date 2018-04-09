module core.RepositoryManager;

import std.json;
import core.EnvironmentManager;
import std.stdio : writeln;

import std.stdio;
import std.string;
import std.algorithm.iteration;
import std.algorithm.searching;

import std.array;

import std.net.curl;
import std.json;
import std.file;

import std.process;
import std.conv : to;


class RepositoryManager {
    public:
        bool RequestPacD(JSONValue pacDObject) {
        //writeln(pacDObject["package"]);
        auto pack = pacDObject["package"];
        writeln("_____________________________________________");
        writeln(format("Name: %s", pack["name"].str));
        string ver = format("%s.%s.%s",pack["major"], pack["minor"], pack["patch"]);
        writeln(format("Version: %s", ver));
        writeln(format("Author: %s", pack["author"].str));
        writeln("_____________________________________________");
        writeln(format("You are about to install \"%s\" : v.%s by %s. Continue installing? [Y|n]", pack["name"].str, ver, pack["author"].str));
              auto read = stdin.readln();
        if(read.canFind("n")){
            writeln("Installation abort by user!");
            return false;
        } else {


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

    private:
    string[] mirrors = [];
}