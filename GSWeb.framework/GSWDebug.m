/* debug.m - debug
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Jan 1999
   
   This file is part of the GNUstep Web Library.
   
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
*/

static char rcsId[] = "$Id$";

#include <gsweb/GSWeb.framework/GSWeb.h>
#include <Foundation/NSThread.h>
#include <Foundation/NSAutoreleasePool.h>
#include <unistd.h>

#define USTART	NSAutoreleasePool* arp=[NSAutoreleasePool new];
#define USTOP	DESTROY(arp);
#define DOTRACE 1

@interface NSObject (GSISA)
-(Class)isa;
@end

@implementation NSObject (GSISA)
-(Class)isa
{
  return  self->isa;
};
@end

void GSWAssertGood(NSObject* object,CONST char* file,int line)
{
  if (object)
	{
#ifdef DEBUG
	  if ([object isa]==((Class)0xdeadface))
		{
		  char buffer[1024]="";
		  sprintf(buffer,"DEAD FACE: object %p isa=%p in %s at %d\n",
				  (void*)object,
				  (void*)[object isa],
				  file,
				  line);
		  GSWLogCStdOut(buffer);
		  GSWLogC(buffer);
		  NSCParameterAssert([object isa]==(Class)0xdeadface);
		};
#else
	  NSCAssert2([object isa]!=((Class)0xdeadface),@"Dead face object %s %d",file, line);
#endif
	}
  else
	{
#ifdef DEBUG
	  char buffer[1024]="";
	  sprintf(buffer,"NULL: object %p in %s at %d\n",
			  (void*)object,
			  file,
			  line);
	  GSWLogCStdOut(buffer);
	  GSWLogC(buffer);
	  NSCParameterAssert(object);
#else
	  NSCAssert2(object,@"Nil object %s %d",file, line);
#endif
	};
};

void GSWLogExceptionF(CONST char* file,int line,NSString* format,...)
{
  NSString* string=nil;
  va_list ap;
  USTART
  va_start (ap, format);
  string=[NSString stringWithFormat:format
				   arguments: ap];
  va_end (ap);
#if DOTRACE
  GSWLogCStdOut("EXCEPTION:");
  GSWLogC("EXCEPTION:");
  GSWLogStdOut(string);
  GSWLog(string);
#endif
  USTOP  
};
void GSWLogException(CONST char* comment,CONST char* file,int line)
{
  char buff[25];
  fputs ("EXCEPTION (", stderr);
  fputs ("EXCEPTION (", stdout);
  fputs (file, stderr);
  fputs (file, stdout);
  fputs (" ", stderr);
  fputs (" ", stdout);
  sprintf(buff,"%d",line);
  fputs (buff, stderr);
  fputs (buff, stdout);
  fputs ("):", stderr);
  fputs ("):", stdout);
  if (comment)
	{
	  fputs (comment, stderr);
	  fputs (comment, stdout);
	};
  fputs ("\n", stderr);
  fputs ("\n", stdout);
  fflush(stderr);
  fflush(stdout);
};

//--------------------------------------------------------------------
void GSWLogC(CONST char* string)
{
#ifdef DEBUG
#if DOTRACE
  int len=0;
  if ([NSThread isMultiThreaded])
	{
	  NSThread* t = [NSThread currentThread];
	  fprintf(stderr,"TID=");
	  if (t && t->_thread_id)
		fprintf(stderr,"%p [%ld] (%d) ",(void*)t->_thread_id,(long)t->_thread_id,(int)getpid());
	  else
		{
		  void* tid=(void*)objc_thread_id();
		  fprintf(stderr,"%p [%ld] (%d) ",tid,(long)tid,(int)getpid());
		};
	};
  fprintf(stderr,string);
  len=strlen(string);
  if (len<=0 || string[len-1]!='\n')
	fprintf(stderr,"\n");
  fflush(stderr);
#endif
#endif
};

//--------------------------------------------------------------------
void GSWLogCStdOut(CONST char* string)
{
#ifdef DEBUG
#if DOTRACE
  int len=0;
  if ([NSThread isMultiThreaded])
	{
	  NSThread* t = [NSThread currentThread];
	  fprintf(stdout,"TID=");
	  if (t && t->_thread_id)
		  fprintf(stdout,"%p [%ld] (%d) ",(void*)t->_thread_id,(long)t->_thread_id,(int)getpid());
	  else
		{
		  void* tid=(void*)objc_thread_id();
		  fprintf(stdout,"%p [%ld] (%d) ",tid,(long)tid,(int)getpid());
		};
	};
  fprintf(stdout,string);
  len=strlen(string);
  if (len<=0 || string[len-1]!='\n')
	fprintf(stdout,"\n");
  fflush(stdout);
#endif
#endif
};

