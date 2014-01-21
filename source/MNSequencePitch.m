//
//  MNSequencePitch.m
//  NotationTest
//
//  Created by Michael Norris on Sun Jun 15 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "MNSequencePitch.h"


@implementation MNSequencePitch
- (id)initWithPitch:(int)p chromaticAlteration:(int)c {
    self = [super init];
    if (self) {
        [self setPitch:p];
        [self setChromaticAlteration:c];
    }
    return self;
}

- (int)pitch { return pitch; }
- (int)chromaticAlteration { return chromaticAlteration; }
- (void)setPitch:(int)p { pitch = p; }
- (void)setChromaticAlteration:(int)c { chromaticAlteration = c; }

- (MNSequencePitch *)copyWithZone:(NSZone *)zone {
    MNSequencePitch	*p;

    p = [[MNSequencePitch allocWithZone:zone] initWithPitch:[self pitch] chromaticAlteration:[self chromaticAlteration]];
    return p;
}

@end
