//
//  Account.h
//  NetSchool
//
//  Created by 周文松 on 15/9/18.
//  Copyright (c) 2015年 TalkWeb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Account : NSManagedObject

@property (nonatomic, retain) NSString * acc;
@property (nonatomic, retain) NSString * cid;
@property (nonatomic, retain) NSString * pwd;

@end
