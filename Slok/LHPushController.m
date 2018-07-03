//
//  LHPushController.m
//  LHQuickOpening
//
//  Created by Haoliu on 17/4/20.
//  Copyright © 2017年 supude. All rights reserved.
//

#import "LHPushController.h"

@implementation LHPushController
-(void)sendPushId:(NSString *)userId
{
    BOOL isPush =  [LHDataManager getBoolValue:LHIsPush];
  
    NSString *oldPushId = [LHDataManager getStringValue:LHUserId];

    
    //if(isPush == NO || ![oldPushId isEqualToString:userId])
   
        [LHNetworkManager postSendPushIdhandle:userId handle:^(id result, NSError *error) {
            
            If_Respose_Success(result, error)
            {
                [LHDataManager saveBoolValue:YES withKey:LHIsPush];
                
                [LHDataManager saveStringValue:userId withKey:LHUserId];
            }else{
                
                [LHDataManager saveBoolValue:NO withKey:LHIsPush];
            }
        }];

}

@end
