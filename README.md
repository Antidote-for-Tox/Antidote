[![Build Status](http://img.shields.io/travis/dvor/Antidote/master.svg?style=flat)](https://travis-ci.org/dvor/Antidote)

[Tox](https://tox.im/) client for iOS 7.0+;

## Screenshots

![](https://i.imgur.com/geSRhlQ.png)
![](https://i.imgur.com/kAXdWwI.png)
![](https://i.imgur.com/VOpGzgg.png)

##Usage

#### TestFlight beta testing

Antidote is available for beta testing via TestFlight. If you wish to participate, you must:
- be on iOS 8+
- install [TestFlight](https://itunes.apple.com/us/app/testflight/id899247664?mt=8) from AppStore
- give [dvor](https://github.com/dvor) your Apple ID email - you can send it to [antidote@dvor.me](mailto:antidote@dvor.me?subject=Beta%20testing) (optional PGP key is [0x95714DFB28AFC4DC](https://pgp.mit.edu/pks/lookup?op=get&search=0x95714DFB28AFC4DC)).

#### Cydia

You can install [0.2](https://github.com/dvor/Antidote/releases/tag/0.2) version of Antidote from Cydia repo `http://dvor.me/cydia/`

#### Downloads

Clone repo `git clone --recursive https://github.com/dvor/Antidote.git` and open `Antidote.xcworkspace` file with Xcode 5+.

## Features

-  one to one conversations
-  typing notification
-  emoticons
-  spell check
-  reading/scanning Tox ID via QR code
-  file transfer
-  read receipts
-  multiple profiles
-  tox_save import/export
-  avatars

#### In progress

-  migrating to new tox API (see [migrating-to-objcTox](https://github.com/dvor/Antidote/tree/migrating-to-objcTox) branch and [objcTox](https://github.com/dvor/objcTox) for more details)
-  UI polishing
-  fixing bugs

#### Then

-  group chats *(as soon as group chats will be rewritten in toxcore)*
-  audio calls
-  video calls

#### Future

-  offline mode
-  background mode (via background fetch?)
-  iOS notifications (with app in background)
-  tox:// scheme from another apps
-  *...*
-  App Store ?
-  *...*
-  iPad app
-  *???*
-  **PROFIT**

## Contact

[email](mailto:antidote@dvor.me)

## License

Antidote is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## Links

- [icons8](http://icons8.com/) - icons used in app

#### Third-party frameworks

- [BlocksKit](https://zwaldowski.github.io/BlocksKit/)
- [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack)
- [JSQMessagesViewController](http://www.jessesquires.com/JSQMessagesViewController/)
- [MagicalRecord](https://github.com/magicalpanda/MagicalRecord)
- [libsodium-ios](https://github.com/mochtu/libsodium-ios)

