#include <EOControl/EOControl.h>
#include <EOAccess/EOAccess.h>

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

- (void)createTables
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  EODatabaseDataSource *dataSource = (id)[authorDG dataSource];
  EOEntity *entity = [dataSource entity];
  EOModel *model = [entity model];
  NSArray *entities = [model entities];
  EOAdaptor *adaptor = [EOAdaptor adaptorWithModel: model];
  Class exprClass = [adaptor expressionClass];
  NSDictionary *createOptDict
    = [NSDictionary dictionaryWithObjectsAndKeys:
                      @"NO", @"EODropTablesKey",
                    @"NO", @"EODropPrimaryKeySupportKey", nil];

  EOAdaptorContext *context = [adaptor createAdaptorContext];
  EOAdaptorChannel *channel = [context createAdaptorChannel];
  NSArray *exprs;
  EOSQLExpression *expr;
  unsigned i,c;

  exprs = [exprClass schemaCreationStatementsForEntities: entities
                     options: createOptDict];

  [channel openChannel];
  for (i=0, c=[exprs count]; i<c; i++)
    {
      expr = [exprs objectAtIndex: i];
      [channel evaluateExpression: expr];
    }
  [channel closeChannel];

  [pool release];
}

- (void)dropTables
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  EODatabaseDataSource *dataSource = (id)[authorDG dataSource];
  EOEntity *entity = [dataSource entity];
  EOModel *model = [entity model];
  NSArray *entities = [model entities];
  EOAdaptor *adaptor = [EOAdaptor adaptorWithModel: model];
  Class exprClass = [adaptor expressionClass];
  NSDictionary *dropOptDict
    = [NSDictionary dictionaryWithObjectsAndKeys:
                      @"NO", @"EOPrimaryKeyConstraintsKey",
                    @"NO", @"EOCreatePrimaryKeySupportKey",
                    @"NO", @"EOCreateTablesKey",
                    nil];

  EOAdaptorContext *context = [adaptor createAdaptorContext];
  EOAdaptorChannel *channel = [context createAdaptorChannel];
  NSArray *exprs;
  EOSQLExpression *expr;
  unsigned i,c;

  exprs = [exprClass schemaCreationStatementsForEntities: entities
                     options: dropOptDict];

  [channel openChannel];
  for (i=0, c=[exprs count]; i<c; i++)
    {
      expr = [exprs objectAtIndex: i];
      [channel evaluateExpression: expr];
    }
  [channel closeChannel];

  [pool release];
}

- (void)dealloc
{
  /* These variables were set via EOKeyValueCoding (KVC) from
     the gswi initialization or */
  DESTROY(author);
  DESTROY(authorDG);

  [super dealloc];
}

@end
