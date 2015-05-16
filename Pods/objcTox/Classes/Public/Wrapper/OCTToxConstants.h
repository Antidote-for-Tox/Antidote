//
//  OCTToxConstants.h
//  objcTox
//
//  Created by Dmytro Vorobiov on 02.03.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef uint32_t OCTToxNoSpam;
typedef uint16_t OCTToxPort;
typedef uint32_t OCTToxFriendNumber;
typedef uint32_t OCTToxMessageId;
typedef uint32_t OCTToxFileNumber;
typedef uint64_t OCTToxFileSize;

extern const OCTToxFriendNumber kOCTToxFriendNumberFailure;
extern const OCTToxFileNumber kOCTToxFileNumberFailure;
extern const OCTToxFileSize kOCTToxFileSizeUnknown;

extern NSString *const kOCTToxErrorDomain;

/**
 * Length of address. Address is hex string, has following format:
 * [publicKey (32 bytes, 64 characters)][nospam number (4 bytes, 8 characters)][checksum (2 bytes, 4 characters)]
 */
extern const NSUInteger kOCTToxAddressLength;

/**
 * Length of public key. It is hex string, 32 bytes, 64 characters.
 */
extern const NSUInteger kOCTToxPublicKeyLength;
/**
 * Length of secret key. It is hex string, 32 bytes, 64 characters.
 */
extern const NSUInteger kOCTToxSecretKeyLength;

extern const NSUInteger kOCTToxMaxNameLength;
extern const NSUInteger kOCTToxMaxStatusMessageLength;
extern const NSUInteger kOCTToxMaxFriendRequestLength;
extern const NSUInteger kOCTToxMaxMessageLength;
extern const NSUInteger kOCTToxMaxCustomPacketSize;
extern const NSUInteger kOCTToxMaxFileNameLength;

extern const NSUInteger kOCTToxHashLength;
extern const NSUInteger kOCTToxFileIdLength;

typedef NS_ENUM(NSUInteger, OCTToxProxyType) {
    OCTToxProxyTypeNone,
    OCTToxProxyTypeSocks5,
    OCTToxProxyTypeHTTP,
};

typedef NS_ENUM(NSUInteger, OCTToxConnectionStatus) {
    /**
     * There is no connection. This instance, or the friend the state change is about, is now offline.
     */
    OCTToxConnectionStatusNone,

    /**
     * A TCP connection has been established. For the own instance, this means it
     * is connected through a TCP relay, only. For a friend, this means that the
     * connection to that particular friend goes through a TCP relay.
     */
    OCTToxConnectionStatusTCP,

    /**
     * A UDP connection has been established. For the own instance, this means it
     * is able to send UDP packets to DHT nodes, but may still be connected to
     * a TCP relay. For a friend, this means that the connection to that
     * particular friend was built using direct UDP packets.
     */
    OCTToxConnectionStatusUDP,
};

typedef NS_ENUM(NSUInteger, OCTToxUserStatus) {
    /**
     * User is online and available.
     */
    OCTToxUserStatusNone,
    /**
     * User is away. Clients can set this e.g. after a user defined
     * inactivity time.
     */
    OCTToxUserStatusAway,
    /**
     * User is busy. Signals to other clients that this client does not
     * currently wish to communicate.
     */
    OCTToxUserStatusBusy,
};

typedef NS_ENUM(NSUInteger, OCTToxMessageType) {
    /**
     * Normal text message. Similar to PRIVMSG on IRC.
     */
    OCTToxMessageTypeNormal,
    /**
     * A message describing an user action. This is similar to /me (CTCP ACTION)
     * on IRC.
     */
    OCTToxMessageTypeAction,
};

