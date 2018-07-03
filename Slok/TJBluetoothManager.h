//
//  TJBluetoothManager.h
//  Slok
//
//  Created by user on 2018/5/15.
//  Copyright © 2018年 LiuHao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface TJBluetoothManager : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate,CBPeripheralManagerDelegate>
//蓝牙扫描返回的数据
typedef void (^BluetoothScanReturnedDataBlock)(NSUInteger *selectIndex,NSMutableDictionary *peripheralDic);

//返回蓝牙连接状态
typedef void (^ReturnBluetoothStatusBlock)(NSUInteger *status,NSString *mac);

//返回蓝牙返回的数据
typedef void (^BluetoothReturnsDataBlock)(NSUInteger *status,NSData *ReturnsData,NSString *mac);

/**
 单例实现方法
 */
+ (TJBluetoothManager *)shareTJBluetoothManager;

//设置使用单例的界面，1为主界面，2为蓝牙加锁，3为设置快击密码
-(void)SetViewController:(NSUInteger *)priority;

//返回蓝牙对象
-(CBCentralManager *)getcentralManager;

//指定连接某一个蓝牙
-(void)ConnectBluetooth:(CBPeripheral *)peripheral;
//关闭蓝牙扫描
-(void)stopScan;
//断开当前连接
-(void)BluetoothDisconnect;
//前台开启蓝牙扫描
- (void)scanPeripehrals;
//后台开启连接
- (void)htconnectionPeripehrals;
//不加UUID蓝牙扫描
- (void)NotUUIDscanPeripehrals;
//蓝牙发送数据
-(void)BluetoothSendData:(NSString *)bleWord;
//设置读取到Characteristics描述的值的block
- (void)setBluetoothScanReturnedDataBlock:(void (^)(NSUInteger *selectIndex,NSMutableDictionary *peripheralDic))block;
//返回蓝牙连接状态、0未连接，1已连接，2通讯成功
-(void)setReturnBluetoothStatusBlock:(void (^)(NSUInteger *status,NSString *mac))block;

//返回蓝牙连接状态、0未连接，1已连接，2通讯成功
-(void)setBluetoothReturnsDataBlock:(void (^)(NSUInteger *status,NSData *ReturnsData,NSString *mac))block;

-(CBCentralManager *)ReturnCBCentralManager;
-(CBPeripheral *)ReturnCBPeripheral;
@end
