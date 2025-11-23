# Dwarf Online

[![License](https://img.shields.io/badge/license-ZLib-blue)](https://en.wikipedia.org/wiki/Zlib_License)

Cross-fortress interactions in dwarf fortress, over
the internet!

Dwarf Online comes in two parts: A **client mod** and a 
**server** which the client connects to. 

## Disclaimer!

At this time, Dwarf Online does not support Transport Layer 
Security. Your data is sent using plain HTTP requests, 
meaning data and authentication information is entirely 
unsecured. Please do not pass sensitive data (such as 
passwords) into this software.

**Why?** 
I haven't implemented TLS because (as far as I can tell)
I would have to implement OpenSSL from scratch in Lua. 
That would be tremendous undertaking, prone to mistakes, 
and would likely run slowly in Lua. 

If this project gets off the ground, I will politely beg 
the DFHack developers to add OpenSSL bindings (or possibly
do the work myself).

## Planned features

 * [ ] Deposit and retrieve items from your fortress into a bank on the server
 * [ ] Send items and messages as gifts to other users

