//
//  ViewController.m
//  healthyKit
//
//  Created by ws on 16/1/26.
//  Copyright © 2016年 ws. All rights reserved.
//

#import "ViewController.h"
#import <HealthKit/HealthKit.h>
#import "MBProgressHUD.h"

@interface ViewController (){
    
    NSTimer *_timer;
    NSTimer *_labelTimer;
}

@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, strong) HKHealthStore *store;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *timeLable;

@property (nonatomic, strong) NSDate *lastDate;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.textField.keyboardType = UIKeyboardTypeNumberPad;
    
    
    [self getPermissions];

}
- (IBAction)run:(id)sender {
    
    if (self.textField.text.length == 0){
        
        [self showMBProgressHUDWithOnlyString:@"请填写跑步个数"];
        return;
    }
    
//    [self writeRunData];
    

    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(runTimer) userInfo:nil repeats:YES];
        [_timer fire];
    }
    
    
    if (!_labelTimer) {
        _labelTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeLableText) userInfo:nil repeats:YES];
        [_labelTimer fire];
    }
    
    
}


- (void)changeLableText{
    
    NSString *str = self.timeLable.text;
    NSInteger time = str.integerValue;
    self.timeLable.text = [NSString stringWithFormat:@"%ld",--time];
    NSLog(@"%@",self.timeLable.text);
}


- (void)runTimer{
    
    NSLog(@"1111");
    self.timeLable.text = @"60";
    if (self.lastDate) {
        
        [self writeRunDataWithStartDate:self.lastDate];
    }
    
    self.lastDate = [NSDate date];
    
}

- (void)getPermissions
{
    
    if ([HKHealthStore isHealthDataAvailable]) {
        
        if(self.store == nil)
            self.store = [[HKHealthStore alloc] init];
        
        /*
         组装需要读写的数据类型
         */
        NSSet *writeDataTypes = [self dataTypesToWrite];
        NSSet *readDataTypes = [self dataTypesRead];
        
        /*
         注册需要读写的数据类型，也可以在“健康”APP中重新修改
         */
        [self.store requestAuthorizationToShareTypes:writeDataTypes readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"%@\n\n%@",error, [error userInfo]);
                
                
                [self showMBProgressHUDWithOnlyString:@"获取权限成功"];
                return ;
            }
            else
            {
                
            }
        }];
    }

}


- (void)showMBProgressHUDWithOnlyString:(NSString *)str{
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = str;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:3];
    
}




/**
 *  写入跑步集合
 */
- (void)writeRunDataWithStartDate:(NSDate *)startDate{
    
    
    HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    HKUnit *count = [HKUnit unitFromString:@"count"];
    
    HKQuantity *qunantity = [HKQuantity quantityWithUnit:count doubleValue:self.textField.text.integerValue];
    
    

    
    HKQuantitySample *sample = [HKQuantitySample quantitySampleWithType:type quantity:qunantity startDate:startDate endDate:[NSDate date]];
    
    
    
    [self.store saveObject:sample withCompletion:^(BOOL success, NSError * _Nullable error) {
        
        NSString *str;
        if (error) {
//            NSLog(@"%@",error);
            
            str = @"写入数据出错";
        }else{
            
            
            str = @"ok，装逼走起";
            
//            NSLog(@"%d",success);
        }
        
        
        
        dispatch_sync(dispatch_get_main_queue(), ^{
//            self.hud = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
//            self.hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark"]];
//            
//            // Set custom view mode
//            self.hud.mode = MBProgressHUDModeCustomView;
//            self.hud.labelText = str;
//            
//            [self.hud show:YES];
//            [self.hud hide:YES afterDelay:3];
            
            [self showMBProgressHUDWithOnlyString:str];
            [self.view endEditing:YES];
        });
        
        
    }];
    
    
    
    
}



/*!
 *  @author Lcong, 15-04-20 16:04:42
 *
 *  @brief  写权限
 *
 *  @return 集合
 */
- (NSSet *)dataTypesToWrite
{
    
    HKQuantityType *runType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKQuantityType *temperatureType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyTemperature];
    HKQuantityType *activeEnergyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    
    return [NSSet setWithObjects:heightType, temperatureType, weightType,activeEnergyType,runType,nil];
}

/*!
 *  @author Lcong, 15-04-20 16:04:03
 *
 *  @brief  读权限
 *
 *  @return 集合
 */
- (NSSet *)dataTypesRead
{
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKQuantityType *temperatureType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyTemperature];
    HKCharacteristicType *birthdayType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
    HKCharacteristicType *sexType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];
    HKQuantityType *stepCountType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *activeEnergyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    
    return [NSSet setWithObjects:heightType, temperatureType,birthdayType,sexType,weightType,stepCountType, activeEnergyType,nil];
}






@end
