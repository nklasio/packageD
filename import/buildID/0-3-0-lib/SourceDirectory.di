// D import file generated from 'source/core/models/SourceDirectory.d'
module core.models.SourceDirectory;
import std.file;
import std.stdio;
class SourceDirectory
{
	private string _path = void;
	private bool _recursive = false;
	private string[] _entries = void;
	import std.format;
	this(string path, bool recursive = false, bool createIfNonExistent = false)
	{
		if (!createIfNonExistent)
		{
			assert(exists(path) == true, format("Source Path is not valid \"%s\"", path));
		}
		else
		{
			if (!exists(path))
				mkdirRecurse(path);
		}
		this._path = path;
		this._recursive = recursive;
		fetchEntries();
	}
	string[] fetchEntries(string pattern);
	private void fetchEntries();
	@property string[] getEntries();
}
