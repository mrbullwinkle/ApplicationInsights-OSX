#import "AppInsights.h"

#if MSAI_FEATURE_METRICS

@class MSAIAppClient;
@class MSAIChannel;
@class MSAITelemetryData;

@interface MSAIMetricsManager () {
}

- (instancetype)initWithAppIdentifier:(NSString *)appIdentifier appClient:(MSAIAppClient *)appClient isAppStoreEnvironment:(BOOL)appStoreEnvironment;

/**
 *  must be set
 */
@property (nonatomic, strong) MSAIAppClient *appClient;

/**
 *  used by MSAIMetricsManager if disable status is changed
 */
@property (nonatomic, getter = isMetricsManagerDisabled) BOOL disableMetricsManager;

/**
 *  To send data in background
 */
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskIdentifier;

/**
 * Removes the stored first_time setup, so the next session will be reported as first_session again
 *
 * Call this before invoking `startManager`!
 */
- (void) cleanupInternalStorage;


///-----------------------------------------------------------------------------
/// @name Send data to channel
///-----------------------------------------------------------------------------

/**
 *  Telemetry channel for enqueueing metric data
 */
@property (nonatomic, strong, readonly) MSAIChannel *telemetryChannel;

/**
 * Sends message to the channel.
 *
 * @param telemetry    telemetry object
 */
- (void)trackDataItem:(MSAITelemetryData *)dataItem;

@end

#endif