typedef NS_ENUM(NSUInteger, OCTToxFileKind) {
    /**
     * Arbitrary file data. Clients can choose to handle it based on the file name
     * or magic or any other way they choose.
     */
    OCTToxFileKindData,

    /**
     * Avatar filename. This consists of toxHash(image).
     * Avatar data. This consists of the image data.
     *
     * Avatars can be sent at any time the client wishes. Generally, a client will
     * send the avatar to a friend when that friend comes online, and to all
     * friends when the avatar changed. A client can save some traffic by
     * remembering which friend received the updated avatar already and only send
     * it if the friend has an out of date avatar.
     *
     * Clients who receive avatar send requests can reject it (by sending
     * OCTToxFileControl before any other controls), or accept it (by
     * sending OCTToxFileControlResume). The fileId of length kOCTToxHashLength bytes
     * (same length as kOCTToxFileIdLength) will contain the hash. A client can compare
     * this hash with a saved hash and send OCTToxFileControlCancel to terminate the avatar
     * transfer if it matches.
     *
     * When fileSize is set to 0 in the transfer request it means that the client has no
     * avatar.
     */
    OCTToxFileKindAvatar,
};

typedef NS_ENUM(NSUInteger, OCTToxFileControl) {
    /**
     * Sent by the receiving side to accept a file send request. Also sent after a
     * OCTToxFileControlPause command to continue sending or receiving.
     */
    OCTToxFileControlResume,

    /**
     * Sent by clients to pause the file transfer. The initial state of a file
     * transfer is always paused on the receiving side and running on the sending
     * side. If both the sending and receiving side pause the transfer, then both
     * need to send OCTToxFileControlResume for the transfer to resume.
     */
    OCTToxFileControlPause,

    /**
     * Sent by the receiving side to reject a file send request before any other
     * commands are sent. Also sent by either side to terminate a file transfer.
     */
    OCTToxFileControlCancel,
};


/*******************************************************************************
 *
 * Error Codes
 *
 ******************************************************************************/

/**
 * Error codes for init method.
 */
typedef NS_ENUM(NSUInteger, OCTToxErrorInitCode) {
    OCTToxErrorInitCodeUnknown,
    /**
     * Was unable to allocate enough memory to store the internal structures for the Tox object.
     */
    OCTToxErrorInitCodeMemoryError,

    /**
     * Was unable to bind to a port. This may mean that all ports have already been bound,
     * e.g. by other Tox instances, or it may mean a permission error.
     */
    OCTToxErrorInitCodePortAlloc,

    /**
     * proxyType was invalid.
     */
    OCTToxErrorInitCodeProxyBadType,

    /**
     * proxyAddress had an invalid format or was nil (while proxyType was set).
     */
    OCTToxErrorInitCodeProxyBadHost,

    /**
     * proxyPort was invalid.
     */
    OCTToxErrorInitCodeProxyBadPort,

    /**
     * The proxy host passed could not be resolved.
     */
    OCTToxErrorInitCodeProxyNotFound,

    /**
     * The saved data to be loaded contained an encrypted save.
     */
    OCTToxErrorInitCodeEncrypted,

    /**
     * The data format was invalid. This can happen when loading data that was
     * saved by an older version of Tox, or when the data has been corrupted.
     * When loading from badly formatted data, some data may have been loaded,
     * and the rest is discarded. Passing an invalid length parameter also
     * causes this error.
     */
    OCTToxErrorInitCodeLoadBadFormat,
};

/**
 * Error codes for bootstrap and addTCPRelay methods.
 */
typedef NS_ENUM(NSUInteger, OCTToxErrorBootstrapCode) {
    OCTToxErrorBootstrapCodeUnknown,

    /**
     * The host could not be resolved to an IP address, or the IP address passed was invalid.
     */
    OCTToxErrorBootstrapCodeBadHost,

    /**
     * The port passed was invalid. The valid port range is (1, 65535).
     */
    OCTToxErrorBootstrapCodeBadPort,
};

/**
 * Common error codes for all methods that set a piece of user-visible client information.
 */
typedef NS_ENUM(NSUInteger, OCTToxErrorSetInfoCode) {
    OCTToxErrorSetInfoCodeUnknow,

    /**
     * Information length exceeded maximum permissible size.
     */
    OCTToxErrorSetInfoCodeTooLong,
};

/**
 * Error codes for addFriend method.
 */
