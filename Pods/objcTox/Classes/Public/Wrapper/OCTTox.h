//
//  OCTTox.h
//  objcTox
//
//  Created by Dmytro Vorobiov on 02.03.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OCTToxDelegate.h"
#import "OCTToxOptions.h"
#import "OCTToxConstants.h"

@interface OCTTox : NSObject

@property (weak, nonatomic) id<OCTToxDelegate> delegate;

/**
 * Indicates if we are connected to the DHT.
 */
@property (assign, nonatomic, readonly) OCTToxConnectionStatus connectionStatus;

/**
 * Our address.
 *
 * Address for Tox as a hex string. Address is kOCTToxAddressLength length and has following format:
 * [publicKey (32 bytes, 64 characters)][nospam number (4 bytes, 8 characters)][checksum (2 bytes, 4 characters)]
 */
@property (strong, nonatomic, readonly) NSString *userAddress;

/**
 * Our Tox Public Key (long term public key) of kOCTToxPublicKeyLength.
 */
@property (strong, nonatomic, readonly) NSString *publicKey;

/**
 * Our secret key of kOCTToxSecretKeyLength.
 */
@property (strong, nonatomic, readonly) NSString *secretKey;

/**
 * Client's nospam part of the address. Any 32 bit unsigned integer.
 */
@property (assign, nonatomic) OCTToxNoSpam nospam;

/**
 * Client's user status.
 */
@property (assign, nonatomic) OCTToxUserStatus userStatus;

#pragma mark -  Class methods

/**
 * Return toxcore version in format X.Y.Z, where
 * X - The major version number. Incremented when the API or ABI changes in an incompatible way.
 * Y - The minor version number. Incremented when functionality is added without breaking the API or ABI.
 * Set to 0 when the major version number is incremented.
 * Z - The patch or revision number. Incremented when bugfixes are applied without changing any functionality or API or ABI.
 */
+ (NSString *)version;

/**
 * The major version number of toxcore. Incremented when the API or ABI changes in an incompatible way.
 */
+ (NSUInteger)versionMajor;

/**
 * The minor version number of toxcore. Incremented when functionality is added without breaking the API or ABI.
 * Set to 0 when the major version number is incremented.
 */
+ (NSUInteger)versionMinor;

/**
 * The patch or revision number of toxcore. Incremented when bugfixes are applied without changing any functionality or API or ABI.
 */
+ (NSUInteger)versionPatch;

#pragma mark -  Lifecycle

/**
 * Creates new Tox object with configuration options and loads saved data.
 *
 * @param options Configuration options.
 * @param data Data load Tox from previously stored by `-save` method. Pass nil if there is no saved data.
 * @param error If an error occurs, this pointer is set to an actual error object containing the error information.
 * See OCTToxErrorInitCode for all error codes.
 *
 * @return New instance of Tox or nil if fatal error occured during loading.
 *
 * @warning If loading failed or succeeded only partially, the new or partially loaded instance is returned and
 * an error is set.
 */
- (instancetype)initWithOptions:(OCTToxOptions *)options savedData:(NSData *)data error:(NSError **)error;

/**
 * Saves Tox into NSData.
 *
 * @return NSData with Tox save.
 */
- (NSData *)save;

/**
 * Starts the main loop of the Tox on it's own unique queue.
 *
 * @warning Tox won't do anything without calling this method.
 */
- (void)start;

/**
 * Stops the main loop of the Tox.
 */
- (void)stop;

#pragma mark -  Methods

/**
 * Sends a "get nodes" request to the given bootstrap node with IP, port, and
 * public key to setup connections.
 *
 * This function will attempt to connect to the node using UDP and TCP at the
 * same time.
 *
 * Tox will use the node as a TCP relay in case OCTToxOptions.UDPEnabled was
 * YES, and also to connect to friends that are in TCP-only mode. Tox will
 * also use the TCP connection when NAT hole punching is slow, and later switch
 * to UDP if hole punching succeeds.
 *
 * @param host The hostname or an IP address (IPv4 or IPv6) of the node.
 * @param port The port on the host on which the bootstrap Tox instance is listening.
 * @param publicKey Public key of the node (of kOCTToxPublicKeyLength length).
 * @param error If an error occurs, this pointer is set to an actual error object containing the error information.
 * See OCTToxErrorBootstrapCode for all error codes.
 *
 * @return YES on success, NO on failure.
 */
