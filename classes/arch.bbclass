# -*- mode:python; -*-

addhook arch_update to post_recipe_parse first before base_after_parse

def arch_update(d):
    import oelite.arch
    oelite.arch.update(d)

HOST_EXEEXT ??= ""
TARGET_EXEEXT ??= ""
HOST_EXEEXT[expand] = 3
TARGET_EXEEXT[expand] = 3