typedef NS_ENUM(NSUInteger, OCTToxErrorFriendAdd) {
    OCTToxErrorFriendAddUnknown,

    /**
     * The length of the friend request message exceeded kOCTToxMaxFriendRequestLength.
     */
    OCTToxErrorFriendAddTooLong,

    /**
     * The friend request message was empty.
     */
    OCTToxErrorFriendAddNoMessage,

    /**
     * The friend address belongs to the sending client.
     */
    OCTToxErrorFriendAddOwnKey,

    /**
     * A friend request has already been sent, or the address belongs to a friend
     * that is already on the friend list.
     */
    OCTToxErrorFriendAddAlreadySent,

    /**
     * The friend address checksum failed.
     */
    OCTToxErrorFriendAddBadChecksum,

    /**
     * The friend was already there, but the nospam value was different.
     */
    OCTToxErrorFriendAddSetNewNospam,

    /**
     * A memory allocation failed when trying to increase the friend list size.
     */
    OCTToxErrorFriendAddMalloc,
};

/**
 * Error codes for deleteFriend method.
 */
typedef NS_ENUM(NSUInteger, OCTToxErrorFriendDelete) {
    /**
     * There was no friend with the given friend number. No friends were deleted.
     */
    OCTToxErrorFriendDeleteNotFound,
};

/**
 * Error codes for friendNumberWithPublicKey
 */
typedef NS_ENUM(NSUInteger, OCTToxErrorFriendByPublicKey) {
    OCTToxErrorFriendByPublicKeyUnknown,

    /**
     * No friend with the given Public Key exists on the friend list.
     */
    OCTToxErrorFriendByPublicKeyNotFound,
};

/**
 * Error codes for publicKeyFromFriendNumber.
 */
typedef NS_ENUM(NSUInteger, OCTToxErrorFriendGetPublicKey) {
    /**
     * No friend with the given number exists on the friend list.
     */
    OCTToxErrorFriendGetPublicKeyFriendNotFound,
};

/**
 * Error codes for last online methods.
 */
typedef NS_ENUM(NSUInteger, OCTToxErrorFriendGetLastOnline) {
    /**
     * No friend with the given number exists on the friend list.
     */
    OCTToxErrorFriendGetLastOnlineFriendNotFound,
};

/**
 * Error codes for friend state query methods.
 */
typedef NS_ENUM(NSUInteger, OCTToxErrorFriendQuery) {
    OCTToxErrorFriendQueryUnknown,

    /**
     * The friendNumber did not designate a valid friend.
     */
    OCTToxErrorFriendQueryFriendNotFound,
};

/**
 * Error codes for changing isTyping.
 */
typedef NS_ENUM(NSUInteger, OCTToxErrorSetTyping) {
    /**
     * The friend number did not designate a valid friend.
     */
    OCTToxErrorSetTypingFriendNotFound,
};

/**
 * Error codes for sending message.
 */
typedef NS_ENUM(NSUInteger, OCTToxErrorFriendSendMessage) {
    OCTToxErrorFriendSendMessageUnknown,

    /**
     * The friend number did not designate a valid friend.
     */
    OCTToxErrorFriendSendMessageFriendNotFound,

    /**
     * This client is currently not connected to the friend.
     */
    OCTToxErrorFriendSendMessageFriendNotConnected,

    /**
     * An allocation error occurred while increasing the send queue size.
     */
    OCTToxErrorFriendSendMessageAlloc,

    /**
     * Message length exceeded kOCTToxMaxMessageLength.
     */
    OCTToxErrorFriendSendMessageTooLong,

    /**
     * Attempted to send a zero-length message.
     */
    OCTToxErrorFriendSendMessageEmpty,
};

/**
 * Error codes for sending file control.
 */
