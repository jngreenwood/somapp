//
//  MNSequenceBar.h
//  NotationTest
//
//  Created by Michael Norris on Sun Jun 15 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MNTimeSignature;
@class MNSequenceNote;
@class MNBaseSequence;
//@class MNBar;

@interface MNSequenceBar : NSObject {
    MNBaseSequence	*sequence;
    NSMutableArray	*notes;
    MNTimeSignature	*timeSignature;
}
- (id)initWithTimeSignature:(MNTimeSignature*)timeSig
                   sequence:(MNBaseSequence*)s;
- (MNSequenceNote *)addRestWithDuration:(float)dur;
- (MNSequenceNote *)addNoteWithPitch:(int)pitch chromaticAlteration:(int)acc duration:(float)dur;
- (float)duration;
- (int)countNotes;
- (int)countNotesIgnoringTies;
- (int)countNotesIgnoringTiesAndRests;
- (MNSequenceNote *)noteAtIndex:(int)i;
- (MNSequenceNote *)firstNote;
- (MNSequenceNote *)lastNote;
- (void)setNotes:(NSMutableArray *)notes;
- (NSMutableArray *)notes;
- (MNSequenceBar *)copyWithZone:(NSZone*)theZone;
- (void)deleteNote:(MNSequenceNote*)note;
//- (BOOL)rhythmsEqualTo:(MNBar*)bar;
- (MNSequenceBar *)nextBar;
- (MNSequenceBar *)prevBar;
- (void)removeNoteAtIndex:(int)i;
- (MNSequenceNote *)findNoteAtStartTime:(float)startTime;
- (void)clear;
- (NSArray*)rhythmArray;
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained *)stackbuf count:(NSUInteger)len;
@property (retain) MNTimeSignature *timeSignature;
@property (retain) MNBaseSequence *sequence;
@end
