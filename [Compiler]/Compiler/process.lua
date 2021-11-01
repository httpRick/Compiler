local function ignore_set(str, set)
    if set then
        str = str:gsub("[" .. set .. "]", "")
    end
    return str
end

local function pure_from_bit(str)
    return (str:gsub(
        "........",
        function(cc)
            return string.char(tonumber(cc, 2))
        end
    ))
end

local IT = {}
local bitMap = {o = "0", i = "1", l = "1"}

function IT.from_bit(str, ignore)
    str = ignore_set(str, ignore)
    str = string.lower(str)
    str =
        str:gsub(
        "[ilo]",
        function(c)
            return bitMap[c]
        end
    )
    local pos = string.find(str, "[^01]")
    if pos then
        return nil
    end
    return pure_from_bit(str)
end

function IT.to_bit(str)
    return (str:gsub(
        ".",
        function(c)
            local byte = string.byte(c)
            local bits = {}
            for _ = 1, 8 do
                table.insert(bits, byte % 2)
                byte = math.floor(byte / 2)
            end
            return table.concat(bits):reverse()
        end
    ))
end

local function hex2bin(s)
    local dec = tonumber(s,16)
    return tostring(basen(dec,2))
end

local function toCode(str)
    return IT.to_bit(str)
end

local function toDecode(binary)
    return IT.from_bit(binary)
end

local function encodeBinary( data, key )
    return teaEncode( base64Encode( data ), key )
end

local function decodeBinary( data, key )
    return base64Decode( teaDecode( data, key ) )
end

function onDisabledDebugHook(...)
    return "skip"
end
addDebugHook( "preFunction", onDisabledDebugHook, {"addDebugHook"} )
addDebugHook( "postFunction", onDisabledDebugHook, {"addDebugHook"} )

function getFileExtension(url)
  return url:match("^.+(%..+)$")
end

function getFileName(path)
    local path = path:match("[^/]*.$")
    return path:sub(0, #path - 4)
end

function getFilePath(path)
    local name, extenstion = getFileName(path), getFileExtension(path)
    return path:gsub( string.format("[%s, %s]", name, extenstion) ,""), name, extenstion:gsub("[.]","")
end

function fileCompile(filePath, key, maxBytes)
    if sourceResource and type(filePath) == "string" and string.sub(filePath, 1, 1) ~= ":" then
       filePath =  string.format(":%s/%s", getResourceName(sourceResource), filePath )
    end
    if not fileExists(filePath) then 
        outputDebugString("The specified file does not exist", 1) 
        return false
    elseif type(key) ~= "string" and type(key) ~= "number" and type(key) ~= "function" and type(key) ~= "boolean" then 
        outputDebugString("Key for file compilation not provided", 1)
        return false
    end
    if type(key) == "function" then
        key = key()
        if type(key) ~= "string" and type(key) ~= "number" then
            outputDebugString("Key for file compilation not provided", 1)
            return false
        end
    elseif type(key) == "boolean" then
        key = tostring(key)
    end
    local fileHandler = fileOpen(filePath)
    local fileSize = fileGetSize(fileHandler)
    local startPos, endPos = string.find( fileRead(fileHandler, fileSize), "0xSUM")
    if endPos then
        fileClose(fileHandler)
        outputDebugString("The file is already compiled", 1) 
        return false
    else
        fileSetPos(fileHandler, 0)
    end
    local maxBytesToEncode = maxBytes or 1024
    local bytesToEncode = fileSize < maxBytesToEncode and fileSize or maxBytesToEncode
    local dataToEncode = fileRead(fileHandler, bytesToEncode)
    local dataEncrypted = toCode( encodeBinary("0xHeader"..dataToEncode, key) )
    local restData = "0xSUM"
    if fileSize > bytesToEncode then
        restData = restData..fileRead(fileHandler, fileSize-bytesToEncode)
    end
    local contentData = dataEncrypted..restData
    fileClose(fileHandler)
    return contentData
end

function fileDecompile(filePath, key)
    if sourceResource and type(filePath) == "string" and string.sub(filePath, 1, 1) ~= ":" then
       filePath =  string.format(":%s/%s", getResourceName(sourceResource), filePath )
    end
    if not fileExists(filePath) then 
        outputDebugString("The specified file does not exist", 1) 
        return false
    elseif type(key) ~= "string" and type(key) ~= "number" and type(key) ~= "function" and type(key) ~= "boolean" then 
        outputDebugString("Key for file compilation not provided", 1) 
        return false
    end
    if type(key) == "function" then
        key = key()
        if type(key) ~= "string" and type(key) ~= "number" then
            outputDebugString("Key for file compilation not provided", 1)
            return false
        end
    elseif type(key) == "boolean" then
        key = tostring(key) 
    end
    local fileHandler = fileOpen(filePath)
    local fileSize = fileGetSize(fileHandler)
    local fileEncryptedData = fileRead(fileHandler, fileSize)
    local startPos, endPos = string.find(fileEncryptedData, "0xSUM")
    local restData = ""
    if startPos == nil or endPos == nil then
        fileClose(fileHandler)
        outputDebugString("The file is not compiled", 1) 
        return false
    else
        fileSetPos(fileHandler, 0)
    end
    local dataEncrypted = decodeBinary( toDecode( fileEncryptedData:sub(0, startPos-1) ), key)
    local HeaderStartPos, HeaderEndPos = string.find(dataEncrypted, "0xHeader")
    if HeaderStartPos == nil or HeaderEndPos == nil then
        fileClose(fileHandler)
        outputDebugString("Invalid file compilation key", 1)
        return false
    end
    local dataEncrypted = dataEncrypted:sub(HeaderEndPos+1)
    if fileSize > endPos then
        restData = fileEncryptedData:sub(endPos+1, fileSize)
    end
    fileClose(fileHandler)
    local contentData = dataEncrypted..restData
    return contentData
end