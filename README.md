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

#### Manual Installation

Clone repo, install [CocoaPods](https://cocoapods.org/) and open `Antidote.xcworkspace` file with Xcode 5+.

```
git clone https://github.com/dvor/Antidote.git
cd Antidote
pod install
open Antidote.xcworkspace
```

## Features

-  one to one conversations
-  typing notification
-  emoticons
-  spell check
-  reading/scanning Tox ID via QR code
-  file transfer (temporary disabled)
-  read receipts
-  multiple profiles
-  tox_save import/export
-  avatars (temporary disabled)

#### In progress

-  audio calls groundwork [see (objcTox/audio)](https://github.com/dvor/objcTox/tree/audio)
-  getting back file transfers and avatars
-  designing UX
-  UI polishing
-  fixing bugs

#### Then

-  video calls
-  group chats

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

