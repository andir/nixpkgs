{ lib }:
rec {
  pc = {
    linux-kernel = {
      name = "pc";

      baseConfig = "defconfig";
      # Build whatever possible as a module, if not stated in the extra config.
      autoModules = true;
      target = "bzImage";
    };
  };

  pc_simplekernel = lib.recursiveUpdate pc {
    linux-kernel.autoModules = false;
  };

  powernv = {
    linux-kernel = {
      name = "PowerNV";

      baseConfig = "powernv_defconfig";
      target = "zImage";
      installTarget = "install";
      file = "vmlinux";
      autoModules = true;
      # avoid driver/FS trouble arising from unusual page size
      extraConfig = ''
        PPC_64K_PAGES n
        PPC_4K_PAGES y
        IPV6 y
      '';
    };
  };

  ##
  ## ARM
  ##

  pogoplug4 = {
    linux-kernel = {
      name = "pogoplug4";

      baseConfig = "multi_v5_defconfig";
      autoModules = false;
      extraConfig = ''
        # Ubi for the mtd
        MTD_UBI y
        UBIFS_FS y
        UBIFS_FS_XATTR y
        UBIFS_FS_ADVANCED_COMPR y
        UBIFS_FS_LZO y
        UBIFS_FS_ZLIB y
        UBIFS_FS_DEBUG n
      '';
      makeFlags = [ "LOADADDR=0x8000" ];
      target = "uImage";
      # TODO reenable once manual-config's config actually builds a .dtb and this is checked to be working
      #DTB = true;
    };
    gcc = {
      arch = "armv5te";
    };
  };

  sheevaplug = {
    linux-kernel = {
      name = "sheevaplug";

      baseConfig = "multi_v5_defconfig";
      autoModules = false;
      extraConfig = ''
        BLK_DEV_RAM y
        BLK_DEV_INITRD y
        BLK_DEV_CRYPTOLOOP m
        BLK_DEV_DM m
        DM_CRYPT m
        MD y
        REISERFS_FS m
        BTRFS_FS m
        XFS_FS m
        JFS_FS m
        EXT4_FS m
        USB_STORAGE_CYPRESS_ATACB m

        # mv cesa requires this sw fallback, for mv-sha1
        CRYPTO_SHA1 y
        # Fast crypto
        CRYPTO_TWOFISH y
        CRYPTO_TWOFISH_COMMON y
        CRYPTO_BLOWFISH y
        CRYPTO_BLOWFISH_COMMON y

        IP_PNP y
        IP_PNP_DHCP y
        NFS_FS y
        ROOT_NFS y
        TUN m
        NFS_V4 y
        NFS_V4_1 y
        NFS_FSCACHE y
        NFSD m
        NFSD_V2_ACL y
        NFSD_V3 y
        NFSD_V3_ACL y
        NFSD_V4 y
        NETFILTER y
        IP_NF_IPTABLES y
        IP_NF_FILTER y
        IP_NF_MATCH_ADDRTYPE y
        IP_NF_TARGET_LOG y
        IP_NF_MANGLE y
        IPV6 m
        VLAN_8021Q m

        CIFS y
        CIFS_XATTR y
        CIFS_POSIX y
        CIFS_FSCACHE y
        CIFS_ACL y

        WATCHDOG y
        WATCHDOG_CORE y
        ORION_WATCHDOG m

        ZRAM m
        NETCONSOLE m

        # Disable OABI to have seccomp_filter (required for systemd)
        # https://github.com/raspberrypi/firmware/issues/651
        OABI_COMPAT n

        # Fail to build
        DRM n
        SCSI_ADVANSYS n
        USB_ISP1362_HCD n
        SND_SOC n
        SND_ALI5451 n
        FB_SAVAGE n
        SCSI_NSP32 n
        ATA_SFF n
        SUNGEM n
        IRDA n
        ATM_HE n
        SCSI_ACARD n
        BLK_DEV_CMD640_ENHANCED n

        FUSE_FS m

        # systemd uses cgroups
        CGROUPS y

        # Latencytop
        LATENCYTOP y

        # Ubi for the mtd
        MTD_UBI y
        UBIFS_FS y
        UBIFS_FS_XATTR y
        UBIFS_FS_ADVANCED_COMPR y
        UBIFS_FS_LZO y
        UBIFS_FS_ZLIB y
        UBIFS_FS_DEBUG n

        # Kdb, for kernel troubles
        KGDB y
        KGDB_SERIAL_CONSOLE y
        KGDB_KDB y
      '';
      makeFlags = [ "LOADADDR=0x0200000" ];
      target = "uImage";
      DTB = true; # Beyond 3.10
    };
    gcc = {
      arch = "armv5te";
    };
  };

  raspberrypi = {
    linux-kernel = {
      name = "raspberrypi";

      baseConfig = "bcm2835_defconfig";
      DTB = true;
      autoModules = true;
      preferBuiltin = true;
      extraConfig = ''
        # Disable OABI to have seccomp_filter (required for systemd)
        # https://github.com/raspberrypi/firmware/issues/651
        OABI_COMPAT n
      '';
      target = "zImage";
    };
    gcc = {
      arch = "armv6";
      fpu = "vfp";
    };
  };

  # Legacy attribute, for compatibility with existing configs only.
  raspberrypi2 = armv7l-hf-multiplatform;

  zero-gravitas = {
    linux-kernel = {
      name = "zero-gravitas";

      baseConfig = "zero-gravitas_defconfig";
      # Target verified by checking /boot on reMarkable 1 device
      target = "zImage";
      autoModules = false;
      DTB = true;
    };
    gcc = {
      fpu = "neon";
      cpu = "cortex-a9";
    };
  };

  zero-sugar = {
    linux-kernel = {
      name = "zero-sugar";

      baseConfig = "zero-sugar_defconfig";
      DTB = true;
      autoModules = false;
      preferBuiltin = true;
      target = "zImage";
    };
    gcc = {
      cpu = "cortex-a7";
      fpu = "neon-vfpv4";
      float-abi = "hard";
    };
  };

  scaleway-c1 = lib.recursiveUpdate armv7l-hf-multiplatform {
    gcc = {
      cpu = "cortex-a9";
      fpu = "vfpv3";
    };
  };

  utilite = {
    linux-kernel = {
      name = "utilite";
      maseConfig = "multi_v7_defconfig";
      autoModules = false;
      extraConfig = ''
        # Ubi for the mtd
        MTD_UBI y
        UBIFS_FS y
        UBIFS_FS_XATTR y
        UBIFS_FS_ADVANCED_COMPR y
        UBIFS_FS_LZO y
        UBIFS_FS_ZLIB y
        UBIFS_FS_DEBUG n
      '';
      makeFlags = [ "LOADADDR=0x10800000" ];
      target = "uImage";
      DTB = true;
    };
    gcc = {
      cpu = "cortex-a9";
      fpu = "neon";
    };
  };

  guruplug = lib.recursiveUpdate sheevaplug {
    # Define `CONFIG_MACH_GURUPLUG' (see
    # <http://kerneltrap.org/mailarchive/git-commits-head/2010/5/19/33618>)
    # and other GuruPlug-specific things.  Requires the `guruplug-defconfig'
    # patch.
    linux-kernel.baseConfig = "guruplug_defconfig";
  };

  beaglebone = lib.recursiveUpdate armv7l-hf-multiplatform {
    linux-kernel = {
      name = "beaglebone";
      baseConfig = "bb.org_defconfig";
      autoModules = false;
      extraConfig = ""; # TBD kernel config
      target = "zImage";
    };
  };

  # https://developer.android.com/ndk/guides/abis#v7a
  armv7a-android = {
    linux-kernel.name = "armeabi-v7a";
    gcc = {
      arch = "armv7-a";
      float-abi = "softfp";
      fpu = "vfpv3-d16";
    };
  };

  armv7l-hf-multiplatform = {
    linux-kernel = {
      name = "armv7l-hf-multiplatform";
      Major = "2.6"; # Using "2.6" enables 2.6 kernel syscalls in glibc.
      baseConfig = "multi_v7_defconfig";
      DTB = true;
      autoModules = true;
      preferBuiltin = true;
      target = "zImage";
      extraConfig = ''
        # Serial port for Raspberry Pi 3. Wasn't included in ARMv7 defconfig
        # until 4.17.
        SERIAL_8250_BCM2835AUX y
        SERIAL_8250_EXTENDED y
        SERIAL_8250_SHARE_IRQ y

        # Hangs ODROID-XU4
        ARM_BIG_LITTLE_CPUIDLE n

        # Disable OABI to have seccomp_filter (required for systemd)
        # https://github.com/raspberrypi/firmware/issues/651
        OABI_COMPAT n
      '';
    };
    gcc = {
      # Some table about fpu flags:
      # http://community.arm.com/servlet/JiveServlet/showImage/38-1981-3827/blogentry-103749-004812900+1365712953_thumb.png
      # Cortex-A5: -mfpu=neon-fp16
      # Cortex-A7 (rpi2): -mfpu=neon-vfpv4
      # Cortex-A8 (beaglebone): -mfpu=neon
      # Cortex-A9: -mfpu=neon-fp16
      # Cortex-A15: -mfpu=neon-vfpv4

      # More about FPU:
      # https://wiki.debian.org/ArmHardFloatPort/VfpComparison

      # vfpv3-d16 is what Debian uses and seems to be the best compromise: NEON is not supported in e.g. Scaleway or Tegra 2,
      # and the above page suggests NEON is only an improvement with hand-written assembly.
      arch = "armv7-a";
      fpu = "vfpv3-d16";

      # For Raspberry Pi the 2 the best would be:
      #   cpu = "cortex-a7";
      #   fpu = "neon-vfpv4";
    };
  };

  aarch64-multiplatform = {
    linux-kernel = {
      name = "aarch64-multiplatform";
      baseConfig = "defconfig";
      DTB = true;
      autoModules = true;
      preferBuiltin = true;
      extraConfig = ''
        # Raspberry Pi 3 stuff. Not needed for   s >= 4.10.
        ARCH_BCM2835 y
        BCM2835_MBOX y
        BCM2835_WDT y
        RASPBERRYPI_FIRMWARE y
        RASPBERRYPI_POWER y
        SERIAL_8250_BCM2835AUX y
        SERIAL_8250_EXTENDED y
        SERIAL_8250_SHARE_IRQ y

        # Cavium ThunderX stuff.
        PCI_HOST_THUNDER_ECAM y

        # Nvidia Tegra stuff.
        PCI_TEGRA y

        # The default (=y) forces us to have the XHCI firmware available in initrd,
        # which our initrd builder can't currently do easily.
        USB_XHCI_TEGRA m
      '';
      target = "Image";
    };
    gcc = {
      arch = "armv8-a";
    };
  };

  ##
  ## MIPS
  ##

  ben_nanonote = {
    linux-kernel = {
      name = "ben_nanonote";
    };
    gcc = {
      arch = "mips32";
      float = "soft";
    };
  };

  unifi-appro = {
    linux-kernel = {
      name = "unifi-appro";
      autoModules = false;
      baseConfig = "defconfig";
      target = "uImage";
      extraConfig = ''
        CONFIG_AG71XX=y
        # CONFIG_AG71XX_DEBUG is not set
        CONFIG_AG71XX_DEBUG_FS=y
        CONFIG_AR8216_PHY=y
        CONFIG_AR8216_PHY_LEDS=y
        CONFIG_ARCH_32BIT_OFF_T=y
        CONFIG_ARCH_HIBERNATION_POSSIBLE=y
        CONFIG_ARCH_MMAP_RND_BITS_MAX=15
        CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MAX=15
        CONFIG_ARCH_SUSPEND_POSSIBLE=y
        CONFIG_ATH79=y
        CONFIG_ATH79_WDT=y
        CONFIG_BLK_MQ_PCI=y
        CONFIG_CEVT_R4K=y
        CONFIG_CLKDEV_LOOKUP=y
        CONFIG_CLONE_BACKWARDS=y
        CONFIG_CMDLINE="rootfstype=squashfs,jffs2"
        CONFIG_CMDLINE_BOOL=y
        # CONFIG_CMDLINE_OVERRIDE is not set
        CONFIG_COMMON_CLK=y
        # CONFIG_COMMON_CLK_BOSTON is not set
        CONFIG_COMPAT_32BIT_TIME=y
        CONFIG_CPU_BIG_ENDIAN=y
        CONFIG_CPU_GENERIC_DUMP_TLB=y
        CONFIG_CPU_HAS_DIEI=y
        CONFIG_CPU_HAS_PREFETCH=y
        CONFIG_CPU_HAS_RIXI=y
        CONFIG_CPU_HAS_SYNC=y
        CONFIG_CPU_MIPS32=y
        CONFIG_CPU_MIPS32_R2=y
        CONFIG_CPU_MIPSR2=y
        CONFIG_CPU_NEEDS_NO_SMARTMIPS_OR_MICROMIPS=y
        CONFIG_CPU_R4K_CACHE_TLB=y
        CONFIG_CPU_SUPPORTS_32BIT_KERNEL=y
        CONFIG_CPU_SUPPORTS_HIGHMEM=y
        CONFIG_CPU_SUPPORTS_MSA=y
        # CONFIG_CRYPTO_CHACHA_MIPS is not set
        CONFIG_CRYPTO_LIB_POLY1305_RSIZE=2
        # CONFIG_CRYPTO_POLY1305_MIPS is not set
        CONFIG_CRYPTO_RNG2=y
        CONFIG_CSRC_R4K=y
        CONFIG_DMA_NONCOHERENT=y
        CONFIG_DTC=y
        CONFIG_EARLY_PRINTK=y
        CONFIG_FIXED_PHY=y
        CONFIG_FW_LOADER_PAGED_BUF=y
        CONFIG_GENERIC_ATOMIC64=y
        CONFIG_GENERIC_CLOCKEVENTS=y
        CONFIG_GENERIC_CMOS_UPDATE=y
        CONFIG_GENERIC_CPU_AUTOPROBE=y
        CONFIG_GENERIC_GETTIMEOFDAY=y
        CONFIG_GENERIC_IOMAP=y
        CONFIG_GENERIC_IRQ_CHIP=y
        CONFIG_GENERIC_IRQ_EFFECTIVE_AFF_MASK=y
        CONFIG_GENERIC_IRQ_SHOW=y
        CONFIG_GENERIC_LIB_ASHLDI3=y
        CONFIG_GENERIC_LIB_ASHRDI3=y
        CONFIG_GENERIC_LIB_CMPDI2=y
        CONFIG_GENERIC_LIB_LSHRDI3=y
        CONFIG_GENERIC_LIB_UCMPDI2=y
        CONFIG_GENERIC_PCI_IOMAP=y
        CONFIG_GENERIC_PHY=y
        CONFIG_GENERIC_PINCONF=y
        CONFIG_GENERIC_PINCTRL_GROUPS=y
        CONFIG_GENERIC_PINMUX_FUNCTIONS=y
        CONFIG_GENERIC_SCHED_CLOCK=y
        CONFIG_GENERIC_SMP_IDLE_THREAD=y
        CONFIG_GENERIC_TIME_VSYSCALL=y
        CONFIG_GPIOLIB=y
        CONFIG_GPIOLIB_IRQCHIP=y
        CONFIG_GPIO_74X164=y
        CONFIG_GPIO_ATH79=y
        CONFIG_GPIO_GENERIC=y
        CONFIG_HANDLE_DOMAIN_IRQ=y
        CONFIG_HARDWARE_WATCHPOINTS=y
        CONFIG_HAS_DMA=y
        CONFIG_HAS_IOMEM=y
        CONFIG_HAS_IOPORT_MAP=y
        CONFIG_HZ=250
        CONFIG_HZ_250=y
        CONFIG_HZ_PERIODIC=y
        CONFIG_IMAGE_CMDLINE_HACK=y
        CONFIG_INITRAMFS_SOURCE=""
        CONFIG_IRQCHIP=y
        CONFIG_IRQ_DOMAIN=y
        CONFIG_IRQ_FORCED_THREADING=y
        CONFIG_IRQ_MIPS_CPU=y
        CONFIG_IRQ_WORK=y
        # CONFIG_KERNEL_ZSTD is not set
        CONFIG_LEDS_GPIO=y
        # CONFIG_LEDS_RESET is not set
        CONFIG_LIBFDT=y
        CONFIG_LLD_VERSION=0
        CONFIG_LOCK_DEBUGGING_SUPPORT=y
        CONFIG_MDIO_BITBANG=y
        CONFIG_MDIO_BUS=y
        CONFIG_MDIO_DEVICE=y
        CONFIG_MDIO_GPIO=y
        CONFIG_MEMFD_CREATE=y
        CONFIG_MFD_SYSCON=y
        CONFIG_MIGRATION=y
        CONFIG_MIPS=y
        CONFIG_MIPS_ASID_BITS=8
        CONFIG_MIPS_ASID_SHIFT=0
        CONFIG_MIPS_CBPF_JIT=y
        CONFIG_MIPS_CLOCK_VSYSCALL=y
        # CONFIG_MIPS_CMDLINE_BUILTIN_EXTEND is not set
        # CONFIG_MIPS_CMDLINE_DTB_EXTEND is not set
        # CONFIG_MIPS_CMDLINE_FROM_BOOTLOADER is not set
        CONFIG_MIPS_CMDLINE_FROM_DTB=y
        # CONFIG_MIPS_ELF_APPENDED_DTB is not set
        # CONFIG_MIPS_GENERIC_KERNEL is not set
        CONFIG_MIPS_L1_CACHE_SHIFT=5
        CONFIG_MIPS_LD_CAN_LINK_VDSO=y
        # CONFIG_MIPS_NO_APPENDED_DTB is not set
        CONFIG_MIPS_RAW_APPENDED_DTB=y
        CONFIG_MIPS_SPRAM=y
        CONFIG_MODULES_USE_ELF_REL=y
        CONFIG_MTD_CFI_ADV_OPTIONS=y
        CONFIG_MTD_CFI_GEOMETRY=y
        # CONFIG_MTD_CFI_I2 is not set
        # CONFIG_MTD_CFI_INTELEXT is not set
        CONFIG_MTD_CMDLINE_PARTS=y
        # CONFIG_MTD_MAP_BANK_WIDTH_1 is not set
        # CONFIG_MTD_MAP_BANK_WIDTH_4 is not set
        CONFIG_MTD_PARSER_CYBERTAN=y
        CONFIG_MTD_PHYSMAP=y
        CONFIG_MTD_SPI_NOR=y
        CONFIG_MTD_SPLIT_ELF_FW=y
        CONFIG_MTD_SPLIT_LZMA_FW=y
        CONFIG_MTD_SPLIT_SEAMA_FW=y
        CONFIG_MTD_SPLIT_TPLINK_FW=y
        CONFIG_MTD_SPLIT_UIMAGE_FW=y
        CONFIG_MTD_SPLIT_WRGG_FW=y
        CONFIG_MTD_VIRT_CONCAT=y
        CONFIG_NEED_DMA_MAP_STATE=y
        CONFIG_NEED_PER_CPU_KM=y
        CONFIG_NO_GENERIC_PCI_IOPORT_MAP=y
        CONFIG_NVMEM=y
        CONFIG_OF=y
        CONFIG_OF_ADDRESS=y
        CONFIG_OF_EARLY_FLATTREE=y
        CONFIG_OF_FLATTREE=y
        CONFIG_OF_GPIO=y
        CONFIG_OF_IRQ=y
        CONFIG_OF_KOBJ=y
        CONFIG_OF_MDIO=y
        CONFIG_OF_NET=y
        CONFIG_PCI=y
        CONFIG_PCI_AR71XX=y
        CONFIG_PCI_AR724X=y
        CONFIG_PCI_DISABLE_COMMON_QUIRKS=y
        CONFIG_PCI_DOMAINS=y
        CONFIG_PCI_DRIVERS_LEGACY=y
        CONFIG_PERF_USE_VMALLOC=y
        CONFIG_PGTABLE_LEVELS=2
        CONFIG_PHYLIB=y
        # CONFIG_PHY_AR7100_USB is not set
        # CONFIG_PHY_AR7200_USB is not set
        # CONFIG_PHY_ATH79_USB is not set
        CONFIG_PINCTRL=y
        CONFIG_RATIONAL=y
        CONFIG_REGMAP=y
        CONFIG_REGMAP_MMIO=y
        CONFIG_RESET_ATH79=y
        CONFIG_RESET_CONTROLLER=y
        CONFIG_SERIAL_8250_NR_UARTS=1
        CONFIG_SERIAL_8250_RUNTIME_UARTS=1
        CONFIG_SERIAL_AR933X=y
        CONFIG_SERIAL_AR933X_CONSOLE=y
        CONFIG_SERIAL_AR933X_NR_UARTS=2
        CONFIG_SERIAL_MCTRL_GPIO=y
        CONFIG_SERIAL_OF_PLATFORM=y
        CONFIG_SPI=y
        CONFIG_SPI_AR934X=y
        CONFIG_SPI_ATH79=y
        CONFIG_SPI_BITBANG=y
        CONFIG_SPI_GPIO=y
        CONFIG_SPI_MASTER=y
        CONFIG_SPI_MEM=y
        # CONFIG_SPI_RB4XX is not set
        CONFIG_SRCU=y
        CONFIG_SWCONFIG=y
        CONFIG_SWCONFIG_LEDS=y
        CONFIG_SWPHY=y
        CONFIG_SYSCTL_EXCEPTION_TRACE=y
        CONFIG_SYS_HAS_CPU_MIPS32_R2=y
        CONFIG_SYS_HAS_EARLY_PRINTK=y
        CONFIG_SYS_SUPPORTS_32BIT_KERNEL=y
        CONFIG_SYS_SUPPORTS_ARBIT_HZ=y
        CONFIG_SYS_SUPPORTS_BIG_ENDIAN=y
        CONFIG_SYS_SUPPORTS_MIPS16=y
        CONFIG_SYS_SUPPORTS_ZBOOT=y
        CONFIG_SYS_SUPPORTS_ZBOOT_UART_PROM=y
        CONFIG_TARGET_ISA_REV=2
        CONFIG_TICK_CPU_ACCOUNTING=y
        CONFIG_TINY_SRCU=y
        CONFIG_USB_SUPPORT=y
        CONFIG_USE_OF=y
      '';
    };

    gcc = {
      arch = "mips32r2";
      float = "soft";
    };
  };

  fuloong2f_n32 = {
    linux-kernel = {
      name = "fuloong2f_n32";
      baseConfig = "lemote2f_defconfig";
      autoModules = false;
      extraConfig = ''
        MIGRATION n
        COMPACTION n

        # nixos mounts some cgroup
        CGROUPS y

        BLK_DEV_RAM y
        BLK_DEV_INITRD y
        BLK_DEV_CRYPTOLOOP m
        BLK_DEV_DM m
        DM_CRYPT m
        MD y
        REISERFS_FS m
        EXT4_FS m
        USB_STORAGE_CYPRESS_ATACB m

        IP_PNP y
        IP_PNP_DHCP y
        IP_PNP_BOOTP y
        NFS_FS y
        ROOT_NFS y
        TUN m
        NFS_V4 y
        NFS_V4_1 y
        NFS_FSCACHE y
        NFSD m
        NFSD_V2_ACL y
        NFSD_V3 y
        NFSD_V3_ACL y
        NFSD_V4 y

        # Fail to build
        DRM n
        SCSI_ADVANSYS n
        USB_ISP1362_HCD n
        SND_SOC n
        SND_ALI5451 n
        FB_SAVAGE n
        SCSI_NSP32 n
        ATA_SFF n
        SUNGEM n
        IRDA n
        ATM_HE n
        SCSI_ACARD n
        BLK_DEV_CMD640_ENHANCED n

        FUSE_FS m

        # Needed for udev >= 150
        SYSFS_DEPRECATED_V2 n

        VGA_CONSOLE n
        VT_HW_CONSOLE_BINDING y
        SERIAL_8250_CONSOLE y
        FRAMEBUFFER_CONSOLE y
        EXT2_FS y
        EXT3_FS y
        REISERFS_FS y
        MAGIC_SYSRQ y

        # The kernel doesn't boot at all, with FTRACE
        FTRACE n
      '';
      target = "vmlinux";
    };
    gcc = {
      arch = "loongson2f";
      float = "hard";
      abi = "n32";
    };
  };

  ##
  ## Other
  ##

  riscv-multiplatform = {
    linux-kernel = {
      name = "riscv-multiplatform";
      target = "vmlinux";
      autoModules = true;
      baseConfig = "defconfig";
      extraConfig = ''
        FTRACE n
        SERIAL_OF_PLATFORM y
      '';
    };
  };

  select = platform:
    # x86
    /**/ if platform.isx86 then pc

    # ARM
    else if platform.isAarch32 then let
      version = platform.parsed.cpu.version or null;
      in     if version == null then pc
        else if lib.versionOlder version "6" then sheevaplug
        else if lib.versionOlder version "7" then raspberrypi
        else armv7l-hf-multiplatform
    else if platform.isAarch64 then aarch64-multiplatform

    else if platform.isRiscV then riscv-multiplatform

    else if platform.parsed.cpu == lib.systems.parse.cpuTypes.mipsel then fuloong2f_n32

    else if platform.parsed.cpu == lib.systems.parse.cpuTypes.powerpc64le then powernv

    else pc;
}
