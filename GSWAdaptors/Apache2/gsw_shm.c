/*
   Copyright (C) 2007-2008 Free Software Foundation, Inc.
   
   Written by:	David Wetzel <dave@turbocat.de>
   Based on Apache2 Sample Module
      
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

#include "gsw_private.h"

/*--------------------------------------------------------------------------*/
/*                                                                          */
/* Shared-memory state and the routines that manipulate it.  The segment    */
/* holds one exipc_data record per configured application instance; every   */
/* accessor takes the global mutex around its read or write.                */
/*                                                                          */
/* This file *defines* the four shared cells declared extern in             */
/* gsw_private.h.                                                           */
/*                                                                          */
/*--------------------------------------------------------------------------*/

// shared memory
apr_shm_t *exipc_shm;
char *shmfilename;
apr_global_mutex_t *exipc_mutex;
char *mutexfilename;


void * read_shared_mem(apr_pool_t * pool, int appcount)
{
  apr_size_t   memsize = apr_shm_size_get(exipc_shm);
  void       * mem     = NULL;

  if (memsize) {
    mem = apr_pcalloc(pool, memsize);
    
    if (mem) {
      void * base = NULL;
      apr_status_t rv;


      rv = apr_global_mutex_lock(exipc_mutex);
      if (rv != APR_SUCCESS) {
        //char errstr[1024];
        //apr_strerror(rv,errstr,1024);
        //syslog(LOG_ERR,"rv != APR_SUCCESS %s\n", errstr);
        return NULL;
      }
      base = apr_shm_baseaddr_get(exipc_shm);
      memcpy(mem, base, memsize);
      apr_global_mutex_unlock(exipc_mutex);
    }
  }
  
  return mem;
}


void mark_unreachable(request_rec *r, gsw_app_conf * app)
{
  exipc_data   * mem   = NULL;
  apr_time_t     now     = apr_time_now();
  u_int16_t      index   = app->total_index;
  
  apr_global_mutex_lock(exipc_mutex);
  mem = (exipc_data *) apr_shm_baseaddr_get(exipc_shm);
  
  if (mem) {
    mem[index].last_request_time = now;
    mem[index].unreachable = 1;
  }
  
  apr_global_mutex_unlock(exipc_mutex);
}

void mark_refusing(gsw_app_conf * app)
{
  exipc_data   * mem   = NULL;
  apr_time_t     now     = apr_time_now();
  u_int16_t      index   = app->total_index;
  
  apr_global_mutex_lock(exipc_mutex);
  mem = (exipc_data *) apr_shm_baseaddr_get(exipc_shm);
  
  if (mem) {
    mem[index].last_request_time = now;
    mem[index].refusing = 1;
  }
  
  apr_global_mutex_unlock(exipc_mutex);
}

void update_app_statistics(gsw_app_conf * app, apr_time_t last_request_time, apr_time_t last_response_time, u_int32_t load)
{
  exipc_data   * mem   = NULL;
  u_int16_t      index   = app->total_index;
  
  apr_global_mutex_lock(exipc_mutex);
  mem = (exipc_data *) apr_shm_baseaddr_get(exipc_shm);
  
  if (mem) {
    mem[index].last_request_time = last_request_time;
    mem[index].last_response_time = last_response_time;
    mem[index].load = load;
    mem[index].unreachable = 0;
  }

  apr_global_mutex_unlock(exipc_mutex);
}


void init_shared_mem(const apr_shm_t * xxx, int count, server_rec * s)
{
  int i;
  
  exipc_data *currentRecord  =  (exipc_data *) apr_shm_baseaddr_get(xxx);

  for (i = 0;i<count;i++) {
    currentRecord[i].last_response_time = 0;
    currentRecord[i].load = 0;
    currentRecord[i].unreachable = 0;
    currentRecord[i].refusing = 0;
  }
  
}


