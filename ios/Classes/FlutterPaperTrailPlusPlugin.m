#import "FlutterPaperTrailPlusPlugin.h"
#import <flutter_paper_trail_plus/flutter_paper_trail_plus-Swift.h>

@implementation FlutterPaperTrailPlusPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterPaperTrailPlusPlugin registerWithRegistrar:registrar];
}
@end
