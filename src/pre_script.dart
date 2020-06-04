import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:rxdart/rxdart.dart';

import 'globals.dart' as g;

extension ShortPaths on File {
  String shortPath(String vaultLocation) {
    return path.replaceFirst(vaultLocation, '');
  }
}

///
/// The 'list' command searches the Vault and identifies those scripts which would be executed
/// by a "run" command, in the order in which they would be executed.
///
/// If an parameter is provided to the list command it will be used (as a regular expression)
/// to filter the resulting list.
///
/// The "run" command accepts the same parameter, allowing only selected scripts to
/// be executed, if required.
///
void list(ArgResults globalResults, ArgResults commandResults) async {
  locateAllScriptFilesInVault(globalResults, commandResults).then((scriptFiles) async {
    for (File f in scriptFiles) {
      var contents = f.readAsStringSync();

      var chunks = extractChunksFromContents(contents, f);

      // first match in a chunkis the tool that  it needs
      var tools = chunks.map((chunk) => chunk[1]).join(', ').toString();

      print("${f.shortPath(g.vaultPath)} : $tools");
    }
  });
}

///
/// The "run" command searches the Vault in the same way as the "list" command above
/// but will also execute the scripts identified.
///
void execute(ArgResults globalResults, ArgResults commandResults) {
  locateAllScriptFilesInVault(globalResults, commandResults).then((scriptFiles) async {
    for (File f in scriptFiles) {
      g.log.finest("Start: ${f.shortPath(g.vaultPath)}");

      var contents = f.readAsStringSync();

      await extractAndExecuteScriptChunk(contents, f);

      g.log.finest("End: ${f.shortPath(g.vaultPath)}");
    }
  });
}

///
/// Extract a script from the script file contents
/// and execute it.
///
/// Scripts are stored in Notes as code fenced chunks. Each chunk has an explicit
/// annotation which defines the implementation language of the script.
///
/// The code fences MUST be of the form "~~~".
/// The variant using back tick instead of tilde is not accepted.
///
Future<int> extractAndExecuteScriptChunk(String contents, File f) async {
  var chunks = extractChunksFromContents(contents, f);

  // the working directory is the parent of the place we found the script
  var cwd = RegExp(g.scriptDirectory).firstMatch(f.path)[1];

  // Match the requested executable from the list of chunks with the
  // executables specified as available on this system ...
  // FIXME: for now though we just take the first alternative
  var executable = chunks.first[1];
  var script = chunks.first[2];

  g.log.info("Running ${f.shortPath(g.vaultPath)} with executable: $executable");

  // this starts the process and then returns, the only way
  // we know it's finished is when we get the return code
  return Process.start(
    executable,
    [],
    workingDirectory: cwd,
    includeParentEnvironment: true,
  ).then((process) async {
    g.log.fine("${f.shortPath(g.vaultPath)} starting with PID: ${process.pid}");

    //have to be sure to empty stdout & stderr so process can terminate
    process.stdout.transform(utf8.decoder).listen((data) {
      g.log.finest("pid:${process.pid}: stdout: $data");
    });
    process.stderr.transform(utf8.decoder).listen((data) {
      g.log.finest("pid:${process.pid}: stderr: $data");
    });

    // and feed it the commands from the script
    process.stdin.writeln(script);
    g.log.finest("pid:${process.pid}: stdin: $script");
    process.stdin.close();

    return process.exitCode;
  });
}

///
/// extracts the chunks defined in the contents of Script note
///
Iterable<RegExpMatch> extractChunksFromContents(String contents, File f) {
  g.log.finest("searching for chunk in script file");

  // script will be in in a code segment
  // first line should be ~~~ <executable> ...
  var codeFencedChunk = RegExp(
    r"~~~\W(\w+)\W*\n(.*?)\n~~~",
    multiLine: true,
    dotAll: true,
  );

  // there may be several alternative code fenced script sections, each with different executable
  // e.g. bash (for use on linux), cmd (for use on windows), python (attempt to be more portable), ...
  // long term pre-script should scan the host system to see what is available and pick a matching
  // alternative from the list, if it can
  var chunks = codeFencedChunk.allMatches(contents);

  if (chunks.isEmpty) {
    g.log.warning("${f.shortPath(g.vaultPath)} no chunks found, nothing to execute");
  }

  for (var c in chunks) {
    g.log.finest("found chunk: ${c[1]} - ${c[2]}");
  }

  return chunks;
}

///
/// Locate all script files in the vault and order them for execution
/// Ordering criteria is simply "bottom up" ...
///
/// This function is used by both the "list" and "run" commandsto
/// ensure that we actually do what we say we'll do !!!
///
Future<List<FileSystemEntity>> locateAllScriptFilesInVault(ArgResults globalResults, ArgResults commandResults) async {
  final scriptDirectory = RegExp(g.scriptDirectory);

  g.vaultPath = globalResults['vaultDirectory'];

  if (!g.vaultPath.endsWith('/')) {
    g.vaultPath = "${g.vaultPath}/";
  }

  g.log.fine("Vault: '${g.vaultPath}'");

  if (!await Directory("${g.vaultPath}.obsidian").exists()) {
    g.log.warning("Couldn't find ${g.vaultPath}.obsidian, I'm not convinced this is an Obsidian vault");
  }

  // iterate through the entire vault
  var scriptFiles = await Directory(g.vaultPath)
      .list(
        recursive: true,
        followLinks: false,
      )
      .doOnEach((n) {
        if (n.kind == Kind.OnData && n.value is File) {
          g.log.finest("inspectinging ${(n.value as File).shortPath(g.vaultPath)}");
        }
      })
      // looking for *.s.md files in a "/.../scripts/" diewctory
      .where((e) => scriptDirectory.hasMatch(e.path))
      .doOnEach((n) {
        if (n.kind == Kind.OnData && n.value is File) {
          g.log.fine("Found ${(n.value as File).shortPath(g.vaultPath)}");
        }
      })
      .toList();

  // sort in execution order (bottom up)
  scriptFiles.sort((a, b) {
    return '/'.allMatches(b.path).length - '/'.allMatches(a.path).length;
  });

  g.log.fine("Finished script search");
  g.log.finest("sorted scriptfile list: $scriptFiles");

  return scriptFiles;
}
