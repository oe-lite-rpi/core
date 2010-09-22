# Class to handle all the arhicture related variables.

# To be able to reuse definitions for both build, machine and sdk
# architectures, the usual bitbake variables are not used, but a more
# hierarchical setup using a number of Python dictionaries.


def arch_init():
    g = globals()

    g['gccspecs'] = {}

    g['archspecs'] = {
        'powerpc'	: {
            'wordsize'		: '32',
            'endian'		: 'b',
            'elf'		: 'PowerPC or cisco 4500',
            },
        'powerpc64'	: {
            'wordsize'		: '64',
            'endian'		: 'b',
            },
        'arm'		: {
            'wordsize'		: '32',
            'endian'		: 'l',
	    'elf'		: 'ELF 32-bit LSB shared object, ARM, version 1 (SYSV)',
            },
        'armeb'		: {
            'wordsize'		: '32',
            'endian'		: 'b',
            },
        'avr32'		: {
            'wordsize'		: '32',
            'endian'		: 'b',
            },
        'mips'		: {
            'wordsize'		: '32',
            'endian'		: 'b',
            },
        'mipsel'	: {
            'wordsize'		: '32',
            'endian'		: 'l',
            },
        'sparc'		: {
            'wordsize'		: '32',
            'endian'		: 'b',
            },
        'bfin'		: {
            'wordsize'		: '32',
            'endian'		: 'l',
            },
        'sh3'		: {
            'wordsize'		: '32',
            'endian'		: 'l',
            },
        'sh4'		: {
            'wordsize'		: '32',
            'endian'		: 'l',
            },
        'i386'		: {
            'wordsize'		: '32',
            'endian'		: 'l',
            'elf'		: 'Intel 80386',
            'fpu'		: '1',
            },
        'i486'		: {
            'wordsize'		: '32',
            'endian'		: 'l',
            'fpu'		: '1',
            },
        'i586'		: {
            'wordsize'		: '32',
            'endian'		: 'l',
            'fpu'		: '1',
            },
        'i686'		: {
            'wordsize'		: '32',
            'endian'		: 'l',
            'fpu'		: '1',
            },
        'i786'		: {
            'wordsize'		: '32',
            'endian'		: 'l',
            'march'		: 'pentium4',
            'mtune'		: 'pentium4',
            'fpu'		: '1',
            },
        'x86_64'	: {
            'wordsize'		: '64',
            'endian'		: 'l',
            'march'		: 'x86_64',
            'mtune'		: 'x86_64',
            'fpu'		: '1',
            'elf'		: 'x86-64',
            },
        'ia64'		: {
            'wordsize'		: '64',
            'endian'		: 'l',
            },
        }

    g['corespecs'] = {
        'powerpc' : {
            'e300c1'		: {
                'mcpu'		: 'e300c1',
                'fpu'		: '1',
                },
            'e300c2'	: {
                'mcpu'		: 'e300c2',
                },
            'e300c3'	: {
                'mcpu'		: 'e300c3',
                'fpu'		: '1',
                },
            'e300c4'	: {
                'mcpu'		: 'e300c4',
                'fpu'		: '1',
                },
            },
        'arm' : {
            '920t'	: {
                'mcpu'		: 'arm920t',
                'mtune'		: 'arm920t',
                },
            '926ejs'	: {
                'march'		: 'armv5te',
                'mcpu'		: 'arm926ej-s',
                'mtune'		: 'arm926ej-s',
                },
            },
        }

    g['socmap'] = {
        'powerpc'	: {
            'mpc8313'		: 'e300c3',
            'mpc8313e'		: 'e300c3',
            'mpc8360'		: 'e300c1',
            'mpc8270'		: 'g2le',
            },
        'arm'	: {
            'at91rm9200'	: '920t',
            'at91sam9260'	: '926ejs',
            },
        }

    g['osspecs'] = {
        'mingw32'	: {
            'exeext'		: '.exe',
            },
        }

python () {
    arch_init()
    arch_after_parse(d)
}


def arch_after_parse(d):
    import bb, os
    gcc_version = bb.data.getVar('GCC_VERSION', d, True)
    arch_set_build_arch(d, gcc_version)
    arch_set_cross_arch(d, 'MACHINE', gcc_version)
    arch_set_cross_arch(d, 'SDK', gcc_version)
    arch_update(d, 'BUILD', gcc_version)
    arch_update(d, 'HOST', gcc_version)
    arch_update(d, 'TARGET', gcc_version)


