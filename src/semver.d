/**** Provides SemVer versioning support.
  * 
  * Author: ARaspiK
  * License: MIT
  */
module semver;

import std.range;
import std.format: format;

struct SemVer {
  ubyte[3] data;
  // TODO: Extra text

 @safe pure:

  string toString() {
    return data[].format!"%(%u%|.%)";
  }

  int opCmp(const typeof(this) other) nothrow {
    foreach (const a, const b; data[].zip(other.data[]))
      if (a - b) return a - b;
    return 0;
  }
}
