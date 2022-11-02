# l4d2-vpk-trimmer

Valve Pak (or VPK) files are used in some Source engine games such as Left 4 Dead 2,
which usually contain many assets for the custom campaigns.
When hosting the custom campaigns on the dedicated server, while we can just drop them
into the `left4dead2/addons` folder, there is a better way we can do.

Consider the servers are usually headless, they don't need to know how a texture looks like,
or how the music feels like. By removing those unnecessary files, we can save a lot of space!

1. Typically the output size is 50% of the original (or even smaller on larger campaigns).
2. By removing media files which are hard to compress, we have lowered the compress rate of the vpk files,
since the left files (bsp, nav, mdl, etc.) can usually be compressed by a lot. This will save significant
amount of time when being transferred over network.

## How to use

The usage is simple: 

```bash
docker run \
    -v /my/upload:/in \
    -v /wherever/addons:/out \
    yxnan/l4d2-vpk-trimmer:latest
```

You bind mount an input directory (usually your server upload folder)
and an output directory (the `left4dead2/addons` folder), the app will then watch
the file actions in the `/in` directory, once a new vpk file is uploaded, 
the app will apply the trimming processes on it, and install it to the `/out` directory.

The accepted input files are either:

1. Plain vpk files.
2. Archives (zip, 7z, rar, ...) that contain vpk files in them.
The structure doesn't matter, since the app will find all the vpk files in it
and process them.

Any other files will be ignored.

## What exactly are trimmed in those vpk files?

1. All directories except `maps|modes|missions|models|scripts|scenes|particles`.
2. Any file in the root that is not `addoninfo.txt`.
3. [`*.vtx`](https://developer.valvesoftware.com/wiki/VTX) and [`*.vvd`](https://developer.valvesoftware.com/wiki/VVD) files

## Check the result

The app will output the campaign name, original size and trimmed size to the stdout,
you can check the result using `docker logs` or any docker management tools:

```bash
$ docker logs <container-name>
...
------ Received file: buried-deep_v172.vpk
> Processing buried-deep_v172.vpk
  Campaign installed: burieddeep
  Size: 621M -> 249M
------ done! ------
...
------ Received file: batch_upload.zip
> Processing journey-to-splash-mountain_v10.vpk
  Campaign installed: jtsm
  Size: 909M -> 362M
> Processing suicide-blitz-2_v4.vpk
  Campaign installed: suicideblitz2
  Size: 533M -> 342M
> Processing white-forest_v30.vpk
  Campaign installed: whiteforest_mission
  Size: 250M -> 165M
------ done! ------
```

## Local usage

The app watches the `CLOSE_WRITE` action, which happens when the file is opened as write mode
and has been closed. This usually applies to the situation where a file is uploaded through
ftp/sftp, but if you already have that file on the target machine and want it to be processed,
you can copy it into `/in` directory OR move and touch it.
