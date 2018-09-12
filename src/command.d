/**** Provides the NAM Command type.
  * 
  * Author: ARaspiK
  * License: MIT
  */
module command;

import sdlang;
import std.algorithm: map, joiner, minElement, maxElement, filter, each;
import std.array: array, join;
import std.range: chain, only;
import std.datetime: SysTime;
import std.file: timeLastModified;
import std.exception: ifThrown, assumeWontThrow;
import std.string: join;
import std.process: spawnShell, wait;

struct Command {
  string name;
  string[] sources;
  string[] outputs;
  string[] commands;
  string[] depends;

  this(Tag tag) {
    name = tag.expectValue!string;
    sources = tag.tags["sources"].map!(t => t.values.map!(e => e.get!string))
      .joiner.array;
    outputs = tag.tags["outputs"].map!(t => t.values.map!(e => e.get!string))
      .joiner.array;
    commands = tag.tags.filter!(t => t.name == "command" || t.name == "commands")
      .map!(t => t.name == "command"
          ? t.values.map!(e => e.get!string).join(" ").only.array
          : t.values.map!(e => e.get!string).array)
      .join;
    depends = tag.maybe.tags["depends"]
      .map!(t => t.values.map!(e => e.get!string)).join;
  }

 @safe:

  /// Executes the stored commands.
  void regenerate() const {
    commands.each!(c => c.spawnShell.wait);
  }

  /// Updates as necessary.
  void update() const {
    if (needsUpdate) regenerate;
  }

 @property nothrow const:

  /// Returns latest time that source files were modified.
  /// Returns `SysTime(0)` if any files were nonexistent.
  SysTime sourceUpdateTime() {
    return sources.map!(i => i.timeLastModified).maxElement
      .ifThrown(SysTime(0)).assumeWontThrow;
  }

  /// Returns the earliest time that output files were modified.
  SysTime outputUpdateTime() {
    return outputs.map!(o => o.timeLastModified.ifThrown(SysTime(long.max)))
      .minElement.assumeWontThrow;
  }

  /// Returns whether the outputs need to be updated.
  bool needsUpdate() {
    return outputUpdateTime < sourceUpdateTime;
  }
}
