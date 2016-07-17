# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased][unreleased]
- Migration to new Realm, app speed improvements.

## [0.10.3] - 2016-04-12
### Added
- Arabic localication.
- Sending files from other apps [#182](https://github.com/Antidote-for-Tox/Antidote/issues/182).
- Highlighting links in chat [#176](https://github.com/Antidote-for-Tox/Antidote/issues/176).

### Changed
- Returned back iOS 8.0 support [#188](https://github.com/Antidote-for-Tox/Antidote/issues/188).
- Translations updated.

### Fixed
- Music stops when switching to Antidote [#177](https://github.com/Antidote-for-Tox/Antidote/issues/177).
- Layout for right to left interface [#190](https://github.com/Antidote-for-Tox/Antidote/issues/190).
- Long contact names overflow in the top bar [#184](https://github.com/Antidote-for-Tox/Antidote/issues/184).
- Time in chat doesn't fit sometimes [#178](https://github.com/Antidote-for-Tox/Antidote/issues/178).
- User stays online for some time after quitting Antidote [#171](https://github.com/Antidote-for-Tox/Antidote/issues/171).
- Top info view with is hidden on video call [#173](https://github.com/Antidote-for-Tox/Antidote/issues/173).

## [0.10.2] - 2016-03-31
### Added
- Chinese, Danish, German, Portuguese, Spanish localizations.

## [0.10.1] - 2016-03-29
### Added
- Added profile import support [#170](https://github.com/Antidote-for-Tox/Antidote/issues/170).

## [0.10.0] - 2016-03-28
### Added
- Audio and video calls.
- File transfer support.
- Avatar support.
- iPad support.
- Russian translation.

### Changed
- Antidote fully rewritten in Swift.
- objcTox updated to version 0.6.0.
- Dropped 7.0 support.
- Friends replaced with Contacts.

## [0.6.1] - 2015-09-26
### Fixed
- Chat bubbles sometimes were completely black and text was unreadable.

## [0.6.0] - 2015-09-22
### Added
- Login/logout, create/import/delete profile features.
- Encrypted profiles support (login with encrypted profile, change/remove password).
- Status change support.

### Changed
- Icon updated.
- Launch image updated.
- objcTox updated to version 0.3.0.
- Profiles list screen removed, login screens are used instead.
- Themes removed.

## [0.5.0] - 2015-08-30
### Added
- "Import profile" instruction.

### Changed
- objcTox updated to version 0.2.1.
- Using improved bootstrapping methods from objcTox, now it works better.
- Feedback email replaced with feedback@antidote.im

### Fixed
- Updating connection status when changing IPv6/UDP setting.
- Various fixes and crashes when importing profile.

## [0.4.0] - 2015-08-01
### Added
- Profile tab, containing user profile information (avatar, username, status message, Tox ID).
- Status of connection in tabBar.
- About screen with version information.
- Showing alert view with text on different errors.
- Showing timestamps in chat after every 3 messages (temporary solution, will be improved in future).

### Changed
- Improving flow for removing friends/requests.
- Updating UI for friends screen.
- Updating UI for incoming friend request screen.
- Updating UI for sending friend request screen.
- Updating UI for friend card screen.
- Default colorscheme changed to blue.

### Fixed
- Bug with copying Tox ID in some cases.
- Updating profile name in "Settings" tab after renaming.
- Bug with resetting wrong settings when pressing "Restore default settings".
- Showing "+" button on requests tab.
- Ugly avatars (like "I(").
- Fixing height of "Friends | Requests" bar (it was changing randomly).
- Blinking of badge icon when Antidote was in background.

## [0.3.0] - 2015-06-30
This version is incompatible with 0.2. After update you will lose your old profile with all chats and contacts.
It is a good idea to remove old version of Antidote before updating.

### Changed
- Moving part of Antidote to [objcTox](https://github.com/Antidote-for-Tox/objcTox) library.
- Total refactoring.
- Migration to new Tox api.
- Realm is now used instead of Core Data.
- File transfers and avatars are temporary disabled.
- Added connectivity status.

[unreleased]: https://github.com/Antidote-for-Tox/Antidote/compare/0.10.3...master
[0.10.3]: https://github.com/Antidote-for-Tox/Antidote/compare/0.10.2...0.10.3
[0.10.2]: https://github.com/Antidote-for-Tox/Antidote/compare/0.10.1...0.10.2
[0.10.1]: https://github.com/Antidote-for-Tox/Antidote/compare/0.10.0...0.10.1
[0.10.0]: https://github.com/Antidote-for-Tox/Antidote/compare/0.6.1...0.10.0
[0.6.1]: https://github.com/Antidote-for-Tox/Antidote/compare/0.6.0...0.6.1
[0.6.0]: https://github.com/Antidote-for-Tox/Antidote/compare/0.5.0...0.6.0
[0.5.0]: https://github.com/Antidote-for-Tox/Antidote/compare/0.4.0...0.5.0
[0.4.0]: https://github.com/Antidote-for-Tox/Antidote/compare/0.3.0...0.4.0
[0.3.0]: https://github.com/Antidote-for-Tox/Antidote/compare/0.2.5...0.3.0

