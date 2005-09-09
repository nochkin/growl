//
//  GrowlUDPPathway.m
//  Growl
//
//  Created by Ingmar Stein on 18.11.04.
//  Copyright 2004-2005 The Growl Project. All rights reserved.
//
// This file is under the BSD License, refer to License.txt for details

#import "GrowlUDPPathway.h"
#import "NSStringAdditions.h"
#import "NSDictionaryAdditions.h"
#import "GrowlDefinesInternal.h"
#import "GrowlDefines.h"
#import "GrowlPreferencesController.h"
#include "GrowlUDPUtils.h"
#include "sha2.h"
#include "cdsa.h"
#include <netinet/in.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>

#define keychainServiceName "Growl"
#define keychainAccountName "Growl"

static Boolean authenticateWithCSSM(const CSSM_DATA_PTR packet, CSSM_ALGORITHMS digestAlg, unsigned digestLength, const CSSM_DATA_PTR password) {
	unsigned       messageLength;
	CSSM_DATA      digestData;
	CSSM_RETURN    crtn;
	CSSM_CC_HANDLE ccHandle;
	CSSM_DATA      inData;

	crtn = CSSM_CSP_CreateDigestContext(cspHandle, digestAlg, &ccHandle);
	if (crtn)
		return false;

	crtn = CSSM_DigestDataInit(ccHandle);
	if (crtn) {
		CSSM_DeleteContext(ccHandle);
		return false;
	}

	messageLength = packet->Length - digestLength;
	inData.Data = (uint8 *)packet->Data;
	inData.Length = messageLength;
	crtn = CSSM_DigestDataUpdate(ccHandle, &inData, 1U);
	if (crtn) {
		CSSM_DeleteContext(ccHandle);
		return false;
	}

	if (password && password->Length) {
		crtn = CSSM_DigestDataUpdate(ccHandle, password, 1U);
		if (crtn) {
			CSSM_DeleteContext(ccHandle);
			return false;
		}
	}

	digestData.Data = NULL;
	digestData.Length = 0U;
	crtn = CSSM_DigestDataFinal(ccHandle, &digestData);
	CSSM_DeleteContext(ccHandle);
	if (crtn)
		return false;

	Boolean authenticated;
	if (digestData.Length != digestLength) {
		NSLog(@"GrowlUDPPathway: digestData.Length != digestLength (%u != %u)", digestData.Length, digestLength);
		authenticated = false;
	} else {
		authenticated = !memcmp(digestData.Data, packet->Data+messageLength, digestData.Length);
	}
	free(digestData.Data);

	return authenticated;
}

static Boolean authenticatePacket(const CSSM_DATA_PTR packet, const CSSM_DATA_PTR password, enum GrowlAuthenticationMethod authMethod) {
	switch (authMethod) {
		default:
		case GROWL_AUTH_MD5:
			return authenticateWithCSSM(packet,
										CSSM_ALGID_MD5,
										MD5_DIGEST_LENGTH,
										password);
		case GROWL_AUTH_SHA256: {
#if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_4
			// CSSM_ALGID_SHA256 is only available on Mac OS X >= 10.4
			return authenticateWithCSSM(packet,
										CSSM_ALGID_SHA256,
										SHA256_DIGEST_LENGTH,
										password);
#else
			unsigned messageLength;
			SHA_CTX ctx;
			unsigned char digest[SHA256_DIGEST_LENGTH];

			messageLength = packet->Length-sizeof(digest);
			SHA256_Init(&ctx);
			SHA256_Update(&ctx, packet->Data, messageLength);
			if (password && password->Length)
				SHA256_Update(&ctx, password->Data, password->Length);
			SHA256_Final(digest, &ctx);

			return !memcmp(digest, packet->Data+messageLength, sizeof(digest));
#endif
		}
		case GROWL_AUTH_NONE:
			return !password->Length;
	}
}

