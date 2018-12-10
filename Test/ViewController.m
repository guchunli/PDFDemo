//
//  ViewController.m
//  Test
//
//  Created by Yomob on 2018/12/5.
//  Copyright © 2018年 Yomob. All rights reserved.
//

#import "ViewController.h"
#import <QuickLook/QuickLook.h>
#import "ReaderViewController.h"
#import <AFNetworking.h>
#import <AFURLSessionManager.h>
#import <SVProgressHUD.h>
#import <WebKit/WebKit.h>
#import "UIWebView+WYFile.h"
#define statusH     [UIApplication sharedApplication].statusBarFrame.size.height

@interface ViewController ()<QLPreviewControllerDataSource,QLPreviewControllerDelegate,ReaderViewControllerDelegate,UIWebViewDelegate>
@property (strong, nonatomic) UIWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self addBtn];
    //显示
//    [self loadPDFFile1];
//    [self loadPDFFile2];
//    [self loadPDFFile4];
    
    //下载
//    [self downloadPDFFile1];
//    [self downloadPDFFile2];
    
//    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(100, 100, 200, 400)];
//    imgView.backgroundColor = [UIColor orangeColor];
//    imgView.image = [UIImage imageNamed:@"face.jpg"];
//    imgView.contentMode = UIViewContentModeScaleAspectFit;
//    [self.view addSubview:imgView];
//    //图片转PDF文件
//    [self createPDFFileInView:imgView];
    

    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(50, statusH, 100, 40)];
//    btn.backgroundColor = [UIColor orangeColor];
    [btn setTitle:@"转换PDF" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(convertImagesToPDFFile) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
//
//    UIButton *btn1 = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width-100-50, statusH, 100, 40)];
////    btn1.backgroundColor = [UIColor greenColor];
//    [btn1 setTitle:@"转换Image" forState:UIControlStateNormal];
//    [btn1 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    [btn1 addTarget:self action:@selector(convertToImage) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btn1];
//
//    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"Xcode快捷键" ofType:@"rtf"];
//    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
//    NSURLRequest *request = [NSURLRequest requestWithURL:fileUrl];
//    [self.webView loadRequest:request];
//    [self.view addSubview:self.webView];
}

- (void)convertImagesToPDFFile{
    
    NSString *fileName = [NSString stringWithFormat:@"Images_%.0f.pdf",[[NSDate date] timeIntervalSince1970]];
    NSString *pdfPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]stringByAppendingPathComponent:fileName];
    
    NSMutableArray *selectImages = [NSMutableArray arrayWithCapacity:3];
    // 默认添加九张不同大小的图片
    for (NSInteger i = 0; i < 9; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"image%zd.jpg",i]];
        [selectImages addObject:image];
    }
    BOOL result = [self convertPDFWithImages:selectImages filePath:pdfPath];
    if (result) {
        NSLog(@"%@",pdfPath);
        NSLog(@"多张图片转换PDF成功");
    }else{
        NSLog(@"多张图片转换PDF失败");
    }
}

- (BOOL)convertPDFWithImages:(NSArray<UIImage *>*)images filePath:(NSString *)filePath{
    
    if (!images || images.count == 0) return NO;
    
    BOOL result = UIGraphicsBeginPDFContextToFile(filePath, CGRectZero, NULL);
    
    // pdf每一页的尺寸大小
    
    CGRect pdfBounds = UIGraphicsGetPDFContextBounds();
    CGFloat pdfWidth = pdfBounds.size.width;
    CGFloat pdfHeight = pdfBounds.size.height;
    
    NSLog(@"%@",NSStringFromCGRect(pdfBounds));
    
    [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull image, NSUInteger idx, BOOL * _Nonnull stop) {
        // 绘制PDF
        UIGraphicsBeginPDFPage();
        
        // 获取每张图片的实际长宽
        CGFloat imageW = image.size.width;
        CGFloat imageH = image.size.height;
        //        CGRect imageBounds = CGRectMake(0, 0, imageW, imageH);
        //        NSLog(@"%@",NSStringFromCGRect(imageBounds));
        
        // 每张图片居中显示
        // 如果图片宽高都小于PDF宽高
        if (imageW <= pdfWidth && imageH <= pdfHeight) {
            
            CGFloat originX = (pdfWidth - imageW) * 0.5;
            CGFloat originY = (pdfHeight - imageH) * 0.5;
            [image drawInRect:CGRectMake(originX, originY, imageW, imageH)];
            
        }
        else{
            CGFloat w,h; // 先声明缩放之后的宽高
            //            图片宽高比大于PDF
            if ((imageW / imageH) > (pdfWidth / pdfHeight)){
                w = pdfWidth - 20;
                h = w * imageH / imageW;
                
            }else{
                //             图片高宽比大于PDF
                h = pdfHeight - 20;
                w = h * imageW / imageH;
            }
            [image drawInRect:CGRectMake((pdfWidth - w) * 0.5, (pdfHeight - h) * 0.5, w, h)];
        }
    }];
    
    UIGraphicsEndPDFContext();
    
    return result;
}

