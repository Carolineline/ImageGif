//
//  GifViewController.m
//  ImageGif
//
//  Created by 晓琳 on 16/12/12.
//  Copyright © 2016年 xiaolin.han. All rights reserved.
//

#import "GifViewController.h"
#import <ImageIO/ImageIO.h>//图片的输入输出文件
#import <MobileCoreServices/MobileCoreServices.h>
@interface GifViewController ()

@end

@implementation GifViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self deCompositionGif];
    
    [self loadImageToGif];
    
//    [self createGif];
}

/**
 分解gif
 1 拿到gif数据
 2 将gif分解到一帧
 3 将单帧数据转为UIImage
 4 单帧图片保存
 */
- (void) deCompositionGif{
    // 1 拿到gif数据
    
    NSString *gifPathSource = [[NSBundle mainBundle] pathForResource:@"ss" ofType:@"gif"];
    NSData *data = [NSData dataWithContentsOfFile:gifPathSource];
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    //查看帧数
    //2 将gif分解到一帧
    
    size_t count = CGImageSourceGetCount(source);
    NSMutableArray *tempArray = [NSMutableArray array];
    for (size_t i= 0; i < count; i++) {
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source,i, NULL);
        //3 将单帧数据转为UIImage
        
        UIImage *image = [UIImage imageWithCGImage:imageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
        [tempArray addObject:image];
        CGImageRelease(imageRef);
    }
    CFRelease(source);
    // 4 单帧图片保存
    int i= 0;
    for (UIImage *image in tempArray) {
        NSData *data = UIImagePNGRepresentation(image);
        NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *gifPath = path[0];
        i++;
        NSString *pathNum = [gifPath stringByAppendingString:[NSString stringWithFormat:@"%d.png",i]];
        [data writeToFile:pathNum atomically:NO];
    }
}

//分解gif图片，加载gif动画图片
- (void) loadImageToGif{
    NSMutableArray *imageTmp = [NSMutableArray array];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(275/2, 100, 100, 100)];
    [self.view addSubview:imageView];
    
    for (int i = 1; i < 33; i++) {
        UIImage  *image = [UIImage imageNamed:[NSString stringWithFormat:@"Documents%d.png",i]];
        [imageTmp addObject:image];
    }
    [imageView setAnimationImages:imageTmp];
    [imageView setAnimationDuration:2];
    [imageView setAnimationRepeatCount:10];
    [imageView startAnimating];
    
    
}

/**
  合成gif
 1 获取到图片资源
 2 创建gif文件
 3 配置gif属性
 4 单帧添加到gif
 */

-  (void) createGif{
    // 1 获取到图片资源

    NSMutableArray *images = [NSMutableArray arrayWithObjects:[UIImage imageNamed:@"Documents1.png"],[UIImage imageNamed:@"Documents2.png"],[UIImage imageNamed:@"Documents3.png"], [UIImage imageNamed:@"Documents4.png"],nil];
    // 2 创建gif文件
    NSArray *document  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentStr = [document objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *textDic = [documentStr stringByAppendingString:@"/gif"];
    [fileManager createDirectoryAtPath:textDic withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *path = [textDic stringByAppendingString:@"test1.gif"];
    NSLog(@"path = %@",path);
    // 3 配置gif属性
    CGImageDestinationRef destion;
    CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)path, kCFURLPOSIXPathStyle, false);
    destion = CGImageDestinationCreateWithURL(url, kUTTypeGIF, images.count, NULL);
    NSDictionary *frameDic = [NSDictionary dictionaryWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:0.3],(NSString*)kCGImagePropertyGIFDelayTime, nil] forKey:(NSString*)kCGImagePropertyGIFDelayTime];
    
    NSMutableDictionary *gifParmDic = [NSMutableDictionary dictionaryWithCapacity:2];//重复次数
    [gifParmDic setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCGImagePropertyGIFHasGlobalColorMap];
    [gifParmDic setObject:(NSString*)kCGImagePropertyColorModel forKey:(NSString *)kCGImagePropertyColorModel];
    [gifParmDic setObject:[NSNumber numberWithInt:8] forKey:(NSString *) kCGImagePropertyDepth];//颜色深度
    [gifParmDic setObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCGImagePropertyGIFLoopCount];
    NSDictionary *gifProperty = [NSDictionary dictionaryWithObject:gifParmDic forKey:(NSString *)kCGImagePropertyGIFDictionary];
    // 4 单帧添加到gif
    for (UIImage *dimage in images) {
        CGImageDestinationAddImage(destion, dimage.CGImage,(__bridge CFDictionaryRef)frameDic);
    }
    CGImageDestinationSetProperties(destion, (__bridge CFDictionaryRef)gifProperty);
    CGImageDestinationFinalize(destion);
    CFRelease(destion);

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