static void socketCallBack(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *d, void *info) {
#pragma unused(s,type)
	char *notificationName;
	char *title;
	char *description;
	char *applicationName;
	char *notification;
	unsigned notificationNameLen, titleLen, descriptionLen, priority, applicationNameLen;
	unsigned length, num, i, size, packetSize, notificationIndex;
	unsigned digestLength;
	BOOL isSticky;
	enum GrowlAuthenticationMethod authMethod;
	CSSM_DATA packetData;
	CSSM_DATA passwordData;
	CFDataRef data = (CFDataRef)d;

//	NSLog(@"Received UDP packet from %@", [NSString stringWithAddressData:address]);

	length = CFDataGetLength(data);
	if (length >= sizeof(struct GrowlNetworkPacket)) {
		struct GrowlNetworkPacket *packet = (struct GrowlNetworkPacket *)CFDataGetBytePtr(data);
		packetData.Data = (uint8 *)packet;
		packetData.Length = length;

		if (packet->version == GROWL_PROTOCOL_VERSION || packet->version == GROWL_PROTOCOL_VERSION_AES128) {
			unsigned char *password;
			OSStatus status;
			UInt32 passwordLength = 0U;

			status = SecKeychainFindGenericPassword(/*keychainOrArray*/ NULL,
													strlen(keychainServiceName), keychainServiceName,
													strlen(keychainAccountName), keychainAccountName,
													&passwordLength, (void **)&password, NULL);

			if (status == noErr) {
				passwordData.Data = password;
				passwordData.Length = passwordLength;
			} else if (status != errSecItemNotFound) {
				NSLog(@"Failed to retrieve password from keychain. Error: %d", status);
				passwordData.Data = NULL;
				passwordData.Length = 0U;
			}

			if (packet->version == GROWL_PROTOCOL_VERSION_AES128) {
				GrowlUDPUtils_cryptPacket(&packetData,
										  CSSM_ALGID_AES,
										  &passwordData,
										  NO);
				length = packetData.Length;
			}
			switch (packet->type) {
				case GROWL_TYPE_REGISTRATION:
				case GROWL_TYPE_REGISTRATION_SHA256:
				case GROWL_TYPE_REGISTRATION_NOAUTH:
					if (length >= sizeof(struct GrowlNetworkRegistration)) {
						BOOL enabled = [[GrowlPreferencesController sharedController] boolForKey:GrowlRemoteRegistrationKey];

						if (enabled) {
							BOOL valid = YES;
							struct GrowlNetworkRegistration *nr = (struct GrowlNetworkRegistration *)packet;
							applicationName = (char *)nr->data;
							applicationNameLen = ntohs(nr->appNameLen);

							// check packet size
							switch (packet->type) {
								default:
								case GROWL_TYPE_REGISTRATION:
									authMethod = GROWL_AUTH_MD5;
									digestLength = MD5_DIGEST_LENGTH;
									break;
								case GROWL_TYPE_REGISTRATION_SHA256:
									authMethod = GROWL_AUTH_SHA256;
									digestLength = SHA256_DIGEST_LENGTH;
									break;
								case GROWL_TYPE_REGISTRATION_NOAUTH:
									authMethod = GROWL_AUTH_NONE;
									digestLength = 0U;
									break;
							}
							packetSize = sizeof(*nr) + nr->numDefaultNotifications + applicationNameLen + digestLength;
							if (packetSize > length) {
								valid = NO;
							} else {
								num = nr->numAllNotifications;
								notification = applicationName + applicationNameLen;
								for (i = 0U; i < num; ++i) {
									if (packetSize >= length) {
										valid = NO;
										break;
									}
									size = ntohs(*(unsigned short *)notification) + sizeof(unsigned short);
									notification += size;
									packetSize += size;
								}
								if (packetSize != length)
									valid = NO;
							}

							if (valid) {
								// all notifications
								num = nr->numAllNotifications;
								notification = applicationName + applicationNameLen;
								NSMutableArray *allNotifications = [[NSMutableArray alloc] initWithCapacity:num];
								for (i = 0U; i < num; ++i) {
									size = ntohs(*(unsigned short *)notification);
									notification += sizeof(unsigned short);
									NSString *n = [[NSString alloc] initWithUTF8String:notification length:size];
									[allNotifications addObject:n];
									[n release];
									notification += size;
								}

								// default notifications
								num = nr->numDefaultNotifications;
								NSMutableArray *defaultNotifications = [[NSMutableArray alloc] initWithCapacity:num];
								for (i = 0U; i < num; ++i) {
									notificationIndex = *notification++;
									if (notificationIndex < nr->numAllNotifications)
										[defaultNotifications addObject:[allNotifications objectAtIndex: notificationIndex]];
									else
										NSLog(@"GrowlUDPPathway: Bad notification index: %u", notificationIndex);
								}

								if (authenticatePacket(&packetData, &passwordData, authMethod)) {
									NSString *appName = [[NSString alloc] initWithUTF8String:applicationName length:applicationNameLen];
									NSDictionary *registerInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
										appName,              GROWL_APP_NAME,
										allNotifications,     GROWL_NOTIFICATIONS_ALL,
										defaultNotifications, GROWL_NOTIFICATIONS_DEFAULT,
										address,              GROWL_REMOTE_ADDRESS,
										nil];
									[appName release];
									[(GrowlUDPPathway *)info registerApplicationWithDictionary:registerInfo];
									[registerInfo release];
								} else
									NSLog(@"GrowlUDPPathway: authentication failed.");

								[allNotifications     release];
								[defaultNotifications release];
							} else
								NSLog(@"GrowlUDPPathway: received invalid registration packet.");
						}
					} else
						NSLog(@"GrowlUDPPathway: received runt registration packet.");
					break;
				case GROWL_TYPE_NOTIFICATION:
				case GROWL_TYPE_NOTIFICATION_SHA256:
				case GROWL_TYPE_NOTIFICATION_NOAUTH:
					if (length >= sizeof(struct GrowlNetworkNotification)) {
						struct GrowlNetworkNotification *nn = (struct GrowlNetworkNotification *)packet;

						priority = nn->flags.priority;
						isSticky = nn->flags.sticky;
						notificationName = (char *)nn->data;
						notificationNameLen = ntohs(nn->nameLen);
						title = notificationName + notificationNameLen;
						titleLen = ntohs(nn->titleLen);
						description = title + titleLen;
						descriptionLen = ntohs(nn->descriptionLen);
						applicationName = description + descriptionLen;
						applicationNameLen = ntohs(nn->appNameLen);
						switch (packet->type) {
							default:
							case GROWL_TYPE_NOTIFICATION:
								authMethod = GROWL_AUTH_MD5;
								digestLength = MD5_DIGEST_LENGTH;
								break;
							case GROWL_TYPE_NOTIFICATION_SHA256:
								authMethod = GROWL_AUTH_SHA256;
								digestLength = SHA256_DIGEST_LENGTH;
								break;
							case GROWL_TYPE_NOTIFICATION_NOAUTH:
								authMethod = GROWL_AUTH_NONE;
								digestLength = 0U;
								break;
						}
						packetSize = sizeof(*nn) + notificationNameLen + titleLen + descriptionLen + applicationNameLen + digestLength;

						if (length == packetSize) {
							if (authenticatePacket(&packetData, &passwordData, authMethod)) {
								NSString *growlNotificationName = [[NSString alloc] initWithUTF8String:notificationName length:notificationNameLen];
								NSString *growlAppName = [[NSString alloc] initWithUTF8String:applicationName length:applicationNameLen];
								NSString *growlNotificationTitle = [[NSString alloc] initWithUTF8String:title length:titleLen];
								NSString *growlNotificationDesc = [[NSString alloc] initWithUTF8String:description length:descriptionLen];
								NSNumber *growlNotificationPriority = [[NSNumber alloc] initWithInt:priority];
								NSNumber *growlNotificationSticky = [[NSNumber alloc] initWithBool:isSticky];
								NSImage *growlNotificationIcon = [(GrowlUDPPathway *)info notificationIcon];
								NSDictionary *notificationInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
									growlNotificationName,     GROWL_NOTIFICATION_NAME,
									growlAppName,              GROWL_APP_NAME,
									growlNotificationTitle,    GROWL_NOTIFICATION_TITLE,
									growlNotificationDesc,     GROWL_NOTIFICATION_DESCRIPTION,
									growlNotificationPriority, GROWL_NOTIFICATION_PRIORITY,
									growlNotificationSticky,   GROWL_NOTIFICATION_STICKY,
									growlNotificationIcon,     GROWL_NOTIFICATION_ICON,
									address,                   GROWL_REMOTE_ADDRESS,
									nil];
								[growlNotificationName     release];
								[growlAppName              release];
								[growlNotificationTitle    release];
								[growlNotificationDesc     release];
								[growlNotificationPriority release];
								[growlNotificationSticky   release];
								[(GrowlUDPPathway *)info postNotificationWithDictionary:notificationInfo];
								[notificationInfo release];
							} else
								NSLog(@"GrowlUDPPathway: authentication failed.");
						} else
							NSLog(@"GrowlUDPPathway: received invalid notification packet.");
					} else
						NSLog(@"GrowlUDPPathway: received runt notification packet.");
					break;
				default:
					NSLog(@"GrowlUDPPathway: received packet of invalid type.");
					break;
			}
			if (password)
				SecKeychainItemFreeContent(/*attrList*/ NULL, password);
		} else
			NSLog(@"GrowlUDPPathway: unknown version %u, expected %d or %d", packet->version, GROWL_PROTOCOL_VERSION, GROWL_PROTOCOL_VERSION_AES128);
	} else
		NSLog(@"GrowlUDPPathway: received runt packet.");
}

