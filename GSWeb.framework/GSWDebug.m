/** GSWDebug.m - <title>GSWeb: Debug</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999
      
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

static char rcsId[] = "$Id$";

#include <GSWeb/GSWeb.h>
#include <GSWeb/GSWDebug.h>
#include <Foundation/NSThread.h>
#include <Foundation/NSAutoreleasePool.h>
#include <unistd.h>

#define USTART	NSAutoreleasePool* arp=[NSAutoreleasePool new];
#define USTOP	DESTROY(arp);

@interface NSObject (GSISA)
-(Class)isa;
@end

@implementation NSObject (GSISA)
-(Class)isa
{
  return  self->isa;
};
@end

#ifdef DEBUG
NSString* GSWDebugMethodMsg(id obj, SEL sel, const char *file, int line, NSString *fmt)
{
  NSString      *message;
  Class         cls = (Class)obj;
  char          c = '+';

  if ([obj isInstance] == YES)
    {
      c = '-';
      cls = [obj class];
    }
  message = [NSString stringWithFormat: @"File %s: %d. In object %p [%@ %c%@] %@",
        file, line, obj,NSStringFromClass(cls), c, NSStringFromSelector(sel), fmt];
  return message;
}

//--------------------------------------------------------------------
void GSWLogC_(CONST char* file,int line,CONST char* string)
{
  int len=0;
/*  if ([NSThread isMultiThreaded])
	{
	  NSThread* t = [NSThread currentThread];
	  fprintf(stderr,"TID=");
#if 0
	  if (t && t->_thread_id)
		fprintf(stderr,"%p [%ld] (%d) ",(void*)t->_thread_id,(long)t->_thread_id,(int)getpid());
	  else
#endif
		{
*/
		  void* tid=(void*)objc_thread_id();
		  fprintf(stderr,"%p [%ld] (%d) ",tid,(long)tid,(int)getpid());
/*		};
	};*/
  fprintf(stderr,"File %s: %d. ",file,line);
  fprintf(stderr,string);
  len=strlen(string);
  if (len<=0 || string[len-1]!='\n')
	fprintf(stderr,"\n");
  fflush(stderr);
};
#endif

#ifdef DEBUG
//--------------------------------------------------------------------
NSString* objectDescription(id object)
{
  NSString* description=nil;
  if ([object respondsToSelector:@selector(description)])
    {
      NS_DURING
        {
          description=[object description];
        }
      NS_HANDLER
        {
        }
      NS_ENDHANDLER;
    };
  return description;
};

//--------------------------------------------------------------------
NSString* IVarInString(const char* aType,void* aValue)
{
  if (aType && aValue)
    {
      switch (*aType)
        {
        case _C_ID:
          {
            id* pvalue=(id*)aValue;
            return [NSString stringWithFormat:@"object:%ld Class:%s Description:%@",
                             (long)(*pvalue),
                             [*pvalue class],
                             objectDescription(*pvalue)];
          };
          break;
        case _C_CLASS:
          {
            Class* pvalue=(Class*)aValue;
            return [NSString stringWithFormat:@"Class:%s",
                             class_get_class_name(*pvalue)];
          };
          break;
        case _C_SEL:
          {
            SEL* pvalue=(SEL*)aValue;
            return [NSString stringWithFormat:@"SEL:%s",
                             sel_get_name(*pvalue)];
          };
          break;
        case _C_CHR:
          {
            char* pvalue=(char*)aValue;
            return [NSString stringWithFormat:@"CHAR:%c",
                             *pvalue];
          };
          break;
        case _C_UCHR:
          {
            unsigned char* pvalue=(unsigned char*)aValue;
            return [NSString stringWithFormat:@"UCHAR:%d",
                             (int)*pvalue];
          };
          break;
        case _C_SHT:
          {
            short* pvalue=(short*)aValue;
            return [NSString stringWithFormat:@"SHORT:%d",
                             (int)*pvalue];
          };
          break;
        case _C_USHT:
          {
            unsigned short* pvalue=(unsigned short*)aValue;
            return [NSString stringWithFormat:@"USHORT:%d",
                             (int)*pvalue];
          };
          break;
        case _C_INT:
          {
            int* pvalue=(int*)aValue;
            return [NSString stringWithFormat:@"INT:%d",
                             *pvalue];
          };
          break;
        case _C_UINT:
          {
            unsigned int* pvalue=(unsigned int*)aValue;
            return [NSString stringWithFormat:@"UINT:%u",
                             *pvalue];
          };
          break;
        case _C_LNG:
          {
            long* pvalue=(long*)aValue;
            return [NSString stringWithFormat:@"LONG:%ld",
                             *pvalue];
          };
          break;
        case _C_ULNG:
          {
            unsigned long* pvalue=(unsigned long*)aValue;
            return [NSString stringWithFormat:@"ULONG:%lu",
                             *pvalue];
          };
          break;
        case _C_FLT:
          {
            float* pvalue=(float*)aValue;
            return [NSString stringWithFormat:@"FLOAT:%f",
                             (double)*pvalue];
          };
          break;
        case _C_DBL:
          {
            double* pvalue=(double*)aValue;
            return [NSString stringWithFormat:@"DOUBLE:%f",
                             *pvalue];
          };
          break;
        case _C_VOID:
          {
            void* pvalue=(void*)aValue;
            return [NSString stringWithFormat:@"VOID:*%lX",
                             (unsigned long)pvalue];
          };
          break;
        case _C_CHARPTR:
          {
            char* pvalue=(void*)aValue;
            return [NSString stringWithFormat:@"CHAR*:%s",
                             pvalue];
          };
          break;
        case _C_PTR:
          {
            return [NSString stringWithFormat:@"PTR"];
          };
          break;
        case _C_STRUCT_B:
          {
            return [NSString stringWithFormat:@"STRUCT"];
          };
          break;
        default:
          return [NSString stringWithFormat:@"Unknown"];
        };
    }
  else
    return [NSString stringWithString:@"NULL type or NULL pValue"];
};

