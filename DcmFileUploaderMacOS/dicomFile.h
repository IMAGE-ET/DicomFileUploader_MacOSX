//
//  dicomFile.h
//  DcmFileUploaderMacOS
//
//  Created by Sage Aucoin on 5/6/14.
//
//

#import <Foundation/Foundation.h>

@interface dicomFile : NSObject

@property (nonatomic, strong) NSString *PatientID;
@property (nonatomic, strong) NSString *Sex;
@property (nonatomic, strong) NSString *PatientName;
@property (nonatomic, strong) NSString *StudyUID;
@property (nonatomic, strong) NSString *StudyDate;
@property (nonatomic, strong) NSString *Modality;
@property (nonatomic, strong) NSString *SopUID;
@property (nonatomic, strong) NSString *Path;

@end
