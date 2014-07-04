Sonijohn
========

A very simple script to extract usernames and hashes from Sonicwall encoded firewall configs.

Just point to the config file, it will base64 decode it, extract all local user accounts and password hashes and format/output them in the correct way to run John the Ripper over them.

Nothing special, just written on the spot onsite to review some firewalls.

Developed by Daniel Compton

https://github.com/commonexploits/sonijohn

Released under AGPL see LICENSE for more information


Installing
========

    git clone https://github.com/commonexploits/sonijohn.git

How To Use
========

    ./sonijohn.sh


Features
========

* Base64 decodes the config file 
* Extract all firewall usernames and password hashes
* Formats in the correct way for John the Ripper password cracking

Screen Shots
========

coming soon.


Change Log
========

* Version 1.0 - First release.

