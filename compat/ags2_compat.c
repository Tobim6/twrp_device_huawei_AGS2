/*
 * libags2_compat.so - lets the EMUI8 (Android 9) vendor libraries libxcollie.so / libhwlog.so, which the TEE keymaster
 * module links against, run inside TWRP, whose system libraries are built from Android 12:
 *  - libxcollie wants android::base::LogMessage::LogMessage(const char*, unsigned, LogId, LogSeverity, int)
 *    (Android 9 signature); Android 12 libbase only has the variant with an extra `const char* tag`.
 *  - libhwlog wants liblog's android_log_shouldPrintLine / android_log_printLogLine (log formatting helpers
 *    that Android 12's liblog no longer exports); they only format log lines, so no-ops are fine.
 * Loaded with LD_PRELOAD by the keymaster-3-0 service in TWRP only (the ROM is Android 9 and does not need it).
 */
void _ZN7android4base10LogMessageC1EPKcjNS0_5LogIdENS0_11LogSeverityES3_i(void *self, const char *file, unsigned int line,
                                                                       int log_id, int severity, const char *tag, int error);

void _ZN7android4base10LogMessageC1EPKcjNS0_5LogIdENS0_11LogSeverityEi(void *self, const char *file, unsigned int line,
                                                                      int log_id, int severity, int error)
{
    _ZN7android4base10LogMessageC1EPKcjNS0_5LogIdENS0_11LogSeverityES3_i(self, file, line, log_id, severity, 0, error);
}

int android_log_shouldPrintLine(void *format, const char *tag, int priority)
{
    (void)format; (void)tag; (void)priority;
    return 1;
}

int android_log_printLogLine(void *format, int fd, const void *entry)
{
    (void)format; (void)fd; (void)entry;
    return 0;
}
