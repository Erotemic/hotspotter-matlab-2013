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
#include <stdio.h>
#include "mclmcrrt.h"
#ifdef __cplusplus
extern "C" {
#endif

extern mclComponentData __MCC_dumbproject_component_data;

#ifdef __cplusplus
}
#endif

static HMCRINSTANCE _mcr_inst = NULL;

#ifdef __cplusplus
extern "C" {
#endif

static int mclDefaultPrintHandler(const char *s)
{
  return mclWrite(1 /* stdout */, s, sizeof(char)*strlen(s));
}

#ifdef __cplusplus
} /* End extern "C" block */
#endif

#ifdef __cplusplus
extern "C" {
#endif

static int mclDefaultErrorHandler(const char *s)
{
  int written = 0;
  size_t len = 0;
  len = strlen(s);
  written = mclWrite(2 /* stderr */, s, sizeof(char)*len);
  if (len > 0 && s[ len-1 ] != '\n')
    written += mclWrite(2 /* stderr */, "\n", sizeof(char));
  return written;
}

#ifdef __cplusplus
} /* End extern "C" block */
#endif

#ifndef LIB_dumbproject_C_API
#define LIB_dumbproject_C_API /* No special import/export declaration */
#endif

LIB_dumbproject_C_API 
bool MW_CALL_CONV dumbprojectInitializeWithHandlers(
    mclOutputHandlerFcn error_handler,
    mclOutputHandlerFcn print_handler)
{
    int bResult = 0;
  if (_mcr_inst != NULL)
    return true;
  if (!mclmcrInitialize())
    return false;
    {
        mclCtfStream ctfStream = 
            mclGetEmbeddedCtfStream((void *)(dumbprojectInitializeWithHandlers), 
                                    41061);
        if (ctfStream) {
            bResult = mclInitializeComponentInstanceEmbedded(   &_mcr_inst,
                                                                
                                                     &__MCC_dumbproject_component_data,
                                                                true, 
                                                                NoObjectType, 
                                                                ExeTarget,
                                                                error_handler, 
                                                                print_handler,
                                                                ctfStream, 
                                                                41061);
            mclDestroyStream(ctfStream);
        } else {
            bResult = 0;
        }
    }  
    if (!bResult)
    return false;
  return true;
}

LIB_dumbproject_C_API 
bool MW_CALL_CONV dumbprojectInitialize(void)
{
  return dumbprojectInitializeWithHandlers(mclDefaultErrorHandler, 
                                           mclDefaultPrintHandler);
}
LIB_dumbproject_C_API 
void MW_CALL_CONV dumbprojectTerminate(void)
{
  if (_mcr_inst != NULL)
    mclTerminateInstance(&_mcr_inst);
}

int run_main(int argc, const char **argv)
{
  int _retval;
  /* Generate and populate the path_to_component. */
  char path_to_component[(PATH_MAX*2)+1];
  separatePathName(argv[0], path_to_component, (PATH_MAX*2)+1);
  __MCC_dumbproject_component_data.path_to_component = path_to_component; 
  if (!dumbprojectInitialize()) {
    return -1;
  }
  argc = mclSetCmdLineUserData(mclGetID(_mcr_inst), argc, argv);
  _retval = mclMain(_mcr_inst, argc, argv, "dummain", 0);
  if (_retval == 0 /* no error */) mclWaitForFiguresToDie(NULL);
  dumbprojectTerminate();
  mclTerminateApplication();
  return _retval;
}

int main(int argc, const char **argv)
{
  if (!mclInitializeApplication(
    __MCC_dumbproject_component_data.runtime_options, 
    __MCC_dumbproject_component_data.runtime_option_count))
    return 0;

  return mclRunMain(run_main, argc, argv);
}
