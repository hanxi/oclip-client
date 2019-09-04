-- Version of bin/oclip.lua for use in oclip binaries.

-- Do not load modules from filesystem in case a bundled module is broken.
package.path = ""
package.cpath = ""

require "oclip.main"