- (UIWebView *)webView{
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, statusH+40, self.view.bounds.size.width, self.view.bounds.size.height - 40 - statusH)];
        _webView.delegate = self;
        _webView.scalesPageToFit = YES;
        [self.view addSubview:_webView];
    }return _webView;
}

- (void)convertToPDF{
    
    NSData *pdfData = [self.webView convert2PDFData];
    NSString *fileName = [NSString stringWithFormat:@"PDF_%.0f.pdf",[[NSDate date] timeIntervalSince1970]];
    NSString *pdfPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]stringByAppendingPathComponent:fileName];
    BOOL result = [pdfData writeToFile:pdfPath atomically:YES];
    if (result) {
        NSLog(@"%@",pdfPath);
        NSLog(@"转换PDF成功");
    }else{
        NSLog(@"转换PDF失败");
    }
}

- (void)convertToImage{
    
    UIImage *image = [self.webView convert2Image];
    NSData *imageData = UIImagePNGRepresentation(image);
//    NSString *imagePath = [WYPDFConverter saveDirectory:[NSString stringWithFormat:@"%@_IMG.png",self.fileName]];
    NSString *fileName = [NSString stringWithFormat:@"IMG_%.0f.jpg",[[NSDate date] timeIntervalSince1970]];
    NSString *imagePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]stringByAppendingPathComponent:fileName];
    BOOL result = [imageData writeToFile:imagePath atomically:YES];
    
    if (result) {
        NSLog(@"%@",imagePath);
        NSLog(@"转换Image成功");
    }else{
        NSLog(@"转换Image失败");
    }
}