- (BOOL)bootstrapFromHost:(NSString *)host port:(OCTToxPort)port publicKey:(NSString *)publicKey error:(NSError **)error;

/**
 * Adds additional host:port pair as TCP relay.
 *
 * This function can be used to initiate TCP connections to different ports on
 * the same bootstrap node, or to add TCP relays without using them as
 * bootstrap nodes.
 *
 * @param host The hostname or IP address (IPv4 or IPv6) of the TCP relay.
 * @param port The port on the host on which the TCP relay is listening.
 * @param publicKey Public key of the node (of kOCTToxPublicKeyLength length).
 * @param error If an error occurs, this pointer is set to an actual error object containing the error information.
 * See OCTToxErrorBootstrapCode for all error codes.
 *
 * @return YES on success, NO on failure.
 */
- (BOOL)addTCPRelayWithHost:(NSString *)host port:(OCTToxPort)port publicKey:(NSString *)publicKey error:(NSError **)error;

/**
 * Add a friend.
 *
 * @param address Address of a friend to add. Must be exactry kOCTToxAddressLength length.
 * @param message Message that would be send with friend request. Minimum length - 1 byte.
 * @param error If an error occurs, this pointer is set to an actual error object containing the error information.
 * See OCTToxErrorFriendAdd for all error codes.
 *
 * @return On success returns friend number. On failure returns kOCTToxFriendNumberFailure and fills `error` parameter.
 *
 * @warning You can check maximum length of message with `-checkLengthOfString:withCheckType:` method with
 * OCTToxCheckLengthTypeFriendRequest type.
 */
- (OCTToxFriendNumber)addFriendWithAddress:(NSString *)address message:(NSString *)message error:(NSError **)error;

/**
 * Add a friend without sending friend request.
 *
 * This function is used to add a friend in response to a friend request. If the
 * client receives a friend request, it can be reasonably sure that the other
 * client added this client as a friend, eliminating the need for a friend
 * request.
 *
 * This function is also useful in a situation where both instances are
 * controlled by the same entity, so that this entity can perform the mutual
 * friend adding. In this case, there is no need for a friend request, either.
 *
 * @param publicKey Public key of a friend to add. Public key is hex string, must be exactry kOCTToxPublicKeyLength length.
 * @param error If an error occurs, this pointer is set to an actual error object containing the error information.
 * See OCTToxErrorFriendAdd for all error codes.
 *
 * @return On success returns friend number. On failure returns kOCTToxFriendNumberFailure.
 */
- (OCTToxFriendNumber)addFriendWithNoRequestWithPublicKey:(NSString *)publicKey error:(NSError **)error;

/**
 * Remove a friend from the friend list.
 *
 * This does not notify the friend of their deletion. After calling this
 * function, this client will appear offline to the friend and no communication
 * can occur between the two.
 *
 * @param friendNumber Friend number to remove.
 * @param error If an error occurs, this pointer is set to an actual error object containing the error information.
 * See OCTToxErrorFriendDelete for all error codes.
 *
 * @return YES on success, NO on failure.
 */
- (BOOL)deleteFriendWithFriendNumber:(OCTToxFriendNumber)friendNumber error:(NSError **)error;

/**
 * Return the friend number associated with that Public Key.
 *
 * @param publicKey Public key of a friend. Public key is hex string, must be exactry kOCTToxPublicKeyLength length.
 * @param error If an error occurs, this pointer is set to an actual error object containing the error information.
 * See OCTToxErrorFriendByPublicKey for all error codes.
 *
 * @return The friend number on success, kOCTToxFriendNumberFailure on failure.
 */
- (OCTToxFriendNumber)friendNumberWithPublicKey:(NSString *)publicKey error:(NSError **)error;

/**
 * Get public key from associated friend number.
 *
 * @param friendNumber Associated friend number
 * @param error If an error occurs, this pointer is set to an actual error object containing the error information.
 * See OCTToxErrorFriendGetPublicKey for all error codes.
 *
 * @return Public key of a friend. Public key is hex string, must be exactry kOCTToxPublicKeyLength length. If there is no such friend returns nil.
 */
