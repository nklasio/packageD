import std.stdio;
import std.getopt;


int main(string[] args)
{
	import EnvironmentManager : EnvironmentManager;
	EnvironmentManager.initialize();

	string pack = "";
	bool handlerFailed = false;
	if(args.length == 1) {
		ver();
	}

	GetoptResult helpInformation = getopt(args, "version|v", "Show version of packaged", &ver,
									 			"environment|env", "Debug Environment Variables", &eDebug);

	if(helpInformation.helpWanted) {
		defaultGetoptPrinter("usage: packaged <operation> [...]", helpInformation.options);
	} 

	

	return handlerFailed ? 1 : 0;
}

private:
static void ver() {
	printf("\n");
		printf("packageD - © by Niklas Stambor\n");
		printf("A Dlang based package manager\n");
		printf("This program may be freely redistributed\nunder the terms of the GNU General Public License V3.\n");
		printf("\n");
		printf("usage: packaged <operation> [...]\n");
		printf("Use --help or \"man packaged\" to get help\n");
		printf("\n");
}

static void eDebug() {
	import EnvironmentManager : EnvironmentManager;
	EnvironmentManager.dDebug();
}

