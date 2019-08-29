-- read ico files.

print("hello world")
local fname = arg[1]
print(fname)
local f = io.open(fname, "rb")
if not f then
    print("ico file not found. ", fname)
    return
end

local outfname = arg[2]
local outf = io.open(outfname, "w")

local content = f:read("a")
f:close()

outf:write("local icon_bytes_table = {")
local len = #content
for i=1,len do
    if (i-1) % 12 == 0 then
        outf:write("\n    ")
    end
    outf:write(string.format("0x%02x, ", content:byte(i)))
end
outf:write("}\nreturn string.char(table.unpack(icon_bytes_table))")

outf:close()

