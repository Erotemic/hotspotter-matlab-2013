/*
 * MATLAB Compiler: 4.13 (R2010a)
 * Date: Wed Mar  7 16:43:40 2012
 * Arguments: "-B" "macro_default" "-o" "dumbproject" "-W" "main:dumbproject"
 * "-T" "link:exe" "-d" "/Volumes/NO NAME/Zebras/DUMMY/dumbproject/src" "-w"
 * "enable:specified_file_mismatch" "-w" "enable:repeated_file" "-w"
 * "enable:switch_ignored" "-w" "enable:missing_lib_sentinel" "-w"
 * "enable:demo_license" "-R" "-logfile,xxxxx" "-v" "/Volumes/NO
 * NAME/Zebras/DUMMY/dummain.m" 
 */

#include "mclmcrrt.h"

#ifdef __cplusplus
extern "C" {
#endif
const unsigned char __MCC_dumbproject_session_key[] = {
    '2', '5', '7', '1', '1', 'E', '1', 'C', 'E', 'F', '8', '1', '6', '8', 'B',
    '8', 'C', '0', 'E', '6', 'C', '1', 'E', '9', 'C', '6', 'A', '1', '9', 'F',
    'D', '4', '0', 'B', '8', 'F', 'C', 'A', '0', '0', '1', '2', '2', '4', 'B',
    '4', 'F', '4', 'C', 'E', 'B', '7', '2', 'F', '1', 'B', 'A', '4', '2', 'D',
    'B', '0', 'C', 'B', '2', '7', 'B', 'D', 'B', '5', '2', '3', 'B', 'F', '4',
    'A', '1', '3', 'F', 'E', '6', 'E', '5', 'F', 'E', 'D', '9', '5', '1', 'C',
    'C', '9', 'A', '7', '9', '3', 'E', 'C', '4', '6', 'B', '0', '1', '2', 'A',
    'A', '9', '4', '6', 'A', '6', '1', 'B', 'A', '2', '5', 'C', 'A', 'E', '7',
    '6', '8', '0', '2', '9', '8', 'D', '0', '1', '6', '3', '6', 'E', 'E', 'F',
    'B', 'C', 'A', '8', '9', 'B', '3', '4', '1', '9', 'B', '8', 'C', 'C', '7',
    '4', 'C', '9', '8', '3', '3', '8', '7', 'A', 'D', 'D', 'C', '6', '4', '1',
    '6', '3', '5', '2', '1', '5', 'A', '3', '0', '1', '5', 'A', 'D', '8', 'C',
    '6', 'F', '7', '7', '1', '1', '6', '4', '6', '5', '3', '8', '2', '1', '7',
    '9', 'A', '0', '4', '4', '9', 'E', '9', '8', '0', 'C', '6', '7', 'C', '2',
    'D', '7', '4', 'F', '1', 'B', '0', 'E', '3', '7', '8', '5', '4', 'E', '9',
    '8', '1', 'F', '4', 'B', '1', '2', '3', 'D', 'D', '1', 'C', 'C', '1', '1',
    '5', 'C', 'B', '1', '0', '5', 'F', 'C', '3', '5', '4', 'F', '6', '9', '5',
    'B', '\0'};

const unsigned char __MCC_dumbproject_public_key[] = {
    '3', '0', '8', '1', '9', 'D', '3', '0', '0', 'D', '0', '6', '0', '9', '2',
    'A', '8', '6', '4', '8', '8', '6', 'F', '7', '0', 'D', '0', '1', '0', '1',
    '0', '1', '0', '5', '0', '0', '0', '3', '8', '1', '8', 'B', '0', '0', '3',
    '0', '8', '1', '8', '7', '0', '2', '8', '1', '8', '1', '0', '0', 'C', '4',
    '9', 'C', 'A', 'C', '3', '4', 'E', 'D', '1', '3', 'A', '5', '2', '0', '6',
    '5', '8', 'F', '6', 'F', '8', 'E', '0', '1', '3', '8', 'C', '4', '3', '1',
    '5', 'B', '4', '3', '1', '5', '2', '7', '7', 'E', 'D', '3', 'F', '7', 'D',
    'A', 'E', '5', '3', '0', '9', '9', 'D', 'B', '0', '8', 'E', 'E', '5', '8',
    '9', 'F', '8', '0', '4', 'D', '4', 'B', '9', '8', '1', '3', '2', '6', 'A',
    '5', '2', 'C', 'C', 'E', '4', '3', '8', '2', 'E', '9', 'F', '2', 'B', '4',
    'D', '0', '8', '5', 'E', 'B', '9', '5', '0', 'C', '7', 'A', 'B', '1', '2',
    'E', 'D', 'E', '2', 'D', '4', '1', '2', '9', '7', '8', '2', '0', 'E', '6',
    '3', '7', '7', 'A', '5', 'F', 'E', 'B', '5', '6', '8', '9', 'D', '4', 'E',
    '6', '0', '3', '2', 'F', '6', '0', 'C', '4', '3', '0', '7', '4', 'A', '0',
    '4', 'C', '2', '6', 'A', 'B', '7', '2', 'F', '5', '4', 'B', '5', '1', 'B',
    'B', '4', '6', '0', '5', '7', '8', '7', '8', '5', 'B', '1', '9', '9', '0',
    '1', '4', '3', '1', '4', 'A', '6', '5', 'F', '0', '9', '0', 'B', '6', '1',
    'F', 'C', '2', '0', '1', '6', '9', '4', '5', '3', 'B', '5', '8', 'F', 'C',
    '8', 'B', 'A', '4', '3', 'E', '6', '7', '7', '6', 'E', 'B', '7', 'E', 'C',
    'D', '3', '1', '7', '8', 'B', '5', '6', 'A', 'B', '0', 'F', 'A', '0', '6',
    'D', 'D', '6', '4', '9', '6', '7', 'C', 'B', '1', '4', '9', 'E', '5', '0',
    '2', '0', '1', '1', '1', '\0'};

static const char * MCC_dumbproject_matlabpath_data[] = 
  { "dumbproject/", "$TOOLBOXDEPLOYDIR/", "$TOOLBOXMATLABDIR/general/",
    "$TOOLBOXMATLABDIR/ops/", "$TOOLBOXMATLABDIR/lang/",
    "$TOOLBOXMATLABDIR/elmat/", "$TOOLBOXMATLABDIR/randfun/",
    "$TOOLBOXMATLABDIR/elfun/", "$TOOLBOXMATLABDIR/specfun/",
    "$TOOLBOXMATLABDIR/matfun/", "$TOOLBOXMATLABDIR/datafun/",
    "$TOOLBOXMATLABDIR/polyfun/", "$TOOLBOXMATLABDIR/funfun/",
    "$TOOLBOXMATLABDIR/sparfun/", "$TOOLBOXMATLABDIR/scribe/",
    "$TOOLBOXMATLABDIR/graph2d/", "$TOOLBOXMATLABDIR/graph3d/",
    "$TOOLBOXMATLABDIR/specgraph/", "$TOOLBOXMATLABDIR/graphics/",
    "$TOOLBOXMATLABDIR/uitools/", "$TOOLBOXMATLABDIR/strfun/",
    "$TOOLBOXMATLABDIR/imagesci/", "$TOOLBOXMATLABDIR/iofun/",
    "$TOOLBOXMATLABDIR/audiovideo/", "$TOOLBOXMATLABDIR/timefun/",
    "$TOOLBOXMATLABDIR/datatypes/", "$TOOLBOXMATLABDIR/verctrl/",
    "$TOOLBOXMATLABDIR/codetools/", "$TOOLBOXMATLABDIR/helptools/",
    "$TOOLBOXMATLABDIR/demos/", "$TOOLBOXMATLABDIR/timeseries/",
    "$TOOLBOXMATLABDIR/hds/", "$TOOLBOXMATLABDIR/guide/",
    "$TOOLBOXMATLABDIR/plottools/", "toolbox/local/",
    "$TOOLBOXMATLABDIR/datamanager/", "toolbox/compiler/" };

static const char * MCC_dumbproject_classpath_data[] = 
  { "" };

static const char * MCC_dumbproject_libpath_data[] = 
  { "" };

static const char * MCC_dumbproject_app_opts_data[] = 
  { "" };

static const char * MCC_dumbproject_run_opts_data[] = 
  { "-logfile", "xxxxx" };

static const char * MCC_dumbproject_warning_state_data[] = 
  { "off:MATLAB:dispatcher:nameConflict" };


mclComponentData __MCC_dumbproject_component_data = { 

  /* Public key data */
  __MCC_dumbproject_public_key,

  /* Component name */
  "dumbproject",

  /* Component Root */
  "",

  /* Application key data */
  __MCC_dumbproject_session_key,

  /* Component's MATLAB Path */
  MCC_dumbproject_matlabpath_data,

  /* Number of directories in the MATLAB Path */
  37,

  /* Component's Java class path */
  MCC_dumbproject_classpath_data,
  /* Number of directories in the Java class path */
  0,

  /* Component's load library path (for extra shared libraries) */
  MCC_dumbproject_libpath_data,
  /* Number of directories in the load library path */
  0,

  /* MCR instance-specific runtime options */
  MCC_dumbproject_app_opts_data,
  /* Number of MCR instance-specific runtime options */
  0,

  /* MCR global runtime options */
  MCC_dumbproject_run_opts_data,
  /* Number of MCR global runtime options */
  2,
  
  /* Component preferences directory */
  "dumbproject_F0F18C5481925C6DA256EAB06399BC5C",

  /* MCR warning status data */
  MCC_dumbproject_warning_state_data,
  /* Number of MCR warning status modifiers */
  1,

  /* Path to component - evaluated at runtime */
  NULL

};

#ifdef __cplusplus
}
#endif


