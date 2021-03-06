# FFmpeg for Android
# http://sourceforge.net/projects/ffmpeg4android/
# Srdjan Obucina <obucinac@gmail.com>

LOCAL_PATH:=$(call my-dir)

include $(CLEAR_VARS)

ifeq ($(FFMPEG_STANDALONE_BUILD),yes)

    NDK_CROSS_PREFIX := $(subst -gcc,-,$(TARGET_CC))

    NDK_SYSROOT := $(SYSROOT)

else

    # Use $(ANDROID_TOOLCHAIN) for library configuration
    NDK_CROSS_PREFIX := $(subst -gcc,-,$(shell (ls $(ANDROID_TOOLCHAIN)/*gcc)))

    # Always select highest NDK and SDK version
    NDK_SYSROOT := $(ANDROID_BUILD_TOP)/$(shell (ls -dv prebuil*/ndk/android-ndk-r*/platforms/android-*/arch-$(TARGET_ARCH) | tail -1))

    # Fix for latest master branch
    ifeq ($(NDK_SYSROOT),$(ANDROID_BUILD_TOP)/)
        NDK_SYSROOT := $(ANDROID_BUILD_TOP)/$(shell (ls -dv prebuil*/ndk/current/platforms/android-*/arch-$(TARGET_ARCH) | tail -1))
    endif

endif # FFMPEG_STANDALONE_BUILD

FF_CONFIGURATION_FLAGS :=

ifeq ($(FFMPEG_COMPILE_STATIC),yes)
    FF_CONFIGURATION_FLAGS += --enable-static
else
    FF_CONFIGURATION_FLAGS += --disable-static
endif

ifeq ($(FFMPEG_COMPILE_SHARED),yes)
    FF_CONFIGURATION_FLAGS += --enable-shared
else
    FF_CONFIGURATION_FLAGS += --disable-shared
endif

FF_CONFIGURATION_FLAGS_GPL :=

ifeq ($(FFMPEG_COMPILE_GPL),yes)
    FF_CONFIGURATION_FLAGS_GPL := --enable-gpl
endif


FF_CONFIGURATION_STRING := \
    --arch=$(TARGET_ARCH) \
    --target-os=linux \
    --enable-cross-compile \
    --cross-prefix=$(NDK_CROSS_PREFIX) \
    --sysroot=$(NDK_SYSROOT) \
    $(FF_CONFIGURATION_FLAGS)

ifeq ($(VERSION_BRANCH),2.2)
    FF_CONFIGURATION_STRING += \
        --enable-avresample
endif

ifeq ($(VERSION_BRANCH),2.1)
    FF_CONFIGURATION_STRING += \
        --enable-avresample
endif

ifeq ($(VERSION_BRANCH),1.1)
    FF_CONFIGURATION_STRING += \
        --enable-avresample
endif

ifeq ($(VERSION_BRANCH),1.0)
    FF_CONFIGURATION_STRING += \
        --enable-avresample
endif

ifeq ($(VERSION_BRANCH),0.11)
    FF_CONFIGURATION_STRING += \
        --enable-avresample
endif

ifeq ($(VERSION_BRANCH),0.7)
    FF_CONFIGURATION_STRING += \
        --disable-ffplay
endif

# Temporary, until bug is fixed
ifeq ($(TARGET_ARCH),x86)
    FF_DISABLE_MMX := --disable-mmx
    FF_DISABLE_MMX2 := --disable-mmx2
    ifeq ($(VERSION_BRANCH),2.2)
        FF_DISABLE_MMX2 := --disable-mmxext
    endif
    ifeq ($(VERSION_BRANCH),2.1)
        FF_DISABLE_MMX2 := --disable-mmxext
    endif
    ifeq ($(VERSION_BRANCH),1.1)
        FF_DISABLE_MMX2 := --disable-mmxext
    endif
    ifeq ($(VERSION_BRANCH),1.0)
        FF_DISABLE_MMX2 := --disable-mmxext
    endif
    FF_CONFIGURATION_STRING += $(FF_DISABLE_MMX) $(FF_DISABLE_MMX2) 
endif


ifeq ($(FFMPEG_STANDALONE_BUILD),yes)

FF_CONFIGURATION_STRING += --extra-cflags='$(TARGET_CFLAGS)'
FF_CONFIGURATION_STRING += --extra-ldflags='$(TARGET_LDFLAGS)'

else

include $(ANDROID_BUILD_TOP)/build/core/combo/arch/$(TARGET_ARCH)/$(TARGET_ARCH_VARIANT).mk

FF_CONFIGURATION_STRING += --extra-cflags='$(arch_variant_cflags)'
FF_CONFIGURATION_STRING += --extra-ldflags='$(arch_variant_ldflags)'

endif

FF_CONFIGURATION_STRING += --extra-version=.android



# Do not edit after this line
#===============================================================================

FF_LAST_CONFIGURATION_STRING_COMMAND := \
    cat $(FFMPEG_ROOT_DIR)/$(FFMPEG_CONFIG_DIR)/LAST_CONFIGURATION_STRING;
FF_LAST_CONFIGURATION_STRING_OUTPUT := $(shell $(FF_LAST_CONFIGURATION_STRING_COMMAND))

#===============================================================================
ifneq ($(FF_CONFIGURATION_STRING), $(FF_LAST_CONFIGURATION_STRING_OUTPUT))

    FF_CREATE_CONFIG_DIR_COMMAND := \
        cd $(FFMPEG_ROOT_DIR); \
        rm -rf $(FFMPEG_CONFIG_DIR); \
        mkdir -p $(FFMPEG_CONFIG_DIR); \
        cd $$OLDPWD;

    $(warning ============================================================)
    $(warning Creating configuration directory...)
    $(warning $(FF_CREATE_CONFIG_DIR_COMMAND))
    FF_CREATE_CONFIG_DIR_OUTPUT := $(shell $(FF_CREATE_CONFIG_DIR_COMMAND))
    $(warning Done.)
    $(warning ============================================================)



    FF_CREATE_REQUIRED_FILES_COMMAND := \
        cd $(FFMPEG_ROOT_DIR)/$(FFMPEG_CONFIG_DIR); \
        ../../configure \
            $(FF_CONFIGURATION_FLAGS) \
            $(FF_CONFIGURATION_FLAGS_GPL) \
            --disable-everything \
            --disable-mmx \
            --disable-yasm; \
        make -j; \
        cd $$OLDPWD;

    ifeq ($(VERSION_BRANCH),2.2)
        FF_CREATE_REQUIRED_FILES_COMMAND := \
            cd $(FFMPEG_ROOT_DIR)/$(FFMPEG_CONFIG_DIR); \
            ../../configure \
                $(FF_CONFIGURATION_FLAGS) \
                $(FF_CONFIGURATION_FLAGS_GPL) \
                --enable-shared \
                --enable-static \
                --enable-gpl \
                --enable-avresample \
                --disable-everything \
                --disable-yasm; \
            make -j; \
            find | grep -v "\.ver" | grep -v "ffversion\.h" | grep -v "version\.h" | xargs rm; \
            cd $$OLDPWD;
    endif

    ifeq ($(VERSION_BRANCH),2.1)
        FF_CREATE_REQUIRED_FILES_COMMAND := \
            cd $(FFMPEG_ROOT_DIR)/$(FFMPEG_CONFIG_DIR); \
            ../../configure \
                $(FF_CONFIGURATION_FLAGS) \
                $(FF_CONFIGURATION_FLAGS_GPL) \
                --enable-shared \
                --enable-static \
                --enable-gpl \
                --enable-avresample \
                --disable-everything \
                --disable-yasm; \
            make -j; \
            find | grep -v "\.ver" | grep -v "ffversion\.h" | grep -v "version\.h" | xargs rm; \
            cd $$OLDPWD;
    endif

    ifeq ($(VERSION_BRANCH),1.1)
        FF_CREATE_REQUIRED_FILES_COMMAND := \
            cd $(FFMPEG_ROOT_DIR)/$(FFMPEG_CONFIG_DIR); \
            ../../configure \
                $(FF_CONFIGURATION_FLAGS) \
                $(FF_CONFIGURATION_FLAGS_GPL) \
                --disable-devices \
                --enable-avresample \
                --disable-mmx \
                --disable-yasm; \
            make -j8; \
            cd $$OLDPWD;
    endif

    ifeq ($(VERSION_BRANCH),1.1)
        FF_CREATE_REQUIRED_FILES_COMMAND := \
            cd $(FFMPEG_ROOT_DIR)/$(FFMPEG_CONFIG_DIR); \
            ../../configure \
                $(FF_CONFIGURATION_FLAGS) \
                $(FF_CONFIGURATION_FLAGS_GPL) \
                --disable-devices \
                --enable-avresample \
                --disable-mmx \
                --disable-yasm; \
            make -j8; \
            cd $$OLDPWD;
    endif

    ifeq ($(VERSION_BRANCH),1.0)
        FF_CREATE_REQUIRED_FILES_COMMAND := \
            cd $(FFMPEG_ROOT_DIR)/$(FFMPEG_CONFIG_DIR); \
            ../../configure \
                $(FF_CONFIGURATION_FLAGS) \
                $(FF_CONFIGURATION_FLAGS_GPL) \
                --enable-avresample \
                --disable-everything \
                --disable-mmx \
                --disable-yasm; \
            make -j; \
            cd $$OLDPWD;
    endif

    ifeq ($(VERSION_BRANCH),0.11)
        FF_CREATE_REQUIRED_FILES_COMMAND := \
            cd $(FFMPEG_ROOT_DIR)/$(FFMPEG_CONFIG_DIR); \
            ../../configure \
                $(FF_CONFIGURATION_FLAGS) \
                $(FF_CONFIGURATION_FLAGS_GPL) \
                --enable-avresample \
                --disable-everything \
                --disable-mmx \
                --disable-yasm; \
            make -j; \
            cd $$OLDPWD;
    endif

    $(warning ============================================================)
    $(warning Creating required files...)
    $(warning $(FF_CREATE_REQUIRED_FILES_COMMAND))
    FF_CREATE_REQUIRED_FILES_OUTPUT := $(shell $(FF_CREATE_REQUIRED_FILES_COMMAND))
    $(warning Done.)
    $(warning ============================================================)

    ARCH_ARM :=
    ARCH_MIPS :=
    ARCH_X86 :=
    ARCH_INLINE_ASM := 1
    ifeq ($(TARGET_ARCH),arm)
        ARCH_ARM := 1
        ARCH_INLINE_ASM := 0 # NDK toolchain compiles for Thumb, and ffmpeg uses generic arm code
    endif
    ifeq ($(TARGET_ARCH),mips)
        ARCH_MIPS := 1
    endif
    ifeq ($(TARGET_ARCH),x86)
        ARCH_X86 := 1
    endif

    FF_CONFIGURATION_COMMAND := \
        cd $(FFMPEG_ROOT_DIR)/$(FFMPEG_CONFIG_DIR); \
        ../../configure $(FF_CONFIGURATION_STRING); \
        cd $$OLDPWD;

    $(warning ============================================================)
    $(warning Configuring FFmpeg...)
    $(warning $(FF_CONFIGURATION_COMMAND))
    FF_CONFIGURATION_OUTPUT := $(shell $(FF_CONFIGURATION_COMMAND))
    $(warning Done.)
    $(warning ============================================================)

    ifeq ($(VERSION_BRANCH),2.2)
        FF_FIX_CONFIGURATION_COMMAND := \
            cd $(FFMPEG_ROOT_DIR)/$(FFMPEG_CONFIG_DIR); \
            \
            cat config.h | \
            sed 's/\#define av_restrict /\#ifdef av_restrict\n\#undef av_restrict\n\#endif\n\#define av_restrict /g' | \
            sed 's/\#define ARCH_ARM /\#ifdef ARCH_ARM\n\#undef ARCH_ARM\n\#endif\n\#define ARCH_ARM /g' | \
            sed 's/\#define ARCH_MIPS /\#ifdef ARCH_MIPS\n\#undef ARCH_MIPS\n\#endif\n\#define ARCH_MIPS /g' | \
            sed 's/\#define ARCH_X86 /\#ifdef ARCH_X86\n\#undef ARCH_X86\n\#endif\n\#define ARCH_X86 /g' | \
            sed 's/\#define HAVE_PTHREADS/\#ifdef HAVE_PTHREADS\n\#undef HAVE_PTHREADS\n\#endif\n\#define HAVE_PTHREADS/g' | \
            sed 's/\#define HAVE_MALLOC_H/\#ifdef HAVE_MALLOC_H\n\#undef HAVE_MALLOC_H\n\#endif\n\#define HAVE_MALLOC_H/g' | \
            sed 's/\#define HAVE_STRERROR_R 1/\#define HAVE_STRERROR_R 0/g' | \
            sed 's/\#define HAVE_SYSCTL 1/\#define HAVE_SYSCTL 0/g' | \
            cat > config.h.tmp; \
            mv config.h config.h.bak; \
            mv config.h.tmp config.h; \
            \
            cat config.mak | \
            sed 's/HAVE_STRERROR_R=yes/!HAVE_STRERROR_R=yes/g' | \
            sed 's/HAVE_SYSCTL=yes/!HAVE_SYSCTL=yes/g' | \
            cat > config.mak.tmp; \
            mv config.mak config.mak.bak; \
            mv config.mak.tmp config.mak; \
            \
            cd $(OLDPWD);
    endif

    ifeq ($(VERSION_BRANCH),2.1)
        FF_FIX_CONFIGURATION_COMMAND := \
            cd $(FFMPEG_ROOT_DIR)/$(FFMPEG_CONFIG_DIR); \
            \
            cat config.h | \
            sed 's/\#define av_restrict /\#ifdef av_restrict\n\#undef av_restrict\n\#endif\n\#define av_restrict /g' | \
            sed 's/\#define ARCH_ARM /\#ifdef ARCH_ARM\n\#undef ARCH_ARM\n\#endif\n\#define ARCH_ARM /g' | \
            sed 's/\#define ARCH_MIPS /\#ifdef ARCH_MIPS\n\#undef ARCH_MIPS\n\#endif\n\#define ARCH_MIPS /g' | \
            sed 's/\#define ARCH_X86 /\#ifdef ARCH_X86\n\#undef ARCH_X86\n\#endif\n\#define ARCH_X86 /g' | \
            sed 's/\#define HAVE_PTHREADS/\#ifdef HAVE_PTHREADS\n\#undef HAVE_PTHREADS\n\#endif\n\#define HAVE_PTHREADS/g' | \
            sed 's/\#define HAVE_MALLOC_H/\#ifdef HAVE_MALLOC_H\n\#undef HAVE_MALLOC_H\n\#endif\n\#define HAVE_MALLOC_H/g' | \
            sed 's/\#define HAVE_STRERROR_R 1/\#define HAVE_STRERROR_R 0/g' | \
            sed 's/\#define HAVE_SYSCTL 1/\#define HAVE_SYSCTL 0/g' | \
            cat > config.h.tmp; \
            mv config.h config.h.bak; \
            mv config.h.tmp config.h; \
            \
            cat config.mak | \
            sed 's/HAVE_STRERROR_R=yes/!HAVE_STRERROR_R=yes/g' | \
            sed 's/HAVE_SYSCTL=yes/!HAVE_SYSCTL=yes/g' | \
            cat > config.mak.tmp; \
            mv config.mak config.mak.bak; \
            mv config.mak.tmp config.mak; \
            \
            cd $(OLDPWD);
    endif

    ifeq ($(VERSION_BRANCH),1.1)
        # NEON presence is checked at runtime, so enable it
        FF_FIX_CONFIGURATION_COMMAND := \
            cd $(FFMPEG_ROOT_DIR)/$(FFMPEG_CONFIG_DIR); \
            \
            cat config.h | \
            sed 's/\#define ARCH_ARM .*/\#ifdef ARCH_ARM\n\#undef ARCH_ARM\n\#endif\n\#define ARCH_ARM $(if $(ARCH_ARM),1,0)/g' | \
            sed 's/\#define ARCH_MIPS .*/\#ifdef ARCH_MIPS\n\#undef ARCH_MIPS\n\#endif\n\#define ARCH_MIPS $(if $(ARCH_MIPS),1,0)/g' | \
            sed 's/\#define ARCH_X86 .*/\#ifdef ARCH_X86\n\#undef ARCH_X86\n\#endif\n\#define ARCH_X86 $(if $(ARCH_X86),1,0)/g' | \
            sed 's/\#define ARCH_X86_32 .*/\#ifdef ARCH_X86_32\n\#undef ARCH_X86_32\n\#endif\n\#define ARCH_X86_32 $(if $(ARCH_X86),1,0)/g' | \
            sed 's/\#define ARCH_X86_64 .*/\#ifdef ARCH_X86_64\n\#undef ARCH_X86_64\n\#endif\n\#define ARCH_X86_64 0/g' | \
            sed 's/\#define HAVE_PTHREADS/\#ifdef HAVE_PTHREADS\n\#undef HAVE_PTHREADS\n\#endif\n\#define HAVE_PTHREADS/g' | \
            sed 's/\#define HAVE_MALLOC_H/\#ifdef HAVE_MALLOC_H\n\#undef HAVE_MALLOC_H\n\#endif\n\#define HAVE_MALLOC_H/g' | \
            sed 's/\#define HAVE_STRERROR_R 1/\#define HAVE_STRERROR_R 0/g' | \
            sed 's/\#define HAVE_SYSCTL 1/\#define HAVE_SYSCTL 0/g' | \
            sed 's/\#define HAVE_POSIX_MEMALIGN 1/\#define HAVE_POSIX_MEMALIGN 0/g' | \
            sed 's/\#define HAVE_PTHREAD_CANCEL 1/\#define HAVE_PTHREAD_CANCEL 0/g' | \
            sed 's/\#define HAVE_GLOB 1/\#define HAVE_GLOB 0/g' | \
            sed 's/\#define HAVE_LOG2 1/\#define HAVE_LOG2 0/g' | \
            sed 's/\#define HAVE_LOG2F 1/\#define HAVE_LOG2F 0/g' | \
            sed 's/\#define HAVE_FAST_CMOV 1/\#define HAVE_FAST_CMOV $(if $(ARCH_X86),1,0)/g' | \
            sed 's/\#define HAVE_CMOV 1/\#define HAVE_CMOV 0/g' | \
            sed 's/\#define HAVE_EBP_AVAILABLE 1/\#define HAVE_EBP_AVAILABLE 0/g' | \
            sed 's/\#define HAVE_EBX_AVAILABLE 1/\#define HAVE_EBX_AVAILABLE 0/g' | \
            sed 's/\#define HAVE_FAST_CLZ 1/\#define HAVE_FAST_CLZ 1/g' | \
            sed 's/\#define HAVE_FAST_UNALIGNED 1/\#define HAVE_FAST_UNALIGNED 0/g' | \
            sed 's/\#define CONFIG_FAST_UNALIGNED 1/\#define CONFIG_FAST_UNALIGNED 0/g' | \
            sed 's/\#define HAVE_ARMV5TE 0/\#define HAVE_ARMV5TE 1/g' | \
            sed 's/\#define HAVE_VFP 0/\#define HAVE_VFP 1/g' | \
            sed 's/\#define HAVE_NEON 0/\#define HAVE_NEON 1/g' | \
            sed 's/\#define HAVE_ARMV6 0/\#define HAVE_ARMV6 1/g' | \
            sed 's/\#define HAVE_INLINE_ASM 1/\#define HAVE_INLINE_ASM $(ARCH_INLINE_ASM)/g' | \
            cat > config.h.tmp; \
            mv config.h config.h.bak; \
            mv config.h.tmp config.h; \
            \
            cat config.mak | \
            sed 's/HAVE_STRERROR_R=yes/!HAVE_STRERROR_R=yes/g' | \
            sed 's/HAVE_FAST_UNALIGNED=yes/!HAVE_FAST_UNALIGNED=yes/g' | \
            sed 's/HAVE_LOG2=yes/!HAVE_LOG2=yes/g' | \
            sed 's/HAVE_LOG2F=yes/!HAVE_LOG2F=yes/g' | \
            sed 's/ARCH_X86_64=yes/!ARCH_X86_64=yes/g' | \
            sed 's/ARCH=x86/ARCH=$(TARGET_ARCH)/g' | \
            sed 's/!ARCH_ARM=yes/ARCH_ARM=$(if $(ARCH_ARM),yes)/g' | \
            sed 's/!ARCH_MIPS=yes/ARCH_MIPS=$(if $(ARCH_MIPS),yes)/g' | \
            sed 's/!ARCH_X86_32=yes/ARCH_X86_32=$(if $(ARCH_X86),yes)/g' | \
            sed 's/!HAVE_ARMV5TE=yes/HAVE_ARMV5TE=yes/g' | \
            sed 's/!HAVE_ARMV6=yes/HAVE_ARMV6=yes/g' | \
            sed 's/!HAVE_NEON=yes/HAVE_NEON=yes/g' | \
            sed 's/!HAVE_VFP=yes/HAVE_VFP=yes/g' | \
            cat > config.mak.tmp; \
            mv config.mak config.mak.bak; \
            mv config.mak.tmp config.mak; \
            \
            cd $(OLDPWD);
    endif

    ifeq ($(VERSION_BRANCH),1.0)
        FF_FIX_CONFIGURATION_COMMAND := \
            cd $(FFMPEG_ROOT_DIR)/$(FFMPEG_CONFIG_DIR); \
            \
            cat config.h | \
            sed 's/\#define ARCH_ARM /\#ifdef ARCH_ARM\n\#undef ARCH_ARM\n\#endif\n\#define ARCH_ARM /g' | \
            sed 's/\#define ARCH_MIPS /\#ifdef ARCH_MIPS\n\#undef ARCH_MIPS\n\#endif\n\#define ARCH_MIPS /g' | \
            sed 's/\#define ARCH_X86 /\#ifdef ARCH_X86\n\#undef ARCH_X86\n\#endif\n\#define ARCH_X86 /g' | \
            sed 's/\#define HAVE_PTHREADS/\#ifdef HAVE_PTHREADS\n\#undef HAVE_PTHREADS\n\#endif\n\#define HAVE_PTHREADS/g' | \
            sed 's/\#define HAVE_MALLOC_H/\#ifdef HAVE_MALLOC_H\n\#undef HAVE_MALLOC_H\n\#endif\n\#define HAVE_MALLOC_H/g' | \
            sed 's/\#define HAVE_STRERROR_R 1/\#define HAVE_STRERROR_R 0/g' | \
            cat > config.h.tmp; \
            mv config.h config.h.bak; \
            mv config.h.tmp config.h; \
            \
            cat config.mak | \
            sed 's/HAVE_STRERROR_R=yes/!HAVE_STRERROR_R=yes/g' | \
            cat > config.mak.tmp; \
            mv config.mak config.mak.bak; \
            mv config.mak.tmp config.mak; \
            \
            cd $(OLDPWD);
    endif

    ifeq ($(VERSION_BRANCH),0.11)
        FF_FIX_CONFIGURATION_COMMAND := \
            cd $(FFMPEG_ROOT_DIR)/$(FFMPEG_CONFIG_DIR); \
            \
            cat config.h | \
            sed 's/\#define ARCH_ARM /\#ifdef ARCH_ARM\n\#undef ARCH_ARM\n\#endif\n\#define ARCH_ARM /g' | \
            sed 's/\#define ARCH_MIPS /\#ifdef ARCH_MIPS\n\#undef ARCH_MIPS\n\#endif\n\#define ARCH_MIPS /g' | \
            sed 's/\#define ARCH_X86 /\#ifdef ARCH_X86\n\#undef ARCH_X86\n\#endif\n\#define ARCH_X86 /g' | \
            sed 's/\#define HAVE_PTHREADS/\#ifdef HAVE_PTHREADS\n\#undef HAVE_PTHREADS\n\#endif\n\#define HAVE_PTHREADS/g' | \
            sed 's/\#define HAVE_MALLOC_H/\#ifdef HAVE_MALLOC_H\n\#undef HAVE_MALLOC_H\n\#endif\n\#define HAVE_MALLOC_H/g' | \
            sed 's/\#define HAVE_STRERROR_R 1/\#define HAVE_STRERROR_R 0/g' | \
            cat > config.h.tmp; \
            mv config.h config.h.bak; \
            mv config.h.tmp config.h; \
            \
            cat config.mak | \
            sed 's/HAVE_STRERROR_R=yes/!HAVE_STRERROR_R=yes/g' | \
            cat > config.mak.tmp; \
            mv config.mak config.mak.bak; \
            mv config.mak.tmp config.mak; \
            \
            cd $(OLDPWD);
    endif

    ifeq ($(VERSION_BRANCH),0.10)
        FF_FIX_CONFIGURATION_COMMAND := \
            cd $(FFMPEG_ROOT_DIR)/$(FFMPEG_CONFIG_DIR); \
            \
            cat config.h | \
            sed 's/\#define ARCH_ARM /\#ifdef ARCH_ARM\n\#undef ARCH_ARM\n\#endif\n\#define ARCH_ARM /g' | \
            sed 's/\#define ARCH_MIPS /\#ifdef ARCH_MIPS\n\#undef ARCH_MIPS\n\#endif\n\#define ARCH_MIPS /g' | \
            sed 's/\#define ARCH_X86 /\#ifdef ARCH_X86\n\#undef ARCH_X86\n\#endif\n\#define ARCH_X86 /g' | \
            sed 's/\#define HAVE_PTHREADS/\#ifdef HAVE_PTHREADS\n\#undef HAVE_PTHREADS\n\#endif\n\#define HAVE_PTHREADS/g' | \
            sed 's/\#define HAVE_MALLOC_H/\#ifdef HAVE_MALLOC_H\n\#undef HAVE_MALLOC_H\n\#endif\n\#define HAVE_MALLOC_H/g' | \
            sed 's/\#define HAVE_STRERROR_R 1/\#define HAVE_STRERROR_R 0/g' | \
            cat > config.h.tmp; \
            mv config.h config.h.bak; \
            mv config.h.tmp config.h; \
            \
            cat config.mak | \
            sed 's/HAVE_STRERROR_R=yes/!HAVE_STRERROR_R=yes/g' | \
            cat > config.mak.tmp; \
            mv config.mak config.mak.bak; \
            mv config.mak.tmp config.mak; \
            \
            cd $(OLDPWD);
    endif

    ifeq ($(VERSION_BRANCH),0.9)
        FF_FIX_CONFIGURATION_COMMAND := \
            cd $(FFMPEG_ROOT_DIR)/$(FFMPEG_CONFIG_DIR); \
            \
            cat config.h | \
            sed 's/\#define ARCH_ARM /\#ifdef ARCH_ARM\n\#undef ARCH_ARM\n\#endif\n\#define ARCH_ARM /g' | \
            sed 's/\#define ARCH_MIPS /\#ifdef ARCH_MIPS\n\#undef ARCH_MIPS\n\#endif\n\#define ARCH_MIPS /g' | \
            sed 's/\#define ARCH_X86 /\#ifdef ARCH_X86\n\#undef ARCH_X86\n\#endif\n\#define ARCH_X86 /g' | \
            sed 's/\#define HAVE_PTHREADS/\#ifdef HAVE_PTHREADS\n\#undef HAVE_PTHREADS\n\#endif\n\#define HAVE_PTHREADS/g' | \
            sed 's/\#define HAVE_MALLOC_H/\#ifdef HAVE_MALLOC_H\n\#undef HAVE_MALLOC_H\n\#endif\n\#define HAVE_MALLOC_H/g' | \
            sed 's/\#define HAVE_STRERROR_R 1/\#define HAVE_STRERROR_R 0/g' | \
            cat > config.h.tmp; \
            mv config.h config.h.bak; \
            mv config.h.tmp config.h; \
            \
            cat config.mak | \
            sed 's/HAVE_STRERROR_R=yes/!HAVE_STRERROR_R=yes/g' | \
            cat > config.mak.tmp; \
            mv config.mak config.mak.bak; \
            mv config.mak.tmp config.mak; \
            \
            cd $(OLDPWD);
    endif

    ifeq ($(VERSION_BRANCH),0.8)
        FF_FIX_CONFIGURATION_COMMAND := \
            cd $(FFMPEG_ROOT_DIR)/$(FFMPEG_CONFIG_DIR); \
            \
            cat config.h | \
            sed 's/\#define ARCH_ARM /\#ifdef ARCH_ARM\n\#undef ARCH_ARM\n\#endif\n\#define ARCH_ARM /g' | \
            sed 's/\#define ARCH_MIPS /\#ifdef ARCH_MIPS\n\#undef ARCH_MIPS\n\#endif\n\#define ARCH_MIPS /g' | \
            sed 's/\#define ARCH_X86 /\#ifdef ARCH_X86\n\#undef ARCH_X86\n\#endif\n\#define ARCH_X86 /g' | \
            sed 's/\#define HAVE_PTHREADS/\#ifdef HAVE_PTHREADS\n\#undef HAVE_PTHREADS\n\#endif\n\#define HAVE_PTHREADS/g' | \
            sed 's/\#define HAVE_MALLOC_H/\#ifdef HAVE_MALLOC_H\n\#undef HAVE_MALLOC_H\n\#endif\n\#define HAVE_MALLOC_H/g' | \
            sed 's/\#define HAVE_STRERROR_R 1/\#define HAVE_STRERROR_R 0/g' | \
            cat > config.h.tmp; \
            mv config.h config.h.bak; \
            mv config.h.tmp config.h; \
            \
            cat config.mak | \
            sed 's/HAVE_STRERROR_R=yes/!HAVE_STRERROR_R=yes/g' | \
            cat > config.mak.tmp; \
            mv config.mak config.mak.bak; \
            mv config.mak.tmp config.mak; \
            \
            cd $(OLDPWD);
    endif

    ifeq ($(VERSION_BRANCH),0.7)
        FF_FIX_CONFIGURATION_COMMAND := \
            cd $(FFMPEG_ROOT_DIR)/$(FFMPEG_CONFIG_DIR); \
            \
            cat config.h | \
            sed 's/\#define ARCH_ARM /\#ifdef ARCH_ARM\n\#undef ARCH_ARM\n\#endif\n\#define ARCH_ARM /g' | \
            sed 's/\#define ARCH_MIPS /\#ifdef ARCH_MIPS\n\#undef ARCH_MIPS\n\#endif\n\#define ARCH_MIPS /g' | \
            sed 's/\#define ARCH_X86 /\#ifdef ARCH_X86\n\#undef ARCH_X86\n\#endif\n\#define ARCH_X86 /g' | \
            sed 's/\#define HAVE_PTHREADS/\#ifdef HAVE_PTHREADS\n\#undef HAVE_PTHREADS\n\#endif\n\#define HAVE_PTHREADS/g' | \
            sed 's/\#define HAVE_MALLOC_H/\#ifdef HAVE_MALLOC_H\n\#undef HAVE_MALLOC_H\n\#endif\n\#define HAVE_MALLOC_H/g' | \
            sed 's/\#define HAVE_STRERROR_R 1/\#define HAVE_STRERROR_R 0/g' | \
            cat > config.h.tmp; \
            mv config.h config.h.bak; \
            mv config.h.tmp config.h; \
            \
            cat config.mak | \
            sed 's/HAVE_STRERROR_R=yes/!HAVE_STRERROR_R=yes/g' | \
            cat > config.mak.tmp; \
            mv config.mak config.mak.bak; \
            mv config.mak.tmp config.mak; \
            \
            cd $(OLDPWD);
    endif

    $(warning ============================================================)
    $(warning Fixing configuration...)
    #$(warning $(FF_FIX_CONFIGURATION_COMMAND))
    FF_FIX_CONFIGURATION_OUTPUT := $(shell $(FF_FIX_CONFIGURATION_COMMAND))
    $(warning Done.)
    $(warning ============================================================)

    ifeq ($(VERSION_BRANCH),2.2)
        FF_FIX_MAKEFILES_COMMAND := \
            cd $(FFMPEG_ROOT_DIR); \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavcodec/Makefile     > libavcodec/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavdevice/Makefile    > libavdevice/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavfilter/Makefile    | \
                sed 's/clean::/\#clean::/g'                                                                           | \
                sed 's/\t$$(RM) $$(CLEANSUFFIXES/\#\t$$(RM) $$(CLEANSUFFIXES/g'                                       > libavfilter/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavformat/Makefile    > libavformat/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavresample/Makefile  > libavresample/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavutil/Makefile      > libavutil/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libpostproc/Makefile    > libpostproc/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libswresample/Makefile  > libswresample/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libswscale/Makefile     > libswscale/Makefile.android; \
                cd $$OLDPWD;
    endif

    ifeq ($(VERSION_BRANCH),2.1)
        FF_FIX_MAKEFILES_COMMAND := \
            cd $(FFMPEG_ROOT_DIR); \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavcodec/Makefile     > libavcodec/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavdevice/Makefile    > libavdevice/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavfilter/Makefile    | \
                sed 's/clean::/\#clean::/g'                                                                           | \
                sed 's/\t$$(RM) $$(CLEANSUFFIXES/\#\t$$(RM) $$(CLEANSUFFIXES/g'                                       > libavfilter/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavformat/Makefile    > libavformat/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavresample/Makefile  > libavresample/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavutil/Makefile      > libavutil/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libpostproc/Makefile    > libpostproc/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libswresample/Makefile  > libswresample/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libswscale/Makefile     > libswscale/Makefile.android; \
                cd $$OLDPWD;
    endif

    ifeq ($(VERSION_BRANCH),1.1)
        FF_FIX_MAKEFILES_COMMAND := \
            cd $(FFMPEG_ROOT_DIR); \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavcodec/Makefile     > libavcodec/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavdevice/Makefile    > libavdevice/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavfilter/Makefile    | \
                sed 's/clean::/\#clean::/g'                                                                           | \
                sed 's/\t$$(RM) $$(CLEANSUFFIXES/\#\t$$(RM) $$(CLEANSUFFIXES/g'                                       > libavfilter/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavformat/Makefile    > libavformat/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavresample/Makefile  > libavresample/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavutil/Makefile      > libavutil/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libpostproc/Makefile    > libpostproc/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libswresample/Makefile  > libswresample/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libswscale/Makefile     > libswscale/Makefile.android; \
                cd $$OLDPWD;
    endif
    ifeq ($(VERSION_BRANCH),1.0)
        FF_FIX_MAKEFILES_COMMAND := \
            cd $(FFMPEG_ROOT_DIR); \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavcodec/Makefile     > libavcodec/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavdevice/Makefile    > libavdevice/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavfilter/Makefile    | \
                sed 's/clean::/\#clean::/g'                                                                           | \
                sed 's/\t$$(RM) $$(CLEANSUFFIXES/\#\t$$(RM) $$(CLEANSUFFIXES/g'                                       > libavfilter/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavformat/Makefile    > libavformat/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavresample/Makefile  > libavresample/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavutil/Makefile      > libavutil/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libpostproc/Makefile    > libpostproc/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libswresample/Makefile  > libswresample/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libswscale/Makefile     > libswscale/Makefile.android; \
                cd $$OLDPWD;
    endif

    ifeq ($(VERSION_BRANCH),0.11)
        FF_FIX_MAKEFILES_COMMAND := \
            cd $(FFMPEG_ROOT_DIR); \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavcodec/Makefile     > libavcodec/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavdevice/Makefile    > libavdevice/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavfilter/Makefile    > libavfilter/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavformat/Makefile    > libavformat/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavresample/Makefile  > libavresample/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavutil/Makefile      > libavutil/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libpostproc/Makefile    > libpostproc/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libswresample/Makefile  > libswresample/Makefile.android; \
                sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libswscale/Makefile     > libswscale/Makefile.android; \
                cd $$OLDPWD;
    endif

    ifeq ($(VERSION_BRANCH),0.10)
        FF_FIX_MAKEFILES_COMMAND := \
            cd $(FFMPEG_ROOT_DIR); \
            sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavcodec/Makefile     > libavcodec/Makefile.android; \
            sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavdevice/Makefile    > libavdevice/Makefile.android; \
            sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavfilter/Makefile    > libavfilter/Makefile.android; \
            sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavformat/Makefile    > libavformat/Makefile.android; \
            sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavutil/Makefile      > libavutil/Makefile.android; \
            sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libpostproc/Makefile    > libpostproc/Makefile.android; \
            sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libswresample/Makefile  > libswresample/Makefile.android; \
            sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libswscale/Makefile     > libswscale/Makefile.android; \
            cd $$OLDPWD;
    endif

    ifeq ($(VERSION_BRANCH),0.9)
        FF_FIX_MAKEFILES_COMMAND := \
            cd $(FFMPEG_ROOT_DIR); \
            sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavcodec/Makefile     | \
            sed 's/include $$(SRC_PATH)\/subdir.mak/\#include $$(SRC_PATH)\/subdir.mak/g'                         | \
            sed 's/-include $$(SRC_PATH)\/$$(SUBDIR)$$(ARCH)\/Makefile/include $$(LOCAL_PATH)\/libavcodec\/$$(ARCH)\/Makefile/g' > libavcodec/Makefile.android; \
            sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavdevice/Makefile    | \
            sed 's/include $$(SRC_PATH)\/subdir.mak/\#include $$(SRC_PATH)\/subdir.mak/g'                         > libavdevice/Makefile.android; \
            sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavfilter/Makefile    | \
            sed 's/include $$(SRC_PATH)\/subdir.mak/\#include $$(SRC_PATH)\/subdir.mak/g'                         > libavfilter/Makefile.android; \
            sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavformat/Makefile    | \
            sed 's/include $$(SRC_PATH)\/subdir.mak/\#include $$(SRC_PATH)\/subdir.mak/g'                         > libavformat/Makefile.android; \
            sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavutil/Makefile      | \
            sed 's/include $$(SRC_PATH)\/subdir.mak/\#include $$(SRC_PATH)\/subdir.mak/g'                         > libavutil/Makefile.android; \
            sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libpostproc/Makefile    | \
            sed 's/include $$(SRC_PATH)\/subdir.mak/\#include $$(SRC_PATH)\/subdir.mak/g'                         > libpostproc/Makefile.android; \
            sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libswresample/Makefile  | \
            sed 's/include $$(SRC_PATH)\/subdir.mak/\#include $$(SRC_PATH)\/subdir.mak/g'                         > libswresample/Makefile.android; \
            sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libswscale/Makefile     | \
            sed 's/include $$(SRC_PATH)\/subdir.mak/\#include $$(SRC_PATH)\/subdir.mak/g'                         > libswscale/Makefile.android; \
            cd $$OLDPWD;
    endif

    ifeq ($(VERSION_BRANCH),0.8)
        FF_FIX_MAKEFILES_COMMAND := \
            cd $(FFMPEG_ROOT_DIR); \
            sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavcodec/Makefile     | \
            sed 's/include $$(SUBDIR)..\/subdir.mak/\#include $$(SUBDIR)..\/subdir.mak/g'                         | \
            sed 's/-include $$(SUBDIR)..\/$$(SUBDIR)$$(ARCH)\/Makefile/include $$(LOCAL_PATH)\/libavcodec\/$$(ARCH)\/Makefile/g' > libavcodec/Makefile.android; \
            sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavdevice/Makefile    | \
            sed 's/include $$(SUBDIR)..\/subdir.mak/\#include $$(SUBDIR)..\/subdir.mak/g'                         > libavdevice/Makefile.android; \
            sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavfilter/Makefile    | \
            sed 's/include $$(SUBDIR)..\/subdir.mak/\#include $$(SUBDIR)..\/subdir.mak/g'                         > libavfilter/Makefile.android; \
            sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavformat/Makefile    | \
            sed 's/include $$(SUBDIR)..\/subdir.mak/\#include $$(SUBDIR)..\/subdir.mak/g'                         > libavformat/Makefile.android; \
            sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavutil/Makefile      | \
            sed 's/include $$(SUBDIR)..\/subdir.mak/\#include $$(SUBDIR)..\/subdir.mak/g'                         > libavutil/Makefile.android; \
            sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libpostproc/Makefile    | \
            sed 's/include $$(SUBDIR)..\/subdir.mak/\#include $$(SUBDIR)..\/subdir.mak/g'                         > libpostproc/Makefile.android; \
            sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libswresample/Makefile  | \
            sed 's/include $$(SUBDIR)..\/subdir.mak/\#include $$(SUBDIR)..\/subdir.mak/g'                         > libswresample/Makefile.android; \
            sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libswscale/Makefile     | \
            sed 's/include $$(SUBDIR)..\/subdir.mak/\#include $$(SUBDIR)..\/subdir.mak/g'                         > libswscale/Makefile.android; \
            cd $$OLDPWD;
    endif

    ifeq ($(VERSION_BRANCH),0.7)
        FF_FIX_MAKEFILES_COMMAND := \
            cd $(FFMPEG_ROOT_DIR); \
            sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavcodec/Makefile     | \
            sed 's/include $$(SUBDIR)..\/subdir.mak/\#include $$(SUBDIR)..\/subdir.mak/g'                         | \
            sed 's/-include $$(SUBDIR)..\/$$(SUBDIR)$$(ARCH)\/Makefile/include $$(LOCAL_PATH)\/libavcodec\/$$(ARCH)\/Makefile/g' > libavcodec/Makefile.android; \
            sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavdevice/Makefile    | \
            sed 's/include $$(SUBDIR)..\/subdir.mak/\#include $$(SUBDIR)..\/subdir.mak/g'                         > libavdevice/Makefile.android; \
            sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavfilter/Makefile    | \
            sed 's/include $$(SUBDIR)..\/subdir.mak/\#include $$(SUBDIR)..\/subdir.mak/g'                         > libavfilter/Makefile.android; \
            sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavformat/Makefile    | \
            sed 's/include $$(SUBDIR)..\/subdir.mak/\#include $$(SUBDIR)..\/subdir.mak/g'                         > libavformat/Makefile.android; \
            sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libavutil/Makefile      | \
            sed 's/include $$(SUBDIR)..\/subdir.mak/\#include $$(SUBDIR)..\/subdir.mak/g'                         > libavutil/Makefile.android; \
            sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libpostproc/Makefile    | \
            sed 's/include $$(SUBDIR)..\/subdir.mak/\#include $$(SUBDIR)..\/subdir.mak/g'                         > libpostproc/Makefile.android; \
            sed 's/include $$(SUBDIR)..\/config.mak/\#include $$(SUBDIR)..\/config.mak/g' libswscale/Makefile     | \
            sed 's/include $$(SUBDIR)..\/subdir.mak/\#include $$(SUBDIR)..\/subdir.mak/g'                         > libswscale/Makefile.android; \
            cd $$OLDPWD;
    endif

    $(warning ============================================================)
    $(warning Fixing Makefiles...)
    #$(warning $(FF_FIX_MAKEFILES_COMMAND))
    FF_FIX_MAKEFILES_OUTPUT := $(shell $(FF_FIX_MAKEFILES_COMMAND))
    $(warning Done.)
    $(warning ============================================================)



    #Saving configuration
    FF_LAST_CONFIGURATION_STRING_COMMAND := \
        echo "$(FF_CONFIGURATION_STRING)" > $(FFMPEG_ROOT_DIR)/$(FFMPEG_CONFIG_DIR)/LAST_CONFIGURATION_STRING
    FF_LAST_CONFIGURATION_STRING_OUTPUT := $(shell $(FF_LAST_CONFIGURATION_STRING_COMMAND))

endif
