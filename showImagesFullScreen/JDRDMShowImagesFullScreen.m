//
//  JDRDMShowImagesFullScreen.m
//  RDM
//
//  Created by phh on 15/11/28.
//  Copyright © 2015年 phh. All rights reserved.
//

#import "JDRDMShowImagesFullScreen.h"
#import "ImgScrollView.h"

@interface JDRDMShowImagesFullScreen()

@property (nonatomic, strong)UIView *scrollPanel;
@property (nonatomic, strong)UIView *markPanelView;
@property (nonatomic, strong)UIScrollView *myScrollView;
@property (nonatomic, strong)UIWindow *window;
@property (nonatomic, strong)UIPageControl *imagePageControll;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign)CGFloat itemWidth;

@end
static CGFloat spaceWidth = 10;

@implementation JDRDMShowImagesFullScreen

+ (JDRDMShowImagesFullScreen*)shareJDRDMShowImagesFullScreenManager
{
    static dispatch_once_t once;
    static JDRDMShowImagesFullScreen *shareInstance = nil;
    dispatch_once(&once, ^{
        
        if (!shareInstance) {
            shareInstance = [[JDRDMShowImagesFullScreen alloc] init];
        }
    });
    return shareInstance;
}

- (id)init
{
    if (self = [super init]) {
        self.window = [[UIApplication sharedApplication].delegate window];
        self.scrollPanel = [[UIView alloc] initWithFrame:self.window.frame];
        [self.scrollPanel setBackgroundColor:[UIColor clearColor]];
        [self.scrollPanel setAlpha:0];
        
        self.markPanelView = [[UIView alloc] initWithFrame:self.scrollPanel.frame];
        [self.markPanelView setBackgroundColor:[UIColor blackColor]];
        self.markPanelView.alpha = 0;
        [self.scrollPanel addSubview:self.markPanelView];
        
        self.myScrollView = [[UIScrollView alloc] initWithFrame:self.scrollPanel.frame];
        [self.myScrollView setShowsHorizontalScrollIndicator:NO];
        [self.myScrollView setShowsVerticalScrollIndicator:NO];
        [self.scrollPanel addSubview:self.myScrollView];
        self.myScrollView.pagingEnabled = YES;
        [self.myScrollView setDelegate:(id<UIScrollViewDelegate>)self];
        self.imagePageControll = [[UIPageControl alloc] init];
        [self.scrollPanel addSubview:self.imagePageControll];
        [self.imagePageControll setHidden:YES];
        self.itemWidth = self.myScrollView.frame.size.width + 2*spaceWidth;
    }
    return self;
}

- (void)createPageControll:(NSUInteger)numbers currentIndex:(NSUInteger)index
{
    [self.imagePageControll setNumberOfPages:numbers];
    [self.imagePageControll setCurrentPage:index];
    [self.imagePageControll setFrame:CGRectMake(0, 0, numbers*10, 100)];
    [self.imagePageControll setCenter:CGPointMake(self.scrollPanel.center.x, self.scrollPanel.bounds.size.height - 20)];
    self.imagePageControll.currentPageIndicatorTintColor = [UIColor whiteColor];
    self.imagePageControll.pageIndicatorTintColor = [UIColor colorWithWhite:1.0 alpha:0.5];
}

