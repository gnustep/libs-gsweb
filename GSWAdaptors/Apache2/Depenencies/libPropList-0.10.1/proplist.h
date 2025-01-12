/* proplist.h: This is -*- c -*-

   Copyright (c) 1997 Bjoern Giesler <giesler@ira.uka.de>
   libPropList and this file are subject to the GNU Library Public License
   (LPL). You should have received a copy of that license; it's in the 
   file COPYING.LIB.
   
   Interface declaration for the property-list handling library. This
   library allows plain C programs to use (read and write)
   GNUstep-style property lists. It defines the opaque data type
   proplist_t. An element of type proplist_t can be a string, an
   array, a dictionary or a data object.

   */

#ifndef PROPLIST_H
#define PROPLIST_H


/* Version number: 0.10.1
 * Use 2 digits for each number in version - like 00.10.01 but without
 * decimal dots and leading zeros
 */
#define PROPLIST_VERSION	1001



#ifndef BOOL
#define BOOL int
#endif /* !def BOOL */
#ifndef YES
#define YES 1
#define NO 0
#endif /* !def YES */

typedef void *proplist_t;

typedef void (*plcallback_t)(void);


/*
 * Vanilla file-handling stuff
 */

/* Return a pointer to a proplist structure if successful, NULL otherwise */
proplist_t PLGetProplistWithDescription(const char *description);

/* Return a pointer to a proplist structure if successful, NULL otherwise */
proplist_t PLGetProplistWithPath(const char *filename);

/* Recursively synchronize the proplist with the file: Returns NO on error */
BOOL PLDeepSynchronize(proplist_t pl);

/* Add this for backward compatibility */
#define PLSynchronize(pl)  PLDeepSynchronize((pl))

/* Non-recursively synchronize the proplist with the file: Returns NO on error */
BOOL PLShallowSynchronize(proplist_t pl);

/* Write out to a file. Uses temporary file if atomically==YES. Returns
   NO on error */ 
BOOL PLSave(proplist_t pl, BOOL atomically);

/* Get the file name for the property list */
proplist_t PLSetFilename(proplist_t pl, proplist_t filename);

/* Get the file name, or NULL if there isn't any */
proplist_t PLGetFilename(proplist_t pl);

/*
 * Talking to the daemon
 */

/* Get an array containing all registered domain names. */
proplist_t PLGetDomainNames();

/* Get the named domain from the daemon. If callback is non-NULL, it
   specifies a function to be called whenever the domain is changed. */
proplist_t PLGetDomain(proplist_t name);

/* Set the specified domain. If kickme is NO, a callback function the
   program has registered for this domain will not be called. */
proplist_t PLSetDomain(proplist_t name, proplist_t value,
		 BOOL kickme);

/* See above. */
proplist_t PLDeleteDomain(proplist_t name, BOOL kickme);

/* Returns the specified domain, and registers callback to be called
   whenever domain is changed. Returns name. */
proplist_t PLRegister(proplist_t name, plcallback_t callback);

/* Unregisters callback entries for name, or all callback entries if
   name is NULL. Returns name. */
proplist_t PLUnregister(proplist_t name);

/*
 * Test if the proplist is of a certain type
 */
BOOL PLIsString(proplist_t pl);
BOOL PLIsData(proplist_t pl);
BOOL PLIsArray(proplist_t pl);
BOOL PLIsDictionary(proplist_t pl);
BOOL PLIsSimple(proplist_t pl); /* YES if pl is string or data */
BOOL PLIsCompound(proplist_t pl); /* YES if pl is array or dictionary */

/* Returns a reference. Don't free it! */
char *PLGetString(proplist_t pl); 

/*
 * Values of simple types. Note that all these return copies; free the
 * return value after you're done.
 */
char *PLGetStringDescription(proplist_t pl);
char *PLGetDataDescription(proplist_t pl);
unsigned int PLGetDataLength(proplist_t pl);
unsigned char *PLGetDataBytes(proplist_t pl);

/*
 * The description in proplist format. Free the return value.
 */
char *PLGetDescriptionIndent(proplist_t pl, unsigned int level);
char *PLGetDescription(proplist_t pl);


/*
 * Descending into compound types. None of these return copies.
 */
unsigned int PLGetNumberOfElements(proplist_t pl);
proplist_t PLGetArrayElement(proplist_t pl, unsigned int index);
proplist_t PLGetAllDictionaryKeys(proplist_t pl); /* returns an array */
proplist_t PLGetDictionaryEntry(proplist_t pl, proplist_t key);
 
/*
 * Getting the container
 */
proplist_t PLGetContainer(proplist_t pl);

/*
 * Creating simple types
 */
proplist_t PLMakeString(char *bytes);
proplist_t PLMakeData(unsigned char *data, unsigned int length);

/*
 * Creating/Changing compound types
 */
/* Make an array from the given elements. List must be NULL-terminated. */
proplist_t PLMakeArrayFromElements(proplist_t pl, ...);
/* returns NULL if index out of bounds */
proplist_t PLInsertArrayElement(proplist_t array, proplist_t pl,
				unsigned int index);
proplist_t PLRemoveArrayElement(proplist_t array,
				unsigned int index);
proplist_t PLAppendArrayElement(proplist_t array, proplist_t pl);

proplist_t PLMakeDictionaryFromEntries(proplist_t key, proplist_t value,
				       ...);
proplist_t PLInsertDictionaryEntry(proplist_t dict, proplist_t key,
				   proplist_t value);
proplist_t PLRemoveDictionaryEntry(proplist_t dict, proplist_t key);
/* Changes only dest. Copies entries from source. */
proplist_t PLMergeDictionaries(proplist_t dest, proplist_t source);

/*
 * Destroying and Copying
 */

proplist_t PLShallowCopy(proplist_t pl);
proplist_t PLDeepCopy(proplist_t pl);
void PLRelease(proplist_t pl);
proplist_t PLRetain(proplist_t pl);

/*
 * Comparing
 */

BOOL PLIsEqual(proplist_t pl1, proplist_t pl2);
void PLSetStringCmpHook(BOOL(*fn)(proplist_t, proplist_t));


#endif /* !def PROPLIST_H */


