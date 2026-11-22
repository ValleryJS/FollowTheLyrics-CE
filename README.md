# FTL-Cat's Edition

This is my heavily modified version of [FollowTheLyrics](https://github.com/War3l/FollowTheLyrics), originally created by **War3l**.

I started working on this fork because I enjoyed the original application and wanted to experiment with a few ideas of my own. It has since grown into a much larger set of changes, with new features, UI improvements and fixes built on top of War3l's work.

**This is an unofficial fork.** I am not affiliated with War3l, and I am not part of the development team behind the official FollowTheLyrics application. Please don't mistake this repository or its releases for the official version.

## What's different?

Some of the changes in Cat's Edition include:

- Multi-monitor lyric display options.
- More controls for lyric animations and visual effects.
- UI and text-rendering improvements.
- An optional startup animation.
- Optional Discord Rich Presence showing the current song.
- An add-on manager with a catalogue and manual ZIP installation.
- Various bug fixes and quality-of-life changes.

### Club Mode preview

The packaged Windows and Linux builds include the Godot runtime needed for Club Mode. Open **Settings → General → Launch 3D nightclub** after starting FTL. When running from source, you can install [Godot 4](https://godotengine.org/download/) separately or set `FTL_GODOT_PATH` to its executable. Press **1**, **2** or **3** to switch cameras, and **F11** for fullscreen.

This is an early prototype. Lighting and crowd movement respond to local audio data, but the scene still uses simple placeholder geometry.

This isn't an exhaustive changelog. I'm still working on the fork, so features may change between releases.

## Downloads

You can find my builds on the [Cat's Edition releases page](https://github.com/ValleryJS/FollowTheLyrics-CE/releases).

If you'd rather use the official application, download it from [War3l's repository](https://github.com/War3l/FollowTheLyrics).

## Building from source

The project uses Python 3.12+ and PyQt6. Install the project dependencies and launch it with:

```bash
python -m pip install -e .
python -m followthelyrics
```

To produce a standalone executable, install the build dependencies and run:

```bash
python -m pip install -e ".[build]"
python tools/build.py
```

## Credits

All credit for creating FollowTheLyrics goes to **War3l**. Cat's Edition would not exist without the original project.

This repository contains my modifications to that project. For issues specific to this fork, please open an issue **here**, not on War3l's repository.
