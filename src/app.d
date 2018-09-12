module app;

import sdlang;

import std.algorithm: map;
import std.stdio;

import project;
import command;

void main(string[] args) {

  Tag root = "stuff.sdl".parseFile;

  Project proj = Project(root.expectTag("project"));

  writeln("Project: ", proj.name);
  writeln("Languages: ", proj.langs);
  writeln("Version: ", proj.ver);

  foreach (c; root.tags["cmd"].map!(t => Command(t))) {
    writeln("* Command \"", c.name, "\"");
    writeln("  Sources: ", c.sources);
    writeln("  Outputs: ", c.outputs);
    writeln("  Commands: ", c.commands);
    writeln("  Dependencies: ", c.depends);

    writeln("  Needs updating: ", c.sourceUpdateTime > c.outputUpdateTime);
  }
}
