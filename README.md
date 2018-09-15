# NAM: Not Another Make

A build system which uses [SDL][sdl] as a description language.
It is written in the [D Programming Language][dlang].

### Why SDL?
The idea of having a non-Turing-complete description is from trying out [Meson][meson],
where a customised DSL is used so that processing becomes very fast. Variable defining is
still legal, so functionality is not completely lost.

### Full Example
Here is a detailed example of a build file:
```
project "Example" {
  languages "c" "c++"
  version 0 0 1
  default "example"
}

cmd "example" {
  sources "example.c"
  outputs "example.o"
  depends "example_lib"
  commands "gcc -c example_lib.so example.c -o example.o"
}

cmd "example_lib" {
  sources "example_lib.c"
  outputs "example_lib.so"
  commands "gcc -fPIC -c example_lib.c -shared -o example_lib.so"
}
```

`nam --build /path/to/file.sdl info`: (sources do not exist)
```
Project "Example" (0.0.1)
Languages: c, c++
* Command: "example"
  Sources: ["example.c"]
  Outputs: ["example.o"]
  Dependencies: ["example_lib"]
  Commands: ["gcc -c example_lib.so example.c -o example.o"]
  Needs updating: false
* Command: "example_lib"
  Sources: ["example_lib.c"]
  Outputs: ["example_lib.so"]
  Dependencies: []
  Commands: ["gcc -fPIC -c example_lib.c -shared -o example_lib.so"]
  Needs updating: false
```
The `Needs Updating` line returns `true` if any of the outputs don't exist or if any of
them are older than the input files. If the input files don't exist (as was the case in the
above run), then it will always show `false`.

`nam --build /path/to/file.sdl`: (sources do not exist)
```
No need to update "example"
```
This is shown as it attempts to update the `example` command, but since the source file
doesn't exist it will not update it.

### License
MIT License

Copyright (c) 2018 ARaspiK

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

[sdl]: https://sdlang.org
[dlang]: https://dlang.org
[meson]: https://mesonbuild.com