#pragma mark -

@implementation GrowlUDPPathway

- (id) init {
	if ((self = [super init])) {
		struct sockaddr_in6 addr;
		short port;
		int native;

		port = [[GrowlPreferencesController sharedController] integerForKey:GrowlUDPPortKey];

		addr.sin6_len = sizeof(addr);
		addr.sin6_family = AF_INET6;
		addr.sin6_port = htons(port);
		addr.sin6_flowinfo = 0U;
		addr.sin6_addr = in6addr_any;
		addr.sin6_scope_id = 0U;

		native = socket(AF_INET6, SOCK_DGRAM, IPPROTO_UDP);

		if (native == -1) {
			NSLog(@"GrowlUDPPathway: could not create socket.");
			[self release];
			return nil;
		}

		if (bind(native, (struct sockaddr *)&addr, sizeof(addr)) == -1) {
			NSLog(@"GrowlUDPPathway: could not bind socket.");
			close(native);
			[self release];
			return nil;
		}

		// create CFSocket
		CFSocketContext context = { 0, self, NULL, NULL, NULL };
		cfSocket = CFSocketCreateWithNative(kCFAllocatorDefault,
											native,
											kCFSocketDataCallBack,
											socketCallBack,
											&context);
		if (!cfSocket) {
			close(native);
			[self release];
			return nil;
		}

		// add to run loop
		CFRunLoopSourceRef source = CFSocketCreateRunLoopSource(kCFAllocatorDefault,
																cfSocket,
																0);
		if (!source) {
			[self release];
			return nil;
		}
		CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
		CFRelease(source);

		notificationIcon = [[NSImage alloc] initWithContentsOfFile:
			@"/System/Library/CoreServices/SystemIcons.bundle/Contents/Resources/GenericNetworkIcon.icns"];
		// the icon has moved on 10.4
		if (!notificationIcon)
			notificationIcon = [[NSImage alloc] initWithContentsOfFile:
				@"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericNetworkIcon.icns"];
	}

	return self;
}

- (void) dealloc {
	if (cfSocket) {
		CFSocketInvalidate(cfSocket);	// also invalidates the runloop source
		CFRelease(cfSocket);
	}
	[notificationIcon release];

	[super dealloc];
}

- (NSImage *) notificationIcon {
	return notificationIcon;
}

@end
