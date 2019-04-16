//
//  AppDelegate.h
//  DcmFileUploaderMacOS
//
//  Created by Sage Aucoin on 4/29/14.
//  Copyright (c) 2014 IDS. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (strong) IBOutlet NSOutlineView *dicomList;
@property (weak) IBOutlet NSProgressIndicator *findFileLoader;

- (IBAction)openFileButton:(NSButton *)sender;
- (IBAction)findDriversButton:(NSButton *)sender;
- (IBAction)findFileButton:(NSButton *)sender;
- (IBAction)uploadButton:(NSButton *)sender;


@end
