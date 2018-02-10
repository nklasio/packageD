module core.command.commands.VersionCommand;

import core.command.Command;
class VersionCommand : Command {
    bool execute(string[] args) {
        import core.packageD;
        packageD.ver();
        return true;
    }

    string description() {
        return "Displays version of packageD!";
    }
    
    string helpDescription() {
        return "version - Displays version of packageD!";
    }
    
}