- (NSString *)publicKeyFromFriendNumber:(OCTToxFriendNumber)friendNumber error:(NSError **)error;

/**
 * Checks if there exists a friend with given friendNumber.
 *
 * @param friendNumber Friend number to check.
 *
 * @return YES if friend exists, NO otherwise.
 */
- (BOOL)friendExistsWithFriendNumber:(OCTToxFriendNumber)friendNumber;

/**
 * Return a date of the last time the friend associated with a given friend number was seen online.
 *
 * @param friendNumber The friend number you want to query.
 * @param error If an error occurs, this pointer is set to an actual error object containing the error information.
 * See OCTToxErrorFriendGetLastOnline for all error codes.
 *
 * @return Date of the last time friend was seen online.
 */
- (NSDate *)friendGetLastOnlineWithFriendNumber:(OCTToxFriendNumber)friendNumber error:(NSError **)error;

/**
 * Return the friend's user status (away/busy/...). If the friend number is
 * invalid, the return value is unspecified.
 *
 * @param friendNumber Friend number to check status.
 * @param error If an error occurs, this pointer is set to an actual error object containing the error information.
 * See OCTToxErrorFriendQuery for all error codes.
 *
 * @return Returns friend status.
 */
- (OCTToxUserStatus)friendStatusWithFriendNumber:(OCTToxFriendNumber)friendNumber error:(NSError **)error;

/**
 * Check whether a friend is currently connected to this client.
 *
 * @param friendNumber Friend number to check status.
 * @param error If an error occurs, this pointer is set to an actual error object containing the error information.
 * See OCTToxErrorFriendQuery for all error codes.
 *
 * @return Returns friend connection status.
 */
- (OCTToxConnectionStatus)friendConnectionStatusWithFriendNumber:(OCTToxFriendNumber)friendNumber error:(NSError **)error;

/**
 * Send a text chat message to an online friend.
 *
 * @param friendNumber Friend number to send a message.
 * @param type Type of the message.
 * @param message Message that would be send.
 * @param error If an error occurs, this pointer is set to an actual error object containing the error information.
 * See OCTToxErrorFriendSendMessage for all error codes.
 *
 * @return The message id if packet was successfully put into the send queue, 0 if it was not. You can use id later to check if message has been delivered.
 *
 * @warning You can check maximum length of message with `-checkLengthOfString:withCheckType:` method with
 * OCTToxCheckLengthTypeSendMessage type.
 */
- (OCTToxMessageId)sendMessageWithFriendNumber:(OCTToxFriendNumber)friendNumber
                                          type:(OCTToxMessageType)type
                                       message:(NSString *)message
                                         error:(NSError **)error;

/**
 * Set the nickname for the Tox client.
 *
 * @param name Name to be set. Minimum length of name is 1 byte.
 * @param error If an error occurs, this pointer is set to an actual error object containing the error information.
 * See OCTToxErrorSetInfoCode for all error codes.
 *
 * @return YES on success, NO on failure.
 *
 * @warning You can check maximum length of message with `-checkLengthOfString:withCheckType:` method with
 * OCTToxCheckLengthTypeName type.
 */
- (BOOL)setNickname:(NSString *)name error:(NSError **)error;

/**
 * Get your nickname.
 *
 * @return Your nickname or nil in case of error.
 */
- (NSString *)userName;

/**
 * Get name of friendNumber.
 *
 * @param friendNumber Friend number to get name.
 * @param error If an error occurs, this pointer is set to an actual error object containing the error information.
 * See OCTToxErrorFriendQuery for all error codes.
 *
 * @return Name of friend or nil in case of error.
 */
- (NSString *)friendNameWithFriendNumber:(OCTToxFriendNumber)friendNumber error:(NSError **)error;

/**
 * Set our status message.
 *
 * @param statusMessage Status message to be set.
 * @param error If an error occurs, this pointer is set to an actual error object containing the error information.
 * See OCTToxErrorSetInfoCode for all error codes.
 *
 * @return YES on success, NO on failure.
 *
 * @warning You can check maximum length of message with `-checkLengthOfString:withCheckType:` method with
 * OCTToxCheckLengthTypeStatusMessage type.
 */
