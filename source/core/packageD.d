module core.packageD;

class packageD {
    import core.EnvironmentManager : EnvironmentManager;
    import std.stdio : printf;
    import std.getopt : getopt, defaultGetoptPrinter;

    this(string[] args) {
        if(args.length == 1)
            ver();
	    EnvironmentManager.initialize();
        EnvironmentManager.sharedLogger.log("[I]Initializing packageD");
        import cache.PackageCache : PackageCache;
        PackageCache.buildCaches();
        EnvironmentManager.sharedLogger.log("[I]Building caches");

        string pac;
        auto helpInformation = getopt(args, "version|v", "Show version of packaged", &ver, "search|S", "Search package", &pac);

        if(helpInformation.helpWanted) {
            defaultGetoptPrinter("usage: packaged <operation> [...]", helpInformation.options);
        } 
        import core.RepositoryManager : RepositoryManager, RepositoryType;
        import core.ConfigurationManager : ConfigurationManager;
        RepositoryManager repositoryManager = new RepositoryManager();
        ConfigurationManager configurationManager = new ConfigurationManager(repositoryManager);

        if(pac)
            repositoryManager.Request(RepositoryType.AUR, pac);

        PackageCache.writeCaches();
    }

    public static void ver() {
	    printf("\n");
		printf("packageD - © by Niklas Stambor\n");
		printf("A Dlang based package manager\n");
		printf("This program may be freely redistributed\nunder the terms of the GNU General Public License V3.\n");
		printf("\n");
		printf("usage: packaged <operation> [...]\n");
		printf("Use --help or \"man packaged\" to get help\n");
		printf("\n");
    }

    ~this() {
        import cache.PackageCache : PackageCache;
        EnvironmentManager.sharedLogger.log("[I]Destructing packageD");
    }

}