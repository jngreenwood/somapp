//
//  MNSequencePitch.h
//  NotationTest
//
//  Created by Michael Norris on Sun Jun 15 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MNSequencePitch : NSObject {
    int	pitch;
    int chromaticAlteration;
}
- (id)initWithPitch:(int)p chromaticAlteration:(int)c;
- (int)pitch;
- (int)chromaticAlteration;
- (void)setPitch:(int)p;
- (void)setChromaticAlteration:(int)c;
- (MNSequencePitch *)copyWithZone:(NSZone *)zone;
@end
