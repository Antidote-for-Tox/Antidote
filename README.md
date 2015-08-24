[![Circle CI](https://circleci.com/gh/Antidote-for-Tox/Antidote.svg?style=svg)](https://circleci.com/gh/Antidote-for-Tox/Antidote)

[Tox](https://tox.chat/) client for iOS 7.0+;

![](https://i.imgur.com/5HF5RMX.png)

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

- [**Now**](https://github.com/Antidote-for-Tox/Antidote/milestones/Now) - this milestone has issues that will go to the next release.
- [**Next**](https://github.com/Antidote-for-Tox/Antidote/milestones/Next) - stuff we'll probably do soon.
- [**Faraway**](https://github.com/Antidote-for-Tox/Antidote/milestones/Faraway) - stuff we'll probably *won't* do soon.

Also there may be other [milestones](https://github.com/Antidote-for-Tox/Antidote/milestones) that represent long-running and big ongoing tasks.

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

