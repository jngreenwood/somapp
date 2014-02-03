//
//  AppDelegate.m
//  testing
//
//  Created by Michael Norris on 10/01/14.
//  Copyright (c) 2014 Michael Norris. All rights reserved.
//

#import "AppDelegate.h"
#import "MNBaseSequence.h"
#import "MNCommonFunctions.h"
#import "MNTimeSignature.h"
#import "MNKeySignature.h"
#import "MNMusicTrack.h"
#import "MNMusicPlayer.h"
#import "MNRandomSequenceGenerator.h"
#import "MNMusicSequence.h"

MNMusicPlayer				*gPlayer;
MNMusicSequence				*gQuestionSequence,*gQuestion2Sequence;
extern AUNode               gPercussionNode;
NSString					*gChosenSetTag,*gChosenCourseTag;
AUGraph                     gAUGraph;
AUNode                      gPianoNode,gPercussionNode,gOutputNode,gMixerNode,gReverbNode,gConverterNode;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    // ** The following code covers all the setup for initialization in EarConditioner ** //
    
    // ** Read in typical rhythmic patterns from XML file ** //
    [MNRandomSequenceGenerator loadInRhythms];
    
    // ** Set up and initialize the piano sound playback ** //
    [self setUpPlayback];
    
    // ** Seed random number generator, so you don't get the same random melody on launch! ** //
    srandom(time(NULL));
    
    // ** Initialize some global variables ** //
    gPlayer = [[MNMusicPlayer alloc] init];
    gQuestionSequence = [[MNMusicSequence alloc] initWithTempo:kBaseTempo];
    gQuestion2Sequence = [[MNMusicSequence alloc] initWithTempo:kBaseTempo];
    [gPlayer setSequence:gQuestionSequence];
    
    // ** Not sure if this is needed for iOS, but it was on OS X ** //
	[gPlayer start];
	[gPlayer stop];
    

    
    return YES;
}


