//
//  GrowlBezelPrefs.h
//  Display Plugins
//
//  Created by Jorge Salvador Caffarena on 14/09/04.
//  Copyright 2004 Jorge Salvador Caffarena. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>

#define BezelPrefDomain				@"com.Growl.Bezel"

#define BEZEL_POSITION_PREF			@"Bezel - Position"
#define BEZEL_SIZE_PREF				@"Bezel - Size"
#define BEZEL_OPACITY_PREF			@"Bezel - Opacity"
#define BEZEL_DURATION_PREF			@"Bezel - Duration"

#define BEZEL_POSITION_DEFAULT		0
#define BEZEL_POSITION_TOPRIGHT		1
#define BEZEL_POSITION_BOTTOMRIGHT	2
#define BEZEL_POSITION_BOTTOMLEFT	3
#define BEZEL_POSITION_TOPLEFT		4

#define BEZEL_SIZE_NORMAL			0
#define BEZEL_SIZE_SMALL			1

@interface GrowlBezelPrefs : NSPreferencePane {
	IBOutlet NSButton		*radio_PositionD;
	IBOutlet NSButton		*radio_PositionTR;
	IBOutlet NSButton		*radio_PositionBR;
	IBOutlet NSButton		*radio_PositionBL;
	IBOutlet NSButton		*radio_PositionTL;
	IBOutlet NSMatrix		*radio_Size;
	IBOutlet NSSlider		*slider_Opacity;
	IBOutlet NSTextField	*text_Opacity;
	IBOutlet NSSlider		*slider_Duration;
	IBOutlet NSTextField	*text_Duration;
}

- (IBAction) preferenceChanged:(id)sender;

@end
