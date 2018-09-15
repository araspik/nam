module nam.project;

import nam.command;

struct Project {

  string name;
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

    root.maybe.tags["cmd"]
      .map!(t => Command(t))
      .each!(c => cmds[c.name] = c);

    // Now that all commands are known, we can replace dependency strings with
    // actual dependency pointers. At this point, the Commands are valid.
    foreach (ref c; cmds)
      c.finInit(cmds);
  }

  string toString() {
    import std.format: format;
    import std.array: appender;
    auto res = appender!string;
    res.put(name.format!"Project \"%s\":\n");
    foreach (const c; cmds)
      res.put(c.toString);
    return res.data;
  }

}
