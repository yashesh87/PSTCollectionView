//
//  PSCollectionViewItemKey.m
//  PSPDFKit
//
//  Copyright (c) 2012 Peter Steinberger. All rights reserved.
//

#import "PSCollectionViewItemKey.h"
#import "PSCollectionViewLayout.h"

@implementation PSCollectionViewItemKey

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Static

+ (id)collectionItemKeyForCellWithIndexPath:(NSIndexPath *)indexPath {
    PSCollectionViewItemKey *key = [[self class] new];
    key.indexPath = indexPath;
    key.type = PSCollectionViewItemTypeCell;
    return key;
}

+ (id)collectionItemKeyForLayoutAttributes:(PSCollectionViewLayoutAttributes *)layoutAttributes {
    PSCollectionViewItemKey *key = [[self class] new];
    key.indexPath = layoutAttributes.indexPath;
    key.type = PSCollectionViewItemTypeCell; // TODO figure out real type
//    key.identifier =
    return key;
}

// elementKind or reuseIdentifier?
+ (id)collectionItemKeyForDecorationViewOfKind:(NSString *)elementKind andIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

+ (id)collectionItemKeyForSupplementaryViewOfKind:(NSString *)elementKind andIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

NSString *PSCollectionViewItemTypeToString(PSCollectionViewItemType type) {
    switch (type) {
        case PSCollectionViewItemTypeCell: return @"Cell";
        case PSCollectionViewItemTypeDecorationView: return @"Decoration";
        case PSCollectionViewItemTypeSupplementaryView: return @"Supplementary";
        default: return @"<INVALID>";
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> Type = %@ IndexPath = %@", NSStringFromClass([self class]), self, PSCollectionViewItemTypeToString(self.type), self.indexPath];
}

- (NSUInteger)hash {
    return (([_indexPath hash] + _type) * 31) + [_identifier hash];
}

- (BOOL)isEqual:(id)other {
    if ([other isKindOfClass:[self class]]) {
        PSCollectionViewItemKey *otherKeyItem = (PSCollectionViewItemKey *)other;
        // identifier might be nil?
        if (_type == otherKeyItem.type && [_indexPath isEqual:otherKeyItem.indexPath] && ([_identifier isEqual:otherKeyItem.identifier] || _identifier == otherKeyItem.identifier)) {
            return YES;
            }
        }
    return NO;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    PSCollectionViewItemKey *itemKey = [[self class] new];
    itemKey.indexPath = self.indexPath;
    itemKey.type = self.type;
    itemKey.identifier = self.identifier;
    return itemKey;
}

@end