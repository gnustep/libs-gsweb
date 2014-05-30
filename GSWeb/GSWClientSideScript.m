/** GSWClientSideScript.m - <title>GSWeb: Class GSWClientSideScript</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date:        May 1999
      
   $Revision$
   $Date$

   This file is part of the GNUstep Web Library.
   
   <license>
   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
   
   You should have received a copy of the GNU Library General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
   </license>
**/

#include "config.h"

#include "GSWeb.h"


static GSWIMP_BOOL standardEvaluateConditionInContextIMP = NULL;

static Class standardClass = Nil;

//====================================================================
@implementation GSWClientSideScript

//--------------------------------------------------------------------
+ (void) initialize
{
  if (self == [GSWClientSideScript class])
    {
      standardClass=[GSWClientSideScript class];

      standardEvaluateConditionInContextIMP = 
        (GSWIMP_BOOL)[self instanceMethodForSelector:evaluateConditionInContextSEL];
    };
};

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
         template:(GSWElement*)template
{
  if ((self=[super initWithName:@"SCRIPT"
                   associations:nil
                   template:nil]))
    {
      GSWAssignAndRemoveAssociation(&_scriptFile,_associations,scriptFile__Key);
      GSWAssignAndRemoveAssociation(&_scriptString,_associations,scriptString__Key);
      GSWAssignAndRemoveAssociation(&_scriptSource,_associations,scriptSource__Key);
      GSWAssignAndRemoveAssociation(&_language,_associations,language__Key);
      GSWAssignAndRemoveAssociation(&_hideInComment,_associations,hideInComment__Key);
      if (_scriptFile == nil
	  && _scriptString == nil
	  && _scriptSource == nil)
	{
	  [NSException raise:NSInvalidArgumentException
		       format:@"%s: one of 'scriptFile' or 'scriptString' or 'scriptSource' attributes must be specified.",
		       __PRETTY_FUNCTION__];
	}
      else if (_scriptFile != nil
	       && _scriptString != nil
	       && _scriptFile != nil)
	{
	  [NSException raise:NSInvalidArgumentException
		       format:@"%s: Only one of 'scriptFile' or 'scriptString' or 'scriptSource' attributes can specified.",
		       __PRETTY_FUNCTION__];
	}
    };
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_scriptFile);
  DESTROY(_scriptString);
  DESTROY(_scriptSource);
  DESTROY(_hideInComment);
  DESTROY(_language);
  [super dealloc];
};

//--------------------------------------------------------------------
-(void)setLanguage:(NSString*)language
{
  if (language!=nil)
    ASSIGN(_language,([GSWAssociation associationWithValue:language]));
}

//--------------------------------------------------------------------
-(void)appendAttributesToResponse:(GSWResponse *) aResponse
			inContext:(GSWContext*) aContext
{
  GSWComponent * component = GSWContext_component(aContext);

  NSString* language=[_language valueInComponent:component];
  if (language == nil)
    {
      [NSException raise:NSInternalInconsistencyException
		   format:@"%s: language binding evaluated to nil",
		   __PRETTY_FUNCTION__];
    }
  GSWResponse_appendContentAsciiString(aResponse,@" language=");
  GSWResponse_appendContentHTMLAttributeValue(aResponse,NSStringWithObject(language));

  if (_scriptSource != nil)
    {
      NSString* url=NSStringWithObject([_scriptSource valueInComponent:component]);
      if (url != nil)
	{
	  if ([url isRelativeURL])
	    {
	      if ([url isFragmentURL])
		{
		  NSLog(@"%s warning: relative fragment URL %@",__PRETTY_FUNCTION__,url);
		}
	      else
		{
		  NSString* tmp = [aContext _urlForResourceNamed:url
					    inFramework:nil];//and 3rd param: YES
		  if (tmp != nil)
		    url = tmp;
		  else		    
		    url = [[[component baseURL] 
			     stringByAppendingString:@"/"]
			    stringByAppendingString:tmp];
		} 
	    }
	  if (url != nil)
	    {
	      GSWResponse_appendContentAsciiString(aResponse,@" src=\"");
	      GSWResponse_appendContentString(aResponse,url);
	      GSWResponse_appendContentCharacter(aResponse,'"');
	    }
	}
    }
  [super appendAttributesToResponse:aResponse
	 inContext:aContext];
}

//--------------------------------------------------------------------
-(void)appendChildrenToResponse:(GSWResponse *) aResponse
			inContext:(GSWContext*) aContext
{
  if(_scriptSource == nil)
    {
      NSString* scriptContent = nil;
      BOOL hideInComment = NO;
      GSWComponent * component = GSWContext_component(aContext);

      if (_hideInComment != nil
	 && [_hideInComment boolValueInComponent:component])
	hideInComment = YES;

      if (hideInComment)
	GSWResponse_appendContentAsciiString(aResponse,@"<!-- Dynamic client side script from GNUstepWeb");

      GSWResponse_appendContentCharacter(aResponse,'\n');

      if(_scriptFile != nil)
	{
	  NSString* scriptFile = NSStringWithObject([_scriptFile valueInComponent:component]);
	  if (scriptFile == nil)
	    {
	      [NSException raise:NSInternalInconsistencyException
			   format:@"%s: scriptFile evaluate to nil",
			   __PRETTY_FUNCTION__];
	    }
	  else
	    {
	      NSString* scriptPath = [[GSWApp resourceManager] pathForResourceNamed:scriptFile
							       inFramework:nil
							       languages:[aContext languages]];
	      if (scriptPath == nil)
		{
		  [NSException raise:NSInternalInconsistencyException
			       format:@"%s: cannot find script file '%@'",
			       __PRETTY_FUNCTION__,scriptFile];
		}
	      else
                {
		  NSStringEncoding usedEncoding;
		  NSString* error=nil;
		  NSString* scriptContent = [NSString stringWithContentsOfFile:scriptPath
						      usedEncoding:&usedEncoding
						      error:&error];
		  if (scriptContent == nil)
                    {
		      [NSException raise:NSInternalInconsistencyException
				   format:@"%s: cannot load script at path '%@': %@",
				   __PRETTY_FUNCTION__,scriptPath,error];
		    }
		}
	    }
	}
      else if (_scriptString != nil)
	{
	  scriptContent = NSStringWithObject([_scriptString valueInComponent:component]);
	  if(scriptContent == nil)
	    {
	      [NSException raise:NSInternalInconsistencyException
			   format:@"%s: scriptString evaluate to nil",
			   __PRETTY_FUNCTION__];
	    };
	}

      GSWResponse_appendContentString(aResponse,scriptContent);
      GSWResponse_appendContentCharacter(aResponse,'\n');

      if(hideInComment)
	GSWResponse_appendContentAsciiString(aResponse,@"//-->\n");
    }
}

@end