- (void)addBtn{
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
    btn.backgroundColor = [UIColor orangeColor];
    [btn addTarget:self action:@selector(downloadPDFFile2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

#pragma mark - 加载PDF文件
//1.webview
- (void)loadPDFFile1{
    
    //初始化myWebView
    WKWebView *myWebView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    myWebView.backgroundColor = [UIColor orangeColor];
    NSURL *filePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"photo2" ofType:@"pdf"]];
    NSURLRequest *request = [NSURLRequest requestWithURL: filePath];
    [myWebView loadRequest:request];
    //使文档的显示范围适合UIWebView的bounds
//    [myWebView setScalesPageToFit:YES];
    [self.view addSubview:myWebView];
}



//2.QLPreviewController
- (void)loadPDFFile2{
    
    QLPreviewController *QLPVC = [[QLPreviewController alloc] init];
    QLPVC.dataSource = self;
    QLPVC.delegate = self;
    [self presentViewController:QLPVC animated:YES completion:nil];
}

#pragma mark QLPreviewControllerDataSource
/*
 *所要加载pdf文档的个数
 */
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller{
    return 1;
}

/*
 * 返回每个index pdf文档所对应的文档路径
 */
- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index{
//    NSArray *arr = @[FILE_PATH,FILE_PATH1];
//
//    return [NSURL fileURLWithPath:arr[index]];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"photo" ofType:@"pdf"];
    return [NSURL fileURLWithPath:path];
}

//3.用CGContext画pdf文档，并结合UIPageViewController展示
- (void)loadPDFFile3{
    
//    [self drawPDF];
//    [self showOnPageVC];
}

////(1)将pdf单页的文档画在UIView的画布上
//- (void)drawPDF{
//
//    CFURLRef pdfURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), CFSTR("photo2.pdf"), NULL, NULL);
//    //    CFURLRef pdfURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), (__bridge CFStringRef)self.fileName, NULL, NULL);
//    //创建CGPDFDocument对象
//    CGPDFDocumentRef pdfDocument = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
//
//    //获取当前的上下文
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    //Quartz坐标系和UIView坐标系不一样所致，调整坐标系，使pdf正立
//    CGContextTranslateCTM(context, 0.0, self.view.bounds.size.height);
//    CGContextScaleCTM(context, 1.0, -1.0);
//
//    //获取指定页的pdf文档
//    CGPDFPageRef page = CGPDFDocumentGetPage(pdfDocument, 1);
//    //创建一个仿射变换，该变换基于将PDF页的BOX映射到指定的矩形中。
//    CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFCropBox, self.view.bounds, 0, true);
//    CGContextConcatCTM(context, pdfTransform);
//    //将pdf绘制到上下文中
//    CGContextDrawPDFPage(context, page);
//}
////(2)用UIPageViewController展示分页的pdf文档
//- (void)showOnPageVC{
//
//    //初始化PDFPageModel
//    pdfPageModel = [[CGContextDrawPDFPageModel alloc] initWithPDFDocument:pdfDocument];
//
//    // UIPageViewControllerSpineLocationMin 单页显示
//    NSDictionary *options = [NSDictionary dictionaryWithObject:
//                             [NSNumber numberWithInteger: UIPageViewControllerSpineLocationMin]
//                                                        forKey: UIPageViewControllerOptionSpineLocationKey];
//
//    //初始化UIPageViewController，UIPageViewControllerTransitionStylePageCurl翻页效果，UIPageViewControllerNavigationOrientationHorizontal水平方向翻页
//    pageViewCtrl = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
//                                                                 options:options];
//    //承载pdf每页内容的控制器
//    CGContextDrawPDFPageController *initialViewController = [pdfPageModel viewControllerAtIndex:1];
//    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
//    //设置UIPageViewController的数据源
//    [pageViewCtrl setDataSource:pdfPageModel];
//
//    //pageViewCtrl.doubleSided = YES;设置正反面都有文字
//    //设置pageViewCtrl的子控制器
//    [pageViewCtrl setViewControllers:viewControllers
//                           direction:UIPageViewControllerNavigationDirectionReverse
//                            animated:NO
//                          completion:^(BOOL f){}];
//    [self addChildViewController:pageViewCtrl];
//    [self.view addSubview:pageViewCtrl.view];
//    //当我们向我们的视图控制器容器（就是父视图控制器，它调用addChildViewController方法加入子视图控制器，它就成为了视图控制器的容器）中添加（或者删除）子视图控制器后，必须调用该方法，告诉iOS，已经完成添加（或删除）子控制器的操作。
//    [pageViewCtrl didMoveToParentViewController:self];
//}



//4.第三方框架vfr/Reader加载pdf文档
- (void)loadPDFFile4{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"photo" ofType:@"pdf"];
    ReaderDocument *doc = [[ReaderDocument alloc] initWithFilePath:path password:nil];
    ReaderViewController *rvc = [[ReaderViewController alloc] initWithReaderDocument:doc];
    rvc.delegate = self;
    [self presentViewController:rvc animated:YES completion:nil];
}

#pragma mark - ReaderViewControllerDelegate
- (void)dismissReaderViewController:(ReaderViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - 下载PDF文件
- (void)downloadPDFFile1{
    
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]stringByAppendingPathComponent:@"photo1.pdf"];
    NSLog(@"下载到：%@",filePath);
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSLog(@"已经有该文件了:%@",filePath);
        return;
    }
    
    NSString *pdfPath = @"https://www.tutorialspoint.com/ios/ios_tutorial.pdf";
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:pdfPath]];
    
    BOOL isWrite = [data writeToFile:filePath atomically:YES];
    if (isWrite) {
        NSLog(@"保存成功");
    } else {
        NSLog(@"写入失败");
    }
}

- (void)downloadPDFFile2{
    
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]stringByAppendingPathComponent:@"photo2.pdf"];
    NSLog(@"下载到：%@",filePath);
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSLog(@"已经有该文件了:%@",filePath);
        return;
    }
    
