//
//  dicomFile.m
//  DcmFileUploaderMacOS
//
//  Created by Sage Aucoin on 5/6/14.
//
//

#import "dicomFile.h"

@implementation dicomFile

- (NSString *)description{
    return [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n",
            [self PatientID], [self Sex], [self PatientName], [self StudyUID], [self StudyDate], [self Modality], [self SopUID], [self Path]];
}
@end
