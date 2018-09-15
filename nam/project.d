module nam.project;

import nam.command;

struct Project {

  string name;
  ubyte[3] ver;
  string[] languages;
  Command* def;
  Command[string] cmds;

  this(string file) {
    import sdlang: Tag, parseFile;
    import std.exception: enforce;
    import std.array: join, array;
    import std.range: choose, only;
    import std.algorithm: map, each, filter;

    Tag root = file.parseFile;
    Tag proj = root.expectTag("project");
    name = proj.expectValue!string;
    languages = proj.maybe.tags["languages"].front.values
      .map!(v => v.get!string)
      .array;
    ver = cast(ubyte[3]) proj.maybe.tags["version"].front.values
      .map!(v => cast(ubyte)v.get!int)
      .array[0 .. 3];
    root.maybe.tags["cmd"]
      .map!(t => Command(t))
      .each!(c => cmds[c.name] = c);

    // Second round that resolves dependencies.
    foreach (ref c; cmds)
      c.finInit(cmds);

    auto defTags = proj.maybe.tags["default"];
    if (defTags.length > 0)
      def = defTags[0].values[0].get!string in cmds;
    else
      def = null;
  }

 @safe:

  string toString() const {
    import std.format: format;
    import std.array: appender;
    auto res = appender!string;
    res.put(format!(
        "Project \"%s\" (%(%u%|.%))\n"
      ~ "Languages: %-(%s%|, %)\n"
      )(name, ver[], languages));
    foreach (const c; cmds)
      res.put(c.toString);
    return res.data;
  }

}
