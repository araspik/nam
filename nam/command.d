/**** Provides the NAM command structure.
  * 
  * Author: ARaspiK
  * License: MIT
  */
module nam.command;

import sdlang: Tag;

import std.datetime: SysTime;

/**** The NAM command structure.
  * 
  * Here is a serialized command structure for SDLang:
  * ---
  * command "commandName" {
  *   sources "source1.c" "source2.c"
  *   sources "source3.c"
  *   outputs "outputApp"
  *   commands "gcc output1.c output2.c output3.c -o outputApp"
  *   commands "echo hi > /dev/null"
  * }
  * ---
  */
struct Command {

  /// The name of the command.
  string name;
  /// The input files to the command; They must exist.
  string[] sources;
  /// The output files of the command; They may or may not exist.
  string[] outputs;
  /// A list of commands to execute. They are executed from a shell.
  string[] commands;

  private union {
    /// An unresolved string list of dependencies by command name.
    string[] dependStrs;
    /// A resolved list of dependencies.
    const(Command)*[] depends;
  }

  /// Constructor: Uses an SDLang Tag to read from.
  /// The finInit() function needs to also be run to get a finished valid state.
  /// Before it is run, the dependencies are in an unresolved state and cannot
  /// be used.
  this(Tag tag) {
    import std.array: join;
    import std.algorithm: map;
    name = tag.expectValue!string;
    sources = tag.maybe.tags["sources"]
      .map!(t => t.values.map!(e => e.get!string))
      .join;
    outputs = tag.tags["outputs"]
      .map!(t => t.values.map!(e => e.get!string))
      .join;
    commands = tag.tags["commands"]
      .map!(t => t.values.map!(e => e.get!string))
      .join;
    dependStrs = tag.maybe.tags["depends"]
      .map!(t => t.values.map!(e => e.get!string))
      .join;
  }

  /// Completes initialization given a list of usable commands.
  void finInit(Command[] commands) {
    import std.array: appender;
    import std.stdio: writeln;
    auto deps = appender!(const(Command)*[])();
    foreach (const str; dependStrs) {
      foreach (size_t i; 0 .. commands.length)
        if (commands[i].name == str) {deps.put(&commands[i]); break;}
      writeln("ERROR: Dependency not found for \"", str, "\"!");
    }
    dependencies = deps.data;
  }

  /// ditto
  void finInit(const ref Command[string] commands) {
    import std.array: appender;
    import std.stdio: writeln;
    auto deps = appender!(const(Command)*[])();
    deps.reserve(dependStrs.length);
    foreach (const str; dependStrs) {
      auto ptr = str in commands;
      if (!ptr)
        writeln("ERROR: Dependency not found for \"", str, "\"!");
      else
        deps.put(ptr);
    }
    dependencies = deps.data;
  }

 @safe:

  /// Formats the data as a human-readable string.
  string toString() const {
    import std.format: format;
    return format!(
        "* Command: \"%s\"\n"
      ~ "  Sources: [%(%s%|, %)]\n"
      ~ "  Outputs: [%(%s%|, %)]\n"
      ~ "  Dependencies: [%(%s%|, %)]\n"
      ~ "  Commands: [%(%s%|, %)]\n"
      ~ "  Needs updating: %s\n"
      )(name, sources, outputs, dependencies.map!(c => c.name), commands,
        needsUpdate);
  }

  /// Executes the stored commands regardless of need.
  /// Returns whether the dependencies were generated successfully.
  bool regenerate() const {
    import std.stdio: writeln, writefln;
    import std.process: spawnShell, wait;
    writefln!"Updating \"%s\""(name);
    foreach (d; dependencies) // Update dependencies
      if (!d.regenerate) return false;
    foreach (c; commands) { // Run commands
      writeln("> ", c);
      auto res = c.spawnShell.wait;
      writeln(">= [", res, "]");
      if (res) return false;
    }
    return true;
  }

  /// Executes the commands if an update is necessary.
  bool update() const {
    import std.stdio: writefln;
    if (needsUpdate)
      return regenerate;
    writefln!"No need to update \"%s\""(name);
    return true;
  }

  /// Like update, but also takes a 'force' flag.
  bool update(bool force) const {
    return force ? regenerate : update;
  }

 @property nothrow:

  /// The dependency list.
  @trusted const(const(Command)*[]) dependencies() const {
    return cast(typeof(return)) depends;
  }

  /// ditto
  @trusted const(Command)*[] dependencies(const(Command)*[] newVal) {
    return depends = newVal;
  }

  import std.algorithm: map, minElement, maxElement;
  import std.file: timeLastModified;
  import std.exception: ifThrown, assumeWontThrow;

 const:

  /// Returns whether the outputs or dependencies need to be updated.
  bool needsUpdate() {
    bool res = sourceUpdateTime > outputUpdateTime;
    foreach (d; dependencies)
      res = res || d.needsUpdate;
    return res;
  }

  /// Returns the earliest time that an output was modified.
  SysTime outputUpdateTime() {
    return outputs
      .map!(o => o.timeLastModified.ifThrown(SysTime(long.max)))
      .minElement
      .assumeWontThrow;
  }

  /// Returns the earliest time that a source was modified.
  SysTime sourceUpdateTime() {
    return sources
      .map!(o => o.timeLastModified.ifThrown(SysTime(0)))
      .maxElement
      .assumeWontThrow;
  }

}
