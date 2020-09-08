import std.stdio;
import std.format;
import std.string;
import std.range;
import std.algorithm;
import std.file;
import std.regex;
import core.stdc.stdlib : exit;

void main(string[] args) {
  if (args.length != 2) {
    "Error: Wrong number of argument number".error.writeln;
    showUsage();
    exit(1);
  }

  string path = args[1];
  bundle(path, [path: true]).join("\n").writeln;
}

string[] bundle(string path, bool[string] loadedPaths) {
  string[] lines;
  foreach (line; path.loadLines) {
    if (line.startsWith("module "))
      continue;
    enum re = ctRegex!r"^import +(acl(\.\w+)+)";
    auto cap = line.matchFirst(re);
    if (cap.empty) {
      lines ~= line;
    } else {
      cap.popFront;
      string next = "src/" ~ cap.front.replace(".", "/") ~ ".d";
      if (next in loadedPaths)
        continue;
      loadedPaths[next] = true;
      lines ~= bundle(next, loadedPaths);
    }
  }
  return lines.find!"!a.empty".array;
}

string[] loadLines(string path) {
  scope (failure) {
    format!"Error: Failed to read \"%s\""(path).error.writeln;
    showUsage();
    exit(1);
  }
  return readText(path).splitLines;
}

void showUsage() {
  q"EOS
Usage:
  $ ./bundle src/acl/{name}.d
EOS".info.writeln;
}

string error(string text) {
  return format!"\x1b[31m%s\x1b[0m"(text);
}

string info(string text) {
  return format!"\x1b[32m%s\x1b[0m"(text);
}
