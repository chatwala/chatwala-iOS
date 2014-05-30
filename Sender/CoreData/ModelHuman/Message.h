#import "_Message.h"
#import "UIImageView+AFNetworking.h"

typedef enum eMessageDownloadState
{
    eMessageDownloadStateInvalid = -1,
    eMessageDownloadStateNotDownloaded,
    eMessageDownloadStateNotDownloadedThumbnail,
    eMessageDownloadStateDownloaded,
    eMessageDownloadStateDeviceDeleted,
    eMessageDownloadStateTotal
    
} eMessageDownloadState;

typedef enum eMessageViewedState
{
    eMessageViewedStateInvalid = -1,
    eMessageViewedStateUnOpened,
    eMessageViewedStateOpened,
    eMessageViewedStateRead,
    eMessageViewedStateReplied,
    eMessageViewedStateTotal
    
} eMessageViewedState;


@protocol Message <_Message>
@end

@interface Message : _Message <Message> {}
// Custom logic goes here.

@property (nonatomic, strong) NSURL * tempVideoURL;//not core data backed.
@property (nonatomic, strong) NSURL * chatwalaZipURL;//not saved in core data
@property (nonatomic, strong) UIImage * lastFrameImage; //not saved in core data
@property (nonatomic, strong) NSString *thumbnailUploadURLString;

- (eMessageViewedState) eMessageViewedState;
- (void)setEMessageViewedState:(eMessageViewedState) eViewedState;

- (eMessageDownloadState) eDownloadState;
- (void)setEMessageDownloadState:(eMessageDownloadState ) eState;
- (void)exportZip;
- (void)importZip:(NSURL *)zipURL;
- (void)saveContext;

- (void)addMessageToUserInbox:(NSString *)userID;
- (void)deleteMessageFromInbox;
- (BOOL)isMarkedAsDeleted;
- (BOOL)shouldOpenInViewer;

- (void)uploadThumbnailImage:(UIImage *)image;

// Message file accessors
- (NSURL *)inboxZipURL;
- (NSURL *)inboxVideoFileURL;

- (NSURL *)sentChatwalaZipURL;
- (NSURL *)sentboxVideoFileURL;

- (NSURL *)outboxChatwalaZipURL;
@end
