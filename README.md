# Elfos-del

> [!NOTE]
>This repository has a submodule for the include files needed to build it. You can have these pulled automatically if you add the  --recurse-submodules option to your git pull command.

This is a delete utility for Elf/OS 4 or earlier, able to delete single files, or all the files in a directory (but nor recursively).

If the path names a directory, the files in that directory will be deleted, as well as the directory itself if it is then empty (it contains no dubdirectories).

If the path names a file, that single file is deleted.

When the path is a directory, the user will be asked to confirm a directory deletion is intended. Ending the source path with a slash suppresses this confirmation, excepting for the root directory. Or, specifying the -d option suppresses this confirmation in all cases including for the root directory.

The path name of a directory may be given with a trailing slash or not, with the slight change to behavior as noted.

The -v option will display the path names as they are deleted.
