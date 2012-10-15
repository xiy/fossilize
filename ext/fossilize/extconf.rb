require 'mkmf'

dir_config 'fossilize'
RbConfig::MAKEFILE_CONFIG['CC'] = 'gcc'
RbConfig::MAKEFILE_CONFIG['CXX'] = 'g++'

create_makefile 'fossilize/fossilize'
