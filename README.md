[![Build Status](https://img.shields.io/travis/Antidote-for-Tox/Antidote/master.svg?style=flat)](https://travis-ci.org/Antidote-for-Tox/Antidote)

[Tox](https://tox.chat/) client for iOS 7.0+;

## Screenshots

![](https://i.imgur.com/geSRhlQ.png)
![](https://i.imgur.com/kAXdWwI.png)
![](https://i.imgur.com/VOpGzgg.png)

##Usage

#### TestFlight beta testing

Antidote is available for beta testing via TestFlight. If you wish to participate, you must:
- Be on iOS 8+.
- Install [TestFlight](https://itunes.apple.com/us/app/testflight/id899247664?mt=8) from AppStore.
- Send your Apple ID email to [beta@antidote.im](mailto:beta@antidote.im?subject=Beta%20testing).

#### Manual Installation

Clone repo, install [CocoaPods](https://cocoapods.org/) and open `Antidote.xcworkspace` file with Xcode 5+.

```
git clone https://github.com/Antidote-for-Tox/Antidote.git
cd Antidote
pod install
open Antidote.xcworkspace
```

## Features

See [CHANGELOG](CHANGELOG.md) for list of notable changes (unreleased, current and previous versions).

-  one to one conversations
-  ~~typing notification~~ *(temporary disabled)*
-  emoticons
-  spell check
-  reading/scanning Tox ID via QR code
-  ~~file transfer~~ *(temporary disabled)*
-  read receipts
-  multiple profiles
-  tox_save import/export
-  ~~avatars~~ *(temporary disabled)*

#### What's next?

You can check [milestones](https://github.com/Antidote-for-Tox/Antidote/milestones) to see what is in progress and what is on the list:
- **X.X.X** *(milestone with next version number)* - this milestone has issues that will go to the next release
- **Next** - stuff we'll probably do soon
- **Faraway** - stuff we'll probably *won't* do soon.

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

[feedback@antidote.im](mailto:feedback@antidote.im)

## License

Antidote is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## Links

- [icons8](http://icons8.com/) - icons used in app

