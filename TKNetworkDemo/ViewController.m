//
//  ViewController.m
//  TKNetworkDemo
//
//  Created by unarch on 2021/5/22.
//

#import "ViewController.h"
#import "TKJumpQueue.h"
#import "TKDownloadTask.h"
#import "TKDownloadManager.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) TKJumpQueue *queue;
@property (nonatomic, strong) NSMutableArray *taskArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];

    [@[@"全部开始下载"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.bounds = CGRectMake(0, 0, 300, 100);
        button.center = CGPointMake(self.view.center.x, 50 + 100 * (idx + 1));
        button.tag = idx;
        button.titleLabel.font = [UIFont boldSystemFontOfSize:30];
        [button setTitle:obj forState:UIControlStateNormal];
        [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }];
    TKJumpQueue *queue = [TKJumpQueue new];
    queue.name = @"testQueue";
    NSLog(@"%@",queue);
    NSLog(@"%d front = %@ back = %@",[queue containsObjectForKey:@"key-1"], [queue frontObjectKey], [queue backObjectKey]);
    [queue setObject:@"object-1" forKey:@"key-1"];
    NSLog(@"%d front = %@ back = %@",[queue containsObjectForKey:@"key-1"], [queue frontObjectKey], [queue backObjectKey]);
    [queue setObject:@"object-2" forKey:@"key-2"];
    NSLog(@"%d front = %@ back = %@",[queue containsObjectForKey:@"key-1"], [queue frontObjectKey], [queue backObjectKey]);
    [queue setObject:@"object-3" forKey:@"key-3"];
    NSLog(@"%d front = %@ back = %@",[queue containsObjectForKey:@"key-1"], [queue frontObjectKey], [queue backObjectKey]);
    [queue setObject:@"object-1" forKey:@"key-1"];
    NSLog(@"%d front = %@ back = %@",[queue containsObjectForKey:@"key-1"], [queue frontObjectKey], [queue backObjectKey]);
    [queue popObjectFront];
    NSLog(@"%d front = %@ back = %@",[queue containsObjectForKey:@"key-1"], [queue frontObjectKey], [queue backObjectKey]);
    NSLog(@"key1 = %@ key2 = %@", [queue objectForKey:@"key-1"], [queue objectForKey:@"key-2"]);
    
    NSArray *photoArr = @[
        @"https://unsplash.com/photos/x7K0cE82DZs/download?force=true",
        @"https://unsplash.com/photos/Yn0l7uwBrpw/download?force=true",
        @"https://unsplash.com/photos/H2HZth3RvD8/download?force=true",
        @"https://unsplash.com/photos/7pl56XQNYAw/download?force=true",
        @"https://unsplash.com/photos/5aH8WBin4eM/download?force=true",
        @"https://unsplash.com/photos/sLcVe47YUJI/download?force=true",
        @"https://unsplash.com/photos/X6iAMDUKvwY/download?force=true",
        @"https://unsplash.com/photos/MpJfE4tElbw/download?force=true",
        @"https://unsplash.com/photos/EzYq1HOl5_8/download?force=true",
        @"https://unsplash.com/photos/yXgAiWyT-Ws/download?force=true",
        @"https://unsplash.com/photos/JQUlYfOvh-E/download?force=true",
        @"https://unsplash.com/photos/YaTvYZw4JdI/download?force=true",
        @"https://unsplash.com/photos/QKsQWSKFICk/download?force=true",
    ];
    self.taskArr = [[NSMutableArray alloc] init];
    for (NSInteger index = 0; index < photoArr.count; index++ ) {
        [self addphoto:index url:photoArr[index]];
    };
}
- (void)clickButton:(UIButton *)button {
    if (button.tag == 0) {
        [self searchA];
    } else if(button.tag == 3) {
        [self searchA];
    }
}

- (void)searchA {
    [TKDownloadManager shareManager].maxOperationCount = 3;
    
//    for(TKDownloadTask * task in self.taskArr) {
//        [task start];
//    }
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply(self.taskArr.count, queue, ^(size_t index) {
        TKDownloadTask *task = self.taskArr[index];
        NSLog(@"index %ld---%@", index ,[NSThread currentThread]);
        [task start];
        
    });
    
}


- (void) addphoto :(NSInteger)index url:(NSString *)url {
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES).firstObject;
    NSString *coursewarePath = [cachePath stringByAppendingPathComponent: [NSString stringWithFormat:@"task-png%ld.png",(long)index]];
    TKDownloadTask *request = [TKDownloadTask downloadWithURLString:url downloadFilePath:coursewarePath parameters:nil headers:nil progress:^(NSProgress * _Nonnull progress) {
        NSLog(@"第%ld张图 下载进度 progress = %@", index, progress);
        NSLog(@"当前线程index %ld---%@", index ,[NSThread currentThread]);
    } success:^(NSURLSessionTask * _Nullable task, NSString * _Nullable filePath) {
        NSLog(@"第%ld张图 下载成功 task = %@ filePath = %@", index ,task, filePath);
        NSLog(@"当前线程index %ld---%@", index ,[NSThread currentThread]);
    } failure:^(NSURLSessionTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"第%ld张图 下载失败 task = %@ error = %@",index, task, error);
        NSLog(@"当前线程index %ld---%@", index ,[NSThread currentThread]);
    }];
    [self.taskArr addObject:request];
}





@end
