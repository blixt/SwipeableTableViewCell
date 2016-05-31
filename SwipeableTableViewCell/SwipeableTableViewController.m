#import "SwipeableTableViewController.h"

@interface SwipeableTableViewController ()

@property (nonatomic) NSArray *labels;

@end

@implementation SwipeableTableViewController

#pragma mark Lifecycle methods

- (void)viewDidLoad {
    self.labels = @[@"Pippi Longstocking", @"Austin Powers", @"Spider-Man", @"James Bond",
                    @"Lisbeth Salander", @"Donald Duck", @"Luke Skywalker", @"Lara Croft",
                    @"Frodo Baggins", @"Hermione Granger", @"Dexter Morgan", @"Ted Mosby",
                    @"Homer Simpson", @"John Connor", @"Arya Stark", @"Captain Kirk"];
}

#pragma mark Private methods

- (void)tickle {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Tee-hee!"
                                                                        message:@"Stop it!"
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:@"Okay :)"
                                                   style:UIAlertActionStyleDefault
                                                 handler:nil]];
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [SwipeableTableViewCell closeAllCells];
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"randomCell";

    // For the purposes of this demo, just return a random cell.
    SwipeableTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[SwipeableTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];

        UIButton *tickleButton = [cell createButtonWithWidth:100 onSide:SwipeableTableViewCellSideLeft];
        tickleButton.backgroundColor = [UIColor colorWithRed:0.23 green:0.34 blue:0.58 alpha:1];
        [tickleButton addTarget:self action:@selector(tickle) forControlEvents:UIControlEventTouchUpInside];
        [tickleButton setTitle:@"Tickle!" forState:UIControlStateNormal];
        [tickleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

        UIButton *moreButton = [cell createButtonWithWidth:80 onSide:SwipeableTableViewCellSideRight];
        moreButton.backgroundColor = [UIColor lightGrayColor];
        [moreButton setTitle:@"More" forState:UIControlStateNormal];
        [moreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

        UIButton *deleteButton = [cell createButtonWithWidth:80 onSide:SwipeableTableViewCellSideRight];
        deleteButton.backgroundColor = [UIColor redColor];
        [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
        [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }

    cell.scrollViewLabel.text = self.labels[indexPath.row];

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.labels count];
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Remove insets and margins from cells.
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }

    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }

    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%i",indexPath.row);
}

@end
