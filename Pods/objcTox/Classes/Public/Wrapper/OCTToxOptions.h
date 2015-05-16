//
//  OCTToxOptions.h
//  objcTox
//
//  Created by Dmytro Vorobiov on 02.03.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OCTToxConstants.h"

@interface OCTToxOptions : NSObject <NSCopying>

/**
 * The type of socket to create.
 *
 * If this is set to NO, an IPv4 socket is created, which subsequently
 * only allows IPv4 communication.
 * If it is set to YES, an IPv6 socket is created, allowing both IPv4 and
 * IPv6 communication.
 */
@property (assign, nonatomic) BOOL IPv6Enabled;

/**
 * Enable the use of UDP communication when available.
 *
 * Setting this to false will force Tox to use TCP only. Communications will
 * need to be relayed through a TCP relay node, potentially slowing them down.
 * Disabling UDP support is necessary when using anonymous proxies or Tor.
 */
@property (assign, nonatomic) BOOL UDPEnabled;

/**
 * The start port of the inclusive port range to attempt to use.
 *
 * If both start_port and end_port are 0, the default port range will be
 * used: [33445, 33545].
 *
 * If either start_port or end_port is 0 while the other is non-zero, the
 * non-zero port will be the only port in the range.
 *
 * Having start_port > end_port will yield the same behavior as if start_port
 * and end_port were swapped.
 */
@property (assign, nonatomic) uint16_t startPort;

/**
 * The end port of the inclusive port range to attempt to use.
 */
@property (assign, nonatomic) uint16_t endPort;


@property (assign, nonatomic) OCTToxProxyType proxyType;
/**
 * The IP address or DNS name of the proxy to be used.
 *
 * If used, this must be non-NULL and be a valid DNS name. The name must not exceed 255 characters.
 * The value is ignored if proxyType is OCTToxProxyTypeNone.
 */
@property (strong, nonatomic) NSString *proxyHost;
/**
 * The port to use to connect to the proxy server.
 *
 * Ports must be in the range (1, 65535). The value is ignored if proxyType is OCTToxProxyTypeNone.
 */
@property (assign, nonatomic) uint16_t proxyPort;

@end
