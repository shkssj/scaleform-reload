# scaleform-reload

Reload a Scaleform movie on FiveM without restarting the game.

If you work on custom Scaleform movies, you know the loop: edit the movie, restart the resource, and
the game still shows the old one. So you restart the game.

This repository explains why that happens, how to avoid it with the game's own
`SCALEFORM_DLC_FILE` data file, and ships a small repro you can try in a minute.

> **Still experimental.** I've tested this on a few resources and scenarios,
> but it needs testing on many more before I'd call it reliable. If you try it, open an issue and let
> me know whether it works for you, especially any case where it crashes or keeps the old movie.

## Why the old movie stays

FiveM does download the new file when the resource restarts. The game just never reads it: the old
movie stays loaded in memory, so `RequestScaleformMovie` keeps returning it.

The game already has a way to drop a loaded movie: the `SCALEFORM_DLC_FILE` data file. When a
resource that declares one stops, the game unloads every movie it lists. When the resource starts
again, the next request loads the new file.

This work is based on [citizenfx/fivem#1576](https://github.com/citizenfx/fivem/issues/1576)

## Try it

1. Copy `resources/sf_demo_assets` and `resources/sf_demo` into your server and start both:

   ```text
   ensure sf_demo_assets
   ensure sf_demo
   ```

   A blue box that says **test 1** appears in the top left corner.

2. Replace `resources/sf_demo_assets/stream/SF_DEMO.gfx` with `movies/SF_DEMO-test-2.gfx`, keeping
   the name `SF_DEMO.gfx`.

3. In the server console, send these as two separate commands:

   ```text
   stop sf_demo
   restart sf_demo_assets; ensure sf_demo
   ```

   The box disappears for a moment and comes back saying **test 2**. Swap back to
   `movies/SF_DEMO-test-1.gfx` and it goes back, as many times as you like.

## Use it in your own resource

**1. Move the movies into their own assets resource**, next to an XML file that lists them. The
`name` is the file name without `.gfx`.

```text
my_resource_assets/
  fxmanifest.lua
  data/scaleform.xml
  stream/MY_SCALEFORM.gfx
```

```xml
<ScaleformPreallocation>
  <movie name="MY_SCALEFORM" />
</ScaleformPreallocation>
```

**2. Declare the data file** in the assets resource's manifest:

```lua
file 'data/scaleform.xml'
data_file 'SCALEFORM_DLC_FILE' 'data/scaleform.xml'
```

**3. Release the movies on stop** in the resource that uses them:

```lua
AddEventHandler('onResourceStop', function(resource)
  if resource ~= GetCurrentResourceName() then return end
  SetScaleformMovieAsNoLongerNeeded(handle)
end)
```

**4. Restart in this order:**

```text
stop my_resource
restart my_resource_assets; ensure my_resource
```

Send the second line a moment after the first, not on the same line.

## Rules

Unloading a movie that is still in use crashes the client. From my tests:

- **Nothing may hold the movie when the assets restart.** That includes another resource, and a
  `RequestScaleformMovie` that never finished loading. Releasing a request that hasn't loaded yet
  doesn't free it: it stays pending until the movie arrives. So don't release and re-request a movie
  in a loop while waiting for it.
- **Nothing may call the movie in the same frame as the unload.** A movie called in that frame either
  crashed the client or stayed stuck on the old version until the game restarted. Giving the client a
  few frames between the stop and the unload avoided it every time.
- **The XML can't live in the resource that uses the movies.** Its data file is unloaded during its
  own stop, while it may still be calling them. That's why the movies go in a separate resource.

Restarting only `my_resource_assets` while `my_resource` is running unloads the movies from under it
and crashes the client. Restarting only `my_resource` is safe, but you get the old movie.

## The demo movie

`SF_DEMO` contains no game assets. Its only code is `movies/src/demo.as`: it draws the box and the
label, and answers `VERSION` with the label.

The two `.gfx` files are that script placed in frame 1 of an empty 1280x720 GFx movie with
[JPEXS Free Flash Decompiler](https://github.com/jindrapetrik/jpexs-decompiler), with `LABEL` set to
`test 1` and `test 2`. Open them in FFDec to see exactly what's inside.
