# MiniDOS-del

This is a delete utility for Mini/DOS, able to delete single files, or all the files in a directory (but nor recursively). The usage is:
```
del [-v] [-d] source target
```
If the path names a directory, the files in that directory will be deleted, as well as the directory itself if it is then empty (it contains no dubdirectories).

If the path names a file, that single file is deleted.

When the path is a directory, the user will be asked to confirm a directory deletion is intended. Ending the source path with a slash suppresses this confirmation, excepting for the root directory. Or, specifying the -d option suppresses this confirmation in all cases including for the root directory.

The path name of a directory may be given with a trailing slash or not, with the slight change to behavior as noted.

The -v option will display the path names as they are deleted.