//    NSString *pdfPath = [[NSBundle mainBundle] pathForResource:@"photo" ofType:@"pdf"];
    NSString *pdfPath = @"https://www.tutorialspoint.com/ios/ios_tutorial.pdf";
    //创建 Request
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:pdfPath]];
    
    //下载进行中的事件
    [SVProgressHUD show];
    /* 开始请求下载 */
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"下载进度：%.0f％", downloadProgress.fractionCompleted * 100);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //如果需要进行UI操作，需要获取主线程进行操作
        });
        /* 设定下载到的位置 */
        return [NSURL fileURLWithPath:filePath];

    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"下载完成");
        [SVProgressHUD dismiss];
    }];
    [downloadTask resume];
}

#pragma mark - 图片转PDF文件
-(void)createPDFFileInView:(UIImageView *)imgView{
    
    NSString *newFilePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"myPDF.pdf"];
    NSLog(@"%@",newFilePath);
    const char *filename = [newFilePath UTF8String];
//    CGRect pageRect = CGRectMake(0, 0, 612, 792);
    CGRect pageRect = imgView.bounds;

    CFStringRef path;
    CFURLRef url;
    CFMutableDictionaryRef myDictionary = NULL;
    CGContextRef pdfContext;
    path = CFStringCreateWithCString (NULL, filename, kCFStringEncodingUTF8);
    url = CFURLCreateWithFileSystemPath (NULL, path, kCFURLPOSIXPathStyle, 0);
    // This dictionary contains extra options mostly for ‘signing’ the PDF
    myDictionary = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(myDictionary, kCGPDFContextTitle, CFSTR("My PDF File"));
    CFDictionarySetValue(myDictionary, kCGPDFContextCreator, CFSTR("My Name"));
    pdfContext = CGPDFContextCreateWithURL (url, &pageRect, myDictionary);
    CFRelease(myDictionary);
    CFRelease(url);
    CFRelease (path);

//    CGContextBeginPage (pdfContext, &pageRect);
    CGPDFContextBeginPage(pdfContext, myDictionary);
    
    

    UIImage* myUIImage = imgView.image;
    CGImageRef pageImage = [myUIImage CGImage];
    
    CGRect scaleRect = [self scaleImageView:imgView image:imgView.image];
    CGContextDrawImage(pdfContext, scaleRect, pageImage); //绘制图片
    // Draws a black rectangle around the page inset by 50 on all sides
//    CGContextStrokeRect(pdfContext, CGRectMake(50, 50, pageRect.size.width - 100, pageRect.size.height - 100));

    // Adding some text on top of the image we just added
//    CGContextSelectFont (pdfContext, "Helvetica", 30, kCGEncodingMacRoman);
//    CGContextSetTextDrawingMode (pdfContext, kCGTextFill);
//    CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);

    UIGraphicsPushContext(pdfContext);  //将需要绘制的层push
    CGContextTranslateCTM(pdfContext, 0, imgView.bounds.size.height);  //转换Y轴坐标,  底层坐标与cocoa 组件不同 Y轴相反
    CGContextScaleCTM(pdfContext, 1, -1);

//    CGContextShowTextAtPoint (pdfContext, 260, 390, [text UTF8String], strlen([text UTF8String])); //汉字不正常

//    [text drawAtPoint:CGPointMake(80, 80) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18]}];  //绘制汉字

//    UIFont *font = [UIFont systemFontOfSize:15 ]; //自定义字体
//    CGContextSetFillColorWithColor(pdfContext, [UIColor blackColor].CGColor); //颜色
//    [text drawAtPoint:CGPointMake(260,390) forWidth:50 withFont:font minFontSize:8 actualFontSize:NULL lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignCenters];

    UIGraphicsPopContext();


    CGContextStrokePath(pdfContext);

    // End text
    // We are done drawing to this page, let’s end it
    // We could add as many pages as we wanted using CGContextBeginPage/CGContextEndPage
//    CGContextEndPage (pdfContext);
    CGPDFContextEndPage(pdfContext);
    // We are done with our context now, so we release it
    CGContextRelease (pdfContext);
    
//    CFDictionaryRef page3Dictionary = CFDictionaryCreate(NULL, (const void **) myKeys, (const void **) myValues, 2,&kCFTypeDictionaryKeyCallBacks, & kCFTypeDictionaryValueCallBacks);
//    CGPDFContextBeginPage(myPDFContext, page3Dictionary);
//    CGContextSetRGBFillColor (myPDFContext, 0, 0, 0, 1);
//    CGPDFContextEndPage(myPDFContext);
}

