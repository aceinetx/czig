# czig
Using libc as the standard library in zig experiment

## Binary sizes
### Debug
```console
$ du -sh zig-out/bin/czig
9.5M    zig-out/bin/czig
```
### ReleaseSafe
```console
$ du -sh zig-out/bin/czig
3.3M    zig-out/bin/czig
```
### ReleaseFast
```console
$ du -sh zig-out/bin/czig
28K     zig-out/bin/czig
```
### ReleaseSmall
```console
$ du -sh zig-out/bin/czig
8.0K    zig-out/bin/czig
```
