#import "_Message.h"
#import "UIImageView+AFNetworking.h"
#import "CWMessageCell.h"

typedef enum eMessageDownloadState
{
    eMessageDownloadStateInvalid = -1,
    eMessageDownloadStateNotDownloaded,
    eMessageDownloadStateNotDownloadedThumbnail,
    eMessageDownloadStateDownloaded,
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

@property (nonatomic, strong) NSURL * videoURL;//not core data backed.
@property (nonatomic, strong) NSURL * zipURL;//not saved in core data
@property (nonatomic, strong) UIImage * lastFrameImage; //not saved in core data

- (eMessageViewedState) eMessageViewedState;
- (void) setEMessageViewedState:(eMessageViewedState) eViewedState;

- (eMessageDownloadState) eDownloadState;
- (void) setEMessageDownloadState:(eMessageDownloadState ) eState;
- (void) downloadChatwalaDataWithMessageCell:(CWMessageCell *) messageCell;
- (void) exportZip;

@end
