module core.packageD;

class packageD {
    import core.EnvironmentManager : EnvironmentManager;
    import std.stdio;
    import std.string;
    import std.json;
    import std.array;
    import std.algorithm.searching;
    import std.algorithm.mutation;

    import std.net.curl;

    import core.RepositoryManager;
    import core.ConfigurationManager;
    import core.command.CommandManager;

    CommandManager commandManager;
    this(string[] args) {
	    EnvironmentManager.initialize();
        EnvironmentManager.sharedLogger.log("[I]Initializing packageD");

        RepositoryManager repositoryManager = new RepositoryManager();
        ConfigurationManager configurationManager = new ConfigurationManager(repositoryManager);

        if(args.length == 2) {

            auto req = args[1].replace("%22", "\"");
            if(startsWith(req, "pacd://")) {
                req = chompPrefix(req, "pacd://");
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
                auto splittedInput = split(input);
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
}