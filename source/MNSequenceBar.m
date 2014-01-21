//
//  MNSequenceBar.m
//  NotationTest
//
//  Created by Michael Norris on Sun Jun 15 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "MNBaseSequence.h"
#import "MNSequenceBar.h"
#import "MNSequenceNote.h"
#import "MNTimeSignature.h"
//#import "NSMutableArrayAdditions.h"
//#import "MNBar.h"
//#import "MNNote.h"

@implementation MNSequenceBar

- (id)init {
    self = [super init];
    if (self) {
        timeSignature = [[MNTimeSignature alloc] init];
        notes = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithTimeSignature:(MNTimeSignature *)timeSig
               sequence:(MNBaseSequence*)s
{
    self = [super init];
    if (self) {
        timeSignature = timeSig;
        notes = [[NSMutableArray alloc] init];
        sequence = s;
    }
    return self;
}

- (MNSequenceNote *)addRestWithDuration:(float)dur {
    MNSequenceNote	*note;
    note = [[MNSequenceNote alloc] initWithDuration:dur bar:self];
    [notes addObject:note];
    return note;
}    

- (MNSequenceNote *)addNoteWithPitch:(int)pitch chromaticAlteration:(int)acc duration:(float)dur {
    MNSequenceNote	*note = [[MNSequenceNote alloc] initWithPitch:pitch
                              chromaticAlteration:acc
                                         duration:dur
                                              bar:self];
    [notes addObject:note];
    return note;
}

- (float)duration {
    float f=0;
    for (MNSequenceNote *n in notes) f+=[n duration];
    return f;
}

- (int)countNotes {
    return [notes count];
}

- (int)countNotesIgnoringTies {
    int m = [notes count];
    for (MNSequenceNote *note in notes) if ([note tied]) m--;
    return m;
}

- (int)countNotesIgnoringTiesAndRests {
    int m = [notes count];
    for (MNSequenceNote *note in notes) if ([note tied] || [note isARest]) m--;
    return m;
}

- (MNSequenceNote *)noteAtIndex:(int)i { return [notes objectAtIndex:i]; }
- (MNSequenceNote *)firstNote { return [self noteAtIndex:0]; }
- (MNSequenceNote *)lastNote {
    if ([notes count] == 0) {
        NSLog (@"Attempted to get notes when there were none.");
        return nil;
    }
    return [notes lastObject];
}

- (void)setNotes:(NSMutableArray *)n {
    notes = n;
}

- (void)deleteNote:(MNSequenceNote*)note {
    [notes removeObjectIdenticalTo:note];
}

- (NSMutableArray *)notes {
    return notes;
}
- (MNSequenceBar *)copyWithZone:(NSZone *)zone {
    MNSequenceBar	*bar;
    bar = [[MNSequenceBar alloc] init];
    [bar setTimeSignature:[self timeSignature]];
    [bar setNotes:[[NSMutableArray alloc] initWithArray:notes copyItems:YES]];
    // set the bar ivar of the notes to this new bar
    for (MNSequenceNote *note in bar) [note setBar:bar];
    return bar;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained *)stackbuf count:(NSUInteger)len {
    return [notes countByEnumeratingWithState:state objects:stackbuf count:len];
}

- (MNSequenceBar *)copy {
    MNSequenceBar	*bar;
    bar = [[MNSequenceBar alloc] init];
    [bar setTimeSignature:[self timeSignature]];
    [bar setNotes:[[NSMutableArray alloc] initWithArray:notes copyItems:YES]];
    
    return bar;
}

/*- (BOOL)rhythmsEqualTo:(MNBar*)bar {
    int     nNotesMe, nNotesHim, i;
    float   durMe, durHim;
    
    nNotesMe = [notes count];
    nNotesHim = [bar countNotes];
    
    if (nNotesMe != nNotesHim) return NO;
    
    for (i=0; i<nNotesMe; i++) {
        durMe = [(MNSequenceNote*)[notes objectAtIndex:i] duration];
        durHim = [[bar noteAtIndex:i] duration];
        if (durMe != durHim) return NO;
    }
    return YES;
}*/

- (MNSequenceBar *)nextBar {
	NSMutableArray  *bars;
	int				i;
    
	bars = [sequence bars];
	i = [bars indexOfObjectIdenticalTo:self];
    
    if (i<[bars count]-1) return [bars objectAtIndex:i+1];
	
	return nil;
}

- (MNSequenceBar *)prevBar {
	NSMutableArray  *bars;
    int             i;
    
    bars = [sequence bars];
    i = [bars indexOfObjectIdenticalTo:self];
    
    if (i>0) return [bars objectAtIndex:i-1];
    
    return nil;
	
}

- (MNSequenceNote *)findNoteAtStartTime:(float)startTime {
	float			s = 0;
	int				n,i;
	MNSequenceNote	*note;
	
	n = [notes count];
	for (i=0;i<n;i++) {
		note = [notes objectAtIndex:i];
		if (s == startTime) {
			return note;
		}
		s += [note duration];
		while ([note tied] && i<(n-1)) {
			i++;
			note = [notes objectAtIndex:i];
			s += [note duration];
		}
	}
	return nil;
}

- (void)removeNoteAtIndex:(int)i { if (i<[notes count]) [notes removeObjectAtIndex:i]; }

- (void) clear { [notes removeAllObjects]; }

- (NSArray *) rhythmArray {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
    for (MNSequenceNote *note in notes) {
        [array addObject:@([note duration])];
    }
    return array;
}

@synthesize timeSignature,sequence;

@end
