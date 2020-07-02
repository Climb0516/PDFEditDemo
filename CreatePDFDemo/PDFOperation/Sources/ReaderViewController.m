//
//	ReaderViewController.m
//	Reader v2.8.6
//
//	Created by Julius Oklamcak on 2011-07-01.
//	Copyright © 2011-2015 Julius Oklamcak. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//	of the Software, and to permit persons to whom the Software is furnished to
//	do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "ReaderConstants.h"
#import "ReaderViewController.h"
#import "ThumbsViewController.h"
#import "ReaderMainToolbar.h"
#import "ReaderMainPagebar.h"
#import "ReaderContentView.h"
#import "ReaderThumbCache.h"
#import "ReaderThumbQueue.h"

#import "UIButtonSuspension.h"
#import "UIImageViewSign.h"
#import "ReaderContentPage.h"

#import "NewMySignatureViewController.h"

#import "NSString+IntervalSince1970.h"

#import "UIControllerPDFOpinionEdit.h"

#import <MessageUI/MessageUI.h>
#import "UIViewExt.h"

/** 处理pdf文件 使用的文件夹 */
#define kDataProcessingPdf @"dataProcessingPdf"

typedef NS_ENUM(NSInteger, PDFCurrEditType) {
    PDFCurrEditType_None = 0,
    PDFCurrEditType_Sign = 1,
    PDFCurrEditType_Opinion = 2
};

@interface ReaderViewController ()
<UIScrollViewDelegate,
UIGestureRecognizerDelegate,
MFMailComposeViewControllerDelegate,
UIDocumentInteractionControllerDelegate,
ReaderMainToolbarDelegate,
ReaderMainPagebarDelegate,
ReaderContentViewDelegate,
ThumbsViewControllerDelegate,
UIActionSheetDelegate,
UIImageViewSignDelegate,
UIControllerPDFOpinionEditDelegate,
UIAlertViewDelegate>

/** 签名按钮 */
@property (nonatomic, strong) UIButtonSuspension *btnSign;

/** 意见按钮 */
@property (nonatomic, strong) UIButtonSuspension *btnOpinion;

/** 签名完成按钮 */
@property (nonatomic, strong) UIButtonSuspension *btnSignDone;

/** 签名图片 */
@property (nonatomic, strong) UIImageViewSign *idCardFrontImageViewSign;
@property (nonatomic, strong) UIImageViewSign *idCardBackImageViewSign;
@property (nonatomic, strong) UIImageViewSign *faceImageViewSign;//人脸识别人脸照片
@property (nonatomic, strong) UIImageViewSign *socialCardImageViewSign;
@property (nonatomic, strong) UIImageViewSign *currentFaceImageViewSign;//现场人脸
@property (nonatomic, strong) UIImageViewSign *titleImageViewOpinion;
@property (nonatomic, strong) UIImageViewSign *cardNumImageViewOpinion;
@property (nonatomic, strong) UIImageViewSign *liushuihaoImageViewOpinion;
@property (nonatomic, strong) UIImageViewSign *customNameImageViewOpinion;
@property (nonatomic, strong) UIImageViewSign *timeImageViewOpinion;
@property (nonatomic, strong) UIImageViewSign *idNumImageViewOpinion;//身份证号码
@property (nonatomic, strong) UIImageViewSign *nameImageViewOpinion;
@property (nonatomic, strong) UIImageViewSign *resultImageViewOpinion;


@property (nonatomic, strong) UIImageViewSign *seccondApplyDateImageViewSign;
@property (nonatomic, strong) UIImageViewSign *seccondTradeJigouImageViewSign;
@property (nonatomic, strong) UIImageViewSign *seccondTradeNameImageViewSign;
@property (nonatomic, strong) UIImageViewSign *seccondCardNumImageViewSign;
@property (nonatomic, strong) UIImageViewSign *seccondCertificateNumImageViewSign;
@property (nonatomic, strong) UIImageViewSign *seccondTradeTimeImageViewSign;
@property (nonatomic, strong) UIImageViewSign *seccondLiushuihaoImageViewSign;
@property (nonatomic, strong) UIImageViewSign *seccondCustomerNameImageViewSign;
@property (nonatomic, strong) UIImageViewSign *seccondCertificateTypeImageViewSign;
@property (nonatomic, strong) UIImageViewSign *seccondCounterNumImageViewSign;
@property (nonatomic, strong) UIImageViewSign *seccondMidNameImageViewSign;
@property (nonatomic, strong) UIImageViewSign *seccondMidCardNumImageViewSign;
@property (nonatomic, strong) UIImageViewSign *seccondMidCertificateNameImageViewSign;
@property (nonatomic, strong) UIImageViewSign *seccondMidCertificateNumImageViewSign;
@property (nonatomic, strong) UIImageViewSign *secondNameSignImageViewSign;//客户签名图片

@property (nonatomic, strong) UIImageViewSign *thirdNameImageViewSign;
@property (nonatomic, strong) UIImageViewSign *thirdNameSignImageViewSign;
@property (nonatomic, strong) UIImageViewSign *thirdDateImageViewSign;

/** 签名时间图片 */
//@property (nonatomic, strong) UIImageViewSign *imageViewSignTime;

@property (nonatomic, strong) UIImageViewSign *imageViewOpinion8;
@property (nonatomic, strong) UIImageViewSign *imageViewOpinion9;

/** 正在编辑的类型 */
@property (nonatomic, assign) PDFCurrEditType currEditType;

/** 是否可以编辑PDF文件 */
@property (nonatomic, assign) BOOL canEditPdf;

/** PDF 文件名称 */
@property (nonatomic, strong) NSString *PdfFileName;

/** 文件ID */
@property (nonatomic, strong) NSString *fileID;

/** 展示文件页码 */
@property (nonatomic, assign) NSInteger showPage;
@end

@implementation ReaderViewController
{
	ReaderDocument *document;

	UIScrollView *theScrollView;

	ReaderMainToolbar *mainToolbar;

	ReaderMainPagebar *mainPagebar;

	NSMutableDictionary *contentViews;

	UIUserInterfaceIdiom userInterfaceIdiom;

	NSInteger currentPage, minimumPage, maximumPage;

	UIDocumentInteractionController *documentInteraction;

	UIPrintInteractionController *printInteraction;

	CGFloat scrollViewOutset;

	CGSize lastAppearSize;

	NSDate *lastHideTime;

	BOOL ignoreDidScroll;
    
}

#pragma mark - 签名按钮

/**
 *@ 按钮大小
 */
#define kBtnSignWidth (54)

/**
 *@ 上方吸引距离
 */
#define kSignTopSpace (100)

/**
 *@ 下方吸引距离
 */
#define kSignBottomSpace (100)

#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width

#pragma mark - Constants

#define STATUS_HEIGHT 20.0f

#define TOOLBAR_HEIGHT 44.0f
#define PAGEBAR_HEIGHT 48.0f

#define SCROLLVIEW_OUTSET_SMALL 4.0f
#define SCROLLVIEW_OUTSET_LARGE 8.0f

#define TAP_AREA_SIZE 48.0f

#pragma mark - Properties

@synthesize delegate;

#pragma mark - ReaderViewController methods

- (void)updateContentSize:(UIScrollView *)scrollView
{
	CGFloat contentHeight = scrollView.bounds.size.height; // Height

	CGFloat contentWidth = (scrollView.bounds.size.width * maximumPage);

	scrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
}

- (void)updateContentViews:(UIScrollView *)scrollView
{
	[self updateContentSize:scrollView]; // Update content size first

	[contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
		^(NSNumber *key, ReaderContentView *contentView, BOOL *stop)
		{
			NSInteger page = [key integerValue]; // Page number value

			CGRect viewRect = CGRectZero; viewRect.size = scrollView.bounds.size;

			viewRect.origin.x = (viewRect.size.width * (page - 1)); // Update X

			contentView.frame = CGRectInset(viewRect, scrollViewOutset, 0.0f);
		}
	];

	NSInteger page = currentPage; // Update scroll view offset to current page

	CGPoint contentOffset = CGPointMake((scrollView.bounds.size.width * (page - 1)), 0.0f);

	if (CGPointEqualToPoint(scrollView.contentOffset, contentOffset) == false) // Update
	{
		scrollView.contentOffset = contentOffset; // Update content offset
	}

	[mainToolbar setBookmarkState:[document.bookmarks containsIndex:page]];

	[mainPagebar updatePagebar]; // Update page bar
}

- (void)addContentView:(UIScrollView *)scrollView page:(NSInteger)page
{
	CGRect viewRect = CGRectZero; viewRect.size = scrollView.bounds.size;

	viewRect.origin.x = (viewRect.size.width * (page - 1)); viewRect = CGRectInset(viewRect, scrollViewOutset, 0.0f);

	NSURL *fileURL = document.fileURL; NSString *phrase = document.password; NSString *guid = document.guid; // Document properties

	ReaderContentView *contentView = [[ReaderContentView alloc] initWithFrame:viewRect fileURL:fileURL page:page password:phrase]; // ReaderContentView

	contentView.message = self; [contentViews setObject:contentView forKey:[NSNumber numberWithInteger:page]]; [scrollView addSubview:contentView];

	[contentView showPageThumb:fileURL page:page password:phrase guid:guid]; // Request page preview thumb
}

