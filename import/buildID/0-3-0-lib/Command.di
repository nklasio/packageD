// D import file generated from 'source/core/models/Command.d'
module core.models.Command;
import std.algorithm.searching;
import std.stdio;
import std.string;
import std.regex;
import std.process;
import std.conv;
import core.VariableManager;
class Command
{
	string _command = void;
	string[] _requirements = void;
	this(string command, string[] requirements = [])
	{
		this._command = command;
		this._requirements = requirements;
	}
	bool execute();
	bool resolveSymbols();
}
