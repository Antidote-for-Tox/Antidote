libsodium-ios
=============


NaCl
-------

The NaCl-Library is the easiest way to use safe crypto for your apps. It provides for network communication, encryption, decryption, signatures and more. Look for yourself: http://nacl.cr.yp.to


Sodium
------

From their readme:

> Sodium is a portable, cross-compilable, installable, packageable fork of NaCl, with a compatible API.
  
https://github.com/jedisct1/libsodium



libsodium-ios
-------------

This repo provides two things:
* a prebuild static library for iOS of the sodium library and the preprocessed headerfiles for targeting a darwin/arm7 system
* the preprocessed headerfiles (for darwin/arm7) and sourcecode to use it directly in XCode

It is used by the CocoaPod "libsodium-ios" and gives easy access to the functionalities of NaCl for iOS developers.

I hope this enables more and more developers to use easy and secure crypto in their apps.


Feedback is most welcome!


Thanks to Frank, all the sodium contributors and the NaCl team to make this possible.