- (void)layoutContentViews:(UIScrollView *)scrollView
{
	CGFloat viewWidth = scrollView.bounds.size.width; // View width

	CGFloat contentOffsetX = scrollView.contentOffset.x; // Content offset X

	NSInteger pageB = ((contentOffsetX + viewWidth - 1.0f) / viewWidth); // Pages

	NSInteger pageA = (contentOffsetX / viewWidth); pageB += 2; // Add extra pages

	if (pageA < minimumPage) pageA = minimumPage; if (pageB > maximumPage) pageB = maximumPage;

	NSRange pageRange = NSMakeRange(pageA, (pageB - pageA + 1)); // Make page range (A to B)

	NSMutableIndexSet *pageSet = [NSMutableIndexSet indexSetWithIndexesInRange:pageRange];

	for (NSNumber *key in [contentViews allKeys]) // Enumerate content views
	{
		NSInteger page = [key integerValue]; // Page number value

		if ([pageSet containsIndex:page] == NO) // Remove content view
		{
			ReaderContentView *contentView = [contentViews objectForKey:key];

			[contentView removeFromSuperview]; [contentViews removeObjectForKey:key];
		}
		else // Visible content view - so remove it from page set
		{
			[pageSet removeIndex:page];
		}
	}

	NSInteger pages = pageSet.count;

	if (pages > 0) // We have pages to add
	{
		NSEnumerationOptions options = 0; // Default

		if (pages == 2) // Handle case of only two content views
		{
			if ((maximumPage > 2) && ([pageSet lastIndex] == maximumPage)) options = NSEnumerationReverse;
		}
		else if (pages == 3) // Handle three content views - show the middle one first
		{
			NSMutableIndexSet *workSet = [pageSet mutableCopy]; options = NSEnumerationReverse;

			[workSet removeIndex:[pageSet firstIndex]]; [workSet removeIndex:[pageSet lastIndex]];

			NSInteger page = [workSet firstIndex]; [pageSet removeIndex:page];

			[self addContentView:scrollView page:page];
		}

		[pageSet enumerateIndexesWithOptions:options usingBlock: // Enumerate page set
			^(NSUInteger page, BOOL *stop)
			{
				[self addContentView:scrollView page:page];
			}
		];
	}
}

- (void)handleScrollViewDidEnd:(UIScrollView *)scrollView
{
	CGFloat viewWidth = scrollView.bounds.size.width; // Scroll view width

	CGFloat contentOffsetX = scrollView.contentOffset.x; // Content offset X

	NSInteger page = (contentOffsetX / viewWidth); page++; // Page number

	if (page != currentPage) // Only if on different page
	{
		currentPage = page; document.pageNumber = [NSNumber numberWithInteger:page];

		[contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
			^(NSNumber *key, ReaderContentView *contentView, BOOL *stop)
			{
				if ([key integerValue] != page) [contentView zoomResetAnimated:NO];
			}
		];

		[mainToolbar setBookmarkState:[document.bookmarks containsIndex:page]];

		[mainPagebar updatePagebar]; // Update page bar
	}
}

- (void)showDocumentPage:(NSInteger)page
{
	if (page != currentPage) // Only if on different page
	{
		if ((page < minimumPage) || (page > maximumPage)) return;

		currentPage = page; document.pageNumber = [NSNumber numberWithInteger:page];

		CGPoint contentOffset = CGPointMake((theScrollView.bounds.size.width * (page - 1)), 0.0f);

		if (CGPointEqualToPoint(theScrollView.contentOffset, contentOffset) == true)
			[self layoutContentViews:theScrollView];
		else
			[theScrollView setContentOffset:contentOffset];

		[contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
			^(NSNumber *key, ReaderContentView *contentView, BOOL *stop)
			{
				if ([key integerValue] != page) [contentView zoomResetAnimated:NO];
			}
		];

		[mainToolbar setBookmarkState:[document.bookmarks containsIndex:page]];

		[mainPagebar updatePagebar]; // Update page bar
	}
}

- (void)showDocument
{
	[self updateContentSize:theScrollView]; // Update content size first

	[self showDocumentPage:[document.pageNumber integerValue]]; // Show page

	document.lastOpen = [NSDate date]; // Update document last opened date
}

- (void)closeDocument
{
	if (printInteraction != nil) [printInteraction dismissAnimated:NO];

	[document archiveDocumentProperties]; // Save any ReaderDocument changes

	[[ReaderThumbQueue sharedInstance] cancelOperationsWithGUID:document.guid];

	[[ReaderThumbCache sharedInstance] removeAllObjects]; // Empty the thumb cache

	if ([delegate respondsToSelector:@selector(dismissReaderViewController:)] == YES)
	{
		[delegate dismissReaderViewController:self]; // Dismiss the ReaderViewController
	}
	else // We have a "Delegate must respond to -dismissReaderViewController:" error
	{
		NSAssert(NO, @"Delegate must respond to -dismissReaderViewController:");
	}
}

#pragma mark - UIViewController methods

- (instancetype)initWithReaderDocument:(ReaderDocument *)object fileName:(NSString *)fileName canEdit:(BOOL)canEdit fileID:(NSString *)fileID showPage:(NSInteger)showPage
{
    
    assert(fileID != nil);// fileID 不可为空
    
	if ((self = [super initWithNibName:nil bundle:nil])) // Initialize superclass
	{
		if ((object != nil) && ([object isKindOfClass:[ReaderDocument class]])) // Valid object
		{
			userInterfaceIdiom = [UIDevice currentDevice].userInterfaceIdiom; // User interface idiom

			NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter]; // Default notification center

			[notificationCenter addObserver:self selector:@selector(applicationWillResign:) name:UIApplicationWillTerminateNotification object:nil];

			[notificationCenter addObserver:self selector:@selector(applicationWillResign:) name:UIApplicationWillResignActiveNotification object:nil];

			scrollViewOutset = ((userInterfaceIdiom == UIUserInterfaceIdiomPad) ? SCROLLVIEW_OUTSET_LARGE : SCROLLVIEW_OUTSET_SMALL);

			[object updateDocumentProperties]; document = object; // Retain the supplied ReaderDocument object for our use

			[ReaderThumbCache touchThumbCacheWithGUID:object.guid]; // Touch the document thumb cache directory
            
            self.PdfFileName = fileName;
            
            self.canEditPdf = canEdit;
            
            self.fileID = fileID;
            
            self.showPage = showPage;
		}
		else // Invalid ReaderDocument object
		{
			self = nil;
		}
	}

	return self;
}

