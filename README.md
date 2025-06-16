# Document
German description how to obtain a Let1s Encrypt
certificate: 
[LetEncFbIP6.md](LetEncFbIP6.md)

# UserScripts
Scripts for Linux user's ~/bin/ directory

## crnupdate
A PERL script to update or insert copyright/licensing
information into a source file.

Such a file could contain this text
```
Author: Himbeertoni
Email: Toni.Himbeer@fn.de
Github: https://www.github.com/himbeer-toni

This script is available for
public use under GPL V3 (see
https://www.gnu.org/licenses/gpl-3.0.en.html )
```
The default filename is copyright.txt but you can 
specify another using -c.

You can then use crnupdate for any source-code that supports the hash-sign as comment delimiter.

So have a look at the top of script itself 
where it did 
inject itself the notice using the command
`crnupdate -m "############## License / Copyright ###############" -r crnupdate`.
```
#!/usr/bin/perl

############## License / Copyright ###############
# Author: Himbeertoni
# Email: Toni.Himbeer@fn.de
# Github: https://www.github.com/himbeer-toni
# 
# This script is available for
# public use under GPL V3 (see
# https://www.gnu.org/licenses/gpl-3.0.en.html )
############## License / Copyright ###############

# Abstract:
# Insert or update a notice about author and license
# (from copyright.txt) into a script. Will always 
# replace the notice with the notice-file contents.
# Work for programmung ane scripting languages where
# comments are introduced by a hash-sign (#).

# Modules used
```
Output of `crnupdate -h`:
```
Usage: crnupdate [option [param]..] inputfile [outputfile]
 The inputfile is mandatory
 The outputfile is mandatory
 The outputfile must not be given when one of
  the options -b or -c are present
 Options:
  -b backup-file-suffix
     edit input file in place, but keep a backup
     file, the suffix will be appended to the
		 name of the inputfile
     e.g. -b .bck for file i.txt will get you
     i.txt.bck as backup. (do this twice and the
     original content will be gone!)
  -c copyright-filename
     specify the name of the file containing the
     copyright infos. If not given copyright.txt
     is used.
  -h this text is displayed
  -m copyright-marker-string
     give a new marker line for enclosing the
     copyright info. MUST start with ##
     otherwise ## will be prepended.
  -r replace the inputfile with the result
  -s stay silent if copyright notice is already
     up to date and no files where touched therefor
```
## smop (**sm**artphone**op**en)

Very personal helper
  to open a file remotely on smartphone and
  copy it back when written remotely
  e. g. to use Markor-app to edit markdown.
  Mainly useful when you ssh-ed from your
  phone to your system.
### pre-reqirements
  - Termux installed on smartphone
  - passwordless (using ssh-keys) ssh-access to termux on smartphone
  - inotifywait installed in termux

