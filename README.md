# Re-digitization of the Votic scholarly dictionary

The retro-digitization or re-digitization of the Votic scholarly dictionary is done purely relying on XML technologies.

The starting point is the print-file exported as XHTML and saved in a XML database (BaseX).

The transformation into EELex dictionary XML format (used by the Institute of Estonian Language) is done by a series of XQuery functions. The functions are run by the main file ```eelexistamine.xq``` and the functions' code is in the module file ```eelexistamise-moodul.xq```.

All other files are deprecated and might be removed.

The transformation sees the underlying XML as a functional data structure. This way the data is transformed but nothing is deleted from it. From the programmer point of view, it is like moving around with a time machine. It is shortly illustrated in this [presentation here](https://kitwiki.csc.fi/twiki/pub/FinCLARIN/KielipankkiEvent2016September/Kankainen_23092016.pdf), which was presented at the Seminar on Fenno-Ugric Computational Linguistics in Helsinki (2016).