- (BOOL)setUserStatusMessage:(NSString *)statusMessage error:(NSError **)error;

/**
 * Get our status message.
 *
 * @return Our status message.
 */
- (NSString *)userStatusMessage;

/**
 * Get status message of a friend.
 *
 * @param friendNumber Friend number to get status message.
 * @param error If an error occurs, this pointer is set to an actual error object containing the error information.
 * See OCTToxErrorFriendQuery for all error codes.
 *
 * @return Status message of a friend.
 */
- (NSString *)friendStatusMessageWithFriendNumber:(OCTToxFriendNumber)friendNumber error:(NSError **)error;

/**
 * Set our typing status for a friend. You are responsible for turning it on or off.
 *
 * @param isTyping Status showing whether user is typing or not.
 * @param friendNumber Friend number to set typing status.
 * @param error If an error occurs, this pointer is set to an actual error object containing the error information.
 * See OCTToxErrorSetTyping for all error codes.
 *
 * @return YES on success, NO on failure.
 */
- (BOOL)setUserIsTyping:(BOOL)isTyping forFriendNumber:(OCTToxFriendNumber)friendNumber error:(NSError **)error;

/**
 * Get the typing status of a friend.
 *
 * @param friendNumber Friend number to get typing status.
 * @param error If an error occurs, this pointer is set to an actual error object containing the error information.
 * See OCTToxErrorFriendQuery for all error codes.
 *
 * @return YES if friend is typing, otherwise NO.
 */
- (BOOL)isFriendTypingWithFriendNumber:(OCTToxFriendNumber)friendNumber error:(NSError **)error;

/**
 * Return the number of friends.
 *
 * @return Return the number of friends.
 */
- (NSUInteger)friendsCount;

/**
 * Return an array of valid friend IDs.
 *
 * @return Return an array of valid friend IDs. Array contain NSNumbers with IDs.
 */
- (NSArray *)friendsArray;

/**
 * Generates a cryptographic hash of the given data.
 * This function may be used by clients for any purpose, but is provided primarily for
 * validating cached avatars. This use is highly recommended to avoid unnecessary avatar
 * updates.
 *
 * @param data Data to be hashed
 *
 * @return Hash generated from data.
 */
- (NSData *)hashData:(NSData *)data;

/**
 * Sends a file control command to a friend for a given file transfer.
 *
 * @param fileNumber The friend-specific identifier for the file transfer.
 * @param friendNumber The friend number of the friend the file is being transferred to or received from.
 * @param control The control command to send.
 * @param error If an error occurs, this pointer is set to an actual error object containing the error information.
 * See OCTToxErrorFileControl for all error codes.
 *
 * @return YES on success, NO on failure.
 */
- (BOOL)fileSendControlForFileNumber:(OCTToxFileNumber)fileNumber
                        friendNumber:(OCTToxFriendNumber)friendNumber
                             control:(OCTToxFileControl)control
                               error:(NSError **)error;

/**
 * Sends a file seek control command to a friend for a given file transfer.
 *
 * This function can only be called to resume a file transfer right before
 * OCTToxFileControlResume is sent.
 *
 * @param fileNumber The friend-specific identifier for the file transfer.
 * @param friendNumber The friend number of the friend the file is being received from.
 * @param position The position that the file should be seeked to.
 * @param error If an error occurs, this pointer is set to an actual error object containing the error information.
 * See OCTToxErrorFileSeek for all error codes.
 *
 * @return YES on success, NO on failure.
 */
- (BOOL)fileSeekForFileNumber:(OCTToxFileNumber)fileNumber
                 friendNumber:(OCTToxFriendNumber)friendNumber
                     position:(OCTToxFileSize)position
                        error:(NSError **)error;

/**
 * Get the file id associated to the file transfer.
 *
 * @param fileNumber The friend-specific identifier for the file transfer.
 * @param friendNumber The friend number of the friend the file is being transferred to or received from.
 * @param error If an error occurs, this pointer is set to an actual error object containing the error information.
 * See OCTToxErrorFileGet for all error codes.
 *
 * @return File id on success, nil on failure.
 */
- (NSData *)fileGetFileIdForFileNumber:(OCTToxFileNumber)fileNumber
                          friendNumber:(OCTToxFriendNumber)friendNumber
                                 error:(NSError **)error;

