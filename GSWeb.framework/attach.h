#ifndef H_DEBUG_ATTACH
#define H_DEBUG_ATTACH

// $Id$

void DebugInstall(char *processname);
void DebugUninstall(void);
void DebugBreakpoint(void);
void DebugEnableBreakpoints(void);
void DebugDisableBreakpoints(void);

#endif //H_DEBUG_ATTACH
