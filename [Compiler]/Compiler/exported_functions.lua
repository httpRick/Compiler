function replaceCompileFile(filePath, key, fileNewPath, maxBytes)
    if sourceResource and type(filePath) == "string" and string.sub(filePath, 1, 1) ~= ":" then
       filePath =  string.format(":%s/%s", getResourceName(sourceResource), filePath )
    end    
    local compile = fileCompile(filePath, key, maxBytes)
    if compile then
        if type(fileNewPath) == "string" then
            if sourceResource and type(fileNewPath) == "string" and string.sub(fileNewPath, 1, 1) ~= ":" then
               fileNewPath =  string.format(":%s/%s", getResourceName(sourceResource), fileNewPath )
            end            
            local fileHandler = fileCreate(fileNewPath)
            fileWrite(fileHandler, compile)
            fileClose(fileHandler)
            return true
        else
            fileDelete(filePath)
            local fileHandler = fileCreate(filePath)
            fileWrite(fileHandler, compile)
            fileClose(fileHandler)
            return true      
        end
    else
        return false
    end
end

function replaceDecompileFile(filePath, key, fileNewPath)
    if sourceResource and type(filePath) == "string" and string.sub(filePath, 1, 1) ~= ":" then
       filePath =  string.format(":%s/%s", getResourceName(sourceResource), filePath )
    end
    local decompile = fileDecompile(filePath, key)
    if decompile then
        if type(fileNewPath) == "string" then
            if sourceResource and type(fileNewPath) == "string" and string.sub(fileNewPath, 1, 1) ~= ":" then
               fileNewPath =  string.format(":%s/%s", getResourceName(sourceResource), fileNewPath )
            end
            local fileHandler = fileCreate(fileNewPath)
            fileWrite(fileHandler, decompile)
            fileClose(fileHandler)
            return true
        else
            fileDelete(filePath)
            local fileHandler = fileCreate(filePath)
            fileWrite(fileHandler, decompile)
            fileClose(fileHandler)
            return true      
        end
    else
        return false
    end
end