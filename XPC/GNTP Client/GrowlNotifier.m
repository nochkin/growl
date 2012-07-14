//
//  GrowlNotifier.m
//  Growl
//
//  Created by Daniel Siemer on 9/15/11.
//  Copyright 2011 The Growl Project. All rights reserved.
//

#import "GrowlNotifier.h"
#import "GrowlDefines.h"
#import "GrowlGNTPCommunicationAttempt.h"
#import "GrowlGNTPRegistrationAttempt.h"
#import "GrowlGNTPNotificationAttempt.h"
#import "GrowlGNTPSubscriptionAttempt.h"

#import "NSObject+XPCHelpers.h"

@implementation GrowlNotifier

@synthesize currentAttempts;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.currentAttempts = [NSMutableArray array];
    }
    
    return self;
}

- (void)dealloc
{
    [currentAttempts release];
    currentAttempts = nil;
    [super dealloc];
}

- (void) sendCommunicationAttempt:(GrowlCommunicationAttempt *)attempt 
{
    [currentAttempts addObject:attempt];
    [attempt begin];
}

-(void)sendXPCMessage:(id)nsMessage connection:(xpc_connection_t)connection
{
    xpc_object_t message = [(NSObject*)nsMessage newXPCObject];
    xpc_connection_send_message(connection, message);
    xpc_release(message);
}

- (void) sendXPCFeedback:(GrowlCommunicationAttempt *)attempt context:(id)context clicked:(BOOL)clicked
{
    NSMutableDictionary *response = [NSMutableDictionary dictionary];
    [response setValue:@"feedback" forKey:@"GrowlActionType"];
    
    [response setValue:context forKey:@"Context"];
    [response setValue:[NSNumber numberWithBool:clicked] forKey:@"Clicked"];
    [self sendXPCMessage:response connection:[(GrowlGNTPCommunicationAttempt*)attempt connection]];
}

-(NSString*)actionTypeForAttempt:(GrowlCommunicationAttempt*)attempt{
	NSString *result = nil;
	if([attempt isKindOfClass:[GrowlGNTPRegistrationAttempt class]]){
		result = @"registration";
	}else if([attempt isKindOfClass:[GrowlGNTPNotificationAttempt class]]){
		result = @"notification";
	}else if([attempt isKindOfClass:[GrowlGNTPSubscriptionAttempt class]]){
		result = @"subscribe";
	}else {
		result = @"unknown";
	}
	return nil;
}

- (void) attemptDidSucceed:(GrowlCommunicationAttempt *)attempt{
	NSMutableDictionary *response = [NSMutableDictionary dictionary];
	[response setValue:[NSNumber numberWithBool:YES] forKey:@"Success"];
	
	[response setObject:[self actionTypeForAttempt:attempt] forKey:@"GrowlActionType"];
	
	if([attempt isKindOfClass:[GrowlGNTPSubscriptionAttempt class]]){
		//Get the info we need
	}
	
	[self sendXPCMessage:response connection:[(GrowlGNTPCommunicationAttempt*)attempt connection]];
}
- (void) attemptDidFail:(GrowlCommunicationAttempt *)attempt{
	__block NSMutableDictionary *response = [NSMutableDictionary dictionary];
	[response setValue:[NSNumber numberWithBool:NO] forKey:@"Success"];
	[response setObject:[self actionTypeForAttempt:attempt] forKey:@"GrowlActionType"];
	
	[[(GrowlGNTPCommunicationAttempt*)attempt callbackHeaderItems] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		if([key isEqualToString:@"Error-Code"])
			[response setValue:obj forKey:key];
		if([key isEqualToString:@"Error-Description"])
			[response setValue:obj forKey:key];
	}];
	
	[self sendXPCMessage:response connection:[(GrowlGNTPCommunicationAttempt*)attempt connection]];
	
	[currentAttempts removeObject:attempt];
}
- (void) finishedWithAttempt:(GrowlCommunicationAttempt *)attempt{
    NSDictionary *response = [NSDictionary dictionaryWithObject:@"finishedAttempt" forKey:@"GrowlActionType"];
    
    [self sendXPCMessage:response connection:[(GrowlGNTPCommunicationAttempt*)attempt connection]];
    [currentAttempts removeObject:attempt];
}
- (void) queueAndReregister:(GrowlCommunicationAttempt *)attempt{
    //we will have to ask our host app for the reg dict again via XPC
    NSMutableDictionary *response = [NSMutableDictionary dictionary];
    [response setValue:@"reregister" forKey:@"GrowlActionType"];
    
    [self sendXPCMessage:response connection:[(GrowlGNTPCommunicationAttempt*)attempt connection]];
}
- (void) notificationClicked:(GrowlCommunicationAttempt *)attempt context:(id)context{
    [self sendXPCFeedback:attempt context:context clicked:YES];
}
- (void) notificationTimedOut:(GrowlCommunicationAttempt *)attempt context:(id)context{
    [self sendXPCFeedback:attempt context:context clicked:NO];
}

- (void)stoppedAttempts:(GrowlCommunicationAttempt *)attempt{
    NSDictionary *response = [NSDictionary dictionaryWithObject:@"stoppedAttempts" forKey:@"GrowlActionType"];
    
    [self sendXPCMessage:response connection:[(GrowlGNTPCommunicationAttempt*)attempt connection]];
}
@end
