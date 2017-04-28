//
//  ViewController.m
//  UdpTest
//
//  Created by fy on 2017/4/28.
//  Copyright © 2017年 LY. All rights reserved.
//

#import "ViewController.h"
#import "AsyncUdpSocket.h"

UInt16    const kUDP_PORT    = 9066;
NSString *const kBroadCastIp = @"192.168.3.34";

@interface ViewController ()<AsyncUdpSocketDelegate>

@property (nonatomic, strong) AsyncUdpSocket *socket;

@property (nonatomic, strong) UIButton *postButton;
@property (nonatomic, strong) UITextField *hostAddressTextField;
@property (nonatomic, strong) UITextView *messageTextView;

@property (nonatomic, assign) NSInteger sendMessageTimes;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor purpleColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initSocket) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self initSocket];
    [self createUI];
    _sendMessageTimes = 0;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initSocket {
    self.socket = [[AsyncUdpSocket alloc] initIPv4];
    [self.socket setDelegate:self];

    [self.socket bindToPort:kUDP_PORT error:nil];
    [self.socket enableBroadcast:YES error:nil];
//    [self.socket bindToAddress:@"192.168.3.38" port:kUDP_PORT error:nil];
//    [self.socket joinMulticastGroup:kBroadCastIp error:nil];
    
    [self.socket receiveWithTimeout:-1 tag:0];
    

}


- (void)createUI {
    self.hostAddressTextField = [[UITextField alloc] initWithFrame:CGRectMake(50, 100, 200, 40)];
    self.hostAddressTextField.borderStyle = UITextBorderStyleLine;
    [self.view addSubview:self.hostAddressTextField];
    
    self.postButton = [[UIButton alloc] initWithFrame:CGRectMake(200, 180, 50, 30)];
    [self.postButton setTitle:@"send" forState:UIControlStateNormal];
    [self.postButton setBackgroundColor:[UIColor greenColor]];
    [self.postButton addTarget:self action:@selector(postButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.postButton];
    
    self.messageTextView = [[UITextView alloc] initWithFrame:CGRectMake(50, 260, 200, 300)];
    [self.view addSubview:self.messageTextView];
}

- (void)postButtonClick:(UIButton *)button {
    [self broadcastEntry:self.hostAddressTextField.text];
}

- (void)broadcastEntry:(NSString *)host {
    NSMutableString *mStr = [[NSMutableString alloc] init];
    self.sendMessageTimes++;
    [mStr appendFormat:@"%@:%@:%ld", @"MacOS", @"Youth", self.sendMessageTimes];
    [self.socket sendData:[mStr dataUsingEncoding:NSUTF8StringEncoding] toHost:host port:kUDP_PORT withTimeout:-1 tag:0];
}

#pragma mark - AsyncUDPDelegate
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port {
    
    NSMutableString *mStr = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [mStr appendFormat:@"\n%@", self.messageTextView.text];
    
    self.messageTextView.text = mStr;
    
    [self.socket receiveWithTimeout:-1 tag:0];
    return YES;
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error {
    NSLog(@"Message not receive for error: %@", error);
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    NSLog(@"Message send Success!");
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    NSLog(@"Message not send for error: %@", error);
}

- (void)onUdpSocketDidClose:(AsyncUdpSocket *)sock {
    NSLog(@"Socket closed!");
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
