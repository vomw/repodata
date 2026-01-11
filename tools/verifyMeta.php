#!/usr/bin/php
<?php
// ============================================================================
// Schema Validator for metadata/*.yml
// © Andreas Itzchak Rehberg
// ----------------------------------------------------------------------------
// Purpose of this script is to check metadata/*.yml files used by F-Droid
// repositories to ensure they are syntactically correct. For this purpose it
// uses JSON Schema Validation based on a schema definition usually located in
// schemas/metadata.json
// Requirements:
// * yaml2json to convert YAML to JSON, e.g. https://github.com/dirtsimple/yaml2json
// * yamllint (Debian package yamllint)
// * JsonSchema to perform the validation. Debian package php-json-schema
// * a metadata.json schema file
// For usage instruction, pass the "-h" parameter to the script.
// ----------------------------------------------------------------------------
// TODO:
// * automatically obtain location of JsonSchema package for autoload.php
// ----------------------------------------------------------------------------
// This program is free software; you can redistribute and/or modify it under
// the terms of the GNU General Public License (see ../LICENSE)
// ============================================================================

$yaml2json = 'yaml2json';
$repobase = getcwd();
$schemafile = '';
$verbose = 1;
$exit_on_error = 1;
$show_help = 0;
$file = '';
$first = '';
$last = '';
if ( !empty( shell_exec("which yamllint 2>/dev/null") ) ) $yamllint = 1;
else $yamllint = 0;

#--=[ parse command line opts ]=--
$opts = getopt("b:e:f:F:hL:qs:vY");
foreach ($opts as $key => $val) {
  switch($key) {
    case 'b': if ( is_dir($val) ) $repobase = $val; break;
    case 'e': $exit_on_error = $val; break;
    case 'f': $file = $val; break;
    case 'F': $first = $val; break;
    case 'h': $show_help = 1; break;
    case 'L': $last = $val; break;
    case 'q': $verbose = 0; break;
    case 's': $schemafile = $val; break;
    case 'v': $verbose = 1; break;
    case 'Y': $yamllint = 0; break;
  }
}

#--=[ show help? ]=--
if ($show_help) {
  $self = $argv[0];
  echo <<<EOF
Syntax: $self [options]
Options:
  -b <dir>      base directory for the repo to scan
  -e <0|1>      exit on error?
  -f <file>     filename to scan (default: all in the repo’s metadata directory)
                without path: look for the file(s) in the repo’s metadata directory
                with path: relative to the current working dir, or absolute
  -F <file>     first file (w/o path) to process
  -h            show this help and exit
  -L <file>     last file (w/o path) to process
  -q            quiet (only show errors)
  -s <file>     alternative JSONSchema file to use. Given a file name, the file will
                first be looked for in the current working directory; if not found
                there, in <repobase>/schemas. If still not found, the script will
                exit with an error message and an error code be returned.
  -v            verbose (also show "OK")
  -Y            disable yamllint

EOF;
  exit;
}

#--=[ check prerequisites ]=--
if ( empty($schemafile) ) $schemafile = "${repobase}/schemas/metadata.json";
elseif ( file_exists($schemafile) && is_readable($schemafile) ) null;
elseif ( file_exists("${repobase}/schemas/${schemafile}") && is_readable("${repobase}/schemas/${schemafile}") ) $schemafile = "${repobase}/schemas/${schemafile}";
else {
  echo "\nthe schemafile specified ('-s $schemafile') could not be found or is not readable.\n";
  echo "could not read '${repobase}/schemas/${schemafile}' either, so no verification can be done.\nAborting.\n\n";
  exit(5);
}
if ( !file_exists("metadata") || !is_dir("metadata") ) {
  echo "\ncould not find the 'metadata' directory here. Make sure you are running this from inside the repo root.\nAborting.\n\n";
  exit(1);
}
if ( !file_exists("{$schemafile}") ) {
  echo "\nschemafile '${schemafile}' could not be found or is not readable. No verification possible.\nAborting.\n\n";
  exit(5);
}
if ($verbose) echo "\nusing schemafile '${schemafile}'\n";

#--=[ get the schema validator ready ]=--
require_once('/usr/share/php/JsonSchema/autoload.php');
$validator = new JsonSchema\Validator;

#--=[ check what shall be validated ]=--
if ( empty($file) ) $files = glob("${repobase}/metadata/*.yml");
elseif ( strpos($file,'/') === false ) $files = glob("${repobase}/metadata/${file}"); // filename without path, look in default directory
else $files = glob($file);

#--=[ validate specified YAML file(s) ]=--
foreach ( $files as $datafile ) {
  if ( !empty($first) && basename($datafile) < $first ) continue; // skip everything before the file specified by "-F"
  if ( !empty($last) && basename($datafile) > $last ) break; // stop when the file specified by "-L" has been reached

  $error_count = 0;

  if ( $yamllint ) {
    $data = shell_exec("yamllint --no-warnings ${datafile} 2>&1");
    if ( empty($data) ) {
      if ($verbose) echo basename($datafile) . ": yamllint OK\n";
    } else {
      echo "${data}\n";
      ++$error_count;
    }
  }

  $data = json_decode( shell_exec("${yaml2json} < $datafile 2> /dev/null") );
  $validator->validate($data, (object)['$ref' => "file://${schemafile}"]);

  if ($validator->isValid()) {
    if ($verbose) echo basename($datafile) . ": schemaCheck OK\n";
  } else {
    echo basename($datafile) . " does not validate. Violations:\n";
    foreach ($validator->getErrors() as $error) {
      printf("  [%s] %s\n", $error['property'], $error['message']);
    }
     ++$error_count;
  }
  if ($exit_on_error && $error_count) exit(1);
}
?>