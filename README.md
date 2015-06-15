[![Build Status](https://img.shields.io/travis/Antidote-for-Tox/Antidote/master.svg?style=flat)](https://travis-ci.org/Antidote-for-Tox/Antidote)

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
git clone https://github.com/Antidote-for-Tox/Antidote.git
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

-  audio calls groundwork see [(objcTox/audio)](https://github.com/Antidote-for-Tox/objcTox/tree/audio)
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

## Contribution

Before contributing please check [style guide](objective-c-style-guide.md).

Antidote is using [Uncrustify](http://uncrustify.sourceforge.net/) code beautifier. Before creating pull request please run it.

You can install it with [Homebrew](http://brew.sh/):

```
brew install uncrustify
```

#### Manually running

After installing you can:

- check if there are any formatting issues with

```
./run-uncrustify.sh --check
```

- apply uncrustify to all sources with

```
./run-uncrustify.sh --apply
```

#### Git hook

There is also git `pre-commit` hook. On committing if there are any it will gently propose you a patch to fix them. To install hook run

```
ln -s ../../pre-commit.sh .git/hooks/pre-commit
```

## Contact

Dmytro Vorobiov [d@dvor.me](mailto:d@dvor.me)

## License

Antidote is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## Links

- [icons8](http://icons8.com/) - icons used in app