/**
 * Send a file transmission request.
 *
 * Maximum filename length is kOCTToxMaxFileNameLength bytes. The filename should generally just be
 * a file name, not a path with directory names.
 *
 * If a non-zero file size is provided, this can be used by both sides to
 * determine the sending progress. File size can be set to zero for streaming
 * data of unknown size.
 *
 * File transmission occurs in chunks, which are requested through the
 * `fileChunkRequest` callback.
 *
 * When a friend goes offline, all file transfers associated with the friend are
 * purged from core.
 *
 * If the file contents change during a transfer, the behaviour is unspecified
 * in general. What will actually happen depends on the mode in which the file
 * was modified and how the client determines the file size.
 *
 * - If the file size was increased
 *   - and sending mode was streaming (fileSize = kOCTToxFileSizeUnknown), the behaviour will be as
 *     expected.
 *   - and sending mode was file (fileSize != kOCTToxFileSizeUnknown), the fileChunkRequest
 *     callback will receive length = 0 when Core thinks the file transfer has
 *     finished. If the client remembers the file size as it was when sending
 *     the request, it will terminate the transfer normally. If the client
 *     re-reads the size, it will think the friend cancelled the transfer.
 * - If the file size was decreased
 *   - and sending mode was streaming, the behaviour is as expected.
 *   - and sending mode was file, the callback will return 0 at the new
 *     (earlier) end-of-file, signalling to the friend that the transfer was
 *     cancelled.
 * - If the file contents were modified
 *   - at a position before the current read, the two files (local and remote)
 *     will differ after the transfer terminates.
 *   - at a position after the current read, the file transfer will succeed as
 *     expected.
 *   - In either case, both sides will regard the transfer as complete and
 *     successful.
 *
 * @param friendNumber The friend number of the friend the file send request should be sent to.
 * @param kind The meaning of the file to be sent.
 * @param fileSize Size in bytes of the file the client wants to send, kOCTToxFileSizeUnknown if unknown or streaming.
 * @param fileId A file identifier of length kOCTToxFileIdLength that can be used to
 *   uniquely identify file transfers across core restarts. If nil, a random one will
 *   be generated by core. It can then be obtained by using `fileGetFileId`.
 * @param fileName Name of the file. Does not need to be the actual name. This
 *   name will be sent along with the file send request.
 * @param error If an error occurs, this pointer is set to an actual error object containing the error information.
 * See OCTToxErrorFileSend for all error codes.
 *
 * @return A file number used as an identifier in subsequent callbacks. This
 *   number is per friend. File numbers are reused after a transfer terminates.
 *   on failure, this function returns kOCTToxFileNumberFailure.
 */
- (OCTToxFileNumber)fileSendWithFriendNumber:(OCTToxFriendNumber)friendNumber
                                        kind:(OCTToxFileKind)kind
                                    fileSize:(OCTToxFileSize)fileSize
                                      fileId:(NSString *)fileId
                                    fileName:(NSString *)fileName
                                       error:(NSError **)error;

/**
 * Send a chunk of file data to a friend.
 *
 * This method is called in response to the `fileChunkRequest` callback. The
 * length of data should be equal to the one received though the callback.
 * If it is zero, the transfer is assumed complete. For files with known size,
 * Core will know that the transfer is complete after the last byte has been
 * received, so it is not necessary (though not harmful) to send a zero-length
 * chunk to terminate. For streams, core will know that the transfer is finished
 * if a chunk with length less than the length requested in the callback is sent.
 *
 * @param friendNumber The friend number of the receiving friend for this file.
 * @param fileNumber The file transfer identifier returned by fileSend.
 * @param position The file or stream position from which to continue reading.
 * @param data Data of chunk to send. May be nil, then transfer is assumed complete.
 * @param error If an error occurs, this pointer is set to an actual error object containing the error information.
 * See OCTToxErrorFileSendChunk for all error codes.
 *
 * @return YES on success, NO on failure.
 */
- (BOOL)fileSendChunkForFileNumber:(OCTToxFileNumber)fileNumber
                      friendNumber:(OCTToxFriendNumber)friendNumber
                          position:(OCTToxFileSize)position
                              data:(NSData *)data
                             error:(NSError **)error;

@end
