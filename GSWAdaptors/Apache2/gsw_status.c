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
/* The /wo/showapps status page: a HTML table of the configured applications */
/* and their live shared-memory state.                                      */
/*                                                                          */
/*--------------------------------------------------------------------------*/

// done using http://www.sveinbjorn.org/dataurlmaker

static void print_image(request_rec * r)
{
    ap_rputs("<img alt=\"exclamation sign\" src=\""
             "data:image/png;base64,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"
             "rF0/R/NzVwuE9PAZoAAAAASUVORK5CYII=\" width=\"60\" height=\"50\">\n", r);
    
}

/*
 * this prints some CSS for use in the error page in gsw_handler
 */

// Escape a string for use inside a HTML element or attribute.  The app
// and host names come from the Apache config file, but a name containing
// a '<' or a quote would otherwise break out of the table markup.
static void html_escape(const char * in, char * out, size_t out_size)
{
  size_t  j = 0;
  size_t  i;

  if (out_size < 1) {
    return;
  }
  for (i = 0; in[i] != '\0' && (j + 6 < out_size); i++) {
    switch (in[i]) {
      case '&':  memcpy(out + j, "&amp;", 5);  j += 5; break;
      case '<':  memcpy(out + j, "&lt;", 4);   j += 4; break;
      case '>':  memcpy(out + j, "&gt;", 4);   j += 4; break;
      case '"':  memcpy(out + j, "&quot;", 6); j += 6; break;
      case '\'': memcpy(out + j, "&#39;", 5);  j += 5; break;
      default:   out[j++] = in[i]; break;
    }
  }
  out[j] = '\0';
}

static void print_css(request_rec * r)
{
    ap_rputs("<style type=\"text/css\"> \
             body {color: #111;font-family:\"Helvetica Neue\",Helvetica,sans-serif;} \
             .fail {margin: auto; padding: 40px; display: block; \
             border: 1px solid #000000; \
             position: relative;} \
             .fail h2 {margin: 0 0 .2em; font-size: 24px} \
             .fail p {margin: 0; font-size: .8em;} \
             .power {float:right;padding-top: 10px;} \
             img {float:left;padding-right: 10px;} \
             a {color: #0092E8;} \
             a:hover {color: #0071b3;} \
             table {white-space:nowrap;} \
             </style>\n", r);
}

void showApps(request_rec * r, gsw_cfg *dcfg)
{
    ap_set_content_type(r, "text/html");
    
    /*
     * Now send our actual output.  Since we tagged this as being
     * "text/html", we need to embed any HTML.
     */
    ap_rputs(DOCTYPE_HTML_3_2, r);
    ap_rputs("<html>\n", r);
    ap_rputs("<head>\n", r);
    print_css(r);
    ap_rputs("<title>GNUstepWeb Status</title>\n", r);
    ap_rputs("<meta name=\"robots\" content=\"NOINDEX, NOFOLLOW\">\n", r);
    ap_rputs("</head>\n", r);
    ap_rputs("<body>\n", r);
    ap_rputs("<h1>GNUstepWeb Status</h1><br>\n", r);
    
    if ((dcfg->showApps)) {
        if ((dcfg->app_table)) {
            const apr_array_header_t *tarr = apr_table_elts(dcfg->app_table);
            const apr_table_entry_t *telts = (const apr_table_entry_t*)tarr->elts;
            int i;
            exipc_data * mem;
            int          appcount = tarr->nelts;
            u_int16_t  * indexes;
            char         timestr[APR_CTIME_LEN];

            // one statistics entry per configured instance, in table order
            indexes = (u_int16_t *) apr_palloc(r->pool, sizeof(u_int16_t) * appcount);
            for (i = 0; i < appcount; i++) {
                indexes[i] = ((gsw_app_conf *) telts[i].val)->total_index;
            }

            mem = read_shared_mem(r->pool, appcount, indexes);
            
            if (mem) {
                ap_rputs("<div class=\"fail\"><table width=\"700\">\n",r);
                print_image(r);
                ap_rputs("<tr><th>Name</th><th>Instance</th><th>Host</th><th>Port</th><th>Load</th><th>Unreachable</th><th>Refusing</th><th>Last Request</th><th>Last Response</th></tr>\n",r);
                
                for (i = 0; i < tarr->nelts; i++) {
                    gsw_app_conf *appconf = (gsw_app_conf *) telts[i].val;
                    char         esc_name[MAX_NAME_LENGTH * 6];
                    char         esc_host[MAX_NAME_LENGTH * 6];

                    html_escape(appconf->app_name, esc_name, sizeof(esc_name));
                    html_escape(appconf->host_name, esc_host, sizeof(esc_host));

                    ap_rprintf(r, "<tr><td><a href=\"%s%s.woa/%d/\">%s</a></td>", ADAPTOR_PREFIX,
                               appconf->app_name,
                               appconf->instance_number,
                               esc_name);
                    ap_rprintf(r, "<td>%u</td>", appconf->instance_number);
                    ap_rprintf(r, "<td>%s</td>", esc_host);
                    ap_rprintf(r, "<td>%u</td>", appconf->port);
                    ap_rprintf(r, "<td>%u</td>", mem[i].load);
                    ap_rprintf(r, "<td>%s</td>", (mem[i].unreachable == 1) ? "YES": "NO");
                    ap_rprintf(r, "<td>%s</td>", (mem[i].refusing == 1) ? "YES": "NO");
                    apr_ctime(timestr, mem[i].last_request_time);
                    ap_rprintf(r, "<td>%s</td>", timestr);
                    if (mem[i].last_response_time > 0) {
                        apr_ctime(timestr, mem[i].last_response_time);
                        ap_rprintf(r, "<td>%s</td></tr>\n", timestr);
                    } else {
                        ap_rprintf(r, "<td>never</td></tr>\n");
                    }
                }
                
                ap_rputs("</table><br>\n",r);
                
            }
            
        }
    } else {
        ap_rputs("<p>Application list hidden. Set <samp>ShowApps on</samp> in your Apache config to list.</p>\n",r);
        
    }
    
    ap_rputs("<p class=\"power\">Powered by <a href=\"http://wiki.gnustep.org/index.php/GNUstepWeb\">GNUstep Web</a></p>\n",r);
    
    ap_rputs("</div>\n</body>\n", r);
    ap_rputs("</html>\n", r);

}

