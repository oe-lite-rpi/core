# Support checking image sizes, which fx. can be useful when installing to
# partitions with a fixed length

SIZECHECK ?= ""

addtask sizecheck before do_install after do_compile
python do_sizecheck () {
    failed = False
    print "SIZECHECK =", d.getVar("SIZECHECK", 1)
    for sizecheck_str in (d.getVar("SIZECHECK", 1) or "").split():
        sizecheck = sizecheck_str.split(":")
        if len(sizecheck) != 2:
            print "Invalid sizecheck:", sizecheck_str
            continue
        size = os.path.getsize(sizecheck[0])
        print "sizecheck %s = %d (%s)"%(sizecheck[0], size, sizecheck[1])
        if size > int(sizecheck[1]):
            print "Image sizecheck failed for: %s: %d > %s"%(
                sizecheck[0], size, sizecheck[1])
            failed = True

    if failed:
        raise Exception("Sizecheck failed")
}