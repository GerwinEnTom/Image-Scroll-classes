
#import "PagingAndZoomingViewController.h"


@interface PagingAndZoomingViewController () <UIScrollViewDelegate>
@end


@implementation PagingAndZoomingViewController

- (CGSize)pageSize {
	CGSize pageSize = scrollView.frame.size;
	if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
		return CGSizeMake(pageSize.height, pageSize.width);
	else
		return pageSize;
}

- (void)setPagingMode {
	// reposition pages side by side, add them back to the view
	CGSize pageSize = [self pageSize];
	NSUInteger page = 0;
	for (UIView *view in pageViews) {
		if (!view.superview)
			[scrollView addSubview:view];
		view.frame = CGRectMake(pageSize.width * page++, 0, pageSize.width, pageSize.height);
	}
	
	scrollView.pagingEnabled = YES;
	scrollView.showsVerticalScrollIndicator = scrollView.showsHorizontalScrollIndicator = NO;
	scrollView.contentSize = CGSizeMake(pageSize.width * [pageViews count], pageSize.height);
	scrollView.contentOffset = CGPointMake(pageSize.width * currentPage, 0);
	
	scrollViewMode = ScrollViewModePaging;
}

- (void)setZoomingMode {
	NSLog(@"setZoomingMode");
	scrollViewMode = ScrollViewModeZooming; // has to be set early, or else currentPage will be mistakenly reset by scrollViewDidScroll
	
	// hide all pages except the current one
	NSUInteger page = 0;
	for (UIView *view in pageViews)
		if (currentPage != page++)
			[view removeFromSuperview];
	
	scrollView.pagingEnabled = NO;
	scrollView.showsVerticalScrollIndicator = scrollView.showsHorizontalScrollIndicator = YES;
	pendingOffsetDelta = scrollView.contentOffset.x;
	scrollView.bouncesZoom = YES;
}

- (void)loadView {
	CGRect frame = [UIScreen mainScreen].applicationFrame;
	scrollView = [[UIScrollView alloc] initWithFrame:frame];
	scrollView.delegate = self;
	scrollView.maximumZoomScale = 5.0f;
	scrollView.minimumZoomScale = 1.0f;
	//	scrollView.zoomInOnDoubleTap = scrollView.zoomOutOnDoubleTap = YES;
	
	UIImageView *imageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1.jpg"]];
	UIImageView *imageView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"2.jpg"]];
	UIImageView *imageView3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"3.jpg"]];
	UIImageView *imageView4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"4.jpg"]];
	UIImageView *imageView5 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"5.jpg"]];
	UIImageView *imageView6 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"6.jpg"]];
	UIImageView *imageView7 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"7.jpg"]];
	UIImageView *imageView8 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"8.jpg"]];
	UIImageView *imageView9 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"9.jpg"]];
	UIImageView *imageView10 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"10.jpg"]];
	UIImageView *imageView11 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eyes.jpg"]];
	UIImageView *imageView12 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blue.jpg"]];
	UIImageView *imageView13 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"red.jpg"]];
	
	// in a real app, you most likely want to have an array of view controllers, not views;
	// also should be instantiating those views and view controllers lazily
	pageViews = [[NSArray alloc] initWithObjects:imageView1, imageView2, imageView3, imageView4, imageView5, imageView6, imageView7, imageView8, imageView9, imageView10, imageView11, imageView12, imageView13, nil];
	
	self.view = scrollView;
}

- (void)setCurrentPage:(NSUInteger)page {
	if (page == currentPage)
		return;
	currentPage = page;
	// in a real app, this would be a good place to instantiate more view controllers -- see SDK examples
}

- (void)viewDidLoad {
	scrollViewMode = ScrollViewModeNotInitialized;
}

- (void)viewWillAppear:(BOOL)animated {
	[self setPagingMode];
}

- (void)viewDidUnload {
	
	[imgArray release];
	[pageViews release]; // need to release all page views here; our array is created in loadView, so just releasing it
	pageViews = nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
	if (scrollViewMode == ScrollViewModePaging)
		[self setCurrentPage:roundf(scrollView.contentOffset.x / [self pageSize].width)];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)aScrollView {
	NSLog(@"viewForZoomingInScrollView");
	if (scrollViewMode != ScrollViewModeZooming)
		[self setZoomingMode];
	return [pageViews objectAtIndex:currentPage];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)aScrollView withView:(UIView *)view atScale:(float)scale {
	NSLog(@"scrollViewDidEndZooming");
	if (scrollView.zoomScale == scrollView.minimumZoomScale)
		[self setPagingMode];
	else if (pendingOffsetDelta > 0) {
		UIView *view = [pageViews objectAtIndex:currentPage];
		view.center = CGPointMake(view.center.x - pendingOffsetDelta, view.center.y);
		CGSize pageSize = [self pageSize];
		scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x - pendingOffsetDelta, scrollView.contentOffset.y);
		scrollView.contentSize = CGSizeMake(pageSize.width * scrollView.zoomScale, pageSize.height * scrollView.zoomScale);
		pendingOffsetDelta = 0;
	}
	
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	NSLog(@"scrollViewWillBeginDragging");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	NSLog(@"scrollViewDidEndDragging");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	if (scrollViewMode == ScrollViewModePaging) {
		scrollViewMode = ScrollViewModeNotInitialized;
		[self setPagingMode];
	} else {
		[self setZoomingMode];
	}
}

@end
