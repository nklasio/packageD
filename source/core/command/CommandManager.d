module core.command.CommandManager;

class CommandManager {
    import core.command.Command;
    import core.command.commands.VersionCommand;
    import core.command.commands.HelpCommand;
    this() {
        registerCommand("version", new VersionCommand());
        registerCommand("help", new HelpCommand());
    }

    void registerCommand(string activator, Command command) {
        registeredCommands[activator] = command;
    }

    int execute(string command, string[] args) {
        import std.stdio : writeln;
        import std.algorithm.searching : canFind;
        if(registeredCommands.keys.canFind(command))
            return registeredCommands[command].execute(args);
        else return 2;
    }

    static Command[string] registeredCommands;
}