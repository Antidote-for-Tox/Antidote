//
//  OCTToxDelegate.h
//  objcTox
//
//  Created by Dmytro Vorobiov on 03.03.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OCTToxConstants.h"

@class OCTTox;

/**
 * All delegate methods will be called on main thread.
 */
@protocol OCTToxDelegate <NSObject>

@optional

/**
 * User connection status changed.
 *
 * @param connectionStatus New connection status of the user.
 */
- (void)tox:(OCTTox *)tox connectionStatus:(OCTToxConnectionStatus)connectionStatus;

/**
 * Received friend request from a new friend.
 *
 * @param message Message sent with request.
 * @param publicKey New friend public key.
 */
- (void)tox:(OCTTox *)tox friendRequestWithMessage:(NSString *)message publicKey:(NSString *)publicKey;

/**
 * Message received from a friend.
 *
 * @param message Received message.
 * @param type Type of the message.
 * @param friendNumber Friend number of appropriate friend.
 */
- (void)tox:(OCTTox *)tox friendMessage:(NSString *)message type:(OCTToxMessageType)type friendNumber:(OCTToxFriendNumber)friendNumber;

/**
 * Friend's name was updated.
 *
 * @param name Updated name.
 * @param friendNumber Friend number of appropriate friend.
 */
- (void)tox:(OCTTox *)tox friendNameUpdate:(NSString *)name friendNumber:(OCTToxFriendNumber)friendNumber;

/**
 * Friend's status message was updated.
 *
 * @param statusMessage Updated status message.
 * @param friendNumber Friend number of appropriate friend.
 */
- (void)tox:(OCTTox *)tox friendStatusMessageUpdate:(NSString *)statusMessage friendNumber:(OCTToxFriendNumber)friendNumber;

/**
 * Friend's status was updated.
 *
 * @param status Updated status.
 * @param friendNumber Friend number of appropriate friend.
 */
- (void)tox:(OCTTox *)tox friendStatusUpdate:(OCTToxUserStatus)status friendNumber:(OCTToxFriendNumber)friendNumber;

/**
 * Friend's isTyping was updated
 *
 * @param isTyping Updated typing status.
 * @param friendNumber Friend number of appropriate friend.
 */
- (void)tox:(OCTTox *)tox friendIsTypingUpdate:(BOOL)isTyping friendNumber:(OCTToxFriendNumber)friendNumber;

/**
 * Message that was previously sent by us has been delivered to a friend.
 *
 * @param messageId Id of message. You could get in in sendMessage method.
 * @param friendNumber Friend number of appropriate friend.
 */
- (void)tox:(OCTTox *)tox messageDelivered:(OCTToxMessageId)messageId friendNumber:(OCTToxFriendNumber)friendNumber;

/**
 * Friend's connection status changed.
 *
 * @param status Updated status.
 * @param friendNumber Friend number of appropriate friend.
 */
- (void)tox:(OCTTox *)tox friendConnectionStatusChanged:(OCTToxConnectionStatus)status friendNumber:(OCTToxFriendNumber)friendNumber;

/**
 * This event is triggered when a file control command is received from a friend.
 *
 * When receiving OCTToxFileControlCancel, the client should release the
 * resources associated with the file number and consider the transfer failed.
 *
 * @param control The control command to send.
 * @param friendNumber The friend number of the friend the file is being transferred to or received from.
 * @param fileNumber The friend-specific identifier for the file transfer.
 */
- (void)tox:(OCTTox *)tox fileReceiveControl:(OCTToxFileControl)control
                                friendNumber:(OCTToxFriendNumber)friendNumber
                                  fileNumber:(OCTToxFileNumber)fileNumber;

/**
 * If the length parameter is 0, the file transfer is finished, and the client's
 * resources associated with the file number should be released. After a call
 * with zero length, the file number can be reused for future file transfers.
 *
 * If the requested position is not equal to the client's idea of the current
 * file or stream position, it will need to seek. In case of read-once streams,
 * the client should keep the last read chunk so that a seek back can be
 * supported. A seek-back only ever needs to read from the last requested chunk.
 * This happens when a chunk was requested, but the send failed. A seek-back
 * request can occur an arbitrary number of times for any given chunk.
 *
 * In response to receiving this callback, the client should call the method
 * `fileSendChunk` with the requested chunk. If the number of bytes sent
 * through that method is zero, the file transfer is assumed complete. A
 * client must send the full length of data requested with this callback.
 *
 * @param friendNumber The friend number of the receiving friend for this file.
 * @param fileNumber The file transfer identifier returned by fileSend.
 * @param position The file or stream position from which to continue reading.
 * @param length The number of bytes requested for the current chunk.
 */
- (void)tox:(OCTTox *)tox fileChunkRequestForFileNumber:(OCTToxFileNumber)fileNumber
                                           friendNumber:(OCTToxFriendNumber)friendNumber
                                               position:(OCTToxFileSize)position
                                                 length:(size_t)length;

/**
 * The client should acquire resources to be associated with the file transfer.
 * Incoming file transfers start in the PAUSED state. After this callback
 * returns, a transfer can be rejected by sending a OCTToxFileControlCancel
 * control command before any other control commands. It can be accepted by
 * sending OCTToxFileControlResume.
 *
 * @param fileNumber The friend-specific file number the data received is associated with.
 * @param friendNumber The friend number of the friend who is sending the file transfer request.
 * @param kind The meaning of the file to be sent.
 * @param fileSize Size in bytes of the file about to be received from the client, kOCTToxFileSizeUnknown if unknown or streaming.
 * @param fileName The name of the file.
 */
- (void)tox:(OCTTox *)tox fileReceiveForFileNumber:(OCTToxFileNumber)fileNumber
                                      friendNumber:(OCTToxFriendNumber)friendNumber
                                              kind:(OCTToxFileKind)kind
                                          fileSize:(OCTToxFileSize)fileSize
                                          fileName:(NSString *)fileName;

/**
 * This method is first called when a file transfer request is received, and
 * subsequently when a chunk of file data for an accepted request was received.
 *
 * When chunk is nil, the transfer is finished and the client should release the
 * resources it acquired for the transfer. After a call with chunk = nil, the
 * file number can be reused for new file transfers.
 *
 * If position is equal to fileSize (received in the fileReceive callback)
 * when the transfer finishes, the file was received completely. Otherwise, if
 * fileSize was kOCTToxFileSizeUnknown, streaming ended successfully when chunk is nil.
 *
 * @param chunk A data containing the received chunk.
 * @param fileNumber The friend-specific file number the data received is associated with.
 * @param friendNumber The friend number of the friend who is sending the file.
 * @param position The file position of the first byte in data.
 */
- (void)tox:(OCTTox *)tox fileReceiveChunk:(NSData *)chunk
                                fileNumber:(OCTToxFileNumber)fileNumber
                              friendNumber:(OCTToxFriendNumber)friendNumber
                                  position:(OCTToxFileSize)position;

@end
