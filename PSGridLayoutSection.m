//
//  PSCollectionLayoutSection.m
//  PSPDFKit
//
//  Copyright (c) 2012 Peter Steinberger. All rights reserved.
//

#import "PSGridLayoutSection.h"
#import "PSGridLayoutItem.h"
#import "PSGridLayoutRow.h"
#import "PSGridLayoutInfo.h"

@interface PSGridLayoutSection() {
    NSMutableArray *_items;
    NSMutableArray *_rows;
    BOOL _isValid;
}
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSArray *rows;
@property (nonatomic, assign) CGFloat otherMargin;
@property (nonatomic, assign) CGFloat beginMargin;
@property (nonatomic, assign) CGFloat endMargin;
@property (nonatomic, assign) CGFloat actualGap;
@property (nonatomic, assign) CGFloat lastRowBeginMargin;
@property (nonatomic, assign) CGFloat lastRowEndMargin;
@property (nonatomic, assign) CGFloat lastRowActualGap;
@property (nonatomic, assign) BOOL lastRowIncomplete;
@property (nonatomic, assign) NSInteger itemsByRowCount;
@property (nonatomic, assign) NSInteger indexOfImcompleteRow;
@end

@implementation PSGridLayoutSection

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (id)init {
    if((self = [super init])) {
        _items = [NSMutableArray new];
        _rows = [NSMutableArray new];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p itemCount:%d frame:%@ rows:%@>", NSStringFromClass([self class]), self, self.itemsCount, NSStringFromCGRect(self.frame), self.rows];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

- (void)invalidate {
    _isValid = NO;
    self.rows = [NSMutableArray array];
}

- (void)computeLayout {
    if (!_isValid) {
        NSAssert([self.rows count] == 0, @"No rows shall be at this point.");

        // iterate over all items, turning them into rows.
        CGSize sectionSize = CGSizeZero;
        CGFloat dimension = self.layoutInfo.dimension;
        NSUInteger rowIndex = 0;
        NSUInteger itemIndex = 0;
        NSUInteger itemsByRowCount = 0;
        CGFloat dimensionLeft = 0;
        PSGridLayoutRow *row = nil;
        do {
            BOOL finishCycle = itemIndex >= self.itemsCount;
            // TODO: fast path could even remove row creation and just calculate on the fly
            PSGridLayoutItem *item = nil;
            if (!finishCycle) {
                item = self.fixedItemSize ? nil : [self.items objectAtIndex:itemIndex];
            }
            CGSize itemSize = self.fixedItemSize ? self.itemSize : item.itemFrame.size;
            CGFloat itemDimension = self.layoutInfo.horizontal ? itemSize.height : itemSize.width;
            if (dimensionLeft < itemDimension || finishCycle) {
                // finish current row
                if (row) {
                    // compensate last row
                    self.itemsByRowCount = fmaxf(itemsByRowCount, self.itemsByRowCount);
                    row.itemCount = itemsByRowCount;
                    [row layoutRow];
                    if (self.layoutInfo.horizontal) {
                        row.rowFrame = CGRectMake(sectionSize.width, 0, row.rowSize.width, row.rowSize.height);
                        sectionSize.height = fmaxf(row.rowSize.height, sectionSize.height);
                        sectionSize.width += row.rowSize.width;
                    }else {
                        row.rowFrame = CGRectMake(0, sectionSize.height, row.rowSize.width, row.rowSize.height);
                        sectionSize.height += row.rowSize.height;
                        sectionSize.width = fmaxf(row.rowSize.width, sectionSize.width);
                    }
                }
                if (!finishCycle) {
                    // create new row
                    row = [self addRow];
                    row.fixedItemSize = self.fixedItemSize;
                    row.index = rowIndex;
                    rowIndex++;
                    itemsByRowCount = 0;
                    dimensionLeft = dimension;
                }
            }
            dimensionLeft -= itemDimension;

            // add item on slow path
            if (item) {
                [row addItem:item];
            }
            itemIndex++;
            itemsByRowCount++;
        }while (itemIndex <= self.itemsCount); // cycle once more to finish last row
        
        _frame = (CGRect){.size=sectionSize};
        _isValid = YES;
    }
}

- (void)recomputeFromIndex:(NSInteger)index {
    // TODO: use index.
    [self invalidate];
    [self computeLayout];
}

- (PSGridLayoutItem *)addItem {
    PSGridLayoutItem *item = [PSGridLayoutItem new];
    item.section = self;
    [_items addObject:item];
    return item;
}

- (PSGridLayoutRow *)addRow {
    PSGridLayoutRow *row = [PSGridLayoutRow new];
    row.section = self;
    [_rows addObject:row];
    return row;
}

- (PSGridLayoutSection *)snapshot {
    PSGridLayoutSection *snapshotSection = [PSGridLayoutSection new];
    snapshotSection.items = [self.items copy];
    snapshotSection.rows = [self.items copy];
    snapshotSection.verticalInterstice = self.verticalInterstice;
    snapshotSection.horizontalInterstice = self.horizontalInterstice;
    snapshotSection.sectionMargins = self.sectionMargins;
    snapshotSection.frame = self.frame;
    snapshotSection.headerFrame = self.headerFrame;
    snapshotSection.footerFrame = self.footerFrame;
    snapshotSection.headerDimension = self.headerDimension;
    snapshotSection.footerDimension = self.footerDimension;
    snapshotSection.layoutInfo = self.layoutInfo;
    snapshotSection.rowAlignmentOptions = self.rowAlignmentOptions;
    snapshotSection.fixedItemSize = self.fixedItemSize;
    snapshotSection.itemSize = self.itemSize;
    snapshotSection.itemsCount = self.itemsCount;
    snapshotSection.otherMargin = self.otherMargin;
    snapshotSection.beginMargin = self.beginMargin;
    snapshotSection.endMargin = self.endMargin;
    snapshotSection.actualGap = self.actualGap;
    snapshotSection.lastRowBeginMargin = self.lastRowBeginMargin;
    snapshotSection.lastRowEndMargin = self.lastRowEndMargin;
    snapshotSection.lastRowActualGap = self.lastRowActualGap;
    snapshotSection.lastRowIncomplete = self.lastRowIncomplete;
    snapshotSection.itemsByRowCount = self.itemsByRowCount;
    snapshotSection.indexOfImcompleteRow = self.indexOfImcompleteRow;
    return snapshotSection;
}

- (NSInteger)itemsCount {
    return self.fixedItemSize ? _itemsCount : [self.items count];
}

@end