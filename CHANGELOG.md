# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased][unreleased]
### Added
- Limiting number of entering pin attempts to 10.

### Changed
- Migrating to toxcore 0.1.4.
- Improved bootstraping mechanism, Antidote now should connect to network faster.

## [1.3.1] - 2016-12-03
### Changed
- Migrating to toxcore 0.0.5.

## [1.3.0] - 2016-11-25
### Changed
- Migrating to Swift 3. [#255](https://github.com/Antidote-for-Tox/Antidote/issues/255).
- Migrating to toxcore 0.0.4.

### Fixed
- Bug with new contact appearing as an old one [#257](https://github.com/Antidote-for-Tox/Antidote/issues/257).
- Various crashes.
- Keeping keyboard when switching chats on iPad.
- Don't show keyboard when opening chat.

## [1.2.0-build-2] - 2016-11-12
### Fixed
- Bug with resending old messages to contacts.

## [1.2.0] - 2016-11-12
### Added
- Faded color for undelivered messages. [#140](https://github.com/Antidote-for-Tox/Antidote/issues/140).
- Resending undelivered messages when friend comes online. This should fix [#249](https://github.com/Antidote-for-Tox/Antidote/issues/249).

### Changed
- Migrating to c-toxcore 0.0.3
- Making Antidote accessible (partly done, more will come in next release) [#115](https://github.com/Antidote-for-Tox/Antidote/issues/115).

## [1.1.0] - 2016-11-05
### Added
- Gemfile
- Fastline
- Migrating to c-toxcore 0.0.2
- Dutch, Polish language.

## [1.0.0-rc.4] - 2016-10-26
### Changed
- Removed voip flag.
- Always enabling IPv6. Removed IPv6 option from settings.
- Switching to TCP by default [#130](https://github.com/Antidote-for-Tox/Antidote/issues/130).

### Fixed
- Links are not visible with new bubble colors [#242](https://github.com/Antidote-for-Tox/Antidote/issues/242).
- Touch ID alert pops during the call [#240](https://github.com/Antidote-for-Tox/Antidote/issues/240).

## [1.0.0-rc.3] - 2016-10-03
### Fixed
- Crash on startup that happened on app reinstall.

## [1.0.0-rc.2] - 2016-10-02
### Added
- Added FAQ.

### Fixed
- Czech language was not working.
- Freezes when bootstraping on bad network [#231](https://github.com/Antidote-for-Tox/Antidote/issues/231).
- Password screen is not entirely visible (iPhone 4s) [#229](https://github.com/Antidote-for-Tox/Antidote/issues/229).
- Ringtone is not reset on next call [#234](https://github.com/Antidote-for-Tox/Antidote/issues/234).

## [1.0.0-rc.1] - 2016-09-28
### Added
- Database encryption. Now all message history and relate data is encrypted.
- Requering password for all accounts.
- Storing password in keychain. There is no need to login on every application launch.
- Added PIN screen and TouchID support [#164](https://github.com/Antidote-for-Tox/Antidote/issues/164), [#165](https://github.com/Antidote-for-Tox/Antidote/issues/165).
- Added Acknowledgements screen [#76](https://github.com/Antidote-for-Tox/Antidote/issues/76).
- Updating app icon and color scheme [#203](https://github.com/Antidote-for-Tox/Antidote/issues/203).
- Czech language.

## [0.10.4-2] - 2016-08-04
### Fixed
- Issue with calls not updating when answered.

## [0.10.4] - 2016-08-04
### Added
- Retry button for file transfers.
- Message removal in chat.
- Breton, Lithuanian, Chinese (China), French, French (France) languages.

### Changed
- Migration to new Realm, app speed improvements.
- Improving file sending UX [#193](https://github.com/Antidote-for-Tox/Antidote/issues/193).
- Improved cleanup of file transfer leftovers.
- In-app notifications look like system ones [#205](https://github.com/Antidote-for-Tox/Antidote/issues/205).

### Fixed
- User stays online for some time after quitting Antidote [#171](https://github.com/Antidote-for-Tox/Antidote/issues/171).
- Crash when sending files from other apps [#193](https://github.com/Antidote-for-Tox/Antidote/issues/193).
- Opening files from other aps on iOS 8 [#198](https://github.com/Antidote-for-Tox/Antidote/issues/198).
- Flashing screen when rotating device on iOS 8 [#196](https://github.com/Antidote-for-Tox/Antidote/issues/196).
- Password screen layout in landscape [#187](https://github.com/Antidote-for-Tox/Antidote/issues/187).
- Error messages sometimes not shown.

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

[unreleased]: https://github.com/Antidote-for-Tox/Antidote/compare/1.3.1...master
[1.3.1]: https://github.com/Antidote-for-Tox/Antidote/compare/1.3.0...1.3.1
[1.3.0]: https://github.com/Antidote-for-Tox/Antidote/compare/1.2.0-build-2...1.3.0
[1.2.0-build-2]: https://github.com/Antidote-for-Tox/Antidote/compare/1.2.0...1.2.0-build-2
[1.2.0]: https://github.com/Antidote-for-Tox/Antidote/compare/1.1.0...1.2.0
[1.1.0]: https://github.com/Antidote-for-Tox/Antidote/compare/1.0.0-rc.4...1.1.0
[1.0.0-rc.4]: https://github.com/Antidote-for-Tox/Antidote/compare/1.0.0-rc.3...1.0.0-rc.4
[1.0.0-rc.3]: https://github.com/Antidote-for-Tox/Antidote/compare/1.0.0-rc.2...1.0.0-rc.3
[1.0.0-rc.2]: https://github.com/Antidote-for-Tox/Antidote/compare/1.0.0-rc.1...1.0.0-rc.2
[1.0.0-rc.1]: https://github.com/Antidote-for-Tox/Antidote/compare/0.10.4-2...1.0.0-rc.1
[0.10.4-2]: https://github.com/Antidote-for-Tox/Antidote/compare/0.10.4...0.10.4-2
[0.10.4]: https://github.com/Antidote-for-Tox/Antidote/compare/0.10.3...0.10.4
[0.10.3]: https://github.com/Antidote-for-Tox/Antidote/compare/0.10.2...0.10.3
[0.10.2]: https://github.com/Antidote-for-Tox/Antidote/compare/0.10.1...0.10.2
[0.10.1]: https://github.com/Antidote-for-Tox/Antidote/compare/0.10.0...0.10.1
[0.10.0]: https://github.com/Antidote-for-Tox/Antidote/compare/0.6.1...0.10.0
[0.6.1]: https://github.com/Antidote-for-Tox/Antidote/compare/0.6.0...0.6.1
[0.6.0]: https://github.com/Antidote-for-Tox/Antidote/compare/0.5.0...0.6.0
[0.5.0]: https://github.com/Antidote-for-Tox/Antidote/compare/0.4.0...0.5.0
[0.4.0]: https://github.com/Antidote-for-Tox/Antidote/compare/0.3.0...0.4.0
[0.3.0]: https://github.com/Antidote-for-Tox/Antidote/compare/0.2.5...0.3.0

