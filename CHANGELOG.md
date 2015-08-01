# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased][unreleased]

## [0.4.0] - 2015-08-01
### Added
- Profile tab, containing user profile information (avatar, username, status message, Tox ID).
- Status of connection in tabBar.
- About screen with version information.
- Showing alert view with text on different errors.
- Showing timestamps in chat after every 3 messages (temporary solution, will be improved in future).

### Changes
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

[unreleased]: https://github.com/Antidote-for-Tox/Antidote/compare/0.4.0...master
[0.4.0]: https://github.com/Antidote-for-Tox/Antidote/compare/0.3.0...0.4.0
[0.3.0]: https://github.com/Antidote-for-Tox/Antidote/compare/0.2.5...0.3.0

