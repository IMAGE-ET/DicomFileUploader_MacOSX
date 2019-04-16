//
//  AppDelegate.m
//  DcmFileUploaderMacOS
//
//  Created by Sage Aucoin on 4/29/14.
//  Copyright (c) 2014 IDS. All rights reserved.
//

#import "AppDelegate.h"
#import "dicomFile.h"
@implementation AppDelegate
@synthesize window = _window;
@synthesize dicomList = _dicomList;
@synthesize findFileLoader = _findFileLoader;





//Uses enumeration to search all drives plugged in via the 'Volumes' directory and its subdirectories.
-(void) searchVolumes{
    bool isFileFound = false;
    //This array holds the DICOMDIR file. Will typically only have 1 file.
    NSMutableArray *dcmFiles = [[NSMutableArray alloc] init]; 
    NSFileManager *localFileManager=[[NSFileManager alloc] init];
    NSDirectoryEnumerator *dirEnum =
    //Search Volumes
    [localFileManager enumeratorAtPath:@"/volumes/"]; 
    NSString *filename = (NSString *)dirEnum;
    //Searches subdirectories
    while ((filename = [dirEnum nextObject])) {
        [_findFileLoader startAnimation:self];
        //compares each filename to dicomdir. If there is a match, the object is stored in dcmFiles.
        if ([filename rangeOfString:@"dicomdir" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [dcmFiles addObject:[filename stringByAppendingPathComponent:filename]];
            NSLog(@"%@",dcmFiles);
            [self xmlParser];
            isFileFound = true;
        }
    }
    if (isFileFound == false) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"No DICOMDIR Files Found."];
        [alert setAlertStyle:NSWarningAlertStyle];
        if ([alert runModal] == NSAlertFirstButtonReturn){
            NSLog(@"DICOMDIR file not found!!");
        }
        
    }
    [_findFileLoader stopAnimation:self];
}


//Connects to a webservice when the user selects a DICOMDIR and turns the file into a usable XML document.
-(void) xmlParser{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"No"];
    [alert addButtonWithTitle:@"Yes"];
    [alert setMessageText:@"DICOMDIR File Found. Do you want to use this file?"];
    [alert setAlertStyle:NSWarningAlertStyle];
    if ([alert runModal] == NSAlertSecondButtonReturn){
        NSLog(@"The XML parser is running");
    }
}


//When the application starts, starts monitoring for drive mount. If a mount is detected, a notification is
//sent to the volumesChanged function.
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector: @selector(searchVolumes) name:NSWorkspaceDidMountNotification object: nil];
    
    //Connect to XML Service URL
    NSURL *url = [NSURL URLWithString:@"http://tazik/IDS.ImageServer.Web/DcmUploadHandler.ashx"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //Downloads data asynchronously and executes a completion block when finished. NSOperationQueue keeps it dispatched on a background thread.
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init]
        completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            //Parse XML here!!!
        }];
}


//When drive mount is detected, fire searchVolumes
-(void) volumesChanged: (NSNotification*) notification{
    [self searchVolumes];
}


//First button. It fires the searchVolumes function. 
- (IBAction)findDriversButton:(NSButton *)sender {
    [self searchVolumes];
}


//Second button. It will open a dialog and allow the user to search through and open the DICOMDIR file and then
//store that file in an object array.
- (IBAction)openFileButton:(NSButton *)sender {
    NSMutableArray *dcmFiles = [[NSMutableArray alloc] init];
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseDirectories:NO];
    [openDlg setCanChooseFiles:YES];
    [openDlg setRepresentedFilename:@"dicomdir"];
    [openDlg setAllowsMultipleSelection:NO];
    if ([openDlg runModal] == NSOKButton) {
        //Stores the URL of the chosen file. 
        NSArray* urls = [openDlg URLs];
        //trims the URL to a usable filepath.
        NSString* fileWay=[urls[0] path];
        //If something besides a DICOMDIR file is selected, the dialog reopens and makes the user select again or cancel.
        if ([fileWay rangeOfString:@"dicomdir" options:NSCaseInsensitiveSearch].location == NSNotFound) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"No"];
            [alert addButtonWithTitle:@"Yes"];
            [alert setMessageText:@"No DICOMDIR File Found. Try again?"];
            [alert setAlertStyle:NSWarningAlertStyle];
            if ([alert runModal] == NSAlertSecondButtonReturn){
                [self openFileButton:(NSButton *)sender];
            }
        }
        else {
            [dcmFiles addObject:fileWay];
            NSLog(@"%@", dcmFiles);
            [self xmlParser];
        }
    }
}


//Third Button. It will open a dialog and allow the user to search through and open a directory that contains
//a DICOMDIR file and then store that file in an object array. This function will search all subdirectories.
- (IBAction)findFileButton:(NSButton *)sender {
    //Flag for file not found.
    bool isFileFound = false;
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setCanChooseFiles:NO];
    [openDlg setAllowsMultipleSelection:NO];
    if ([openDlg runModal] == NSOKButton) {
        //Stores the URL of the selected directory
        NSArray* urls = [openDlg URLs];
        //Converts URL into a usable path
        NSString* fileWay=[urls[0] path];
            NSMutableArray *dcmFiles = [[NSMutableArray alloc] init];
            NSFileManager *localFileManager=[[NSFileManager alloc] init];
            //enumerate directory that is selected and search for DICOMDIR file.
            NSDirectoryEnumerator *dirEnum = [localFileManager enumeratorAtPath:fileWay];
            NSString *filename = (NSString *)dirEnum;
            while ((filename = [dirEnum nextObject])) {
                [_findFileLoader startAnimation:self];
                //compares each filename to dicomdir. If there is a match, the object is stored in dcmFiles.
                if ([filename rangeOfString:@"dicomdir" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                    //If DICOMDIR file is found, add the object to the dirFiles array. 
                    [dcmFiles addObject:[fileWay stringByAppendingPathComponent:filename]];
                    NSLog(@"%@",dcmFiles);
                    [self xmlParser];
                    //Set flag to file found.
                    isFileFound = true;
                }
            }
            //If no file is found, give user option to try again.
            if (isFileFound == false) {
                NSAlert *alert = [[NSAlert alloc] init];
                [alert addButtonWithTitle:@"No"];
                [alert addButtonWithTitle:@"Yes"];
                [alert setMessageText:@"No DICOMDIR File Found. Try again?"];
                [alert setAlertStyle:NSWarningAlertStyle];
                if ([alert runModal] == NSAlertSecondButtonReturn){
                    [self findFileButton:(NSButton *)sender];
                }
            }
            [_findFileLoader stopAnimation:self];
    }
}


//Fourth Button. Takes the information received and sends the selected files to {webservice/cloud/etc}
- (IBAction)uploadButton:(NSButton *)sender {
    
    
}


@end
