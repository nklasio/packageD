module core.command.commands.VersionCommand;

import core.command.Command;
class VersionCommand : Command {
    bool execute(string[] args) {
        import core.packageD;
        packageD.ver();
        return true;
    }

    string discription() {
        return "Displays version of packageD!";
    }
}