//--------------------------------------------------------------------
void _GSWLog(NSString* string)
{
#ifdef DEBUG
#if DOTRACE
  USTART
  GSWLogC([string cString]);
  USTOP
#endif
#endif
};

//--------------------------------------------------------------------
void _GSWLogStdOut(NSString* string)
{
#ifdef DEBUG
#if DOTRACE
  USTART
  GSWLogCStdOut([string cString]);
  USTOP
#endif
#endif
};
/*
//--------------------------------------------------------------------
void _NSDebugMLog(NSString* format,...)
{
  NSString* string=nil;
  va_list ap;
  USTART
  va_start (ap, format);
  string=[NSString stringWithFormat:format
				   arguments: ap];
  va_end (ap);
#if DOTRACE
  _GSWLog(string);
#endif
  USTOP
};

//--------------------------------------------------------------------
void _NSDebugMLog(NSString* format,...)
{
  NSString* string=nil;
  va_list ap;
  USTART
  va_start (ap, format);
  string=[NSString stringWithFormat:format
				   arguments: ap];
  va_end (ap);
#if DOTRACE
  _GSWLogStdOut(string);
  _GSWLog(string);
#endif
  USTOP
};
*/
//--------------------------------------------------------------------
void GSWLogError(CONST char* file,int line)
{
#ifdef DEBUG
  USTART
	{
	  NSString* string=[NSString stringWithFormat:@"ERROR ! file %s line %d\n",
								 (file && isalpha(*file) && line>=0 && line<=50000) ? file :"",
								 line];
	  _GSWLog(string);
#if DOTRACE
	  _GSWLogStdOut(string);
#endif
	};
  USTOP
#endif
};

//--------------------------------------------------------------------
void GSWLogErrorF(CONST char* file,int line,NSString* format,...)
{
#ifdef DEBUG
  NSString* string=nil;
  NSString* stringError=nil;
  va_list ap;
  USTART
  va_start (ap, format);
  string=[NSString stringWithFormat:format
				   arguments: ap];
  stringError=[NSString stringWithFormat:@"ERROR ! file %s line %d: %@\n",
						(file && isalpha(*file) && line>=0 && line<=50000) ? file :"",
						line,
						string];
  _GSWLog(stringError);
#if DOTRACE
  _GSWLogStdOut(stringError);
#endif
  va_end (ap);
  USTOP  
#endif
};
/*
//--------------------------------------------------------------------
void NSDebugMLogCond(BOOL cond,NSString* format,...)
{
  if (cond)
	{
	  NSString* string=nil;
	  va_list ap;
	  USTART
	  va_start (ap, format);
	  string=[NSString stringWithFormat:format
					   arguments: ap];
	  va_end (ap);
#if DOTRACE
	  _GSWLog(string);
#endif
	  USTOP
	};
};
*/

//--------------------------------------------------------------------
void GSWLog(NSString* string)
{
#ifdef DEBUG
#if DOTRACE
  NSDebugFLog(@"%@",string);
#endif
#endif
};

//--------------------------------------------------------------------
void GSWLogStdOut(NSString* string)
{
#ifdef DEBUG
#if DOTRACE
  GSWLogCStdOut([string cString]);
#endif
#endif
};

