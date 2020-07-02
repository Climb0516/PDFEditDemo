//
//  ViewController.m
//  CreatePDFDemo
//
//  Created by Climb 王 on 2020/7/1.
//  Copyright © 2020 Climb 王. All rights reserved.
//

#import "ViewController.h"

#import "UIImage+GIF.h"

#import "ModelFile.h"
#import "MBProgressHUD.h"
#import "MBProgressHUD+JJ.h"
#import "ReaderViewController.h"

#define kWeakSelf  __weak typeof(self) weakSelf = self;

@interface ViewController ()<ReaderViewControllerDelegate, UIScrollViewDelegate>
@property (nonatomic, assign) NSInteger testNumPage;//第几个PDF
@property (nonatomic, copy) NSString *test1FilePath;
@property (nonatomic, copy) NSString *test2FilePath;
@property (nonatomic, copy) NSString *test3FilePath;

@property (nonatomic, strong) UIScrollView *theScrollView;
@property (nonatomic, strong) ReaderViewController *readerViewController1;
@property (nonatomic, strong) ReaderViewController *readerViewController2;
@property (nonatomic, strong) ReaderViewController *readerViewController3;
@property (nonatomic, strong) UIButton *uploadBtn;
@property (nonatomic, strong) UIView *loadingView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor orangeColor];
    
    
//    [MBProgressHUD showSuccess:@"test"];
    
    self.theScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.theScrollView.autoresizesSubviews = NO;
    self.theScrollView.bounces = NO;
    self.theScrollView.contentMode = UIViewContentModeRedraw;
    self.theScrollView.showsHorizontalScrollIndicator = NO;
    self.theScrollView.showsVerticalScrollIndicator = NO;
    self.theScrollView.scrollsToTop = NO;
    self.theScrollView.delaysContentTouches = NO;
    self.theScrollView.pagingEnabled = YES;
    self.theScrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.theScrollView.backgroundColor = [UIColor clearColor];
    self.theScrollView.delegate = self;
    [self.view addSubview:self.theScrollView];
    self.theScrollView.contentSize = CGSizeMake(self.view.frame.size.width*3, 0);
    
    kWeakSelf
    // 添加group，把接口放进里面进行请求
    dispatch_group_t group = dispatch_group_create();

    dispatch_group_enter(group);
    NSString *pdfPath;
    if (self.test1FilePath) {
        pdfPath = self.test1FilePath;
    }else {
        pdfPath = [[NSBundle mainBundle] pathForResource:@"test_1" ofType:@"pdf"];
    }
    ModelFile *file = [[ModelFile alloc] init];
    file.name = @"PDF 测试文件";
    file.notice_mime_id = @"1";
    ReaderDocument *document = [ReaderDocument withDocumentFilePath:pdfPath password:nil];
    self.readerViewController1 = [[ReaderViewController alloc] initWithReaderDocument:document fileName:file.name canEdit:YES fileID:file.notice_mime_id showPage:1];
    self.readerViewController1.testNumPage = 1;
    self.readerViewController1.delegate = self;
    self.readerViewController1.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.theScrollView addSubview:self.readerViewController1.view];
    self.readerViewController1.didCreateNewPDFBlock = ^(NSString *pdfPath) {
        NSLog(@"111--%@",pdfPath);
        weakSelf.test1FilePath = pdfPath;
        dispatch_group_leave(group);
    };
    
    dispatch_group_enter(group);
    NSString *pdf2Path;
    if (self.test2FilePath) {
        pdf2Path = self.test2FilePath;
    }else {
        pdf2Path = [[NSBundle mainBundle] pathForResource:@"test_2" ofType:@"pdf"];
    }
    ModelFile *file2 = [[ModelFile alloc] init];
    file2.name = @"PDF 测试文件";
    file2.notice_mime_id = @"1";
    ReaderDocument *document2 = [ReaderDocument withDocumentFilePath:pdf2Path password:nil];
    self.readerViewController2 = [[ReaderViewController alloc] initWithReaderDocument:document2 fileName:file2.name canEdit:YES fileID:file2.notice_mime_id showPage:1];
    self.readerViewController2.testNumPage = 2;
    //        [readerViewController destructionNewPdfFile];
    self.readerViewController2.delegate = self;
    self.readerViewController2.view.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.theScrollView addSubview:self.readerViewController2.view];
    self.readerViewController2.didCreateNewPDFBlock = ^(NSString *pdfPath) {
        NSLog(@"222--%@",pdfPath);
        weakSelf.test2FilePath = pdfPath;
        dispatch_group_leave(group);
    };
    
    dispatch_group_enter(group);
    NSString *pdf3Path;
    if (self.test3FilePath) {
        pdf3Path = self.test3FilePath;
    }else {
        pdf3Path = [[NSBundle mainBundle] pathForResource:@"test_3" ofType:@"pdf"];
    }
    ModelFile *file3 = [[ModelFile alloc] init];
    file3.name = @"PDF 测试文件3";
    file3.notice_mime_id = @"3";
    ReaderDocument *document3 = [ReaderDocument withDocumentFilePath:pdf3Path password:nil];
    self.readerViewController3 = [[ReaderViewController alloc] initWithReaderDocument:document3 fileName:file3.name canEdit:YES fileID:file3.notice_mime_id showPage:1];
    self.readerViewController3.testNumPage = 3;
    self.readerViewController3.delegate = self;
    self.readerViewController3.view.frame = CGRectMake(self.view.frame.size.width*2, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.theScrollView addSubview:self.readerViewController3.view];
    self.readerViewController3.didCreateNewPDFBlock = ^(NSString *pdfPath) {
        NSLog(@"333--%@",pdfPath);
        weakSelf.test3FilePath = pdfPath;
        dispatch_group_leave(group);
    };
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self testAllInAction];
//        [MBProgressHUD showActivityMessage:@"加载中。。"];
//        [MBProgressHUD hideHUD];
        [self.loadingView removeFromSuperview];
        [MBProgressHUD showSuccess:@"合成PDF成功"];
    });

    [self.view addSubview:self.loadingView];
