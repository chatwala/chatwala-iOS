#import "_Message.h"

typedef enum eMessageDownloadState
{
    eMessageDownloadStateInvalid = -1,
    eMessageDownloadStateNotDownloaded,
    eMessageDownloadStateNotDownloadedThumbnail,
    eMessageDownloadStateDownloaded,
    eMessageDownloadStateTotal
    
} eMessageDownloadState;

@protocol Message <_Message>
@end

@interface Message : _Message <Message> {}
// Custom logic goes here.

- (eMessageDownloadState) eDownloadState;
- (void) downloadChatwalaData;

@end
