#ifndef INC_Main_h_
#define INC_Main_h_

#include <GSWeb/GSWeb.h>

@class GSWDisplayGroup;

@interface Main : GSWComponent
{
  id author;                 /* Custom objects or EOGenericRecord.  */
  GSWDisplayGroup *authorDG; /* Initiilaized by [GSWComponent-init]
				via the components .gswi file. */
}

- (void)selectObject;
- (void)saveChanges;

@end

#endif
