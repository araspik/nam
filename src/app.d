module app;

import std.algorithm: map, each;
import std.stdio;

import nam.project;
import nam.command;

void main(string[] args) {

  Project proj = Project("stuff.sdl");

  switch (args.length) {
    case 1:
      proj.write;
      break;
    case 2:
      proj.cmds[args[1]].write;
      break;
    default: break;
  }
}
