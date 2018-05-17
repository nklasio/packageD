// D import file generated from 'source/core/Parser.d'
module core.Parser;
import std.json;
import std.file;
import std.stdio;
import std.string;
import std.array;
import std.conv;
import core.models.Project;
import core.models.SourceDirectory;
import core.models.Command;
import core.VariableManager;
class Parser
{
	private string _buildFile = void;
	private Project _project = void;
	private string[string] _variables = void;
	private SourceDirectory[] _sourceDirectorys = void;
	private bool[string] _dependencies = void;
	private Command[] _prepareCommands = void;
	private Command[] _buildCommands = void;
	private Command[] _checkCommands = void;
	this(string buildFile)
	{
		assert(exists(buildFile) == true, format("Build file does not exist! << %s", buildFile));
		this._buildFile = buildFile;
	}
	int parse();
}