typedef NS_ENUM(NSUInteger, OCTToxErrorFileControl) {
    /**
     * The friendNumber passed did not designate a valid friend.
     */
    OCTToxErrorFileControlFriendNotFound,

    /**
     * This client is currently not connected to the friend.
     */
    OCTToxErrorFileControlFriendNotConnected,

    /**
     * No file transfer with the given file number was found for the given friend.
     */
    OCTToxErrorFileControlNotFound,

    /**
     * A OCTToxFileControlResume control was sent, but the file transfer is running normally.
     */
    OCTToxErrorFileControlNotPaused,

    /**
     * A OCTToxFileControlResume control was sent, but the file transfer was paused by the other
     * party. Only the party that paused the transfer can resume it.
     */
    OCTToxErrorFileControlDenied,

    /**
     * A OCTToxFileControlPause control was sent, but the file transfer was already paused.
     */
    OCTToxErrorFileControlAlreadyPaused,

    /**
     * Packet queue is full.
     */
    OCTToxErrorFileControlSendq,
};

/**
 * Error codes for file seek method.
 */
typedef NS_ENUM(NSUInteger, OCTToxErrorFileSeek) {
    /**
     * The friendNumber passed did not designate a valid friend.
     */
    OCTToxErrorFileSeekFriendNotFound,

    /**
     * This client is currently not connected to the friend.
     */
    OCTToxErrorFileSeekFriendNotConnected,

    /**
     * No file transfer with the given file number was found for the given friend.
     */
    OCTToxErrorFileSeekNotFound,

    /**
     * File was not in a state where it could be seeked.
     */
    OCTToxErrorFileSeekDenied,

    /**
     * Seek position was invalid
     */
    OCTToxErrorFileSeekInvalidPosition,

    /**
     * Packet queue is full.
     */
    OCTToxErrorFileSeekSendq,
};

/**
 * Error codes for fileGetFileId method.
 */
typedef NS_ENUM(NSUInteger, OCTToxErrorFileGet) {
    /**
     * The friendNumber passed did not designate a valid friend.
     */
    OCTToxErrorFileGetFriendNotFound,

    /**
     * No file transfer with the given file number was found for the given friend.
     */
    OCTToxErrorFileGetNotFound,
};

/**
 * Error codes for fileSend method.
 */
typedef NS_ENUM(NSUInteger, OCTToxErrorFileSend) {
    OCTToxErrorFileSendUnknown,

    /**
     * The friendNumber passed did not designate a valid friend.
     */
    OCTToxErrorFileSendFriendNotFound,

    /**
     * This client is currently not connected to the friend.
     */
    OCTToxErrorFileSendFriendNotConnected,

    /**
     * Filename length exceeded kOCTToxMaxFileNameLength bytes.
     */
    OCTToxErrorFileSendNameTooLong,

    /**
     * Too many ongoing transfers. The maximum number of concurrent file transfers
     * is 256 per friend per direction (sending and receiving).
     */
    OCTToxErrorFileSendTooMany,
};

/**
 * Error codes for fileSendChunk method.
 */
typedef NS_ENUM(NSUInteger, OCTToxErrorFileSendChunk) {
    OCTToxErrorFileSendChunkUnknown,

    /**
     * The friendNumber passed did not designate a valid friend.
     */
    OCTToxErrorFileSendChunkFriendNotFound,

    /**
     * This client is currently not connected to the friend.
     */
    OCTToxErrorFileSendChunkFriendNotConnected,

    /**
     * No file transfer with the given file number was found for the given friend.
     */
    OCTToxErrorFileSendChunkNotFound,

    /**
     * File transfer was found but isn't in a transferring state: (paused, done,
     * broken, etc...) (happens only when not called from the request chunk callback).
     */
    OCTToxErrorFileSendChunkNotTransferring,

    /**
     * Attempted to send more or less data than requested. The requested data size is
     * adjusted according to maximum transmission unit and the expected end of
     * the file. Trying to send less or more than requested will return this error.
     */
    OCTToxErrorFileSendChunkInvalidLength,

    /**
     * Packet queue is full.
     */
    OCTToxErrorFileSendChunkSendq,

    /**
     * Position parameter was wrong.
     */
    OCTToxErrorFileSendChunkWrongPosition
};

