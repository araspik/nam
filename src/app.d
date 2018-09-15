module app;

import std.algorithm: map, each;
import std.stdio;
import std.getopt;

import nam.project;
import nam.command;

void main(string[] args) {

  string build = "build.sdl";
  bool force = false;

  auto getoptRes = args.getopt(
      config.passThrough,
      config.caseSensitive,
      config.bundling,
      "b|build", "The build description file to use.", &build,
      "f|force", "Forces a rebuild.", &force,
    );

  args = args[1 .. $];

  if (getoptRes.helpWanted) {
    defaultGetoptPrinter("Not Another Make: Another Build System.",
        getoptRes.options);
    if (args.length > 0) foreach (arg; args) switch (arg) {
      case "build":
        writeln;
        enum desc = [
          "build: Builds given, default, or all commands.",
          "  If the project has a defined default command and no commands",
          "are specified, then it will update that default command.",
          "If no default command is specified and no commands are given, ",
          "then all the commands in the project are updated.",
          "If one or more commands are specified, they are updated in order.",
        ];
        foreach (s; desc) s.writeln;
        break;
      case "info":
        writeln;
        enum desc = [
          "info: Provides information about all or given commands.",
          "  If no commands are specified, then information is printed about",
          "the whole project.",
          "Otherwise, information is printed about each of the given commands",
          "in order.",
        ];
        foreach (s; desc) s.writeln;
        break;
      default:
        break;
    } else {
      
    }
    return;
  }

  Project proj = Project(build);

  if (args.length == 0) {
    if (proj.def != null)
      proj.def.update(force);
    else
      proj.write;
  } else switch (args[0]) {
    case "info":
      if (args.length >= 2)
        foreach (s; args[1 .. $])
          proj.cmds[s].write;
      else
        proj.write;
      break;
    case "build":
      if (args.length >= 2)
        foreach (s; args[1 .. $])
          proj.cmds[s].update(force);
      else if (proj.def != null)
        proj.def.update(force);
      else
        foreach (c; proj.cmds)
          c.update(force);
      break;
    default:
      foreach (s; args)
        proj.cmds[s].update(force);
  }

}
