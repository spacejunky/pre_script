import 'dart:io';

import 'package:logging/logging.dart';
import '../src/cli.dart';
// import '../lib/globals.dart' as g;
// import '../lib/pre_script.dart' as pre_script;

void main(List<String> arguments) {
  _setupLogging();

  // parseCLI(["-i","-d","/home/nigelhead/obsidian/NigelPrivate","-t","linux,python","list"]);
  // parseCLI(["-i", "-d", "/home/nigelhead/obsidian/NigelPrivate","-t","python","-f","pdf","run"]);
  parseCLI(["-v","-d","/home/nigelhead/obsidian/NigelPrivate","help"]);
  // parseCLI(arguments);
}

void _setupLogging() {
  Logger.root.level = Level.WARNING;
  Logger.root.onRecord.listen((record) {
    stderr.write('${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}\n');
  });
}