/*
//--------------------------------------------------------------------
void NSDebugMLog(NSString* format,...)
{
  NSString* string=nil;
  va_list ap;
  USTART
  va_start (ap, format);
  string=[NSString stringWithFormat:format
				   arguments: ap];
  va_end(ap);
#if DOTRACE
  GSWLog(string);
#endif
  USTOP
};

//--------------------------------------------------------------------
void NSDebugMLog(NSString* format,...)
{
  NSString* string=nil;
  va_list ap;
  USTART
  va_start (ap, format);
  string=[NSString stringWithFormat:format
				   arguments: ap];
  va_end(ap);
#if DOTRACE
  GSWLogStdOut(string);
#endif
  USTOP
};
*/
//--------------------------------------------------------------------
NSString* objectDescription(id object)
{
  NSString* description=nil;
  if ([object respondsToSelector:@selector(description)])
	{
	  NS_DURING
		  description=[object description];
	  NS_HANDLER
	  NS_ENDHANDLER;
	};
  return description;
};
/*
//--------------------------------------------------------------------
void logObjectFnNotImplemented(CONST char* file,int line,id obj,SEL cmd)
{
#if DOTRACE
  USTART
  if (!(file && isalpha(*file) && line>=0 && line<=20000))
	NSDebugMLog(@"Not Implemented Object Function %s",
		  sel_get_name(cmd));
  else
	{
	  BOOL dumpClass=YES;
	  if (!CLS_ISINITIALIZED(object_get_class(obj)))
		dumpClass=NO;
	  
	  NSDebugMLog(@"%s %d - Not Implemented Object Function %s (Class %s)\n",
			(file && isalpha(*file) && line>=0 && line<=20000) ? file :"",
			line,
			sel_get_name(cmd),
			((dumpClass) ? object_get_class_name(obj) : "***"));
	};
  USTOP
#endif
};

//--------------------------------------------------------------------
void logClassFnNotImplemented(CONST char* file,int line,Class class,SEL cmd)
{
#if DOTRACE
  USTART
  if (!(file && isalpha(*file) && line>=0 && line<=20000))
	NSDebugMLog(@"Not Implemented Class Function %s",
		  sel_get_name(cmd));
  else
	{
	  BOOL dumpClass=YES;
	  if (!CLS_ISINITIALIZED(class))
		dumpClass=NO;
	  NSDebugMLog(@"%s %d - Not Implemented Class Function %s (Class %s)\n",
			(file && isalpha(*file) && line>=0 && line<=20000) ? file :"",
			line,
			sel_get_name(cmd),
			((dumpClass && class) ? class->name : "***"));
	};
  USTOP
#endif
};

//--------------------------------------------------------------------
void logObjectFnStart(CONST char* file,int line,id obj,SEL cmd,CONST char* comment,BOOL dumpClass)
{
#if DOTRACE
  USTART
  iFnLevel++;
  if (!CLS_ISINITIALIZED(object_get_class(obj)))
	dumpClass=NO;
  _NSDebugMLog(@"%s %s %d - Obj:%p Start:%s (Class %s [%s])\n",
		  getOpenSign(),
		  ((file && isalpha(*file) && line>=0 && line<=20000) ? file :""),
		  line,
		  (void*)obj,
		  sel_get_name(cmd),
		  ((dumpClass) ? object_get_class_name(obj) : "***"),
		  comment ? comment : "");
  USTOP
#endif
};

//--------------------------------------------------------------------
void logObjectFnStop(CONST char* file,int line,id obj,SEL cmd,CONST char* comment)
{
#if DOTRACE
  BOOL dumpClass=YES;
  USTART
  if (!obj || !CLS_ISINITIALIZED(object_get_class(obj)))
	dumpClass=NO;
  _NSDebugMLog(@"%s %s %d - Obj:%p Stop:%s (Class %s [%s])\n",
		  getCloseSign(),
		  (file && isalpha(*file) && line>=0 && line<=20000) ? file :"",
		  line,
		  (void*)obj,
		  sel_get_name(cmd),
		  ((dumpClass) ? object_get_class_name(obj) : "***"),
		  comment ? comment : "");
  iFnLevel--;
  USTOP
#endif
};

//--------------------------------------------------------------------
void logClassFnStart(CONST char* file,int line,Class class,SEL cmd,CONST char* comment)
{
#if DOTRACE
  BOOL dumpClass=YES;
  USTART
  iFnLevel++;
  if (!CLS_ISINITIALIZED(class))
	dumpClass=NO;
  _NSDebugMLog(@"%s %s %d - Class Start:%s (Class %s [%s])\n",
		getOpenSign(),
		(file && isalpha(*file) && line>=0 && line<=20000) ? file :"",
		line,
		sel_get_name(cmd),
		((dumpClass && class) ? class->name : "***"),
		comment ? comment : "");
  USTOP
#endif
};

//--------------------------------------------------------------------
void logClassFnStop(CONST char* file,int line,Class class,SEL cmd,CONST char* comment)
{
#if DOTRACE
  BOOL dumpClass=YES;
  USTART
  if (!CLS_ISINITIALIZED(class))
	dumpClass=NO;
  _NSDebugMLog(@"%s %s %d - Class Stop:%s (Class %s [%s])\n",
		getCloseSign(),
		(file && isalpha(*file) && line>=0 && line<=20000) ? file :"",
		line,
		sel_get_name(cmd),
		((dumpClass && class) ? class->name : "***"),
		comment ? comment : "");
  iFnLevel--;
  USTOP
#endif
};
*/
//--------------------------------------------------------------------
NSString* IVarInString(CONST char*_type,void* _value)
{
  if (_type && _value)
	{
	  switch (*_type)
		{
		case _C_ID:
		  {
			id* pvalue=(id*)_value;
			return [NSString stringWithFormat:@"object:%ld Class:%s Description:%@",
							 (long)(*pvalue),
							 [*pvalue class],
							 objectDescription(*pvalue)];
		  };
		  break;
		case _C_CLASS:
		  {
			Class* pvalue=(Class*)_value;
			return [NSString stringWithFormat:@"Class:%s",
							 class_get_class_name(*pvalue)];
		  };
		  break;
		case _C_SEL:
		  {
			SEL* pvalue=(SEL*)_value;
			return [NSString stringWithFormat:@"SEL:%s",
							 sel_get_name(*pvalue)];
		  };
		  break;
		case _C_CHR:
		  {
			char* pvalue=(char*)_value;
			return [NSString stringWithFormat:@"CHAR:%c",
							 *pvalue];
		  };
		  break;
		case _C_UCHR:
		  {
			unsigned char* pvalue=(unsigned char*)_value;
			return [NSString stringWithFormat:@"UCHAR:%d",
							 (int)*pvalue];
		  };
		  break;
		case _C_SHT:
		  {
			short* pvalue=(short*)_value;
			return [NSString stringWithFormat:@"SHORT:%d",
							 (int)*pvalue];
		  };
		  break;
		case _C_USHT:
		  {
			unsigned short* pvalue=(unsigned short*)_value;
			return [NSString stringWithFormat:@"USHORT:%d",
							 (int)*pvalue];
		  };
		  break;
		case _C_INT:
		  {
			int* pvalue=(int*)_value;
			return [NSString stringWithFormat:@"INT:%d",
							 *pvalue];
		  };
		  break;
		case _C_UINT:
		  {
			unsigned int* pvalue=(unsigned int*)_value;
			return [NSString stringWithFormat:@"UINT:%u",
							 *pvalue];
		  };
		  break;
		case _C_LNG:
		  {
			long* pvalue=(long*)_value;
			return [NSString stringWithFormat:@"LONG:%ld",
							 *pvalue];
		  };
		  break;
		case _C_ULNG:
		  {
			unsigned long* pvalue=(unsigned long*)_value;
			return [NSString stringWithFormat:@"ULONG:%lu",
							 *pvalue];
		  };
		  break;
		case _C_FLT:
		  {
			float* pvalue=(float*)_value;
			return [NSString stringWithFormat:@"FLOAT:%f",
							 (double)*pvalue];
		  };
		  break;
		case _C_DBL:
		  {
			double* pvalue=(double*)_value;
			return [NSString stringWithFormat:@"DOUBLE:%f",
							 *pvalue];
		  };
		  break;
		case _C_VOID:
		  {
			void* pvalue=(void*)_value;
			return [NSString stringWithFormat:@"VOID:*%lX",
							 (unsigned long)pvalue];
		  };
		  break;
		case _C_CHARPTR:
		  {
			char* pvalue=(void*)_value;
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
NSString* TypeToNSString(CONST char*_type)
{
  if (_type)
	{
	  switch (*_type)
		{
		case _C_ID:
		  { // '@'
			CONST char *t = _type + 1;
			if (*t == '"')
			  {
				CONST char *start = t + 1;
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
						   TypeToNSString(_type + 1)];
		  break;
		case _C_STRUCT_B:
		  {
			NSString *structName = nil;
			CONST char *t = _type + 1;
		
			if (*t == '?')
			  structName = @"?";
			else
			  {
				CONST char *beg = t;
				while ((*t != '=') && (*t != '\0') && (*t != _C_STRUCT_E))
				  t++;
				structName = [NSString stringWithCString:beg length:(t - beg)];
			  };

			return [NSString stringWithFormat:@"struct %@ {...}", structName];
		  };
      
		default:
		  return [NSString stringWithFormat:@"%s", _type];
		};
	}
  else
	return [NSString stringWithString:@"NULL type"];
};

//--------------------------------------------------------------------
void DumpIVar(id object,struct objc_ivar* ivar,int level)
{
#ifdef DEBUG
  if (ivar && object && level>=0)
	{
	  void* pValue=((void*)object) + ivar->ivar_offset;
	  NSString* pType=TypeToNSString(ivar->ivar_type);
	  NSString* pIVar=IVarInString(ivar->ivar_type,pValue);
	  NSDebugFLog(@"IVar %s type:%@ value:%@\n",
			ivar->ivar_name,
			pType,
			pIVar);
	  if (level>0 && ivar->ivar_type && *ivar->ivar_type==_C_ID && pValue)
		{
		  DumpObject(NULL,0,*((id*)pValue),level);
		};
	};
#endif
};

//--------------------------------------------------------------------
void DumpObject(CONST char* file,int line,id object,int level)
{
#ifdef DEBUG
  USTART
  if (object && level>0)
	{
	  struct objc_ivar_list *ivars=NULL;
	  Class class = [object class];
	  if (class)
		{
		  NSDebugFLog(@"--%s %d [%d] Dumping object %p of Class %s Description:%@\n",
				(file && isalpha(*file) && line>=0 && line<=20000) ? file :"",
				line,
				level,
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
					  DumpIVar(object,&ivars->ivar_list[i],level-1);
					};
				}
			};
        };
    };
  USTOP
#endif
};