- (CGRect)scaleImageView:(UIView *)imageView image:(UIImage *)image {
    
    if (imageView.bounds.size.width == 0 || imageView.bounds.size.height == 0 || image.size.width == 0 || image.size.height == 0) {
        return CGRectZero;
    }
    CGSize size;
    if (imageView.bounds.size.width / imageView.bounds.size.height > image.size.width / image.size.height) {
        size = CGSizeMake(imageView.bounds.size.height/image.size.height*image.size.width, imageView.bounds.size.height);
    } else {
        size = CGSizeMake(imageView.bounds.size.width, imageView.bounds.size.width/image.size.width*image.size.height);
    }
    //    return [CommonTool drawImage:image toSize:size];
    
    return CGRectMake(imageView.bounds.origin.x+(imageView.bounds.size.width-size.width)*0.5, imageView.bounds.origin.y+(imageView.bounds.size.height-size.height)*0.5, size.width, size.height);
}

#pragma mark - 创建绘制PDF文件
-(void)creatPDFfile
{
    // 1.创建media box
    CGFloat myPageWidth = self.view.bounds.size.width;
    CGFloat myPageHeight = self.view.bounds.size.height;
    CGRect mediaBox = CGRectMake (0, 0, myPageWidth, myPageHeight);
    
    // 2.设置pdf文档存储的路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *filePath = [documentsDirectory stringByAppendingString:@"/test.pdf"];
    NSLog(@"filePath：%@", filePath);
    const char *cfilePath = [filePath UTF8String];
    CFStringRef pathRef = CFStringCreateWithCString(NULL, cfilePath, kCFStringEncodingUTF8);
    
    
    // 3.设置当前pdf页面的属性
    CFStringRef myKeys[3];
    CFTypeRef myValues[3];
    myKeys[0] = kCGPDFContextMediaBox;
    myValues[0] = (CFTypeRef) CFDataCreate(NULL,(const UInt8 *)&mediaBox, sizeof (CGRect));
    myKeys[1] = kCGPDFContextTitle;
    myValues[1] = CFSTR("我的PDF");
    myKeys[2] = kCGPDFContextCreator;
    myValues[2] = CFSTR("Jymn_Chen");
    CFDictionaryRef pageDictionary = CFDictionaryCreate(NULL, (const void **) myKeys, (const void **) myValues, 3,&kCFTypeDictionaryKeyCallBacks, & kCFTypeDictionaryValueCallBacks);
    
    
    // 4.获取pdf绘图上下文
    CGContextRef myPDFContext = MyPDFContextCreate (&mediaBox, pathRef);
    
    
    // 5.开始描绘第一页页面
    CGPDFContextBeginPage(myPDFContext, pageDictionary);
    CGContextSetRGBFillColor (myPDFContext, 1, 0, 0, 1);
    CGContextFillRect (myPDFContext, CGRectMake (0, 0, 200, 100 ));
    CGContextSetRGBFillColor (myPDFContext, 0, 0, 1, .5);
    CGContextFillRect (myPDFContext, CGRectMake (0, 0, 100, 200 ));
    
    // 为一个矩形设置URL链接www.baidu.com
    CFURLRef baiduURL = CFURLCreateWithString(NULL, CFSTR("http://www.baidu.com"), NULL);
    CGContextSetRGBFillColor (myPDFContext, 0, 0, 0, 1);
    CGContextFillRect (myPDFContext, CGRectMake (200, 200, 100, 200 ));
    CGPDFContextSetURLForRect(myPDFContext, baiduURL, CGRectMake (200, 200, 100, 200 ));
    
    // 为一个矩形设置一个跳转终点
    CGPDFContextAddDestinationAtPoint(myPDFContext, CFSTR("page"), CGPointMake(120.0, 400.0));
    CGPDFContextSetDestinationForRect(myPDFContext, CFSTR("page"), CGRectMake(50.0, 300.0, 100.0, 100.0)); // 跳转点的name为page
    //    CGPDFContextSetDestinationForRect(myPDFContext, CFSTR("page2"), CGRectMake(50.0, 300.0, 100.0, 100.0)); // 跳转点的name为page2
    CGContextSetRGBFillColor(myPDFContext, 1, 0, 1, 0.5);
    CGContextFillEllipseInRect(myPDFContext, CGRectMake(50.0, 300.0, 100.0, 100.0));
    
    CGPDFContextEndPage(myPDFContext);
    
    
    // 6.开始描绘第二页页面
    // 注意要另外创建一个page dictionary
    CFDictionaryRef page2Dictionary = CFDictionaryCreate(NULL, (const void **) myKeys, (const void **) myValues, 3,&kCFTypeDictionaryKeyCallBacks, & kCFTypeDictionaryValueCallBacks);
    CGPDFContextBeginPage(myPDFContext, page2Dictionary);
    
    // 在左下角画两个矩形
    CGContextSetRGBFillColor (myPDFContext, 1, 0, 0, 1);
    CGContextFillRect (myPDFContext, CGRectMake (0, 0, 200, 100 ));
    CGContextSetRGBFillColor (myPDFContext, 0, 0, 1, .5);
    CGContextFillRect (myPDFContext, CGRectMake (0, 0, 100, 200 ));
    
    // 在右下角写一段文字:"Page 2"
    CGContextSelectFont(myPDFContext, "Helvetica", 30, kCGEncodingMacRoman);
    CGContextSetTextDrawingMode (myPDFContext, kCGTextFill);
    CGContextSetRGBFillColor (myPDFContext, 0, 0, 0, 1);
    const char *text = [@"Page 2" UTF8String];
    CGContextShowTextAtPoint (myPDFContext, 120, 80, text, strlen(text));
    //    CGPDFContextAddDestinationAtPoint(myPDFContext, CFSTR("page2"), CGPointMake(120.0, 120.0));  // 跳转点的name为page2
    //    CGPDFContextAddDestinationAtPoint(myPDFContext, CFSTR("page"), CGPointMake(120.0, 120.0)); // 跳转点的name为page
    
    // 为右上角的矩形设置一段file URL链接，打开本地文件
    NSURL *furl = [NSURL fileURLWithPath:@"/Users/one/Library/Application Support/iPhone Simulator/7.0/Applications/3E7CB341-693A-4FE4-8FE5-A827A5210F0A/Documents/test1.pdf"];
    CFURLRef fileURL = (__bridge CFURLRef)furl;
    CGContextSetRGBFillColor (myPDFContext, 0, 0, 0, 1);
    CGContextFillRect (myPDFContext, CGRectMake (200, 200, 100, 200 ));
    CGPDFContextSetURLForRect(myPDFContext, fileURL, CGRectMake (200, 200, 100, 200 ));
    
    CGPDFContextEndPage(myPDFContext);
    
    
    // 7.创建第三页内容
    CFDictionaryRef page3Dictionary = CFDictionaryCreate(NULL, (const void **) myKeys, (const void **) myValues, 3,&kCFTypeDictionaryKeyCallBacks, & kCFTypeDictionaryValueCallBacks);
    CGPDFContextBeginPage(myPDFContext, page3Dictionary);
    CGContextSetRGBFillColor (myPDFContext, 0, 0, 0, 1);
    CGPDFContextEndPage(myPDFContext);
    
    
    // 8.释放创建的对象
    CFRelease(page3Dictionary);
    CFRelease(page2Dictionary);
    CFRelease(pageDictionary);
    CFRelease(myValues[0]);
    CGContextRelease(myPDFContext);
}

/*
 * 获取pdf绘图上下文
 * inMediaBox指定pdf页面大小
 * path指定pdf文件保存的路径
 */
CGContextRef MyPDFContextCreate (const CGRect *inMediaBox, CFStringRef path)
{
    CGContextRef myOutContext = NULL;
    CFURLRef url;
    CGDataConsumerRef dataConsumer;
    
    url = CFURLCreateWithFileSystemPath (NULL, path, kCFURLPOSIXPathStyle, false);
    
    if (url != NULL)
    {
        dataConsumer = CGDataConsumerCreateWithURL(url);
        if (dataConsumer != NULL)
        {
            myOutContext = CGPDFContextCreate (dataConsumer, inMediaBox, NULL);
            CGDataConsumerRelease (dataConsumer);
        }
        CFRelease(url);
    }
    return myOutContext;
}


@end
