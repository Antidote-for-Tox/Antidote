//
//  OCTSubmanagerUser.h
//  objcTox
//
//  Created by Dmytro Vorobiov on 16.05.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCTToxConstants.h"

@interface OCTSubmanagerUser : NSObject

/**
 * Client's address.
 *
 * Address for Tox as a hex string. Address is kOCTToxAddressLength length and has following format:
 * [publicKey (32 bytes, 64 characters)][nospam number (4 bytes, 8 characters)][checksum (2 bytes, 4 characters)]
 */
@property (strong, nonatomic, readonly) NSString *userAddress;

/**
 * Client's Tox Public Key (long term public key) of kOCTToxPublicKeyLength.
 */
@property (strong, nonatomic, readonly) NSString *publicKey;

/**
 * Client's nospam part of the address. Any 32 bit unsigned integer.
 */
@property (assign, nonatomic) OCTToxNoSpam nospam;

/**
 * Client's user status.
 */
@property (assign, nonatomic) OCTToxUserStatus userStatus;

/**
 * Set the nickname for the client.
 *
 * @param name Name to be set. Minimum length of name is 1 byte.
 * @param error If an error occurs, this pointer is set to an actual error object containing the error information.
 * See OCTToxErrorSetInfoCode for all error codes.
 *
 * @return YES on success, NO on failure.
 */
- (BOOL)setUserName:(NSString *)name error:(NSError **)error;

/**
 * Get client's nickname.
 *
 * @return Client's nickname or nil in case of error.
 */
- (NSString *)userName;

/**
 * Set client's status message.
 *
 * @param statusMessage Status message to be set.
 * @param error If an error occurs, this pointer is set to an actual error object containing the error information.
 * See OCTToxErrorSetInfoCode for all error codes.
 *
 * @return YES on success, NO on failure.
 */
- (BOOL)setUserStatusMessage:(NSString *)statusMessage error:(NSError **)error;

/**
 * Get client's status message.
 *
 * @return Client's status message.
 */
- (NSString *)userStatusMessage;

@end
