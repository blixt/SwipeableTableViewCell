#import "SwipeableTableViewCell.h"

NSString *const kSwipeableTableViewCellCloseEvent = @"SwipeableTableViewCellClose";
CGFloat const kSwipeableTableViewCellMaxCloseMilliseconds = 300;
CGFloat const kSwipeableTableViewCellOpenVelocityThreshold = 0.6;

@interface SwipeableTableViewCell ()

@property (nonatomic) NSArray *buttonViews;

@end

@implementation SwipeableTableViewCell

#pragma mark Lifecycle methods

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setUp];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) [self setUp];
    return self;
}

#pragma mark Public class methods

+ (void)closeAllCells {
    [self closeAllCellsExcept:nil];
}

+ (void)closeAllCellsExcept:(SwipeableTableViewCell *)cell {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSwipeableTableViewCellCloseEvent object:cell];
}

#pragma mark Public properties

- (CGFloat)leftInset {
    UIView *view = self.buttonViews[SwipeableTableViewCellSideLeft];
    return view.bounds.size.width;
}

- (CGFloat)rightInset {
    UIView *view = self.buttonViews[SwipeableTableViewCellSideRight];
    return view.bounds.size.width;
}

#pragma mark Public methods

- (void)close {
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

- (UIButton *)createButtonWithWidth:(CGFloat)width onSide:(SwipeableTableViewCellSide)side {
    UIView *container = self.buttonViews[side];
    CGSize size = container.bounds.size;

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    button.frame = CGRectMake(size.width, 0, width, size.height);

    // Resize the container to fit the new button.
    CGFloat x;
    switch (side) {
        case SwipeableTableViewCellSideLeft:
            x = -(size.width + width);
            break;
        case SwipeableTableViewCellSideRight:
            x = self.contentView.bounds.size.width;
            break;
    }
    container.frame = CGRectMake(x, 0, size.width + width, size.height);
    [container addSubview:button];

    // Update the scrollable areas outside the scroll view to fit the buttons.
    self.scrollView.contentInset = UIEdgeInsetsMake(0, self.leftInset, 0, self.rightInset);

    return button;
}

- (void)openSide:(SwipeableTableViewCellSide)side {
    [self openSide:side animated:YES];
}

- (void)openSide:(SwipeableTableViewCellSide)side animated:(BOOL)animate {
    switch (side) {
        case SwipeableTableViewCellSideLeft:
            [self.scrollView setContentOffset:CGPointMake(-self.leftInset, 0) animated:animate];
            break;
        case SwipeableTableViewCellSideRight:
            [self.scrollView setContentOffset:CGPointMake(self.rightInset, 0) animated:animate];
            break;
    }
}

#pragma mark Private methods

- (UIView *)createButtonsView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, self.contentView.bounds.size.height)];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.scrollView addSubview:view];
    return view;
}

- (void)handleCloseEvent:(NSNotification *)notification {
    if (notification.object == self) return;
    [self close];
}

- (void)setUp {
    // Create the scroll view which enables the horizontal swiping.
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scrollView.contentSize = self.contentView.bounds.size;
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    [self.contentView addSubview:scrollView];
    self.scrollView = scrollView;

    // Create the containers which will contain buttons on the left and right sides.
    self.buttonViews = @[[self createButtonsView], [self createButtonsView]];

    // Set up main content area.
    UIView *contentView = [[UIView alloc] initWithFrame:scrollView.bounds];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    contentView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:contentView];
    self.scrollViewContentView = contentView;

    // Put a label in the scroll view content area.
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectInset(contentView.bounds, 10, 0)];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.scrollViewContentView addSubview:label];
    self.scrollViewLabel = label;

    // Listen for events that tell cells to hide their buttons.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleCloseEvent:)
                                                 name:kSwipeableTableViewCellCloseEvent
                                               object:nil];
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ((self.leftInset == 0 && scrollView.contentOffset.x < 0) || (self.rightInset == 0 && scrollView.contentOffset.x > 0)) {
        scrollView.contentOffset = CGPointZero;
    }

    UIView *leftView = self.buttonViews[SwipeableTableViewCellSideLeft];
    UIView *rightView = self.buttonViews[SwipeableTableViewCellSideRight];
    if (scrollView.contentOffset.x < 0) {
        // Make the left buttons stay in place.
        leftView.frame = CGRectMake(scrollView.contentOffset.x, 0, self.leftInset, leftView.frame.size.height);
        leftView.hidden = NO;
        // Hide the right buttons.
        rightView.hidden = YES;
    } else if (scrollView.contentOffset.x > 0) {
        // Make the right buttons stay in place.
        rightView.frame = CGRectMake(self.contentView.bounds.size.width - self.rightInset + scrollView.contentOffset.x, 0,
                                     self.rightInset, rightView.frame.size.height);
        rightView.hidden = NO;
        // Hide the left buttons.
        leftView.hidden = YES;
    } else {
        leftView.hidden = YES;
        rightView.hidden = YES;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [[self class] closeAllCellsExcept:self];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    CGFloat x = scrollView.contentOffset.x, left = self.leftInset, right = self.rightInset;
    if (left > 0 && (x < -left || (x < 0 && velocity.x < -kSwipeableTableViewCellOpenVelocityThreshold))) {
        targetContentOffset->x = -left;
    } else if (right > 0 && (x > right || (x > 0 && velocity.x > kSwipeableTableViewCellOpenVelocityThreshold))) {
        targetContentOffset->x = right;
    } else {
        *targetContentOffset = CGPointZero;

        // If the scroll isn't on a fast path to zero, animate it instead.
        CGFloat ms = x / -velocity.x;
        if (velocity.x == 0 || ms < 0 || ms > kSwipeableTableViewCellMaxCloseMilliseconds) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [scrollView setContentOffset:CGPointZero animated:YES];
            });
        }
    }
}

#pragma mark UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    // This is necessary to ensure that the content size scales with the view.
    self.scrollView.contentSize = self.contentView.bounds.size;
    self.scrollView.contentOffset = CGPointZero;
}

@end
