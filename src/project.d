/**** Provides the NAM project type.
  * 
  * Author: ARaspiK
  * License: MIT
  */
module project;

import semver;
import sdlang;
import std.array: array;
import std.algorithm: map, each;
import std.range: enumerate;
import std.conv: to;

struct Project {
  string name;
  string[] langs;
  SemVer ver;

  this(Tag tag) {
    name = tag.expectValue!string;
    langs = tag.getTagValues("languages").map!(l => l.get!string).array;
    tag.getTagValues("version").map!(l => l.get!int.to!ubyte).enumerate
      .each!((i, e) => ver.data[i] = e);
  }
}