- (void)setUpPlayback {
    // ** This code sets up all the CoreAudio devices for playing back MIDI ** //
    // ** It uses an .sf2 file - some good free ones available from http://hammersound.com ** //
    
    OSStatus result = noErr;
    AudioComponentDescription cd = {};
    cd.componentManufacturer     = kAudioUnitManufacturer_Apple;
    
    // Instantiate an audio processing graph
    result = NewAUGraph (&gAUGraph);
    if (result != noErr) {
        NSLog(@"Unable to create AUGraph");
        return;
    }
    
    // SAMPLER UNIT
    //Specify the Sampler unit, to be used as the first node of the graph
    cd.componentType = kAudioUnitType_MusicDevice;
    cd.componentSubType = kAudioUnitSubType_Sampler;
    
    // Create a new sampler note
    result = AUGraphAddNode (gAUGraph, &cd, &gPianoNode);
    if (result != noErr) {
        NSLog(@"Unable to add sample node");
        return;
    }
    
    result = AUGraphAddNode (gAUGraph, &cd, &gPercussionNode);
    if (result != noErr) {
        NSLog(@"Unable to add percussion node");
        return;
    }
    
    cd.componentType = kAudioUnitType_Output;
    cd.componentSubType = kAudioUnitSubType_RemoteIO;
    
    // Add the Output unit node to the graph
    result = AUGraphAddNode (gAUGraph, &cd, &gOutputNode);
    if (result != noErr) {
        NSLog(@"Unable to add output node");
        return;
    }
    
    // Add some rever!
    cd.componentType = kAudioUnitType_Effect;
    cd.componentSubType = kAudioUnitSubType_Reverb2;
    result = AUGraphAddNode (gAUGraph, &cd, &gReverbNode);
    if (result != noErr) {
        NSLog(@"Unable to add output node");
        return;
    }
    
    
    cd.componentType = kAudioUnitType_Mixer;
    cd.componentSubType = kAudioUnitSubType_MultiChannelMixer;
    // Add the mixer unit node to the graph
    result = AUGraphAddNode (gAUGraph, &cd, &gMixerNode);
    if (result != noErr) {
        NSLog(@"Unable to add output node");
        return;
    }
    
    cd.componentType          = kAudioUnitType_FormatConverter;
    cd.componentSubType       = kAudioUnitSubType_AUConverter;
    result = AUGraphAddNode (gAUGraph, &cd, &gConverterNode);
    if (result != noErr) {
        NSLog(@"Unable to add converter node");
        return;
    }
    
    
    result = AUGraphOpen (gAUGraph);
    if (result != noErr) {
        NSLog(@"Couldn't open AU Graph");
        return;
    }
    
    
    AudioUnit _samplerUnit,_percussionUnit,_mixerUnit,_ioUnit, _reverbUnit, _converterUnit;
    
    result = AUGraphNodeInfo (gAUGraph, gPianoNode, 0, &_samplerUnit);
    if (result != noErr) {
        NSLog(@"Couldn't get AUGraphNodeInfo for sampler");
        return;
    }
    
    result = AUGraphNodeInfo (gAUGraph, gPercussionNode, 0, &_percussionUnit);
    if (result != noErr) {
        NSLog(@"Couldn't get AUGraphNodeInfo for sampler");
        return;
    }
    
    // Load a soundfont into the sampler unit
    [self loadSoundFont:@"CampbellsPianoBeta2"
              withPatch:1
               withBank:kAUSampler_DefaultMelodicBankMSB
            withSampler:_samplerUnit];
    
    // Load a soundfont into the sampler unit
    [self loadSoundFont:@"r8"
              withPatch:1
               withBank:kAUSampler_DefaultMelodicBankMSB
            withSampler:_percussionUnit];
    
    // Create a new mixer unit. This is necessary because if we want to have more than one
    // sampler outputting throught the speakers
    result = AUGraphNodeInfo (gAUGraph, gMixerNode, 0, &_mixerUnit);
    if (result != noErr) {
        NSLog(@"Couldn't get AUGraphNodeInfo for mixer");
        return;
    }
    
    // Obtain a reference to the I/O unit from its node
    result = AUGraphNodeInfo (gAUGraph, gOutputNode, 0, &_ioUnit);
    if (result != noErr) {
        NSLog(@"Couldn't get AUGraphNodeInfo for output");
        return;
    }
    
    // Obtain a reference to the I/O unit from its node
    result = AUGraphNodeInfo (gAUGraph, gConverterNode, 0, &_converterUnit);
    if (result != noErr) {
        NSLog(@"Couldn't get AUGraphNodeInfo for output");
        return;
    }
    
    // Obtain a reference to the I/O unit from its node
    result = AUGraphNodeInfo (gAUGraph, gReverbNode, 0, &_reverbUnit);
    if (result != noErr) {
        NSLog(@"Couldn't get AUGraphNodeInfo for output");
        return;
    }
    
    // Define the number of input busses on the mixer unit
    UInt32 busCount   = 2;
    
    // Set the input channels property on the mixer unit
    result = AudioUnitSetProperty (
                                   _mixerUnit,
                                   kAudioUnitProperty_ElementCount,
                                   kAudioUnitScope_Input,
                                   0,
                                   &busCount,
                                   sizeof (busCount)
                                   );
    if (result != noErr) {
        NSLog(@"Couldn't get set buscount property of mixer");
        return;
    }
    
    
    AudioStreamBasicDescription streamFormat;
    UInt32 streamFormatSize = sizeof(streamFormat);
    result = AudioUnitGetProperty(_mixerUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &streamFormat, &streamFormatSize);
    if (result != noErr) {
        NSLog(@"error 1");
    }
    
    result = AudioUnitSetProperty(_converterUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &streamFormat, streamFormatSize);
    if (result != noErr) {
        NSLog(@"error 1");
    }
    
    result = AudioUnitGetProperty(_reverbUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &streamFormat, &streamFormatSize);
    if (result != noErr) {
        NSLog(@"error 1");
    }
    
    result = AudioUnitSetProperty(_converterUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &streamFormat, streamFormatSize);
    if (result != noErr) {
        NSLog(@"error 1");
    }

    
    // Connect the sampler unit to the mixer unit
    result = AUGraphConnectNodeInput(gAUGraph, gPianoNode, 0, gMixerNode, 0);
    if (result != noErr) {
        NSLog(@"Couldn't connect sampler to reverb");
        return;
    }
    
    // Connect the sampler unit to the mixer unit
    result = AUGraphConnectNodeInput(gAUGraph, gPercussionNode, 0, gMixerNode, 1);
    if (result != noErr) {
        NSLog(@"Couldn't connect sampler to reverb");
        return;
    }
    
    // Connect the sampler unit to the mixer unit
    result = AUGraphConnectNodeInput(gAUGraph, gMixerNode, 0, gConverterNode, 0);
    if (result != noErr) {
        NSLog(@"Couldn't connect reverb to mixer");
        return;
    }
    
    // Connect the sampler unit to the mixer unit
    result = AUGraphConnectNodeInput(gAUGraph, gConverterNode, 0, gReverbNode, 0);
    if (result != noErr) {
        NSLog(@"Couldn't connect reverb to mixer");
        return;
    }
    
     // Set the volume of the channel
     AudioUnitSetParameter(_mixerUnit, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, 0, 1, 0);
     
     // Set reverb time
     AUGraphNodeInfo(gAUGraph, gReverbNode, NULL, &_reverbUnit);
     // set the decay time at 0 Hz to 5 seconds
     AudioUnitSetParameter(_reverbUnit, kAudioUnitScope_Global, 0, kReverb2Param_DryWetMix, 60., 0);
     // set the decay time at 0 Hz to 5 seconds
     AudioUnitSetParameter(_reverbUnit, kAudioUnitScope_Global, 0, kReverb2Param_DecayTimeAt0Hz, 20., 0);
     // set the decay time at Nyquist to 2.5 seconds
     AudioUnitSetParameter(_reverbUnit, kAudioUnitScope_Global, 0, kReverb2Param_DecayTimeAtNyquist, 20., 0);
    AudioUnitSetParameter(_reverbUnit, kAudioUnitScope_Global, 0, kReverb2Param_RandomizeReflections, 1000., 0);
    AudioUnitSetParameter(_reverbUnit, kAudioUnitScope_Global, 0, kReverb2Param_Gain, 10., 0);
    AudioUnitSetParameter(_reverbUnit, kAudioUnitScope_Global, 0, kReverb2Param_MinDelayTime, 0.05, 0);
    AudioUnitSetParameter(_reverbUnit, kAudioUnitScope_Global, 0, kReverb2Param_MaxDelayTime, 0.2, 0);
    
     
     // Connect the output of the mixer node to the input of he io node
     result = AUGraphConnectNodeInput (gAUGraph, gReverbNode, 0, gOutputNode, 0);
     if (result != noErr) {
     NSLog(@"Couldn't connect mixer to output");
     return;
     }
    
    
    
    // Start the graph
    result = AUGraphInitialize (gAUGraph);
    if (result != noErr) {
        NSLog(@"Couldn't initialize AU graph");
        return;
    }
    
    // Start the graph
    result = AUGraphStart (gAUGraph);
    if (result != noErr) {
        NSLog(@"Couldn't start AU graph");
        return;
    }
    
}

