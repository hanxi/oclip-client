if not arg[1] then
    return false
end

local function getopt(arg, options)
  local tab = {}
  for k, v in ipairs(arg) do
    if string.sub( v, 1, 2) == "--" then
      local x = string.find( v, "=", 1, true )
      if x then tab[ string.sub( v, 3, x-1 ) ] = string.sub( v, x+1 )
      else      tab[ string.sub( v, 3 ) ] = true
      end
    elseif string.sub( v, 1, 1 ) == "-" then
      local y = 2
      local l = string.len(v)
      local jopt
      while ( y <= l ) do
        jopt = string.sub( v, y, y )
        if string.find( options, jopt, 1, true ) then
          if y < l then
            tab[ jopt ] = string.sub( v, y+1 )
            y = l
          else
            tab[ jopt ] = arg[ k + 1 ] or true
          end
        else
          tab[ jopt ] = true
        end
        y = y + 1
      end
    end
  end
  return tab
end

local pid_file = '/tmp/oclip.pid'
local function start_master()
    local exe = string.format("%s %s %s", arg[-2] or '', arg[-1] or '', arg[0])
    -- fuck the nohup...
    cmd = string.format("nohup %s >/dev/null 2>&1 & echo $! > %s | ps > /dev/null", exe, pid_file)
    --print(cmd)
    os.execute(cmd)
end
local function get_master_pid()
    local f = io.open(pid_file, 'r')
    local pid
    if f then
        pid = f:read("l")
        f:close()
        local cmd = string.format("kill -USR2 %s >/dev/null 2>&1", pid)
        if os.execute(cmd) then
            return pid
        end
    end
end
local function check_master()
    local pid = get_master_pid()
    if not pid then
        start_master()
        pid = get_master_pid()
        local retry_cnt = 0
        while not pip and retry_cnt < 100 do
            pid = get_master_pid()
            retry_cnt = retry_cnt + 1
        end
    end
    if not pid then
        print("start master failed.")
        os.exit(1)
    end
    return pid
end

local clipboard = require "oclip.clipboard_helper"
local master_pid = check_master()
local opts = getopt(arg, "ioh")
if opts.i then
    local f = io.stdin
    if type(opts.i) == "string" then
        f = io.open(opts.i, 'rb')
    end
    local text = f:read("a")
    if type(opts.i) == "string" then
        f:close()
    end
    clipboard.settext(text)
    local cmd = string.format("kill -USR1 %s >/dev/null 2>&1", master_pid)
    os.execute(cmd)
elseif opts.o then
    local text = clipboard.gettext()
    io.write(text)
else
    io.write([[
                 _   _         
                | | (_)        
   ___     ___  | |  _   _ __  
  / _ \   / __| | | | | | '_ \ 
 | (_) | | (__  | | | | | |_) |
  \___/   \___| |_| |_| | .__/ 
                        | |    
                        |_|   

Usage: oclip [OPTION] [FILE]...
Open clipboard in cloud.

  -i      read text into oclip server from standard input or files (default)
  -o      prints the oclip server to standard out (generally for piping
          to a file or program)
  -h      usage information

Report bugs to <hanxi.info@gamil.com>
]])
end

return true
