module core.packageD;

class packageD {
    import core.EnvironmentManager : EnvironmentManager;
    import std.stdio;
    import std.string;
    import std.json;
    
    import core.command.CommandManager;
    CommandManager commandManager;
    this(string[] args) {
	    EnvironmentManager.initialize();
        EnvironmentManager.sharedLogger.log("[I]Initializing packageD");
        import cache.PackageCache : PackageCache;
        PackageCache.buildCaches();
        EnvironmentManager.sharedLogger.log("[I]Building caches");

        import core.RepositoryManager : RepositoryManager, RepositoryType;
        import core.ConfigurationManager : ConfigurationManager;
        RepositoryManager repositoryManager = new RepositoryManager();
        ConfigurationManager configurationManager = new ConfigurationManager(repositoryManager);
        //PackageCache.writeCaches();

        if(args.length == 2) {
            import std.array : replace;
            import std.algorithm.searching : startsWith;
            auto req = args[1].replace("%22", "\"");
            if(startsWith(req, "pacd://")) {
                req = chompPrefix(req, "pacd://");
                import std.net.curl : get, CurlException;
                try {
                    auto response = get(format("%s", req));
                    repositoryManager.RequestPacD(parseJSON(response));
                    writeln("Press any key to continue!");
                    stdin.readln();
                } catch(CurlException ex) {
                    writeln(ex);
                    stdin.readln();
                } catch(JSONException ex) {
                    writeln(ex);
                    stdin.readln();
                }
            }
        } else {
            commandManager = new CommandManager();
            commandLoop(commandManager);
        }

    }

    import std.algorithm.comparison;
    private static void commandLoop(CommandManager commandManager) {
        while(1) {
            write("packageD > ");
            auto input = stripRight(stdin.readln());
            if(cmp(strip(input), "exit") == 0) {
                return;
            } else {
                import std.array : split;
                auto splittedInput = split(input);
                import std.algorithm.mutation : remove;
                auto command = splittedInput[0];
                auto res = commandManager.execute(command, splittedInput.remove(0));
                if(res == 2) {
                    writeln(format("[E]%s is not a registered command! To see all available commands type help", command));
                }
            }
        }
    }

    public static void ver() {
	    printf("\n");
		printf("packageD - © by Niklas Stambor\n");
		printf("A Dlang based package manager\n");
		printf("This program may be freely redistributed\nunder the terms of the GNU General Public License V3.\n");
		printf("\n");
    }

    ~this() {
        import cache.PackageCache : PackageCache;
        EnvironmentManager.sharedLogger.log("[I]Destructing packageD");
    }

}