-(void) loadSoundFont: (NSString*) path withPatch: (int) patch withBank: (UInt8) bank withSampler: (AudioUnit) sampler {
    
    NSBundle *b = [NSBundle mainBundle];
    NSString *fullPath = [b pathForResource:path ofType:@"sf2"];
    NSURL *presetURL = [[NSURL alloc] initFileURLWithPath:fullPath];
    [self loadFromDLSOrSoundFont: (NSURL *)presetURL withBank: bank withPatch: patch  withSampler:sampler];
    [presetURL relativePath];
}

// Load a SoundFont into a sampler
-(OSStatus) loadFromDLSOrSoundFont: (NSURL *)bankURL withBank: (UInt8) bank withPatch: (int)presetNumber withSampler: (AudioUnit) sampler {
    OSStatus result = noErr;
    
    // fill out a bank preset data structure
    AUSamplerBankPresetData bpdata;
    bpdata.bankURL  = (CFURLRef) CFBridgingRetain(bankURL);
    bpdata.bankMSB  = bank;
    bpdata.bankLSB  = kAUSampler_DefaultBankLSB;
    bpdata.presetID = (UInt8) presetNumber;
    
    // set the kAUSamplerProperty_LoadPresetFromBank property
    result = AudioUnitSetProperty(sampler,
                                  kAUSamplerProperty_LoadPresetFromBank,
                                  kAudioUnitScope_Global,
                                  0,
                                  &bpdata,
                                  sizeof(bpdata));
    
    // check for errors
    if (result != noErr) {
        NSLog(@"Couldn't set AudioUnitSetProperty to load preset");
    }
    
    return result;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
