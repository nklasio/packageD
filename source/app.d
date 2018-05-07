import std.getopt;
import core.Package;
import core.Version;


void main(string[] args)
{

    string searchPackage = void;
    string infoPackage = void;

    auto helpInformation = getopt(args, "S|Search", "Search and Install Package", &searchPackage, 
            "i|info", "Information fo specific package", &infoPackage);

    if(helpInformation.helpWanted) {
        defaultGetoptPrinter("packageD - Copyright © 2018, Niklas Stambor", helpInformation.options);
    }

    if(searchPackage != null) {
        Package.searchAndInstall(searchPackage);
    }

    if(infoPackage != null) {
        Package.info(infoPackage);
    }
}

