module core.command.commands.HelpCommand;

import core.command.Command;
class HelpCommand : Command {
    import std.stdio;
    import std.string;
    bool execute(string[] args) {
        import core.command.CommandManager;
        foreach(key, value; CommandManager.registeredCommands) {
            writeln(value.helpDescription());
        }
        return true;
    }

    string description() {
        return "Displays information about every registered command.";
    }

    string helpDescription() {
        return "help    - Displays information about every registered command.";
    }
}