//    NSString *filePath = [[NSBundle bundleWithPath:[[NSBundle mainBundle] bundlePath]]pathForResource:@"1" ofType:@"gif"];
//    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
//    UIImage *gif = [UIImage sd_imageWithGIFData:imageData];
//    self.uploadBtn = [UIButton new];
//    [self.uploadBtn setImage:gif forState:UIControlStateNormal];
////    [self.uploadBtn setTitle:@"upload" forState:UIControlStateNormal];
//    self.uploadBtn.frame = self.view.bounds;
//    self.uploadBtn.alpha = 0.3;
//    self.uploadBtn.backgroundColor = [UIColor redColor];
//    [self.theScrollView addSubview:self.uploadBtn];
//    [self.uploadBtn addTarget:self action:@selector(testAllInAction) forControlEvents:UIControlEventTouchUpInside];
}


- (UIView *)loadingView {
    if (!_loadingView) {
        _loadingView = [UIView new];
        _loadingView.frame = self.view.bounds;
        _loadingView.backgroundColor = [UIColor blackColor];
        _loadingView.alpha = 0.7;
        UIImage *image = [UIImage imageNamed:@"loading_white"];
        UIImageView * animationImageView = [[UIImageView alloc] initWithImage:image];
        CABasicAnimation* rotationAnimation;
        rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
        rotationAnimation.duration = 2;
        rotationAnimation.cumulative = YES;
        rotationAnimation.removedOnCompletion = NO;//保证切换到其他页面或进入后台再回来动画继续执行
        rotationAnimation.repeatCount = CGFLOAT_MAX;
        [animationImageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
        [_loadingView addSubview:animationImageView];
        animationImageView.frame = CGRectMake(self.view.bounds.size.width/2-24, self.view.bounds.size.height/2-24, 48.f, 48.f);
    }
    return _loadingView;;
}

- (void)testAllInAction {
    NSMutableArray *arrPdfPaths = [[NSMutableArray alloc] init];
//    for (NSInteger i = 1; i <= maximumPage; i++) {
//        NSString *pdfPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/filePages/outPutPDF_%ld.pdf", kDataProcessingPdf, (long)i];
//        [arrPdfPaths addObject:pdfPath];
//    }
    NSLog(@"111--%@\n 222--%@\n 333-%@",self.test1FilePath,self.test2FilePath,self.test3FilePath);
    [arrPdfPaths addObject:self.test1FilePath];
    [arrPdfPaths addObject:self.test2FilePath];
    [arrPdfPaths addObject:self.test3FilePath];
    
    NSString *filePath = [self joinPDF:arrPdfPaths pdfPathOutput:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/dataProcessingPdf/newAllInPdf.pdf"]];
    NSLog(@"444%@",filePath);
//    ModelFile *file = [[ModelFile alloc] init];
//    file.name = @"PDF 整合文件";
//    file.notice_mime_id = @"4";
//    self.testNumPage = 4;
//    [self openPDFWithModel:file filePath:filePath testNum:self.testNumPage];
    
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    NSLog(@"整合后的PDF打印：%@", data);
}


#pragma mark - 打开PDF文件
- (void)openPDFWithModel:(ModelFile *)file filePath:(NSString *)filePath testNum:(NSInteger)testNum
{
    ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:nil];
    
    if (document != nil) // Must have a valid ReaderDocument object in order to proceed with things
    {
        ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document fileName:file.name canEdit:YES fileID:file.notice_mime_id showPage:1];
        readerViewController.testNumPage = testNum;
//        [readerViewController destructionNewPdfFile];
        readerViewController.delegate = self; // Set the ReaderViewController delegate to self
        
        readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
//        readerViewController.view.backgroundColor = [UIColor clearColor];
        [self presentViewController:readerViewController animated:YES completion:NULL];
    }
    else // Log an error so that we know that something went wrong
    {
        NSLog(@"PDF文件打开失败");
    }
}

