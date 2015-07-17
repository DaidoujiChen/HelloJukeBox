//
//  ViewController.m
//  HelloJukeBox
//
//  Created by Mia Yu on 7/14/15.
//  Copyright (c) 2015 Miao. All rights reserved.
//



#import "ViewController.h"
#import "JukeboxMacro.h"
#import <MediaPlayer/MediaPlayer.h>
#import <objc/runtime.h>

@implementation MPRemoteCommand (daidouji)

- (void)resetTargetInvocations {
    unsigned int ivarCount;
    Ivar *ivars = class_copyIvarList ([ self class ], &ivarCount);
    NSMutableArray *targetInvocations = object_getIvar(self, ivars[2]);
    [ targetInvocations removeAllObjects ];
    free (ivars);
}

@end

@interface ViewController ()

@end

@implementation ViewController {
}


@synthesize player;

- (void)viewDidLoad {
    [ super viewDidLoad ];
    // Do any additional setup after loading the view, typically from a nib.

    NSURL *audioFileLocationURL = [ [ NSBundle mainBundle ] URLForResource:@"audiofile"
                                                             withExtension:@"mp3" ];

    player = [ AVPlayer playerWithURL:audioFileLocationURL ];
}

- (void)viewWillAppear:(BOOL)animated {
    [ super viewWillAppear:animated ];
    NSString *loseControlInstagram = @"https://instagram.com/michaeljackson/";
    NSString *symphonyYoutube = @"https://www.youtube.com/watch?v=UPJ1e1Hc1hw";
    //NOTE use loseControlInstagram to witness chaos in control center..
    NSString *socialUrl = loseControlInstagram;

    NSMutableURLRequest *request = [ [ NSMutableURLRequest alloc ] initWithURL:[ NSURL URLWithString:socialUrl ] ];
    [ _socialWebView loadRequest:request ];

}

- (void)didReceiveMemoryWarning {
    [ super didReceiveMemoryWarning ];
    // Dispose of any resources that can be recreated.

}


- (IBAction)switchChanged:(id)sender {

    NSLog(@" switch is %d",
          [ sender isOn ]);

    [ self playMusic:[ sender isOn ] ];

}

- (void)playMusic:(BOOL)isOn {

    if (isOn) {

        [ player play ];
        MPRemoteCommandCenter *commandCenter = [ MPRemoteCommandCenter sharedCommandCenter ];
        [ commandCenter.playCommand resetTargetInvocations ];
        [ commandCenter.playCommand addTargetWithHandler: ^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *event) {
            [ player play ];
            return MPRemoteCommandHandlerStatusSuccess;
        } ];
        commandCenter.playCommand.enabled = YES;
        
        [ commandCenter.pauseCommand resetTargetInvocations ];
        [ commandCenter.pauseCommand addTargetWithHandler: ^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *event) {
            [ player pause ];
            return MPRemoteCommandHandlerStatusSuccess;
        } ];
        commandCenter.pauseCommand.enabled = YES;
        commandCenter.nextTrackCommand.enabled = NO;
        commandCenter.previousTrackCommand.enabled = NO;
        commandCenter.togglePlayPauseCommand.enabled = NO;
        
    } else {

        [ player pause ];
        MPRemoteCommandCenter *commandCenter = [ MPRemoteCommandCenter sharedCommandCenter ];
        [ commandCenter.playCommand resetTargetInvocations ];
        [ commandCenter.pauseCommand resetTargetInvocations ];
        
    }

    [ self setRemoteControl ];

}

- (void)setRemoteControl {

    NSMutableDictionary *songInfo = [ [ NSMutableDictionary alloc ] init ];
    songInfo[MPMediaItemPropertyArtist] = @"name of Artist";
    songInfo[MPMediaItemPropertyAlbumTitle] = @"title of Album";
    songInfo[MPMediaItemPropertyTitle] = @"title of Song";

    [ JukeboxMacro sharedSingleton ].settingNowPlayingInfo = YES;
    [ [ MPNowPlayingInfoCenter defaultCenter ] setNowPlayingInfo:songInfo ];
    [ JukeboxMacro sharedSingleton ].settingNowPlayingInfo = NO;

    [ JukeboxMacro sharedSingleton ].requestingRemoteControl = YES;
    [ [ UIApplication sharedApplication ] beginReceivingRemoteControlEvents ];
    [ [ UIApplication sharedApplication ] becomeFirstResponder ];
    [ JukeboxMacro sharedSingleton ].requestingRemoteControl = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [ super viewDidAppear:animated ];
    //NOTE Symphony by remove mark below
    [ [ NSNotificationCenter defaultCenter ] addObserver:self
                                                selector:@selector(enterVideoFullScreen)
                                                    name:UIWindowDidBecomeVisibleNotification
                                                  object:nil ];
}

- (void)enterVideoFullScreen {
    [ self playMusic:NO ];
    [ [ NSNotificationCenter defaultCenter ] removeObserver:self
                                                       name:UIWindowDidBecomeVisibleNotification
                                                     object:nil ];
    [ [ NSNotificationCenter defaultCenter ] addObserver:self
                                                selector:@selector(leaveVideoFullScreen)
                                                    name:UIWindowDidBecomeHiddenNotification
                                                  object:nil ];
}

- (void)leaveVideoFullScreen {
    
    __weak ViewController *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [ NSThread sleepForTimeInterval:1.0f ];
        dispatch_async(dispatch_get_main_queue(), ^{
            [ weakSelf playMusic:YES ];
            [ [ NSNotificationCenter defaultCenter ] removeObserver:weakSelf
                                                               name:UIWindowDidBecomeHiddenNotification
                                                             object:nil ];
            [ [ NSNotificationCenter defaultCenter ] addObserver:weakSelf
                                                        selector:@selector(enterVideoFullScreen)
                                                            name:UIWindowDidBecomeVisibleNotification
                                                          object:nil ];
        });
    });
}
@end