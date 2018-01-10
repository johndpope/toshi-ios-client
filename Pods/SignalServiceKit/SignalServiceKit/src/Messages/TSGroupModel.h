//
//  Copyright (c) 2017 Open Whisper Systems. All rights reserved.
//

#import "TSYapDatabaseObject.h"
#import "ContactsManagerProtocol.h"

extern NSString *const GroupUpdateTypeSting;
extern NSString *const GroupInfoString;

extern NSString *const GroupCreateMessage;
extern NSString *const GroupBecameMemberMessage;
extern NSString *const GroupUpdatedMessage;
extern NSString *const GroupTitleChangedMessage;
extern NSString *const GroupAvatarChangedMessage;
extern NSString *const GroupMemberLeftMessage;
extern NSString *const GroupMemberJoinedMessage;

@interface TSGroupModel : TSYapDatabaseObject

@property (nonatomic, strong) NSArray<NSString *> *groupMemberIds;
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, strong) NSData *groupId;

#if TARGET_OS_IOS
@property (nonatomic, strong) UIImage *groupImage;

- (instancetype)initWithTitle:(NSString *)title
                    memberIds:(NSMutableArray<NSString *> *)memberIds
                        image:(UIImage *)image
                      groupId:(NSData *)groupId;

- (BOOL)isEqual:(id)other;
- (BOOL)isEqualToGroupModel:(TSGroupModel *)model;
- (NSDictionary *)getInfoAboutUpdateTo:(TSGroupModel *)newModel;
#endif

@end