- (void)dealloc
{
    [self deletePdfPageFiles];
    
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	assert(document != nil); // Must have a valid ReaderDocument

	self.view.backgroundColor = [UIColor grayColor]; // Neutral gray

//	UIView *fakeStatusBar = nil;
    CGRect viewRect = self.view.bounds; // View bounds
//
//	if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) // iOS 7+
//	{
//		if ([self prefersStatusBarHidden] == NO) // Visible status bar
//		{
//			CGRect statusBarRect = viewRect; statusBarRect.size.height = STATUS_HEIGHT;
//			fakeStatusBar = [[UIView alloc] initWithFrame:statusBarRect]; // UIView
//			fakeStatusBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//			fakeStatusBar.backgroundColor = [UIColor blackColor];
//			fakeStatusBar.contentMode = UIViewContentModeRedraw;
//			fakeStatusBar.userInteractionEnabled = NO;
//
//			viewRect.origin.y += STATUS_HEIGHT; viewRect.size.height -= STATUS_HEIGHT;
//		}
//	}

//	CGRect scrollViewRect = CGRectInset(viewRect, -scrollViewOutset, 0.0f);
	theScrollView = [[UIScrollView alloc] initWithFrame:viewRect]; // All
	theScrollView.autoresizesSubviews = NO;
    theScrollView.contentMode = UIViewContentModeRedraw;
	theScrollView.showsHorizontalScrollIndicator = NO;
    theScrollView.showsVerticalScrollIndicator = NO;
	theScrollView.scrollsToTop = NO;
    theScrollView.delaysContentTouches = NO;
    theScrollView.pagingEnabled = YES;
	theScrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	theScrollView.backgroundColor = [UIColor clearColor];
    theScrollView.delegate = self;
	[self.view addSubview:theScrollView];

//	CGRect toolbarRect = viewRect; toolbarRect.size.height = TOOLBAR_HEIGHT;
//	mainToolbar = [[ReaderMainToolbar alloc] initWithFrame:toolbarRect document:document pdfFileName:self.PdfFileName]; // ReaderMainToolbar
//	mainToolbar.delegate = self; // ReaderMainToolbarDelegate
//	[self.view addSubview:mainToolbar];

//	CGRect pagebarRect = self.view.bounds; pagebarRect.size.height = PAGEBAR_HEIGHT;
//	pagebarRect.origin.y = (self.view.bounds.size.height - pagebarRect.size.height);
//	mainPagebar = [[ReaderMainPagebar alloc] initWithFrame:pagebarRect document:document]; // ReaderMainPagebar
//	mainPagebar.delegate = self; // ReaderMainPagebarDelegate
//	[self.view addSubview:mainPagebar];

//	if (fakeStatusBar != nil)
//    [self.view addSubview:fakeStatusBar]; // Add status bar background view

//	UITapGestureRecognizer *singleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
//	singleTapOne.numberOfTouchesRequired = 1; singleTapOne.numberOfTapsRequired = 1; singleTapOne.delegate = self;
//	[self.view addGestureRecognizer:singleTapOne];
//
//	UITapGestureRecognizer *doubleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
//	doubleTapOne.numberOfTouchesRequired = 1; doubleTapOne.numberOfTapsRequired = 2; doubleTapOne.delegate = self;
//	[self.view addGestureRecognizer:doubleTapOne];
//
//	UITapGestureRecognizer *doubleTapTwo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
//	doubleTapTwo.numberOfTouchesRequired = 2; doubleTapTwo.numberOfTapsRequired = 2; doubleTapTwo.delegate = self;
//	[self.view addGestureRecognizer:doubleTapTwo];
//
//	[singleTapOne requireGestureRecognizerToFail:doubleTapOne]; // Single tap requires double tap to fail

	contentViews = [NSMutableDictionary new];
    lastHideTime = [NSDate date];

	minimumPage = 1;
    maximumPage = [document.pageCount integerValue];
    
    [self _initdata];
    
    [self _loadSubviews];
    
    if (self.testNumPage != 4) {
        [self chickSingItem];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	if (CGSizeEqualToSize(lastAppearSize, CGSizeZero) == false)
	{
		if (CGSizeEqualToSize(lastAppearSize, self.view.bounds.size) == false)
		{
			[self updateContentViews:theScrollView]; // Update content views
		}

		lastAppearSize = CGSizeZero; // Reset view size tracking
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	if (CGSizeEqualToSize(theScrollView.contentSize, CGSizeZero) == true)
	{
		[self performSelector:@selector(showDocument) withObject:nil afterDelay:0.0];
	}

#if (READER_DISABLE_IDLE == TRUE) // Option

	[UIApplication sharedApplication].idleTimerDisabled = YES;

#endif // end of READER_DISABLE_IDLE Option
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	lastAppearSize = self.view.bounds.size; // Track view size

#if (READER_DISABLE_IDLE == TRUE) // Option

	[UIApplication sharedApplication].idleTimerDisabled = NO;

#endif // end of READER_DISABLE_IDLE Option
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	mainToolbar = nil; mainPagebar = nil;

	theScrollView = nil; contentViews = nil; lastHideTime = nil;

	documentInteraction = nil; printInteraction = nil;

	lastAppearSize = CGSizeZero; currentPage = 0;

	[super viewDidUnload];
}

- (BOOL)prefersStatusBarHidden
{
	return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if (userInterfaceIdiom == UIUserInterfaceIdiomPad) if (printInteraction != nil) [printInteraction dismissAnimated:NO];

	ignoreDidScroll = YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	if (CGSizeEqualToSize(theScrollView.contentSize, CGSizeZero) == false)
	{
		[self updateContentViews:theScrollView]; lastAppearSize = CGSizeZero;
	}
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	ignoreDidScroll = NO;
}

- (void)didReceiveMemoryWarning
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	[super didReceiveMemoryWarning];
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (ignoreDidScroll == NO) [self layoutContentViews:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	[self handleScrollViewDidEnd:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	[self handleScrollViewDidEnd:scrollView];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)recognizer shouldReceiveTouch:(UITouch *)touch
{
	if ([touch.view isKindOfClass:[UIScrollView class]]) return YES;

	return NO;
}

#pragma mark - UIGestureRecognizer action methods

- (void)decrementPageNumber
{
	if ((maximumPage > minimumPage) && (currentPage != minimumPage))
	{
		CGPoint contentOffset = theScrollView.contentOffset; // Offset

		contentOffset.x -= theScrollView.bounds.size.width; // View X--

		[theScrollView setContentOffset:contentOffset animated:YES];
	}
}

- (void)incrementPageNumber
{
	if ((maximumPage > minimumPage) && (currentPage != maximumPage))
	{
		CGPoint contentOffset = theScrollView.contentOffset; // Offset

		contentOffset.x += theScrollView.bounds.size.width; // View X++

		[theScrollView setContentOffset:contentOffset animated:YES];
	}
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
	{
		CGRect viewRect = recognizer.view.bounds; // View bounds

		CGPoint point = [recognizer locationInView:recognizer.view]; // Point

		CGRect areaRect = CGRectInset(viewRect, TAP_AREA_SIZE, 0.0f); // Area rect

		if (CGRectContainsPoint(areaRect, point) == true) // Single tap is inside area
		{
			NSNumber *key = [NSNumber numberWithInteger:currentPage]; // Page number key

			ReaderContentView *targetView = [contentViews objectForKey:key]; // View

			id target = [targetView processSingleTap:recognizer]; // Target object

			if (target != nil) // Handle the returned target object
			{
				if ([target isKindOfClass:[NSURL class]]) // Open a URL
				{
					NSURL *url = (NSURL *)target; // Cast to a NSURL object

					if (url.scheme == nil) // Handle a missing URL scheme
					{
						NSString *www = url.absoluteString; // Get URL string

						if ([www hasPrefix:@"www"] == YES) // Check for 'www' prefix
						{
							NSString *http = [[NSString alloc] initWithFormat:@"http://%@", www];

							url = [NSURL URLWithString:http]; // Proper http-based URL
						}
					}

					if ([[UIApplication sharedApplication] openURL:url] == NO)
					{
						#ifdef DEBUG
							NSLog(@"%s '%@'", __FUNCTION__, url); // Bad or unknown URL
						#endif
					}
				}
				else // Not a URL, so check for another possible object type
				{
					if ([target isKindOfClass:[NSNumber class]]) // Goto page
					{
						NSInteger number = [target integerValue]; // Number

						[self showDocumentPage:number]; // Show the page
					}
				}
			}
			else // Nothing active tapped in the target content view
			{
				if ([lastHideTime timeIntervalSinceNow] < -0.75) // Delay since hide
				{
					if ((mainToolbar.alpha < 1.0f) || (mainPagebar.alpha < 1.0f)) // Hidden
					{
						[mainToolbar showToolbar]; [mainPagebar showPagebar]; // Show
					}
				}
			}

			return;
		}

		CGRect nextPageRect = viewRect;
		nextPageRect.size.width = TAP_AREA_SIZE;
		nextPageRect.origin.x = (viewRect.size.width - TAP_AREA_SIZE);

		if (CGRectContainsPoint(nextPageRect, point) == true) // page++
		{
			[self incrementPageNumber]; return;
		}

		CGRect prevPageRect = viewRect;
		prevPageRect.size.width = TAP_AREA_SIZE;

		if (CGRectContainsPoint(prevPageRect, point) == true) // page--
		{
			[self decrementPageNumber]; return;
		}
	}
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateRecognized)
	{
		CGRect viewRect = recognizer.view.bounds; // View bounds

		CGPoint point = [recognizer locationInView:recognizer.view]; // Point

		CGRect zoomArea = CGRectInset(viewRect, TAP_AREA_SIZE, TAP_AREA_SIZE); // Area

		if (CGRectContainsPoint(zoomArea, point) == true) // Double tap is inside zoom area
		{
			NSNumber *key = [NSNumber numberWithInteger:currentPage]; // Page number key

			ReaderContentView *targetView = [contentViews objectForKey:key]; // View

			switch (recognizer.numberOfTouchesRequired) // Touches count
			{
				case 1: // One finger double tap: zoom++
				{
					[targetView zoomIncrement:recognizer]; break;
				}

				case 2: // Two finger double tap: zoom--
				{
					[targetView zoomDecrement:recognizer]; break;
				}
			}

			return;
		}

		CGRect nextPageRect = viewRect;
		nextPageRect.size.width = TAP_AREA_SIZE;
		nextPageRect.origin.x = (viewRect.size.width - TAP_AREA_SIZE);

		if (CGRectContainsPoint(nextPageRect, point) == true) // page++
		{
			[self incrementPageNumber]; return;
		}

		CGRect prevPageRect = viewRect;
		prevPageRect.size.width = TAP_AREA_SIZE;

		if (CGRectContainsPoint(prevPageRect, point) == true) // page--
		{
			[self decrementPageNumber]; return;
		}
	}
}

#pragma mark - ReaderContentViewDelegate methods

- (void)contentView:(ReaderContentView *)contentView touchesBegan:(NSSet *)touches
{
	if ((mainToolbar.alpha > 0.0f) || (mainPagebar.alpha > 0.0f))
	{
		if (touches.count == 1) // Single touches only
		{
			UITouch *touch = [touches anyObject]; // Touch info

			CGPoint point = [touch locationInView:self.view]; // Touch location

			CGRect areaRect = CGRectInset(self.view.bounds, TAP_AREA_SIZE, TAP_AREA_SIZE);

			if (CGRectContainsPoint(areaRect, point) == false) return;
		}

		[mainToolbar hideToolbar]; [mainPagebar hidePagebar]; // Hide

		lastHideTime = [NSDate date]; // Set last hide time
	}
}

#pragma mark - ReaderMainToolbarDelegate methods

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar doneButton:(UIButton *)button
{
#if (READER_STANDALONE == FALSE) // Option

	[self closeDocument]; // Close ReaderViewController

#endif // end of READER_STANDALONE Option
}

/** 上传已编辑的文件 */

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar updateButton:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(readerViewController:didChickUpdateItemWithNewPdfPath:fileID:)]) {
        
        NSString *newPdfPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/newPdf.pdf", kDataProcessingPdf];
        
        [self.delegate readerViewController:self didChickUpdateItemWithNewPdfPath:newPdfPath fileID:self.fileID];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
#ifdef DEBUG
	if ((result == MFMailComposeResultFailed) && (error != NULL)) NSLog(@"%@", error);
#endif

	[self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UIDocumentInteractionControllerDelegate methods

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller
{
	documentInteraction = nil;
}

#pragma mark - ThumbsViewControllerDelegate methods

- (void)thumbsViewController:(ThumbsViewController *)viewController gotoPage:(NSInteger)page
{
#if (READER_ENABLE_THUMBS == TRUE) // Option

	[self showDocumentPage:page];

#endif // end of READER_ENABLE_THUMBS Option
}

- (void)dismissThumbsViewController:(ThumbsViewController *)viewController
{
#if (READER_ENABLE_THUMBS == TRUE) // Option

	[self dismissViewControllerAnimated:NO completion:NULL];

#endif // end of READER_ENABLE_THUMBS Option
}

#pragma mark - ReaderMainPagebarDelegate methods

- (void)pagebar:(ReaderMainPagebar *)pagebar gotoPage:(NSInteger)page
{
	[self showDocumentPage:page];
}

#pragma mark - UIApplication notification methods

- (void)applicationWillResign:(NSNotification *)notification
{
	[document archiveDocumentProperties]; // Save any ReaderDocument changes

	if (userInterfaceIdiom == UIUserInterfaceIdiomPad) if (printInteraction != nil) [printInteraction dismissAnimated:NO];
}


#pragma mark - 悬浮按钮相关代码

#pragma mark - Private
- (void)_initdata
{
    
}

- (void)_loadSubviews
{
    
//    if (self.canEditPdf) {
//        [self.view addSubview:self.btnSign];
//
//        [self.view addSubview:self.btnOpinion];
//
//        [self.view addSubview:self.btnSignDone];
//    }
    
    [self showDocumentPage:self.showPage];
}

- (void)showSignBtn
{
    
}

- (void)hideSignBtn
{
    
}

/**
 *@ 创建处理PDF文件路径 并且 清空路径内的文件
 */
- (void)createPDFProcessingFilesPath
{
    NSString *processingPdfPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/filePages",kDataProcessingPdf];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:processingPdfPath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:processingPdfPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        [self splitPdfDataAndWriteToFile];
        
    }else{
        
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:processingPdfPath error:NULL];
        if (contents.count == 0) {
            [self splitPdfDataAndWriteToFile];
        }
    }
}

/** 删除拼接文件 */
- (void)deletePdfPageFiles
{
    NSString *processingPdfPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/filePages",kDataProcessingPdf];
    
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:processingPdfPath error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        
        [[NSFileManager defaultManager] removeItemAtPath:[processingPdfPath stringByAppendingPathComponent:filename] error:NULL];
    }
}

