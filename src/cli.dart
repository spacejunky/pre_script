import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:logging/logging.dart';
import 'globals.dart' as g;
import 'pre_script.dart';

void parseCLI(List<String> arguments) {
  final runner = CommandRunner(g.APPNAME, "Obsidian offline actions");
  runner
    ..argParser.addFlag(
      "verbose",
      abbr: "v",
      defaultsTo: false,
      negatable: false,
      help: "be verbose",
      callback: (verbose) => {if (verbose) Logger.root.level = Level.FINE},
    )
    ..argParser.addFlag(
      "veryVerbose",
      abbr: "V",
      defaultsTo: false,
      negatable: false,
      help: "be very verbose",
      callback: (veryVerbose) => {if (veryVerbose) Logger.root.level = Level.ALL},
    )
    ..argParser.addFlag(
      "info",
      abbr: "i",
      defaultsTo: false,
      negatable: false,
      help: "show low volume informative logging",
      callback: (info) => {if (info) Logger.root.level = Level.INFO},
    )
    ..argParser.addMultiOption(
      "tools",
      abbr: "t",
      help: "list the tools that are available on this system (if not specified the first segment matches)",
      valueHelp: "TOOL,TOOL,...",
      allowed: [
        "windows",
        "nix",          // this should cover linux and osx except in extreme cases ??
        "bash","zsh",   // and for the extreme cases we have these two
        "python",
        "dart",
        "powershell",
        "kotlin",
        "lua",
        "php",
        "java",
        "perl",
        "awk",
      ],
      defaultsTo: [],
    )
    ..argParser.addOption(
      "filter",
      abbr: "f",
      help: "filter to select specific scripts or directories \n(no globbing, no RegEx matching, default matches everything)",
      defaultsTo: "",
    )
    // ..argParser.addFlag(
    //   "dryRun",
    //   abbr: "D",
    //   defaultsTo: false,
    //   negatable: false,
    //   help: "execute scripts but do not make updates",
    // )
    ..argParser.addOption("vaultDirectory", abbr: "d", defaultsTo: ".", help: "/path/to/your/vault")
    ..addCommand(VersionCommand())
    ..addCommand(ListCommand())
    ..addCommand(RunCommand())
    ..run(arguments).catchError((error) {
      if (error is! UsageException) throw error;
      print(error);
      exit(64); // Exit code 64 indicates a usage error.
    });
}

class VersionCommand extends Command {
  VersionCommand();

  @override
  final String description = "Display the ${g.APPNAME} version number";

  @override
  final String name = "version";

  void run() => print("${g.APPNAME} version: ${g.VERSION}");
}

class ListCommand extends Command {
  ListCommand();

  @override
  final String description = "List script files from the Vault";

  @override
  final String name = "list";

  void run() => list(globalResults, argResults); //argResults['verbose']); //();
}

class RunCommand extends Command {
  RunCommand();

  @override
  final String description = "Execute script files from the Vault";

  @override
  final String name = "run";

  void run() => execute(globalResults, argResults); //argResults['verbose']); //();
}
