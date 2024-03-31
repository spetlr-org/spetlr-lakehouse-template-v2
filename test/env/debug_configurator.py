from dataplatform.environment.init_configurator import init_configurator


def debug_configurator():
    c = init_configurator()
    c.set_debug()
    return c