#pragma mark - ReaderViewControllerDelegate

- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
    
    [viewController destructionNewPdfFile];
}

/** 已经生成一个新的文件 */
- (void)readerViewController:(ReaderViewController *)viewController didCreateNewPdfWithPath:(NSString *)pdfPath fileName:(NSString *)fileName fileID:(NSString *)fileID currPage:(NSInteger)currPage
{
//    if (currPage == 1) {
//        self.test1FilePath = pdfPath;
//        NSLog(@"111");
//        [self test2Action];
//    }else if (currPage == 2) {
//        self.test2FilePath = pdfPath;
//        NSLog(@"222");
//        [self test3Action];
//    }else if (currPage == 3) {
//        self.test3FilePath = pdfPath;
//        NSLog(@"333");
//        [self testAllInAction];
//    }
}

/**
 *@  整合 PDF 文件
 *@  listOfPaths  需要整和文件路径数组
 *@  整合后的文件输出
 */

- (NSString *)joinPDF:(NSArray *)listOfPaths pdfPathOutput:(NSString *)pdfPathOutput{
    
    CFURLRef pdfURLOutput = (  CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:pdfPathOutput]);
    NSInteger numberOfPages = 0;
    CGContextRef writeContext = CGPDFContextCreateWithURL(pdfURLOutput, NULL, NULL);
    
    for (NSString *source in listOfPaths) {
        
        CFURLRef pdfURL = (  CFURLRef)CFBridgingRetain([[NSURL alloc] initFileURLWithPath:source]);
        CGPDFDocumentRef pdfRef = CGPDFDocumentCreateWithURL((CFURLRef) pdfURL);
        numberOfPages = CGPDFDocumentGetNumberOfPages(pdfRef);
        CGPDFPageRef page;
        CGRect mediaBox;
        
        for (int i=1; i<=numberOfPages; i++) {
            
            page = CGPDFDocumentGetPage(pdfRef, i);
            mediaBox = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
            CGContextBeginPage(writeContext, &mediaBox);
            CGContextDrawPDFPage(writeContext, page);
            CGContextEndPage(writeContext);
            
        }
        CGPDFDocumentRelease(pdfRef);
        CFRelease(pdfURL);
    }
    
    CFRelease(pdfURLOutput);
    CGPDFContextClose(writeContext);
    CGContextRelease(writeContext);
    
    return pdfPathOutput;
}

@end
