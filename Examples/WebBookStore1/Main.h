#ifndef INC_Main_h_
#define INC_Main_h_

#include <WebObjects/WebObjects.h>

@class WODisplayGroup;

@interface Main : WOComponent
{
  id author;                 /* Custom objects or EOGenericRecord.  */
  WODisplayGroup *authorDG;  /* Initiilaized by [GSWComponent-init]
                                via the components .wod file. */
}

- (void)selectObject;
- (void)saveChanges;

@end

#endif
