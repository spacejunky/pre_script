// ignore_for_file: constant_identifier_names
// ignore_for_file: public_member_api_docs
import 'package:args/args.dart';
import 'package:logging/logging.dart';

const String VERSION = '0.1.0';
const String APPNAME = "pre-script";
String vaultPath;
const scriptDirectory= r"^(/.+)/scripts/[^/]+\.s\.md$";

/// cliArgs -  arguments setting from invocation
// ArgResults cliArgs;

/// log - logging interface
final Logger log = Logger('pre-script');
