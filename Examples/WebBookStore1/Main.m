#include <EOControl/EOControl.h>
#include <EOAccess/EOAccess.h>

#include <GSWDatabase/WODisplayGroup.h>

#include "Main.h"

@implementation Main

- (void)selectObject
{
  [authorDG selectObject: author];
}

- (void)saveChanges
{
  [[[self session] defaultEditingContext] saveChanges]; 
}

- (void) setAuthorDG:(WODisplayGroup*) dg
{
  ASSIGN(authorDG, dg);
}

- (void)dealloc
{
  /* These variables were set via EOKeyValueCoding (KVC) from
     the wod initialization or */
  DESTROY(author);
  DESTROY(authorDG);

  [super dealloc];
}

@end