//--------------------------------------------------------------------
NSString* TypeToNSString(const char* aType)
{
  if (aType)
    {
      switch (*aType)
        {
        case _C_ID:
          { // '@'
            const char *t = aType + 1;
            if (*t == '"')
              {
                const char *start = t + 1;
                do
                  {
                    t++;
                  }
                while ((*t != '"') && (*t != '\0'));
        
                return [[NSString stringWithCString:start
                                  length:(t - start)]
                         stringByAppendingString:@" *"];
              }
            else
              return @"id";
          };
          break;
        case _C_CLASS:    return @"Class";
        case _C_SEL:      return @"SEL";
        case _C_CHR:      return @"char";
        case _C_UCHR:     return @"unsigned char";
        case _C_SHT:      return @"short";
        case _C_USHT:     return @"unsigned short";
        case _C_INT:      return @"int";
        case _C_UINT:     return @"unsigned int";
        case _C_LNG:      return @"long";
        case _C_ULNG:     return @"unsigned long";
          //		case _C_LNG_LNG:  return @"long long";
          //		case _C_ULNG_LNG: return @"unsigned long long";
        case _C_FLT:      return @"float";
        case _C_DBL:      return @"double";
        case _C_VOID:     return @"void";
        case _C_CHARPTR:  return @"char *";
        case _C_PTR:
          return [NSString stringWithFormat:@"%@ *",
                           TypeToNSString(aType + 1)];
          break;
        case _C_STRUCT_B:
          {
            NSString *structName = nil;
            const char *t = aType + 1;
		
            if (*t == '?')
              structName = @"?";
            else
              {
                const char *beg = t;
                while ((*t != '=') && (*t != '\0') && (*t != _C_STRUCT_E))
                  t++;
                structName = [NSString stringWithCString:beg length:(t - beg)];
              };

            return [NSString stringWithFormat:@"struct %@ {...}", structName];
          };
      
        default:
          return [NSString stringWithFormat:@"%s", aType];
        };
    }
  else
    return [NSString stringWithString:@"NULL type"];
};

//--------------------------------------------------------------------
void DumpIVar(id object,struct objc_ivar* ivar,int deep)
{
  if (ivar && object && deep>=0)
    {
      void* pValue=((void*)object) + ivar->ivar_offset;
      NSString* pType=TypeToNSString(ivar->ivar_type);
      NSString* pIVar=IVarInString(ivar->ivar_type,pValue);
      NSDebugFLog(@"IVar %s type:%@ value:%@\n",
                  ivar->ivar_name,
                  pType,
                  pIVar);
      if (deep>0 && ivar->ivar_type && *ivar->ivar_type==_C_ID && pValue)
        {
          GSWLogDumpObjectFn(NULL,0,*((id*)pValue),deep);
        };
    };
};

//--------------------------------------------------------------------
//Dump object 
void GSWLogDumpObjectFn(CONST char* file,int line,id object,int deep)
{
  USTART
    if (object && deep>0)
      {
        struct objc_ivar_list *ivars=NULL;
        Class class = [object class];
        if (class)
          {
            NSDebugFLog(@"--%s %d [%d] Dumping object %p of Class %s Description:%@\n",
                        (file && isalpha(*file) && line>=0 && line<=20000) ? file :"",
                        line,
                        deep,
                        (void*)object,
                        class->name,
                        objectDescription(object));
            while (class)
              {
                ivars = class->ivars;
                class = class->super_class;
                if (ivars)
                  {
                    int   i;
                    for (i = 0; i < ivars->ivar_count; i++)
                      {
                        DumpIVar(object,&ivars->ivar_list[i],deep-1);
                      };
                  }
              };
          };
      };
  USTOP
    };

//--------------------------------------------------------------------
void GSWLogAssertGoodFn(CONST char* file,int line,NSObject* object)
{
  if (object)
    {
      if ([object isa]==((Class)0xdeadface))
        {
          [GSWApp statusDebugWithFormat:@"DEAD FACE: object %p isa=%p in %s at %d\n",
                  (void*)object,
                  (void*)[object isa],
                  file,
                  line];
          NSCParameterAssert([object isa]==(Class)0xdeadface);
        };
    }
  else
    {
      [GSWApp statusDebugWithFormat:@"NULL: object %p in %s at %d\n",
              (void*)object,
              file,
              line];
      NSCParameterAssert(object);
    };
};
#endif