def arch_set_build_arch(d, gcc_version):
    script = arch_find_script(d, 'config.guess')
    try:
        guess = arch_split(os.popen(script).readline().strip())
    except OSError, e:
        bb.fatal('config.guess failed: '+e)
        return None
    # Replace the silly 'pc' vendor with 'unknown' to yield a result
    # comparable with arch_cross().
    if guess[1] == 'pc':
        guess[1] = 'unknown'
    bb.data.setVar('BUILD_ARCH', '-'.join(guess), d)
    return


def arch_set_cross_arch(d, prefix, gcc_version):
    cross_arch = '%s-%s'%(bb.data.getVar(prefix+'_CPU', d, True),
                          bb.data.getVar(prefix+'_OS', d, True))
    cross_arch = arch_config_sub(d, cross_arch)
    cross_arch = arch_fixup(cross_arch, gcc_version)
    bb.data.setVar(prefix+'_ARCH', cross_arch, d)
    return


def arch_update(d, prefix, gcc_version):
    arch = bb.data.getVar(prefix+'_ARCH', d, True)
    gccspec = arch_gccspec(arch, gcc_version)
    (cpu, vendor, os) = arch_split(arch)
    bb.data.setVar(prefix+'_CPU', cpu, d)
    bb.data.setVar(prefix+'_VENDOR', vendor, d)
    bb.data.setVar(prefix+'_OS', os, d)
    ost = os.split('-',1)
    if len(ost) > 1:
        bb.data.setVar(prefix+'_BASEOS', ost[0], d)
    for spec in gccspec:
        bb.data.setVar(prefix+'_'+spec.upper(), gccspec[spec], d)
    return


def arch_fixup(arch, gcc):
    global socmap, corespecs

    gccv=map(int,gcc.split('.'))
    (cpu, vendor, os) = arch_split(arch)

    if cpu in socmap and vendor in socmap[cpu]:
        core = socmap[cpu][vendor]
    elif cpu in corespecs and vendor in corespecs[cpu].keys():
        core = vendor
    else:
        core = 'unknown'

    # Currently, OE-lite does only support EABI for ARM
    # When/if OABI is added, os should be kept as linux-gnu for OABI
    if cpu == 'arm' and os == 'linux-gnu':
        os = 'linux-gnueabi'
    
    return '-'.join((cpu, core, os))


def arch_gccspec(arch, gcc):
    global gccspecs, socmap, archspecs, corespecs, osspecs

    if gcc in gccspecs:
        if arch in gccspecs[gcc]:
            return gccspecs[gcc][arch]
    else:
        gccspecs[gcc] = {}

    gccv=map(int,gcc.split('.'))
    (cpu, vendor, os) = arch_split(arch)

    gccspec = {}
    if cpu in archspecs:
        gccspec.update(archspecs[cpu])
    if cpu in corespecs and vendor in corespecs[cpu]:
        gccspec.update(corespecs[cpu][vendor])
    if os in osspecs:
        gccspec.update(osspecs[os])

    try:
    
        if gccspec['mcpu'] in ('e300c1', 'e300c4'):
            gccspec['mcpu'] = '603e'
        if gccspec['mtune'] in ('e300c1', 'e300c4'):
            gccspec['mtune'] = '603e'
    
        if gccspec['mcpu'] in ('e300c2', 'e300c3'):
            if gccv[0] < 4 or (gccv[0] == 4 and gccv[1] < 4):
                gccspec['mcpu'] = '603e'
        if gccspec['mtune'] in ('e300c2', 'e300c3'):
            if gccv[0] < 4 or (gccv[0] == 4 and gccv[1] < 4):
                gccspec['mtune'] = '603e'
    
    except KeyError, e:
        bb.msg.debug(1, None, 'KeyError in arch_gccspec: ')
    
    gccspecs[gcc][arch] = gccspec
    return gccspec


def arch_config_sub(d, arch):
    script = arch_find_script(d, 'config.sub')

    try:
        canonical_arch = os.popen("%s %s"%(script, arch)).readline().strip()
    except OSError, e:
        bb.error('config.sub(%s) failed: %s'%(arch, e))
        return arch

    return canonical_arch


def arch_split(arch):
    archtuple = arch.split('-', 2)
    if len(archtuple) == 3:
        return archtuple
    else:
        bb.error('invalid arch string: '+arch)
        return None


def arch_find_script(d, filename):
    try:
        scripts = globals()['arch_scripts']
    except KeyError:
        scripts = {}
        globals()['arch_scripts'] = scripts
    if not filename in scripts:
        for bbpath in bb.data.getVar('BBPATH', d, 1).split(':'):
            filepath = os.path.join(bbpath, 'scripts', filename)
            if os.path.isfile(filepath):
                bb.debug('found %s: %s'%(filename, filepath))
                scripts[filename] = filepath
                break
        if not filename in scripts:
            bb.error('could not find script: %s'%filename)
    return scripts[filename]