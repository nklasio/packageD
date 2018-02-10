module core.command.Command;

interface Command {
    public:
    bool execute(string[] args);
    string discription();
}