/**
 *@ 销毁生存的新PDF文件
 */
- (void)destructionNewPdfFile
{
    NSString *newPdfPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/newPdf.pdf", kDataProcessingPdf];
    [[NSFileManager defaultManager] removeItemAtPath:newPdfPath error:NULL];
}

#pragma mark - Setter

- (void)setCurrEditType:(PDFCurrEditType)currEditType
{
    if (_currEditType != currEditType) {
        _currEditType = currEditType;
        
        self.btnSign.animaHidden = _currEditType != PDFCurrEditType_None;
        
        self.btnOpinion.animaHidden = _currEditType != PDFCurrEditType_None;
        
        self.btnSignDone.animaHidden = _currEditType == PDFCurrEditType_None;
    }
}

#pragma mark - Getter

- (UIButtonSuspension *)btnSign
{
    if (_btnSign == nil) {
        _btnSign = [[UIButtonSuspension alloc] initWithFrame:CGRectMake(kScreenWidth - 8 - kBtnSignWidth, kScreenHeight - 200, kBtnSignWidth, kBtnSignWidth) image:[UIImage imageNamed:@"btn_Sign"]];
        [_btnSign addTarget:self action:@selector(chickSingItem) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnSign;
}

- (UIButtonSuspension *)btnOpinion
{
    if (_btnOpinion == nil) {
        _btnOpinion = [[UIButtonSuspension alloc] initWithFrame:CGRectMake(kScreenWidth - 8 - kBtnSignWidth, kScreenHeight - 135, kBtnSignWidth, kBtnSignWidth) image:[UIImage imageNamed:@"btn_Opinion"]];
        [_btnOpinion addTarget:self action:@selector(chickOpinionItem) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnOpinion;
}

- (UIButtonSuspension *)btnSignDone
{
    if (_btnSignDone == nil) {
        _btnSignDone = [[UIButtonSuspension alloc] initWithFrame:CGRectMake(kScreenWidth - 8 - kBtnSignWidth, 150, kBtnSignWidth, kBtnSignWidth) image:[UIImage imageNamed:@"btn_SignDone"]];
        [_btnSignDone addTarget:self action:@selector(chickSignDoneItem) forControlEvents:UIControlEventTouchUpInside];
        _btnSignDone.animaHidden = YES;
    }
    return _btnSignDone;
}

#pragma mark - Action
- (void)chickSingItem
{
    UIImage *fImage = [UIImage imageNamed:@"Sign_Fail"];
    if (self.testNumPage == 1) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.text = @"生成pdf";
        titleLabel.width_ext = kScreenWidth - 100;
        [titleLabel sizeToFit];
//        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.width_ext = titleLabel.width_ext + 40;
        CGSize titleSize = titleLabel.bounds.size;
        UIGraphicsBeginImageContextWithOptions(titleSize, NO, [UIScreen mainScreen].scale);
        [titleLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *titleImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.titleImageViewOpinion removeFromSuperview];
        self.titleImageViewOpinion = [[UIImageViewSign alloc] initWithImage:titleImage width:kScreenWidth - 200 origin:CGPointMake(100, kScreenHeight - 500) showDeleteBtn:NO];
        self.titleImageViewOpinion.frame = CGRectMake(100, 200, 100.f, 13.f);
        self.titleImageViewOpinion.delegate = self;
        [self.view addSubview:self.titleImageViewOpinion];
        
        UILabel *cardNumLabel = [[UILabel alloc] init];
        cardNumLabel.font = [UIFont systemFontOfSize:15];
        cardNumLabel.textColor = [UIColor blackColor];
        cardNumLabel.text = @"12345678901234567890";
        cardNumLabel.width_ext = kScreenWidth - 100;
        [cardNumLabel sizeToFit];
        cardNumLabel.backgroundColor = [UIColor clearColor];
        cardNumLabel.width_ext = cardNumLabel.width_ext + 40;
        CGSize cardNumSize = cardNumLabel.bounds.size;
        UIGraphicsBeginImageContextWithOptions(cardNumSize, NO, [UIScreen mainScreen].scale);
        [cardNumLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *cardNumImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.cardNumImageViewOpinion removeFromSuperview];
        self.cardNumImageViewOpinion = [[UIImageViewSign alloc] initWithImage:cardNumImage width:kScreenWidth - 200 origin:CGPointMake(100, kScreenHeight - 500) showDeleteBtn:NO];
        self.cardNumImageViewOpinion.frame = CGRectMake(100, CGRectGetMaxY(self.titleImageViewOpinion.frame), 100.f, 13.f);
        self.cardNumImageViewOpinion.delegate = self;
        [self.view addSubview:self.cardNumImageViewOpinion];
        
        UILabel *liushuihaoLabel = [[UILabel alloc] init];
        liushuihaoLabel.font = [UIFont systemFontOfSize:15];
        liushuihaoLabel.textColor = [UIColor blackColor];
        liushuihaoLabel.text = @"流水号1234567890";
        liushuihaoLabel.width_ext = kScreenWidth - 100;
        [liushuihaoLabel sizeToFit];
        liushuihaoLabel.backgroundColor = [UIColor clearColor];
        liushuihaoLabel.width_ext = liushuihaoLabel.width_ext + 40;
        CGSize liushuihaoSize = liushuihaoLabel.bounds.size;
        UIGraphicsBeginImageContextWithOptions(liushuihaoSize, NO, [UIScreen mainScreen].scale);
        [liushuihaoLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *liushuihaoImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.liushuihaoImageViewOpinion removeFromSuperview];
        self.liushuihaoImageViewOpinion = [[UIImageViewSign alloc] initWithImage:liushuihaoImage width:kScreenWidth - 200 origin:CGPointMake(100, kScreenHeight - 500) showDeleteBtn:NO];
        self.liushuihaoImageViewOpinion.frame = CGRectMake(kScreenWidth/2+55.f, 190, 100.f, 13.f);
        self.liushuihaoImageViewOpinion.delegate = self;
        [self.view addSubview:self.liushuihaoImageViewOpinion];
        
        UILabel *customNameLabel = [[UILabel alloc] init];
        customNameLabel.font = [UIFont systemFontOfSize:15];
        customNameLabel.textColor = [UIColor blackColor];
        customNameLabel.text = @"王大帅哥";
        customNameLabel.width_ext = kScreenWidth - 100;
        [customNameLabel sizeToFit];
        customNameLabel.backgroundColor = [UIColor clearColor];
        customNameLabel.width_ext = customNameLabel.width_ext + 40;
        CGSize customLabelSize = customNameLabel.bounds.size;
        UIGraphicsBeginImageContextWithOptions(customLabelSize, NO, [UIScreen mainScreen].scale);
        [customNameLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *customNameImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.customNameImageViewOpinion removeFromSuperview];
        self.customNameImageViewOpinion = [[UIImageViewSign alloc] initWithImage:customNameImage width:kScreenWidth - 200 origin:CGPointMake(100, kScreenHeight - 500) showDeleteBtn:NO];
        self.customNameImageViewOpinion.frame = CGRectMake(kScreenWidth/2+70.f, CGRectGetMaxY(self.liushuihaoImageViewOpinion.frame), 100.f, 13.f);
        self.customNameImageViewOpinion.delegate = self;
        [self.view addSubview:self.customNameImageViewOpinion];
        
        UILabel *timeLabel = [[UILabel alloc] init];
        timeLabel.font = [UIFont systemFontOfSize:15];
        timeLabel.textColor = [UIColor blackColor];
        timeLabel.text = @"流水号1234567890";
        timeLabel.width_ext = kScreenWidth - 100;
        [timeLabel sizeToFit];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.width_ext = timeLabel.width_ext + 40;
        CGSize timeSize = timeLabel.bounds.size;
        UIGraphicsBeginImageContextWithOptions(timeSize, NO, [UIScreen mainScreen].scale);
        [timeLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *timeImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.timeImageViewOpinion removeFromSuperview];
        self.timeImageViewOpinion = [[UIImageViewSign alloc] initWithImage:timeImage width:kScreenWidth - 200 origin:CGPointMake(100, kScreenHeight - 500) showDeleteBtn:NO];
        self.timeImageViewOpinion.frame = CGRectMake(kScreenWidth/2+100.f, CGRectGetMaxY(self.customNameImageViewOpinion.frame), 100.f, 13.f);
        self.timeImageViewOpinion.delegate = self;
        [self.view addSubview:self.timeImageViewOpinion];
        
        CGFloat imgWidth = kScreenWidth/2-20;
        [self.idCardFrontImageViewSign removeFromSuperview];
        self.idCardFrontImageViewSign = [[UIImageViewSign alloc] initWithImage:fImage width:imgWidth origin:CGPointMake(100, kScreenHeight - 500) showDeleteBtn:NO];
        self.idCardFrontImageViewSign.frame = CGRectMake(20, 240, imgWidth, imgWidth-40.f);
        [self.view addSubview:self.idCardFrontImageViewSign];
        
        [self.idCardBackImageViewSign removeFromSuperview];
        self.idCardBackImageViewSign = [[UIImageViewSign alloc] initWithImage:fImage width:kScreenWidth/2-40 origin:CGPointMake(100, kScreenHeight - 500) showDeleteBtn:NO];
        self.idCardBackImageViewSign.frame = CGRectMake(kScreenWidth/2+5, 230, imgWidth, imgWidth-40);
        [self.view addSubview:self.idCardBackImageViewSign];
        
        [self.faceImageViewSign removeFromSuperview];
        self.faceImageViewSign = [[UIImageViewSign alloc] initWithImage:fImage width:80.f origin:CGPointMake(100, kScreenHeight - 500) showDeleteBtn:NO];
        self.faceImageViewSign.frame = CGRectMake(kScreenWidth/4-30.f, CGRectGetMaxY(self.idCardFrontImageViewSign.frame)+10.f, 60, 60);
        [self.view addSubview:self.faceImageViewSign];
        
        [self.socialCardImageViewSign removeFromSuperview];
        self.socialCardImageViewSign = [[UIImageViewSign alloc] initWithImage:fImage width:kScreenWidth/2-40.f origin:CGPointMake(100, kScreenHeight - 500) showDeleteBtn:NO];
        self.socialCardImageViewSign.frame = CGRectMake(kScreenWidth/2+5.f, CGRectGetMaxY(self.idCardBackImageViewSign.frame)+10.f, imgWidth, imgWidth-40.f);
        [self.view addSubview:self.socialCardImageViewSign];
        
        [self.currentFaceImageViewSign removeFromSuperview];
        self.currentFaceImageViewSign = [[UIImageViewSign alloc] initWithImage:fImage width:kScreenWidth/2-40.f origin:CGPointMake(100, kScreenHeight - 500) showDeleteBtn:NO];
        self.currentFaceImageViewSign.frame = CGRectMake(kScreenWidth/2+5.f, CGRectGetMaxY(self.socialCardImageViewSign.frame)+10.f, imgWidth, imgWidth-40.f);
        [self.view addSubview:self.currentFaceImageViewSign];
        
        UILabel *idNumLabel = [[UILabel alloc] init];
        idNumLabel.font = [UIFont systemFontOfSize:15];
        idNumLabel.textColor = [UIColor blackColor];
        idNumLabel.text = @"12345678901234567890";
        idNumLabel.width_ext = kScreenWidth - 100;
        [idNumLabel sizeToFit];
        idNumLabel.backgroundColor = [UIColor clearColor];
        idNumLabel.width_ext = idNumLabel.width_ext + 40;
        CGSize idNumSize = idNumLabel.bounds.size;
        UIGraphicsBeginImageContextWithOptions(idNumSize, NO, [UIScreen mainScreen].scale);
        [idNumLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *idNumImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.idNumImageViewOpinion removeFromSuperview];
        self.idNumImageViewOpinion = [[UIImageViewSign alloc] initWithImage:idNumImage width:kScreenWidth - 200 origin:CGPointMake(100, kScreenHeight - 500) showDeleteBtn:NO];
        self.idNumImageViewOpinion.frame = CGRectMake(80, CGRectGetMaxY(self.faceImageViewSign.frame)+30.f, 100.f, 13.f);
        self.idNumImageViewOpinion.delegate = self;
        [self.view addSubview:self.idNumImageViewOpinion];
        
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.font = [UIFont systemFontOfSize:15];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.text = @"王大帅哥";
        nameLabel.width_ext = kScreenWidth - 100;
        [nameLabel sizeToFit];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.width_ext = nameLabel.width_ext + 40;
        CGSize nameSize = nameLabel.bounds.size;
        UIGraphicsBeginImageContextWithOptions(nameSize, NO, [UIScreen mainScreen].scale);
        [nameLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *nameImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.nameImageViewOpinion removeFromSuperview];
        self.nameImageViewOpinion = [[UIImageViewSign alloc] initWithImage:nameImage width:kScreenWidth - 200 origin:CGPointMake(100, kScreenHeight - 500) showDeleteBtn:NO];
        self.nameImageViewOpinion.frame = CGRectMake(60, CGRectGetMaxY(self.idNumImageViewOpinion.frame)+10.f, 100.f, 13.f);
        self.nameImageViewOpinion.delegate = self;
        [self.view addSubview:self.nameImageViewOpinion];
        
        UILabel *resultLabel = [[UILabel alloc] init];
        resultLabel.font = [UIFont systemFontOfSize:15];
        resultLabel.textColor = [UIColor blackColor];
        resultLabel.text = @"检验通过";
        resultLabel.width_ext = kScreenWidth - 100;
        [resultLabel sizeToFit];
        resultLabel.backgroundColor = [UIColor clearColor];
        resultLabel.width_ext = resultLabel.width_ext + 40;
        CGSize resultSize = resultLabel.bounds.size;
        UIGraphicsBeginImageContextWithOptions(resultSize, NO, [UIScreen mainScreen].scale);
        [resultLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.resultImageViewOpinion removeFromSuperview];
        self.resultImageViewOpinion = [[UIImageViewSign alloc] initWithImage:resultImage width:kScreenWidth - 200 origin:CGPointMake(100, kScreenHeight - 500) showDeleteBtn:NO];
        self.resultImageViewOpinion.frame = CGRectMake(90, CGRectGetMaxY(self.nameImageViewOpinion.frame)+8.f, 100.f, 13.f);
        self.resultImageViewOpinion.delegate = self;
        [self.view addSubview:self.resultImageViewOpinion];
    }
    
    if (self.testNumPage == 2) {
        UILabel *applyDateLabel = [[UILabel alloc] init];
        applyDateLabel.font = [UIFont systemFontOfSize:15];
        applyDateLabel.textColor = [UIColor blackColor];
        applyDateLabel.text = @"申请日期2020-7-1";
        applyDateLabel.width_ext = kScreenWidth - 100;
        [applyDateLabel sizeToFit];
        applyDateLabel.backgroundColor = [UIColor clearColor];
        applyDateLabel.width_ext = applyDateLabel.width_ext + 40;
        CGSize applyDateSize = applyDateLabel.bounds.size;
        UIGraphicsBeginImageContextWithOptions(applyDateSize, NO, [UIScreen mainScreen].scale);
        [applyDateLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *applyDateImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.seccondApplyDateImageViewSign removeFromSuperview];
        self.seccondApplyDateImageViewSign = [[UIImageViewSign alloc] initWithImage:applyDateImage width:kScreenWidth - 200 origin:CGPointMake(100, kScreenHeight - 500) showDeleteBtn:NO];
        self.seccondApplyDateImageViewSign.frame = CGRectMake(kScreenWidth/2-15.f, 200, 100.f, 13.f);
        [self.view addSubview:self.seccondApplyDateImageViewSign];
        
        UILabel *jigouLabel = [[UILabel alloc] init];
        jigouLabel.font = [UIFont systemFontOfSize:15];
        jigouLabel.textColor = [UIColor blackColor];
        jigouLabel.text = @"机构广西银行";
        jigouLabel.width_ext = kScreenWidth - 100;
        [jigouLabel sizeToFit];
        jigouLabel.backgroundColor = [UIColor clearColor];
        jigouLabel.width_ext = jigouLabel.width_ext + 40;
        CGSize jigouSize = jigouLabel.bounds.size;
        UIGraphicsBeginImageContextWithOptions(jigouSize, NO, [UIScreen mainScreen].scale);
        [jigouLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *jigouImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.seccondTradeJigouImageViewSign removeFromSuperview];
        self.seccondTradeJigouImageViewSign = [[UIImageViewSign alloc] initWithImage:jigouImage width:kScreenWidth - 200 origin:CGPointMake(100, kScreenHeight - 500) showDeleteBtn:NO];
        self.seccondTradeJigouImageViewSign.frame = CGRectMake(kScreenWidth/4+10.f, CGRectGetMaxY(self.seccondApplyDateImageViewSign.frame)+20.f, 100.f, 13.f);
        [self.view addSubview:self.seccondTradeJigouImageViewSign];
        
        UILabel *jigouNameLabel = [[UILabel alloc] init];
        jigouNameLabel.font = [UIFont systemFontOfSize:15];
        jigouNameLabel.textColor = [UIColor blackColor];
        jigouNameLabel.text = @"交易名称社保卡激活";
        jigouNameLabel.width_ext = kScreenWidth - 100;
        [jigouNameLabel sizeToFit];
        jigouNameLabel.backgroundColor = [UIColor clearColor];
        jigouNameLabel.width_ext = jigouNameLabel.width_ext + 40;
        CGSize jigouNameSize = jigouNameLabel.bounds.size;
        UIGraphicsBeginImageContextWithOptions(jigouNameSize, NO, [UIScreen mainScreen].scale);
        [jigouNameLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *jigouNameImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.seccondTradeNameImageViewSign removeFromSuperview];
        self.seccondTradeNameImageViewSign = [[UIImageViewSign alloc] initWithImage:jigouNameImage width:kScreenWidth - 200 origin:CGPointMake(100, kScreenHeight - 500) showDeleteBtn:NO];
        self.seccondTradeNameImageViewSign.frame = CGRectMake(CGRectGetMinX(self.seccondTradeJigouImageViewSign.frame), CGRectGetMaxY(self.seccondTradeJigouImageViewSign.frame), 100.f, 13.f);
        [self.view addSubview:self.seccondTradeNameImageViewSign];
        
        UILabel *liushuihaoLabel = [[UILabel alloc] init];
        liushuihaoLabel.font = [UIFont systemFontOfSize:15];
        liushuihaoLabel.textColor = [UIColor blackColor];
        liushuihaoLabel.text = @"流水号1234567890";
        liushuihaoLabel.width_ext = kScreenWidth - 100;
        [liushuihaoLabel sizeToFit];
        liushuihaoLabel.backgroundColor = [UIColor clearColor];
        liushuihaoLabel.width_ext = liushuihaoLabel.width_ext + 40;
        CGSize liushuihaoSize = liushuihaoLabel.bounds.size;
        UIGraphicsBeginImageContextWithOptions(liushuihaoSize, NO, [UIScreen mainScreen].scale);
        [liushuihaoLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *liushuihaoImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.seccondLiushuihaoImageViewSign removeFromSuperview];
        self.seccondLiushuihaoImageViewSign = [[UIImageViewSign alloc] initWithImage:liushuihaoImage width:kScreenWidth - 200 origin:CGPointMake(100, kScreenHeight - 500) showDeleteBtn:NO];
        self.seccondLiushuihaoImageViewSign.frame = CGRectMake(kScreenWidth/2+50.f, CGRectGetMinY(self.seccondTradeJigouImageViewSign.frame), 100.f, 13.f);
        [self.view addSubview:self.seccondLiushuihaoImageViewSign];
        
        UILabel *customerNameLabel = [[UILabel alloc] init];
        customerNameLabel.font = [UIFont systemFontOfSize:15];
        customerNameLabel.textColor = [UIColor blackColor];
        customerNameLabel.text = @"王大帅哥";
        customerNameLabel.width_ext = kScreenWidth - 100;
        [customerNameLabel sizeToFit];
        customerNameLabel.backgroundColor = [UIColor clearColor];
        customerNameLabel.width_ext = customerNameLabel.width_ext + 40;
        CGSize customerNameSize = customerNameLabel.bounds.size;
        UIGraphicsBeginImageContextWithOptions(customerNameSize, NO, [UIScreen mainScreen].scale);
        [customerNameLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *customerNameImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.seccondCustomerNameImageViewSign removeFromSuperview];
        self.seccondCustomerNameImageViewSign = [[UIImageViewSign alloc] initWithImage:customerNameImage width:kScreenWidth - 200 origin:CGPointMake(100, kScreenHeight - 500) showDeleteBtn:NO];
        self.seccondCustomerNameImageViewSign.frame = CGRectMake(CGRectGetMinX(self.seccondLiushuihaoImageViewSign.frame), CGRectGetMaxY(self.seccondLiushuihaoImageViewSign.frame), 100.f, 13.f);
        [self.view addSubview:self.seccondCustomerNameImageViewSign];
        
        UILabel *cardNumLabel = [[UILabel alloc] init];
        cardNumLabel.font = [UIFont systemFontOfSize:15];
        cardNumLabel.textColor = [UIColor blackColor];
        cardNumLabel.text = @"1234567890";
        cardNumLabel.width_ext = kScreenWidth - 100;
        [cardNumLabel sizeToFit];
        cardNumLabel.backgroundColor = [UIColor clearColor];
        cardNumLabel.width_ext = cardNumLabel.width_ext + 40;
        CGSize cardNumSize = cardNumLabel.bounds.size;
        UIGraphicsBeginImageContextWithOptions(cardNumSize, NO, [UIScreen mainScreen].scale);
        [cardNumLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *cardNumImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.seccondCardNumImageViewSign removeFromSuperview];
        self.seccondCardNumImageViewSign = [[UIImageViewSign alloc] initWithImage:cardNumImage width:kScreenWidth - 200 origin:CGPointMake(100, kScreenHeight - 500) showDeleteBtn:NO];
        self.seccondCardNumImageViewSign.frame = CGRectMake(CGRectGetMinX(self.seccondTradeJigouImageViewSign.frame)-20.f, CGRectGetMaxY(self.seccondTradeNameImageViewSign.frame), 100.f, 13.f);
        [self.view addSubview:self.seccondCardNumImageViewSign];
        
        UILabel *certNumLabel = [[UILabel alloc] init];
        certNumLabel.font = [UIFont systemFontOfSize:15];
        certNumLabel.textColor = [UIColor blackColor];
        certNumLabel.text = @"证件号码1234567890";
        certNumLabel.width_ext = kScreenWidth - 100;
        [certNumLabel sizeToFit];
        certNumLabel.backgroundColor = [UIColor clearColor];
        certNumLabel.width_ext = certNumLabel.width_ext + 40;
        CGSize certNumSize = certNumLabel.bounds.size;
        UIGraphicsBeginImageContextWithOptions(certNumSize, NO, [UIScreen mainScreen].scale);
        [certNumLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *certNumImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.seccondCertificateNumImageViewSign removeFromSuperview];
        self.seccondCertificateNumImageViewSign = [[UIImageViewSign alloc] initWithImage:certNumImage width:kScreenWidth - 200 origin:CGPointMake(100, kScreenHeight - 500) showDeleteBtn:NO];
        self.seccondCertificateNumImageViewSign.frame = CGRectMake(CGRectGetMinX(self.seccondTradeJigouImageViewSign.frame), CGRectGetMaxY(self.seccondCardNumImageViewSign.frame), 100.f, 13.f);
        [self.view addSubview:self.seccondCertificateNumImageViewSign];
        
        UILabel *certTypeLabel = [[UILabel alloc] init];
        certTypeLabel.font = [UIFont systemFontOfSize:15];
        certTypeLabel.textColor = [UIColor blackColor];
        certTypeLabel.text = @"证件类型身份证";
        certTypeLabel.width_ext = kScreenWidth - 100;
        [certTypeLabel sizeToFit];
        certTypeLabel.backgroundColor = [UIColor clearColor];
        certTypeLabel.width_ext = certTypeLabel.width_ext + 40;
        CGSize certTypeSize = certTypeLabel.bounds.size;
        UIGraphicsBeginImageContextWithOptions(certTypeSize, NO, [UIScreen mainScreen].scale);
        [certTypeLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *certTypeImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.seccondCertificateTypeImageViewSign removeFromSuperview];
        self.seccondCertificateTypeImageViewSign = [[UIImageViewSign alloc] initWithImage:certTypeImage width:kScreenWidth - 200 origin:CGPointMake(100, kScreenHeight - 500) showDeleteBtn:NO];
        self.seccondCertificateTypeImageViewSign.frame = CGRectMake(CGRectGetMinX(self.seccondLiushuihaoImageViewSign.frame), CGRectGetMaxY(self.seccondCardNumImageViewSign.frame), 100.f, 13.f);
        [self.view addSubview:self.seccondCertificateTypeImageViewSign];
        
        UILabel *tradeTimeLabel = [[UILabel alloc] init];
        tradeTimeLabel.font = [UIFont systemFontOfSize:15];
        tradeTimeLabel.textColor = [UIColor blackColor];
        tradeTimeLabel.text = @"交易日期2020-7-1";
        tradeTimeLabel.width_ext = kScreenWidth - 100;
        [tradeTimeLabel sizeToFit];
        tradeTimeLabel.backgroundColor = [UIColor clearColor];
        tradeTimeLabel.width_ext = tradeTimeLabel.width_ext + 40;
        CGSize tradeSize = tradeTimeLabel.bounds.size;
        UIGraphicsBeginImageContextWithOptions(tradeSize, NO, [UIScreen mainScreen].scale);
        [tradeTimeLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *tradeImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.seccondTradeTimeImageViewSign removeFromSuperview];
        self.seccondTradeTimeImageViewSign = [[UIImageViewSign alloc] initWithImage:tradeImage width:kScreenWidth - 200 origin:CGPointMake(100, kScreenHeight - 500) showDeleteBtn:NO];
        self.seccondTradeTimeImageViewSign.frame = CGRectMake(CGRectGetMinX(self.seccondTradeJigouImageViewSign.frame), CGRectGetMaxY(self.seccondCertificateNumImageViewSign.frame), 100.f, 13.f);
        [self.view addSubview:self.seccondTradeTimeImageViewSign];
        
        UILabel *counterLabel = [[UILabel alloc] init];
        counterLabel.font = [UIFont systemFontOfSize:15];
        counterLabel.textColor = [UIColor blackColor];
        counterLabel.text = @"12345678901234567890";
        counterLabel.width_ext = kScreenWidth - 100;
        [counterLabel sizeToFit];
        counterLabel.backgroundColor = [UIColor clearColor];
        counterLabel.width_ext = tradeTimeLabel.width_ext + 40;
        CGSize counterSize = counterLabel.bounds.size;
        UIGraphicsBeginImageContextWithOptions(counterSize, NO, [UIScreen mainScreen].scale);
        [counterLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *counterImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.seccondCounterNumImageViewSign removeFromSuperview];
        self.seccondCounterNumImageViewSign = [[UIImageViewSign alloc] initWithImage:counterImage width:kScreenWidth - 200 origin:CGPointMake(100, kScreenHeight - 500) showDeleteBtn:NO];
        self.seccondCounterNumImageViewSign.frame = CGRectMake(CGRectGetMinX(self.seccondLiushuihaoImageViewSign.frame), CGRectGetMaxY(self.seccondCertificateNumImageViewSign.frame), 100.f, 13.f);
        [self.view addSubview:self.seccondCounterNumImageViewSign];
        
        UILabel *midNameLabel = [[UILabel alloc] init];
        midNameLabel.font = [UIFont systemFontOfSize:15];
        midNameLabel.textColor = [UIColor blackColor];
        midNameLabel.text = @"银行业务凭证";
        midNameLabel.width_ext = kScreenWidth - 100;
        [midNameLabel sizeToFit];
        midNameLabel.backgroundColor = [UIColor clearColor];
        midNameLabel.width_ext = midNameLabel.width_ext + 40;
        CGSize midNameSize = midNameLabel.bounds.size;
        UIGraphicsBeginImageContextWithOptions(midNameSize, NO, [UIScreen mainScreen].scale);
        [midNameLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *midNameImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.seccondMidNameImageViewSign removeFromSuperview];
        self.seccondMidNameImageViewSign = [[UIImageViewSign alloc] initWithImage:midNameImage width:kScreenWidth - 200 origin:CGPointMake(100, kScreenHeight - 500) showDeleteBtn:NO];
        self.seccondMidNameImageViewSign.frame = CGRectMake(CGRectGetMinX(self.seccondTradeTimeImageViewSign.frame)-30.f, CGRectGetMaxY(self.seccondTradeTimeImageViewSign.frame)+25.f, 100.f, 13.f);
        [self.view addSubview:self.seccondMidNameImageViewSign];
        
        UILabel *midCardNumLabel = [[UILabel alloc] init];
        midCardNumLabel.font = [UIFont systemFontOfSize:15];
        midCardNumLabel.textColor = [UIColor blackColor];
        midCardNumLabel.text = @"流水号1234567890";
        midCardNumLabel.width_ext = kScreenWidth - 100;
        [midCardNumLabel sizeToFit];
        midCardNumLabel.backgroundColor = [UIColor clearColor];
        midCardNumLabel.width_ext = midCardNumLabel.width_ext + 40;
        CGSize midCardNumSize = midCardNumLabel.bounds.size;
        UIGraphicsBeginImageContextWithOptions(midCardNumSize, NO, [UIScreen mainScreen].scale);
        [midCardNumLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *midCardNumImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.seccondMidCardNumImageViewSign removeFromSuperview];
        self.seccondMidCardNumImageViewSign = [[UIImageViewSign alloc] initWithImage:midCardNumImage width:kScreenWidth - 200 origin:CGPointMake(100, kScreenHeight - 500) showDeleteBtn:NO];
        self.seccondMidCardNumImageViewSign.frame = CGRectMake(CGRectGetMinX(self.seccondLiushuihaoImageViewSign.frame)-5.f, CGRectGetMinY(self.seccondMidNameImageViewSign.frame), 100.f, 13.f);
        [self.view addSubview:self.seccondMidCardNumImageViewSign];
        
        UILabel *midcertNameLabel = [[UILabel alloc] init];
        midcertNameLabel.font = [UIFont systemFontOfSize:15];
        midcertNameLabel.textColor = [UIColor blackColor];
        midcertNameLabel.text = @"证件名称身份证";
        midcertNameLabel.width_ext = kScreenWidth - 100;
        [midcertNameLabel sizeToFit];
        midcertNameLabel.backgroundColor = [UIColor clearColor];
        midcertNameLabel.width_ext = midCardNumLabel.width_ext + 40;
        CGSize midCernameSize = midcertNameLabel.bounds.size;
        UIGraphicsBeginImageContextWithOptions(midCernameSize, NO, [UIScreen mainScreen].scale);
        [midcertNameLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *midCertNameImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.seccondMidCertificateNameImageViewSign removeFromSuperview];
        self.seccondMidCertificateNameImageViewSign = [[UIImageViewSign alloc] initWithImage:midCertNameImage width:kScreenWidth - 200 origin:CGPointMake(100, kScreenHeight - 500) showDeleteBtn:NO];
        self.seccondMidCertificateNameImageViewSign.frame = CGRectMake(CGRectGetMinX(self.seccondMidNameImageViewSign.frame), CGRectGetMaxY(self.seccondMidNameImageViewSign.frame), 100.f, 13.f);
        [self.view addSubview:self.seccondMidCertificateNameImageViewSign];
        
        UILabel *midCertNumLabel = [[UILabel alloc] init];
        midCertNumLabel.font = [UIFont systemFontOfSize:15];
        midCertNumLabel.textColor = [UIColor blackColor];
        midCertNumLabel.text = @"流水号1234567890";
        midCertNumLabel.width_ext = kScreenWidth - 100;
        [midCertNumLabel sizeToFit];
        midCertNumLabel.backgroundColor = [UIColor clearColor];
        midCertNumLabel.width_ext = midCardNumLabel.width_ext + 40;
        CGSize midCertNumSize = midCertNumLabel.bounds.size;
        UIGraphicsBeginImageContextWithOptions(midCertNumSize, NO, [UIScreen mainScreen].scale);
        [midCertNumLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *midCertNumImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.seccondMidCertificateNumImageViewSign removeFromSuperview];
        self.seccondMidCertificateNumImageViewSign = [[UIImageViewSign alloc] initWithImage:midCertNumImage width:kScreenWidth - 200 origin:CGPointMake(100, kScreenHeight - 500) showDeleteBtn:NO];
        self.seccondMidCertificateNumImageViewSign.frame = CGRectMake(CGRectGetMinX(self.seccondMidCardNumImageViewSign.frame)-5.f, CGRectGetMaxY(self.seccondMidCardNumImageViewSign.frame), 100.f, 13.f);
        [self.view addSubview:self.seccondMidCertificateNumImageViewSign];
        
        [self.secondNameSignImageViewSign removeFromSuperview];
        self.secondNameSignImageViewSign = [[UIImageViewSign alloc] initWithImage:fImage width:kScreenWidth/2-40.f origin:CGPointMake(100, kScreenHeight - 500) showDeleteBtn:NO];
        self.secondNameSignImageViewSign.frame = CGRectMake(kScreenWidth/2+40.f, CGRectGetMaxY(self.seccondMidCertificateNumImageViewSign.frame)+70.f, 50.f, 30.f);
        [self.view addSubview:self.secondNameSignImageViewSign];
//        self.currEditType = PDFCurrEditType_Sign;
    }
    
    if (self.testNumPage == 3) {
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.font = [UIFont systemFontOfSize:15];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.text = @"王大帅哥";
        nameLabel.width_ext = kScreenWidth - 100;
        [nameLabel sizeToFit];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.width_ext = nameLabel.width_ext + 40;
        CGSize nameSize = nameLabel.bounds.size;
        UIGraphicsBeginImageContextWithOptions(nameSize, NO, [UIScreen mainScreen].scale);
        [nameLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *nameImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.thirdNameImageViewSign removeFromSuperview];
        self.thirdNameImageViewSign = [[UIImageViewSign alloc] initWithImage:nameImage width:kScreenWidth - 200 origin:CGPointMake(100, kScreenHeight - 500) showDeleteBtn:NO];
        self.thirdNameImageViewSign.frame = CGRectMake(40, 180, 100.f, 13.f);
        self.thirdNameImageViewSign.delegate = self;
        [self.view addSubview:self.thirdNameImageViewSign];
        
        [self.thirdNameSignImageViewSign removeFromSuperview];
        self.thirdNameSignImageViewSign = [[UIImageViewSign alloc] initWithImage:fImage width:kScreenWidth/2-40.f origin:CGPointMake(100, kScreenHeight - 500) showDeleteBtn:NO];
        self.thirdNameSignImageViewSign.frame = CGRectMake(40.f, kScreenHeight/2, 50.f, 30.f);
        [self.view addSubview:self.thirdNameSignImageViewSign];
        
        UILabel *dateLabel = [[UILabel alloc] init];
        dateLabel.font = [UIFont systemFontOfSize:15];
        dateLabel.textColor = [UIColor blackColor];
        dateLabel.text = @"2020-7-1";
        dateLabel.width_ext = kScreenWidth - 100;
        [dateLabel sizeToFit];
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.width_ext = dateLabel.width_ext + 40;
        CGSize dateSize = dateLabel.bounds.size;
        UIGraphicsBeginImageContextWithOptions(dateSize, NO, [UIScreen mainScreen].scale);
        [dateLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *dateImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.thirdDateImageViewSign removeFromSuperview];
        self.thirdDateImageViewSign = [[UIImageViewSign alloc] initWithImage:dateImage width:kScreenWidth - 200 origin:CGPointMake(100, kScreenHeight - 500) showDeleteBtn:NO];
        self.thirdDateImageViewSign.frame = CGRectMake(kScreenWidth/4+20.f, CGRectGetMinY(self.thirdNameSignImageViewSign.frame)+10.f, 100.f, 13.f);
        [self.view addSubview:self.thirdDateImageViewSign];
        
    }
    
    [self chickSignDoneItem];
}


- (void)chickOpinionItem
{
    
    UIControllerPDFOpinionEdit *opinionEdit = [[UIControllerPDFOpinionEdit alloc] initWithNibName:@"UIControllerPDFOpinionEdit" bundle:[NSBundle mainBundle]];
    opinionEdit.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:opinionEdit];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)chickSignDoneItem
{
    ReaderContentView *currShowView = nil;
    for (id subview in theScrollView.subviews) {
        if ([subview isKindOfClass:[ReaderContentView class]]) {
            
            ReaderContentView *view = subview;
            if (view.tag == currentPage) {
                currShowView = view;
            }
            
        }
    }
    
    
//    switch (self.currEditType) {
//        case PDFCurrEditType_Sign:
//        {
//            NSLog(@"处理中");
//            [self addImageViews:@[self.imageViewSign, self.imageViewSignTime] onPDFURL:document.fileURL page:currentPage readerContentView:currShowView block:^{
//                NSLog(@"处理完成");
//            }];
//
//            [self.imageViewSign removeFromSuperview];
//            [self.imageViewSignTime removeFromSuperview];
    if (self.testNumPage == 1) {
        [self addImageViews:@[self.titleImageViewOpinion,self.cardNumImageViewOpinion,self.liushuihaoImageViewOpinion,self.customNameImageViewOpinion,self.timeImageViewOpinion,self.idCardFrontImageViewSign,self.idCardBackImageViewSign,self.faceImageViewSign,self.socialCardImageViewSign,self.currentFaceImageViewSign,self.idNumImageViewOpinion,self.nameImageViewOpinion,self.resultImageViewOpinion] onPDFURL:document.fileURL page:currentPage readerContentView:currShowView block:^{
            NSLog(@"处理完成");
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    
            
//            [self.imageViewSign removeFromSuperview];
//            [self.imageViewSign1 removeFromSuperview];
//            [self.imageViewSign2 removeFromSuperview];
//            [self.imageViewSign3 removeFromSuperview];
//            [self.imageViewSign4 removeFromSuperview];
//        [self.imageViewOpinion removeFromSuperview];
    
    if (self.testNumPage == 2) {
        [self addImageViews:@[self.seccondApplyDateImageViewSign,self.seccondTradeJigouImageViewSign,self.seccondTradeNameImageViewSign,self.seccondLiushuihaoImageViewSign,self.seccondCustomerNameImageViewSign,self.seccondCardNumImageViewSign,self.seccondCertificateNumImageViewSign,self.seccondCertificateTypeImageViewSign,self.seccondTradeTimeImageViewSign,self.seccondCounterNumImageViewSign,self.seccondMidNameImageViewSign,self.seccondMidCardNumImageViewSign,self.seccondMidCertificateNumImageViewSign,self.seccondMidCertificateNameImageViewSign,self.secondNameSignImageViewSign] onPDFURL:document.fileURL page:currentPage readerContentView:currShowView block:^{
            NSLog(@"处理完成");
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    
    if (self.testNumPage == 3) {
        [self addImageViews:@[self.thirdNameImageViewSign,self.thirdNameSignImageViewSign,self.thirdDateImageViewSign] onPDFURL:document.fileURL page:currentPage readerContentView:currShowView block:^{
            NSLog(@"处理完成");
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
        
//        [self.imageViewSign removeFromSuperview];
//        [self.imageViewSign1 removeFromSuperview];
//        [self.imageViewSign2 removeFromSuperview];
//        [self.imageViewSign3 removeFromSuperview];
//        [self.imageViewSign4 removeFromSuperview];
//    [self.imageViewOpinion removeFromSuperview];
//        }
//            break;
//        case PDFCurrEditType_Opinion:
//        {
//            NSLog(@"处理中");
//            [self addImageViews:@[self.imageViewOpinion] onPDFURL:document.fileURL page:currentPage readerContentView:currShowView block:^{
//                NSLog(@"处理完成");
//            }];
//
//            [self.imageViewOpinion removeFromSuperview];
//        }
//            break;
//        default:
//            break;
//    }
    
//    self.currEditType = PDFCurrEditType_None;
}

- (UIImage *)getCurrTimeImage
{
    NSString *strCurrTime = [[NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]] getYearMonthDayTime];
    
    UILabel *lblTime = [[UILabel alloc] init];
    lblTime.font = [UIFont systemFontOfSize:15];
    lblTime.textColor = [UIColor blackColor];
    lblTime.text = strCurrTime;
    [lblTime sizeToFit];
    lblTime.backgroundColor = [UIColor clearColor];
    lblTime.width_ext = lblTime.width_ext + 40;
    
    CGSize size = lblTime.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [lblTime.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - UIImageViewSignDelegate
/** 点击 编辑图片删除按钮 */
- (void)didchickDeleteImageViewSign:(UIImageViewSign *)view
{
//    if (view == self.imageViewSign) {
//
//        [self.imageViewSign removeFromSuperview];
//
////        [self.imageViewSignTime removeFromSuperview];
//    }
//
//    if (view == self.imageViewOpinion) {
//
//        [self.imageViewOpinion removeFromSuperview];
//
//    }
//
//    self.currEditType = PDFCurrEditType_None;
}

#pragma mark - UIControllerPDFOpinionEditDelegate
/**
 *@ 已经编辑完 意见
 */
- (void)controllerPDFOpinionEdit:(UIControllerPDFOpinionEdit *)controller didEditDoneWithOpinion:(NSString *)opinion
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    UILabel *lblTime = [[UILabel alloc] init];
    lblTime.font = [UIFont systemFontOfSize:15];
    lblTime.textColor = [UIColor blackColor];
    lblTime.text = opinion;
    lblTime.numberOfLines = 0;
    lblTime.width_ext = kScreenWidth - 100;
    [lblTime sizeToFit];
    lblTime.backgroundColor = [UIColor clearColor];
    lblTime.width_ext = lblTime.width_ext + 40;
    
    CGSize size = lblTime.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [lblTime.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
//    [self.imageViewOpinion removeFromSuperview];
//    self.imageViewOpinion = [[UIImageViewSign alloc] initWithImage:image width:kScreenWidth - 200 origin:CGPointMake(100, kScreenHeight - 500) showDeleteBtn:YES];
//    self.imageViewOpinion.delegate = self;
//    [self.view addSubview:self.imageViewOpinion];
//
//    self.currEditType = PDFCurrEditType_Opinion;
    
}

#pragma mark - 将图片贴到PDF文件上
/**
 *@ 将图片添加到  PDF 文件上
 *@ images      (UIImageViewSign) 图片视图数组
 *@ pdfData     pdf文件数据
 *@ pageIndex   pdf页码
 *@ zoomScale   当前pdf页面缩放的比例值
 */
-(void)addImageViews:(NSArray *)imageViews onPDFURL:(NSURL *)pdfURL page:(NSInteger)pageIndex readerContentView:(ReaderContentView *)readerContentView block:(void(^)())block{
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableData* outputPDFData = [[NSMutableData alloc] init];
        CGDataConsumerRef dataConsumer = CGDataConsumerCreateWithCFData((CFMutableDataRef)outputPDFData);
        
        CFMutableDictionaryRef attrDictionary = NULL;
        attrDictionary = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        CFDictionarySetValue(attrDictionary, kCGPDFContextTitle, CFSTR("My Doc"));
        CGContextRef pdfContext = CGPDFContextCreate(dataConsumer, NULL, attrDictionary);
        CFRelease(dataConsumer);
        CFRelease(attrDictionary);
        CGRect pageRect;
        
        // Draw the old "pdfData" on pdfContext
        CFDataRef myPDFData = (__bridge CFDataRef) [NSData dataWithContentsOfURL:pdfURL];
        CGDataProviderRef provider = CGDataProviderCreateWithCFData(myPDFData);
        CGPDFDocumentRef pdf = CGPDFDocumentCreateWithProvider(provider);
        CGDataProviderRelease(provider);
        CGPDFPageRef page = CGPDFDocumentGetPage(pdf, pageIndex);
        pageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
        CGContextBeginPage(pdfContext, &pageRect);
        CGContextDrawPDFPage(pdfContext, page);
        
        for (UIImageViewSign *imageViewSign in imageViews) {
            if ([imageViewSign isKindOfClass:[UIImageViewSign class]]) {
                
                /** 获取PDF某一页信息 */
                ReaderContentPage *contentPage = [[ReaderContentPage alloc] initWithURL:pdfURL page:pageIndex password:@""];
                
                // 显示当前页PDF 缩放后 的高
                CGFloat contentViewHeight = readerContentView.contentSize.width / (contentPage.pageWidth / contentPage.pageHeight);
                
                if (contentViewHeight < kScreenHeight) {
                    
                    CGFloat topSpace = (kScreenHeight - contentViewHeight) / 2.f;
                    CGFloat realTop = imageViewSign.top_ext - topSpace;
                    
                    pageRect = CGRectMake(imageViewSign.left_ext/readerContentView.zoomScale, contentPage.pageHeight - realTop/readerContentView.zoomScale - imageViewSign.height_ext/readerContentView.zoomScale, imageViewSign.width_ext/readerContentView.zoomScale, imageViewSign.height_ext/readerContentView.zoomScale);
                    
                    CGImageRef pageImage = [imageViewSign.image CGImage];
                    CGContextDrawImage(pdfContext, pageRect, pageImage);
                    
                    
                }else{
                    
                    NSLog(@"放大");
                    
                    pageRect = CGRectMake((readerContentView.contentOffset.x + imageViewSign.left_ext)/readerContentView.zoomScale, contentPage.pageHeight - (readerContentView.contentOffset.y + imageViewSign.top_ext)/readerContentView.zoomScale - imageViewSign.height_ext/readerContentView.zoomScale, imageViewSign.width_ext/readerContentView.zoomScale, imageViewSign.height_ext/readerContentView.zoomScale);
                    
                    CGImageRef pageImage = [imageViewSign.image CGImage];
                    CGContextDrawImage(pdfContext, pageRect, pageImage);
                }
            }
        }
        
        // release the allocated memory
        CGPDFContextEndPage(pdfContext);
        CGPDFContextClose(pdfContext);
        CGContextRelease(pdfContext);
        
        [self createPDFProcessingFilesPath];
        
        NSString *pdfFilePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/filePages/outPutPDF_%ld.pdf",kDataProcessingPdf, (long)pageIndex];
        [outputPDFData writeToFile:pdfFilePath atomically:YES];
        
        NSMutableArray *arrPdfPaths = [[NSMutableArray alloc] init];
        
        for (NSInteger i = 1; i <= maximumPage; i++) {
            NSString *pdfPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/filePages/outPutPDF_%ld.pdf", kDataProcessingPdf, (long)i];
            [arrPdfPaths addObject:pdfPath];
        }
        
        NSString *filePath = [self joinPDF:arrPdfPaths pdfPathOutput:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/newPdf_%ld.pdf", kDataProcessingPdf, self.testNumPage]];
        
        if (self.didCreateNewPDFBlock) {
            self.didCreateNewPDFBlock(filePath);
        }
        
        if ([self.delegate respondsToSelector:@selector(readerViewController:didCreateNewPdfWithPath:fileName:fileID:currPage:)]) {
            [self.delegate readerViewController:self didCreateNewPdfWithPath:filePath fileName:self.PdfFileName fileID:self.fileID currPage:self.testNumPage];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block();
            }
        });
        
    });
}

- (void)updateSubviewsWithNewPdfFilePath:(NSString *)pdfFilePath readerContentView:(ReaderContentView *)readerContentView page:(NSInteger)pageIndex
{
    [readerContentView removeFromSuperview];
    
    CGRect viewRect = CGRectZero; viewRect.size = theScrollView.bounds.size;
    
    viewRect.origin.x = (viewRect.size.width * (pageIndex - 1)); viewRect = CGRectInset(viewRect, scrollViewOutset, 0.0f);
    
    NSURL *fileURL = document.fileURL; NSString *phrase = document.password; NSString *guid = document.guid; // Document properties
    
    ReaderContentView *contentView = [[ReaderContentView alloc] initWithFrame:viewRect fileURL:fileURL page:pageIndex password:phrase]; // ReaderContentView
    
    contentView.message = self; [contentViews setObject:contentView forKey:[NSNumber numberWithInteger:pageIndex]]; [theScrollView addSubview:contentView];
    
    [contentView showPageThumb:fileURL page:pageIndex password:phrase guid:guid]; // Request page preview thumb
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


- (void)splitPdfDataAndWriteToFile
{
    for (NSInteger i = 1; i <= maximumPage; i++) {
        
        NSMutableData* outputPDFData = [[NSMutableData alloc] init];
        CGDataConsumerRef dataConsumer = CGDataConsumerCreateWithCFData((CFMutableDataRef)outputPDFData);
        
        CFMutableDictionaryRef attrDictionary = NULL;
        attrDictionary = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        CFDictionarySetValue(attrDictionary, kCGPDFContextTitle, CFSTR("My Doc"));
        CGContextRef pdfContext = CGPDFContextCreate(dataConsumer, NULL, attrDictionary);
        CFRelease(dataConsumer);
        CFRelease(attrDictionary);
        CGRect pageRect;
        
        // Draw the old "pdfData" on pdfContext
        CFDataRef myPDFData = (__bridge CFDataRef) [NSData dataWithContentsOfURL:document.fileURL];
        CGDataProviderRef provider = CGDataProviderCreateWithCFData(myPDFData);
        CGPDFDocumentRef pdf = CGPDFDocumentCreateWithProvider(provider);
        CGDataProviderRelease(provider);
        CGPDFPageRef page = CGPDFDocumentGetPage(pdf, i);
        pageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
        CGContextBeginPage(pdfContext, &pageRect);
        CGContextDrawPDFPage(pdfContext, page);
        
        // release the allocated memory
        CGPDFContextEndPage(pdfContext);
        CGPDFContextClose(pdfContext);
        CGContextRelease(pdfContext);
        
        // write new PDFData in "outPutPDF.pdf" file in document directory
        NSString *pdfFilePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/filePages/outPutPDF_%ld.pdf",kDataProcessingPdf, (long)i];
        [outputPDFData writeToFile:pdfFilePath atomically:YES];
        
    }
}

@end
