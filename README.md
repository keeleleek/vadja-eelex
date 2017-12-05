# Re-digitization of the Votic scholarly dictionary

The retro-digitization or re-digitization of the Votic scholarly dictionary is done purely relying on XML technologies.

The starting point is the print-file exported as XHTML and saved in a XML database (BaseX).

The transformation into EELex dictionary XML format (used by the Institute of Estonian Language) is done by a series of XQuery functions. The functions are run by the main file ```eelexistamine.xq``` and the functions' code is in the module file ```eelexistamise-moodul.xq```.

All other files are deprecated and might be removed.

The transformation sees the underlying XML as a functional data structure. This way the data is transformed but nothing is deleted from it. From the programmer's point of view, it is like moving around with a time machine. The work-flow is shortly illustrated in this [presentation here](https://kitwiki.csc.fi/twiki/pub/FinCLARIN/KielipankkiEvent2016September/Kankainen_23092016.pdf), which was presented at the Seminar on Fenno-Ugric Computational Linguistics in Helsinki (2016).

## Licenses

The software (e.g the XQuery functions) are provided under the GNU GPLv3 license and the dictionary's print source files (as html) are provided under the CC BY SA 4.0 license. More information about the Votic dictionary is found on the Institute of the Estonian Language [website](www.eki.ee/dict/vadja/). Kasutatud on Eesti Keele Instituudi „Vadja keele sõnaraamatut“ (Grünberg jt 2013, www.eki.ee/dict/vadja/vadja.pdf) CC BY 4.0 

## Running the EELexifying script

You need BaseX and the functx repository to run the EELexifying script. The script ``eelexistamine.bxs`` is a simple BaseX specific script that automates the creation of the database and initializes it with the original print files (as html) and runs all the updating transformations of the database in-place. Some backup points are also created by the script.

Run the script with
```shell
basex -z -c eelexistamine.bxs
```