- (void)showImages:(NSArray<UIImageView*> *)imageArray currentShowImageIndex:(NSUInteger)index
{
    if (index < [imageArray count]) {
        
        [self createPageControll:[imageArray count] currentIndex:index];
        
        CGSize contentSize = self.myScrollView.contentSize;
        contentSize.height = self.window.frame.size.height;
        contentSize.width = self.itemWidth * [imageArray count];
        self.myScrollView.contentSize = contentSize;
        [self.window addSubview:self.scrollPanel];
        
        UIImageView *currentImageView = [imageArray objectAtIndex:index];
        CGRect convertRect = [currentImageView.superview convertRect:currentImageView.frame toView:self.window];
        CGPoint contentOffset = self.myScrollView.contentOffset;
        contentOffset.x = index*self.itemWidth;
        self.myScrollView.contentOffset = contentOffset;
        [self addSubIamgeView:imageArray currentShowImageIndex:index];
        
        CGRect frame = self.myScrollView.bounds;
        frame.origin.x = index * self.itemWidth;
        frame.origin.y = 0;
        frame.size.width = self.itemWidth;
        ImgScrollView *tmpImgScrollView = [[ImgScrollView alloc] initWithFrame:CGRectInset(frame, spaceWidth, 0)];

        [tmpImgScrollView setContentWithFrame:convertRect];
        [tmpImgScrollView setImage:currentImageView.image];
        [self.myScrollView addSubview:tmpImgScrollView];
        tmpImgScrollView.i_delegate = (id<ImgScrollViewDelegate>)self;
        [self performSelector:@selector(setOriginFrame:) withObject:tmpImgScrollView afterDelay:0.1];
        
        self.myScrollView.frame = CGRectMake(-spaceWidth, 0, self.itemWidth, self.scrollPanel.frame.size.height);
    }
}

- (void)addSubIamgeView:(NSArray<UIImageView*> *)imageArray currentShowImageIndex:(NSUInteger)index
{
    [imageArray enumerateObjectsUsingBlock:^(UIImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (index == idx) {
            return;
        }
    
        UIImageView *tmpView = (UIImageView *)imageArray[idx];
        
        //转换后的rect
        CGRect convertRect = [tmpView.superview convertRect:tmpView.frame toView:nil];
        
        CGRect frame = self.myScrollView.bounds;
        frame.origin.x = idx * self.itemWidth;
        frame.origin.y = 0;
        frame.size.width = self.itemWidth;
        ImgScrollView *tmpImgScrollView = [[ImgScrollView alloc] initWithFrame:CGRectInset(frame, spaceWidth, 0)];
        [tmpImgScrollView setContentWithFrame:convertRect];
        [tmpImgScrollView setImage:tmpView.image];
        [self.myScrollView addSubview:tmpImgScrollView];
        tmpImgScrollView.i_delegate = (id<ImgScrollViewDelegate>)self;
        
        [tmpImgScrollView setAnimationRect];

    }];
    
}

- (void) setOriginFrame:(ImgScrollView *) sender
{

    [UIView animateWithDuration:0.1 animations:^{
        [self.scrollPanel setAlpha:1.0];
        [self.markPanelView setAlpha:1.0];
    } completion:^(BOOL finished)
     {
         [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
     }];
    
    [UIView animateWithDuration:0.4 animations:^{
        [sender setAnimationRect];
    } completion:^(BOOL finished)
     {
         [self.imagePageControll setHidden:NO];
         self.imagePageControll.hidesForSinglePage = YES;
     }];
}

- (void) tapImageViewTappedWithObject:(id)sender
{
    
    ImgScrollView *tmpImgView = sender;
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];

    [UIView animateWithDuration:0.3 animations:^{
        [self.markPanelView setAlpha:0];
        [self.imagePageControll setHidden:YES];
    }];
    [UIView animateWithDuration:0.4 animations:^{
        [tmpImgView rechangeInitRdct];
    } completion:^(BOOL finished){
        self.scrollPanel.alpha = 0;
        [self.scrollPanel removeFromSuperview];
        for (UIView *tmpView in self.myScrollView.subviews)
        {
            [tmpView removeFromSuperview];
        }
        
    }];
    
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger currentPage=scrollView.contentOffset.x/self.itemWidth;
    [self.imagePageControll setCurrentPage:currentPage];
    for (UIView *tmpView in self.myScrollView.subviews)
    {
        if ([tmpView isKindOfClass:[ImgScrollView class]]) {
            [((ImgScrollView *)tmpView) setZoomScale:1.0];
        }
    }
}



@end

