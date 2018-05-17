// D import file generated from 'source/core/VariableManager.d'
module core.VariableManager;
import core.models.SourceDirectory;
import std.array;
import std.stdio;
import std.string;
import std.regex;
import std.algorithm.searching;
struct VariableManager
{
	static string[string] Variables = void;
	static SourceDirectory[] SourceDirectorys = [];
	static void init(string[string] variables, SourceDirectory[] sourceDirs = []);
	static string ResolveSource(string pattern);
	static string Resolve(string s);
}
